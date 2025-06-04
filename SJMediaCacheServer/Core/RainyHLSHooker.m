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

+ (NSDictionary<NSString *, NSNumber *> *)loopParamsForOriginalURL:(NSURL *)originalURL {
    if (!originalURL) { return nil; }
    [self initializeLoopCache];
    return loopCache[[self normalizedKeyFromURL:originalURL]];
}

/// Normalise URL by removing the last path component.
/// Example:
+ (NSString *)normalizedKeyFromURL:(NSURL *)originalURL {
    if (!originalURL) { return nil; }
    
    NSURLComponents *components = [NSURLComponents componentsWithURL:originalURL resolvingAgainstBaseURL:NO];
    components.query = nil;
    NSURL *urlWithoutQuery = components.URL;
    
    NSURL *baseURL = [urlWithoutQuery URLByDeletingLastPathComponent];
    return baseURL.absoluteString;
}

#pragma mark - Public API

/// Quick check for cache hit / miss (after url normalisation)
+ (BOOL)cacheHitForURL:(NSURL *)originalURL {
    [self initializeLoopCache];
    NSString *key = [self normalizedKeyFromURL:originalURL];
    BOOL hit = (loopCache[key] != nil);
    return hit;
}

/**
 * Stores the loop parameters for the given VOD URL.
 *
 * @param originalURL            The URL for VOD or loop.
 * @param startLoopTime  The starting loop time in milliseconds.
 * @param loopDuration   The duration of the loop in milliseconds.
 */
+ (void)markVODLoop:(NSURL *)originalURL startLoopTime:(double)startLoopTime loopDuration :(double)loopDuration {
    if (!originalURL) return;
    [self initializeLoopCache];

    NSString *key = [self normalizedKeyFromURL:originalURL];
    NSDictionary *old = loopCache[key];

    const double eps = 1.0;                     // 1 ms tolerance
    if (old &&
        fabs([old[@"startLoopTime"] doubleValue] - startLoopTime) < eps &&
        fabs([old[@"loopDuration"]  doubleValue] - loopDuration ) < eps) {
        return;                                // identical → skip overwrite
    }

    NSDictionary *params = @{ @"startLoopTime" : @(startLoopTime),
                              @"loopDuration"  : @(loopDuration) };

    loopCache[key] = params;
    [[NSUserDefaults standardUserDefaults] setObject:loopCache
                                              forKey:kRainyLoopCacheUDKey];
}

/**
 * Trims HLS playlist using the stored loop parameters for the provided URL.
 * If no loop information is found for the URL, only process the first TS.
 *
 * @param playlist The original HLS playlist string.
 * @param originalURL      The URL used to lookup loop parameters.
 * @return A new playlist string trimmed to the specified time interval.
 */
+ (NSString *)hookPlaylist:(NSString *)playlist forOriginalURL:(NSURL *)originalURL {
    [self initializeLoopCache];
    NSString *key = [self normalizedKeyFromURL:originalURL];
    NSDictionary *params = loopCache[key];

    if ([originalURL.absoluteString containsString:@"LiveShow"] && ![playlist containsString:@"#EXT-X-ENDLIST"]) {
        return [self hookLiveShowPlaylist:playlist forOriginalURL:originalURL];
    }
    
    if (!params) {
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

    // --------- read original ms values ---------
    double startMs = [params[@"startLoopTime"] doubleValue];
    double durMs   = [params[@"loopDuration"]  doubleValue];
    double startTime = startMs / 1000.0;
    double endTime   = (startMs + durMs) / 1000.0;
    // -------------------------------------------

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
    double firstSegStart  = -1.0;  // real start of first kept segment

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

        if (!segmentAdded) firstSegStart = cumulative;   // record first keep

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
        
        if (newCum > endTime && segmentAdded) break;
    }

    [result appendString:@"#EXT-X-ENDLIST\n"];
    if (firstSegStart >= 0.0) {
        double newStart  = startTime - firstSegStart;   // sec
        double newStartMs = newStart * 1000.0;

        NSMutableDictionary *newParams = [params mutableCopy];
        newParams[@"hook_startTime"] = @(newStartMs);   // ms
        loopCache[key] = newParams;
        [[NSUserDefaults standardUserDefaults] setObject:loopCache
                                                  forKey:kRainyLoopCacheUDKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    return result;
}

+ (NSString *)hookLiveShowPlaylist:(NSString *)playlist forOriginalURL:(NSURL *)originalURL {
    NSMutableString *result = [playlist mutableCopy];
    [result appendString:@"#EXT-X-ENDLIST\n"];
    return result;
}
@end
