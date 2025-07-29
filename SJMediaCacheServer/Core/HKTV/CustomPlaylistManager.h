//
//  CustomPlaylistManager.h
//  SJMediaCacheServer
//
//  Created by zywan on 23/4/2025.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class VODLoopConfig;

/**
 * 自定義播放清單管理器 Custom Playlist Manager
 * 負責處理 HLS 播放清單的自定義邏輯，包括 VOD 迴圈配置和播放清單處理
 * Handles custom logic for HLS playlists including VOD loop configuration and playlist processing
 */
@interface CustomPlaylistManager : NSObject

/// 單例實例 Singleton instance
+ (instancetype)shared;

/// 獲取 VOD 迴圈配置 Get VOD loop configuration (instance method)
/// @param originalURL 原始 URL Original URL
/// @return VOD 迴圈配置物件，如果沒有配置則返回 nil VOD loop config object, returns nil if no config found
- (nullable VODLoopConfig *)vodLoopConfigForURL:(NSURL *)originalURL;

/// 標記 VOD 迴圈參數 Mark VOD loop parameters (instance method)
/// @param url 媒體 URL Media URL
/// @param startLoopTime 迴圈開始時間（毫秒）Loop start time (milliseconds)
/// @param loopDuration 迴圈持續時長（毫秒）Loop duration (milliseconds)
- (void)markVODLoop:(NSURL *)url startLoopTime:(NSInteger)startLoopTime loopDuration:(NSInteger)loopDuration;

/// 處理播放清單，根據類型應用相應的處理策略 Process playlist with appropriate strategy based on type (instance method)
/// @param playlist 原始播放清單內容 Original playlist content
/// @param originalURL 原始 URL Original URL
/// @return 處理後的播放清單 Processed playlist
- (NSString *)processPlaylist:(NSString *)playlist forOriginalURL:(NSURL *)originalURL;

@end

NS_ASSUME_NONNULL_END
