//
//  VODLoopConfigManager.h
//  SJMediaCacheServer
//
//  Created by zywan on 28/7/2025.
//

#import <Foundation/Foundation.h>
#import "VODLoopConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface VODLoopConfigManager : NSObject

/// 检查指定URL是否有缓存的循环配置
- (BOOL)hasLoopConfigForURL:(NSURL *)url;

/// 获取指定URL的循环配置
- (nullable VODLoopConfig *)loopConfigForURL:(NSURL *)url;

/// 保存循环配置
- (void)setLoopConfig:(VODLoopConfig *)config forURL:(NSURL *)url;

/// 根据参数创建并保存循环配置
/// @param url 媒体URL
/// @param startLoopTime 循环开始时间（毫秒）
/// @param loopDuration 循环持续时长（毫秒）
- (void)markVODLoop:(NSURL *)url startLoopTime:(NSInteger)startLoopTime loopDuration:(NSInteger)loopDuration;

/// 更新配置的实际开始时间偏移
/// @param actualStartTimeOffset 截取后的实际开始时间偏移（毫秒）
/// @param url 目标URL
- (void)updateActualStartTimeOffset:(NSInteger)actualStartTimeOffset forURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
