//
//  LiveShowPlaylistProcessor.h
//  SJMediaCacheServer
//
//  Created by zywan on 28/7/2025.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveShowPlaylistProcessor : NSObject

/// 处理LiveShow播放列表
/// @param playlist 原始LiveShow播放列表
/// @param originalURL 原始URL
/// @return 处理后的播放列表（添加结束标记）
+ (NSString *)processLiveShowPlaylist:(NSString *)playlist 
                          originalURL:(NSURL *)originalURL;

/// 为LiveShow播放列表添加结束标记
/// @param playlist 原始播放列表
/// @return 添加结束标记后的播放列表
+ (NSString *)addEndListToPlaylist:(NSString *)playlist;

@end

NS_ASSUME_NONNULL_END
