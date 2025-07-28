//
//  VODPlaylistProcessor.h
//  SJMediaCacheServer
//
//  Created by zywan on 28/7/2025.
//

#import <Foundation/Foundation.h>
#import "VODLoopConfig.h"

NS_ASSUME_NONNULL_BEGIN

@class VODLoopConfigManager;

/**
 * VOD 播放清單處理器 VOD Playlist Processor
 * 負責處理 VOD 類型的 HLS 播放清單，包括迴圈配置和降級處理
 * Handles VOD type HLS playlists including loop configuration and fallback processing
 */
@interface VODPlaylistProcessor : NSObject

/// 處理 VOD 播放清單（有迴圈配置）Process VOD playlist (with loop configuration)
/// @param playlist 原始播放清單 Original playlist
/// @param config 迴圈配置 Loop configuration
/// @param originalURL 原始 URL（用於更新 hook 開始時間）Original URL (for updating hook start time)
/// @param configManager VOD 迴圈配置管理器（用於更新實際開始時間偏移）VOD loop config manager (for updating actual start time offset)
/// @return 處理後的播放清單 Processed playlist
+ (NSString *)processVODPlaylist:(NSString *)playlist 
                      withConfig:(VODLoopConfig *)config 
                     originalURL:(NSURL *)originalURL
                   configManager:(VODLoopConfigManager *)configManager;

/// 處理首片段播放清單（無迴圈配置時的降級處理）Process first segment playlist (fallback processing when no loop config)
/// @param playlist 原始播放清單 Original playlist
/// @return 只包含第一個片段的播放清單 Playlist containing only the first segment
+ (NSString *)processFirstSegmentOnlyPlaylist:(NSString *)playlist;

@end

NS_ASSUME_NONNULL_END
