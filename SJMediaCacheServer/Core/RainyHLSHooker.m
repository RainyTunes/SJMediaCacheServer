//
//  RainyHLSHooker.m
//  SJMediaCacheServer
//
//  Created by zywan on 23/4/2025.
//

#import "RainyHLSHooker.h"

@implementation RainyHLSHooker

// Static dictionary to cache loop parameters for multiple URLs
static NSMutableDictionary<NSString *, NSDictionary *> *loopCache = nil;

// Helper method to initialize the loop cache if needed
+ (void)initializeLoopCache {
    if (!loopCache) {
        loopCache = [NSMutableDictionary dictionary];
    }
}

/**
 * Stores the loop parameters for the given URL.
 *
 * @param url The URL for VOD or loop.
 * @param startLoopTime The starting loop time in milliseconds.
 * @param loopDuration The duration of the loop in milliseconds.
 */
+ (void)markLoop:(NSURL *)url startLoopTime:(double)startLoopTime loopDuration:(double)loopDuration {
    [self initializeLoopCache];
    // Convert ms to seconds
    NSTimeInterval startTime = startLoopTime / 1000.0;
    NSTimeInterval endTime = startTime + loopDuration / 1000.0;
    NSDictionary *params = @{@"startTime": @(startTime),
                             @"endTime": @(endTime)};
    // Save the loop info using URL's absolute string as the key
    [loopCache setObject:params forKey:url.absoluteString];
}

/**
 * Trims HLS playlist using the stored loop parameters for the provided URL.
 * If no loop information is found for the URL, only process the first TS,
 * processing only the first EXTINF and its corresponding TS file.
 *
 * @param playlist The original HLS playlist string.
 * @param url The URL used to lookup loop parameters.
 * @return A new playlist string trimmed to the specified time interval.
 */
+ (NSString *)hookPlaylist:(NSString *)playlist forURL:(NSURL *)url {
    [self initializeLoopCache];
    NSDictionary *params = [loopCache objectForKey:url.absoluteString];
    
    // If no loop cache exists, only process the first TS.
    if (!params) {
        NSMutableString *result = [NSMutableString string];
        NSArray *lines = [playlist componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        NSInteger count = lines.count;
        BOOL extinfFound = NO;
        
        // Append header lines until the first EXTINF is encountered.
        for (NSInteger i = 0; i < count; i++) {
            NSString *line = lines[i];
            if ([line hasPrefix:@"#EXTINF:"]) {
                extinfFound = YES;
                [result appendFormat:@"%@\n", line];
                // Append the corresponding TS file (skip blank lines).
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
    
    // Cached logic: retrieve the desired time range from cache.
    NSTimeInterval startTime = [params[@"startTime"] doubleValue];
    NSTimeInterval endTime = [params[@"endTime"] doubleValue];
    
    // Validate input and skip playlists that should not be modified.
    if (!playlist || ![playlist hasPrefix:@"#EXT"]) {
        return playlist;
    }
    
    // Skip master playlists.
    if ([playlist containsString:@"#EXT-X-STREAM-INF"]) {
        return playlist;
    }
    
    // Skip live streams (which don't have ENDLIST).
    if (![playlist containsString:@"#EXT-X-ENDLIST"]) {
        return playlist;
    }
    
    NSMutableString *result = [NSMutableString string];
    NSArray *lines = [playlist componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSInteger count = lines.count;
    
    // Append header lines before processing segments.
    for (NSString *line in lines) {
        // Append header lines until we first see an EXTINF segment line.
        if ([line hasPrefix:@"#EXTINF:"]) {
            break;
        }
        // Skip appending ENDLIST here; it will be added at the end.
        if ([line hasPrefix:@"#EXT-X-ENDLIST"]) {
            continue;
        }
        [result appendFormat:@"%@\n", line];
    }
    
    double cumulativeDuration = 0.0;
    BOOL segmentAdded = NO;
    
    // Iterate over the playlist lines.
    for (NSInteger i = 0; i < count; i++) {
        NSString *line = lines[i];
        
        // Skip non-EXTINF lines.
        if (![line hasPrefix:@"#EXTINF:"]) {
            continue;
        }
        
        // Parse the EXTINF duration.
        NSRange colonRange = [line rangeOfString:@":"];
        if (colonRange.location == NSNotFound) {
            continue;
        }
        NSString *durationPart = [line substringFromIndex:colonRange.location + 1];
        NSArray *durationComponents = [durationPart componentsSeparatedByString:@","];
        NSString *durationString = [[durationComponents firstObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        double segmentDuration = [durationString doubleValue];
        
        double newCumulativeDuration = cumulativeDuration + segmentDuration;
        
        // Skip segments that fall completely before the start time.
        if (newCumulativeDuration <= startTime) {
            cumulativeDuration = newCumulativeDuration;
            // Also skip the corresponding TS file.
            if (i + 1 < count) {
                i++; // move past TS file line (if any)
            }
            continue;
        }
        
        // If adding this segment would exceed the end time and at least one segment has already been added,
        // then stop processing further segments.
        if (newCumulativeDuration > endTime && segmentAdded) {
            break;
        }
        
        // Otherwise, include the current EXTINF line.
        [result appendFormat:@"%@\n", line];
        
        // Append the corresponding TS file line (if available). Skip blank lines.
        if (i + 1 < count) {
            NSString *tsLine = lines[i + 1];
            while ([tsLine stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0 && i + 1 < count - 1) {
                i++;
                tsLine = lines[i + 1];
            }
            [result appendFormat:@"%@\n", tsLine];
            i++; // Skip the TS file line.
            segmentAdded = YES;
        }
        cumulativeDuration = newCumulativeDuration;
    }
    
    // Append ENDLIST to complete the playlist.
    [result appendString:@"#EXT-X-ENDLIST\n"];
    
    return result;
}

@end
