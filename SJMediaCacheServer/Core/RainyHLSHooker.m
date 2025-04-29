//
//  RainyHLSHooker.m
//  SJMediaCacheServer
//
//  Created by zywan on 23/4/2025.
//

#import "RainyHLSHooker.h"

@implementation RainyHLSHooker

/// Key used in NSUserDefaults
static NSString *const kRainyLoopCacheUDKey = @"RainyHLSHooker.loopCache";

/// In-memory mutable cache
static NSMutableDictionary<NSString *, NSDictionary *> *loopCache = nil;

#pragma mark - Private helpers

/// Ensure loopCache is initialised and synchronised with UserDefaults.
+ (void)initializeLoopCache {
    if (loopCache) { return; }

    NSDictionary *saved = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kRainyLoopCacheUDKey];
    loopCache = saved ? [saved mutableCopy] : [NSMutableDictionary dictionary];
}

/// Normalise URL by removing the last path component.
/// Example:
/// …/chunklist_b1044100.m3u8  ->  …/e19d350d-2637-495a-94a5-064cd23680f5.smil
+ (NSString *)normalizedKeyFromURL:(NSURL *)url {
    if (!url) { return nil; }
    
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    components.query = nil;
    NSURL *urlWithoutQuery = components.URL;
    
    NSURL *baseURL = [urlWithoutQuery URLByDeletingLastPathComponent];
    return baseURL.absoluteString;
}

#pragma mark - Public API

/// Quick check for cache hit / miss (after url normalisation)
+ (BOOL)cacheHitForURL:(NSURL *)url {
    [self initializeLoopCache];
    NSString *key = [self normalizedKeyFromURL:url];
    BOOL hit = (loopCache[key] != nil);
    NSLog(@"RainyHLSHooker cacheHitForURL -- %@ cache for url = %@", hit ? @"HIT" : @"MISS", url);
    return hit;
}

/**
 * Stores the loop parameters for the given URL.
 *
 * @param url            The URL for VOD or loop.
 * @param startLoopTime  The starting loop time in milliseconds.
 * @param loopDuration   The duration of the loop in milliseconds.
 */
+ (void)markLoop:(NSURL *)url startLoopTime:(double)startLoopTime loopDuration:(double)loopDuration {
    if (!url) { return; }
    [self initializeLoopCache];

    NSString *key = [self normalizedKeyFromURL:url];

    // Convert ms to seconds
    NSTimeInterval startTime = startLoopTime / 1000.0;
    NSTimeInterval endTime   = startTime + loopDuration / 1000.0;

    NSDictionary *params = @{ @"startTime" : @(startTime),
                              @"endTime"   : @(endTime) };

    BOOL willUpdate = ![loopCache[key] isEqual:params];
    loopCache[key]  = params;

    // Persist
    [[NSUserDefaults standardUserDefaults] setObject:loopCache
                                              forKey:kRainyLoopCacheUDKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    if (willUpdate) {
        NSLog(@"RainyHLSHooker markLoop -- UPDATE cache key = %@", key);
    }
}

/**
 * Trims HLS playlist using the stored loop parameters for the provided URL.
 * If no loop information is found for the URL, only process the first TS.
 *
 * @param playlist The original HLS playlist string.
 * @param url      The URL used to lookup loop parameters.
 * @return A new playlist string trimmed to the specified time interval.
 */
+ (NSString *)hookPlaylist:(NSString *)playlist forURL:(NSURL *)url {
    [self initializeLoopCache];
    NSString *key = [self normalizedKeyFromURL:url];
    NSDictionary *params = loopCache[key];

    if (!params) {
        NSLog(@"RainyHLSHooker hookPlaylist -- MISS cache key = %@", key);
        // ------- original MISS logic, unchanged except logging -------
        NSMutableString *result = [NSMutableString string];
        NSArray *lines = [playlist componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        NSInteger count = lines.count;
        BOOL extinfFound = NO;

        for (NSInteger i = 0; i < count; i++) {
            NSString *line = lines[i];
            if ([line hasPrefix:@"#EXTINF:"]) {
                extinfFound = YES;
                [result appendFormat:@"%@\n", line];
                if (i + 1 < count) {
                    NSString *tsLine = lines[i + 1];
                    while ([tsLine stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0 && i + 1 < count - 1) {
                        i++;
                        tsLine = lines[i + 1];
                    }
                    [result appendFormat:@"%@\n", tsLine];
                }
                break;
            } else {
                if (![line hasPrefix:@"#EXT-X-ENDLIST"]) {
                    [result appendFormat:@"%@\n", line];
                }
            }
        }
        [result appendString:@"#EXT-X-ENDLIST\n"];
        return result;
    }

    NSLog(@"RainyHLSHooker hookPlaylist -- HIT cache key = %@", key);

    // --------------- original HIT logic ---------------
    NSTimeInterval startTime = [params[@"startTime"] doubleValue];
    NSTimeInterval endTime   = [params[@"endTime"]   doubleValue];

    if (!playlist || ![playlist hasPrefix:@"#EXT"]) return playlist;
    if ([playlist containsString:@"#EXT-X-STREAM-INF"]) return playlist;   // master
    if (![playlist containsString:@"#EXT-X-ENDLIST"])    return playlist;   // live

    NSMutableString *result = [NSMutableString string];
    NSArray *lines = [playlist componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSInteger count = lines.count;

    // copy headers
    for (NSString *line in lines) {
        if ([line hasPrefix:@"#EXTINF:"]) break;
        if ([line hasPrefix:@"#EXT-X-ENDLIST"]) continue;
        [result appendFormat:@"%@\n", line];
    }

    double cumulative = 0.0;
    BOOL segmentAdded = NO;

    for (NSInteger i = 0; i < count; i++) {
        NSString *line = lines[i];
        if (![line hasPrefix:@"#EXTINF:"]) continue;

        NSRange colon = [line rangeOfString:@":"];
        if (colon.location == NSNotFound) continue;

        NSString *durationStr = [[[line substringFromIndex:colon.location + 1]
                                   componentsSeparatedByString:@","].firstObject
                                 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        double segDur = durationStr.doubleValue;
        double newCum = cumulative + segDur;

        if (newCum <= startTime) {   // before window
            cumulative = newCum;
            if (i + 1 < count) i++;  // skip ts
            continue;
        }
        if (newCum > endTime && segmentAdded) break;

        [result appendFormat:@"%@\n", line];
        if (i + 1 < count) {
            NSString *ts = lines[i + 1];
            while ([ts stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0 && i + 1 < count - 1) {
                i++;
                ts = lines[i + 1];
            }
            [result appendFormat:@"%@\n", ts];
            i++;
            segmentAdded = YES;
        }
        cumulative = newCum;
    }

    [result appendString:@"#EXT-X-ENDLIST\n"];
    return result;
}

@end
