//
//  RainyHLSHooker.m
//  SJMediaCacheServer
//
//  Created by zywan on 23/4/2025.
//

#import "RainyHLSHooker.h"

@implementation RainyHLSHooker

/**
 * Trims HLS playlist to cover the desired time interval.
 *
 * The method accepts a start time and an end time. Segments prior to the start time
 * are skipped. When processing segments, if adding the current segment (EXTINF and its
 * corresponding TS file) causes the cumulative duration to exceed the specified end time,
 * the current segment is skipped (provided that at least one segment has already been processed),
 * and further segments are ignored.
 *
 * If no segment has been processed so far, the first segment will be added even if it
 * exceeds the end time.
 *
 * Example:
 * Input:
 * #EXTM3U
 * #EXT-X-VERSION:3
 * #EXTINF:10.0,
 * segment1.ts
 * #EXTINF:10.0,
 * segment2.ts
 * #EXT-X-ENDLIST
 *
 * For startTime = 0 and endTime = 8, the output will be:
 *
 * #EXTM3U
 * #EXT-X-VERSION:3
 * #EXTINF:10.0,
 * segment1.ts
 * #EXT-X-ENDLIST
 *
 * @param playlist The original HLS playlist string.
 * @param startTime The desired start time (in seconds).
 * @param endTime The desired end time (in seconds).
 * @return A new playlist string trimmed to cover the specified time interval.
 */
+ (NSString *)hookPlaylist:(NSString *)playlist startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime {
    // Validate input and skip playlists that shouldn't be modified.
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
            while ([tsLine stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0
                   && i + 1 < count - 1) {
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
