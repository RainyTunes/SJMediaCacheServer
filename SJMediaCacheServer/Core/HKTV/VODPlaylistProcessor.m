//
//  VODPlaylistProcessor.m
//  SJMediaCacheServer
//
//  Created by zywan on 28/7/2025.
//

#import "VODPlaylistProcessor.h"
#import "VODLoopConfigManager.h"
#import "HLSTagConstants.h"

@implementation VODPlaylistProcessor

#pragma mark - Public Methods

+ (NSString *)processVODPlaylist:(NSString *)playlist 
                      withConfig:(VODLoopConfig *)config 
                     originalURL:(NSURL *)originalURL
                   configManager:(VODLoopConfigManager *)configManager {
    if (!playlist || ![playlist hasPrefix:kHLSTagPrefix]) return playlist;
    if ([playlist containsString:kHLSTagStreamInfo]) return playlist;   // master playlist
    if (![playlist containsString:kHLSTagEndList])    return playlist;   // live playlist

    // 配置时间已经是毫秒，直接使用
    NSInteger startTimeMs = config.startLoopTime;
    NSInteger endTimeMs = config.startLoopTime + config.loopDuration;

    NSMutableString *result = [NSMutableString string];
    NSArray *lines = [playlist componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSInteger count = lines.count;

    // 复制头部信息
    for (NSString *line in lines) {
        if ([line hasPrefix:kHLSTagSegmentInfo]) break;
        if ([line hasPrefix:kHLSTagEndList]) continue;
        [result appendFormat:@"%@\n", line];
    }

    NSInteger cumulativeMs = 0;
    BOOL segmentAdded = NO;
    NSInteger actualFirstSegmentStartTimeMs = -1;  // 实际保留的第一个片段的开始时间（毫秒）

    for (NSInteger i = 0; i < count; i++) {
        NSString *line = lines[i];
        if (![line hasPrefix:kHLSTagSegmentInfo]) continue;

        NSRange colon = [line rangeOfString:@":"];
        if (colon.location == NSNotFound) continue;

        NSString *durationStr = [[[line substringFromIndex:colon.location + 1]
                                   componentsSeparatedByString:@","].firstObject
                                 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        // 将HLS片段时长从秒转换为毫秒，避免浮点运算
        NSInteger segDurMs = (NSInteger)(durationStr.doubleValue * 1000);
        NSInteger newCumMs = cumulativeMs + segDurMs;

        if (newCumMs <= startTimeMs) {   // 在时间窗口之前
            cumulativeMs = newCumMs;
            // 统一处理空行跳转逻辑
            if (i + 1 < count) {
                NSString *nextLine = lines[i + 1];
                // 跳过空行
                while ([nextLine stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0 && i + 1 < count - 1) {
                    i++;
                    nextLine = lines[i + 1];
                }
                i++; // 跳过对应的 TS 行
            }
            continue;
        }

        if (!segmentAdded) actualFirstSegmentStartTimeMs = cumulativeMs;   // 记录实际保留的第一个片段的开始时间

        [result appendFormat:@"%@\n", line];
        if (i + 1 < count) {
            NSString *ts = lines[i + 1];
            // 跳过空行
            while ([ts stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0 && i + 1 < count - 1) {
                i++;
                ts = lines[i + 1];
            }
            [result appendFormat:@"%@\n", ts];
            i++;
            segmentAdded = YES;
        }
        cumulativeMs = newCumMs;
        
        if (newCumMs > endTimeMs && segmentAdded) break;
    }

    [result appendFormat:@"%@\n", kHLSTagEndList];
    
    // 更新实际开始时间偏移（全程使用毫秒，无需转换）
    if (actualFirstSegmentStartTimeMs >= 0 && originalURL && configManager) {
        NSInteger offsetMs = config.startLoopTime - actualFirstSegmentStartTimeMs;
        [configManager updateActualStartTimeOffset:offsetMs forURL:originalURL];
    }

    return result;
}

+ (NSString *)processFirstSegmentOnlyPlaylist:(NSString *)playlist {
    NSMutableString *result = [NSMutableString string];
    NSArray *lines = [playlist componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSInteger count = lines.count;

    for (NSInteger i = 0; i < count; i++) {
        NSString *line = lines[i];
        if ([line hasPrefix:kHLSTagSegmentInfo]) {
            [result appendFormat:@"%@\n", line];
            if (i + 1 < count) {
                NSString *tsLine = lines[i + 1];
                // 跳过空行
                while ([tsLine stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0 && i + 1 < count - 1) {
                    i++;
                    tsLine = lines[i + 1];
                }
                [result appendFormat:@"%@\n", tsLine];
            }
            break;  // 只处理第一个片段
        } else {
            if (![line hasPrefix:kHLSTagEndList]) {
                [result appendFormat:@"%@\n", line];
            }
        }
    }
    [result appendFormat:@"%@\n", kHLSTagEndList];
    return result;
}

@end
