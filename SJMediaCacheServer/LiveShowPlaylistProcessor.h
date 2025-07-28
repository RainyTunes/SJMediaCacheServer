//
//  LiveShowPlaylistProcessor.h
//  SJMediaCacheServer
//
//  Created by zywan on 28/7/2025.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * LiveShow 播放清單處理器 LiveShow Playlist Processor
 * 負責處理 LiveShow 類型的 HLS 播放清單，主要功能是添加結束標記
 * Handles LiveShow type HLS playlists, mainly adds end list markers
 */
@interface LiveShowPlaylistProcessor : NSObject

/// 處理 LiveShow 播放清單 Process LiveShow playlist
/// @param playlist 原始 LiveShow 播放清單 Original LiveShow playlist
/// @param originalURL 原始 URL Original URL
/// @return 處理後的播放清單（添加結束標記）Processed playlist (with end list marker added)
+ (NSString *)processLiveShowPlaylist:(NSString *)playlist 
                          originalURL:(NSURL *)originalURL;

/// 為 LiveShow 播放清單添加結束標記 Add end list marker to LiveShow playlist
/// @param playlist 原始播放清單 Original playlist
/// @return 添加結束標記後的播放清單 Playlist with end list marker added
+ (NSString *)addEndListToPlaylist:(NSString *)playlist;

@end

NS_ASSUME_NONNULL_END
