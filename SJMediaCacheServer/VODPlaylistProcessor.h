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

@interface VODPlaylistProcessor : NSObject

/// 处理VOD播放列表（有循环配置）
/// @param playlist 原始播放列表
/// @param config 循环配置
/// @param originalURL 原始URL（用于更新hook开始时间）
/// @param configManager VOD循环配置管理器（用于更新实际开始时间偏移）
/// @return 处理后的播放列表
+ (NSString *)processVODPlaylist:(NSString *)playlist 
                      withConfig:(VODLoopConfig *)config 
                     originalURL:(NSURL *)originalURL
                   configManager:(VODLoopConfigManager *)configManager;

/// 处理首片段播放列表（无循环配置时的降级处理）
/// @param playlist 原始播放列表  
/// @return 只包含第一个片段的播放列表
+ (NSString *)processFirstSegmentOnlyPlaylist:(NSString *)playlist;

@end

NS_ASSUME_NONNULL_END
