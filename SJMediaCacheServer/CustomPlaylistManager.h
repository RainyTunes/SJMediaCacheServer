//
//  CustomPlaylistManager.h
//  SJMediaCacheServer
//
//  Created by zywan on 23/4/2025.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class VODLoopConfig;

@interface CustomPlaylistManager : NSObject

/// 单例
+ (instancetype)shared;

/// 获取VOD循环配置（实例方法）
/// @param originalURL 原始URL
/// @return VOD循环配置对象，如果没有配置则返回nil
- (nullable VODLoopConfig *)vodLoopConfigForURL:(NSURL *)originalURL;

/// 标记VOD循环参数（实例方法）
/// @param url 媒体URL
/// @param startLoopTime 循环开始时间（毫秒）
/// @param loopDuration 循环持续时长（毫秒）
- (void)markVODLoop:(NSURL *)url startLoopTime:(NSInteger)startLoopTime loopDuration:(NSInteger)loopDuration;

/// 处理播放列表，根据类型应用相应的处理策略（实例方法）
/// @param playlist 原始播放列表内容
/// @param originalURL 原始URL
/// @return 处理后的播放列表
- (NSString *)processPlaylist:(NSString *)playlist forOriginalURL:(NSURL *)originalURL;


@end

NS_ASSUME_NONNULL_END
