//
//  VODLoopConfigManager.h
//  SJMediaCacheServer
//
//  Created by zywan on 28/7/2025.
//

#import <Foundation/Foundation.h>
#import "VODLoopConfig.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * VOD 迴圈配置管理器 VOD Loop Configuration Manager
 * 負責管理 VOD 迴圈配置的儲存、檢索和更新
 * Manages storage, retrieval and updates of VOD loop configurations
 */
@interface VODLoopConfigManager : NSObject

/// 檢查指定 URL 是否有快取的迴圈配置 Check if specified URL has cached loop configuration
- (BOOL)hasLoopConfigForURL:(NSURL *)url;

/// 獲取指定 URL 的迴圈配置 Get loop configuration for specified URL
- (nullable VODLoopConfig *)loopConfigForURL:(NSURL *)url;

/// 根據參數建立並儲存迴圈配置 Create and save loop configuration based on parameters
/// @param url 媒體 URL Media URL
/// @param startLoopTime 迴圈開始時間（毫秒）Loop start time (milliseconds)
/// @param loopDuration 迴圈持續時長（毫秒）Loop duration (milliseconds)
- (void)markVODLoop:(NSURL *)url startLoopTime:(NSInteger)startLoopTime loopDuration:(NSInteger)loopDuration;

/// 更新配置的實際開始時間偏移 Update actual start time offset of configuration
/// @param actualStartTimeOffset 截取後的實際開始時間偏移（毫秒）Actual start time offset after trimming (milliseconds)
/// @param url 目標 URL Target URL
- (void)updateActualStartTimeOffset:(NSInteger)actualStartTimeOffset forURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
