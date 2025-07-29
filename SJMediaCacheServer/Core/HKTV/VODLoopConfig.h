//
//  VODLoopConfig.h
//  SJMediaCacheServer
//
//  Created by zywan on 28/7/2025.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * VOD 迴圈配置 VOD Loop Configuration
 * 儲存 VOD 媒體的迴圈播放相關參數
 * Stores loop playback related parameters for VOD media
 */
@interface VODLoopConfig : NSObject

/// 迴圈開始時間（毫秒）Loop start time (milliseconds)
@property (nonatomic, assign) NSInteger startLoopTime;

/// 迴圈持續時長（毫秒）Loop duration (milliseconds)
@property (nonatomic, assign) NSInteger loopDuration;

/// 截取後的實際開始時間偏移（毫秒）Actual start time offset after trimming (milliseconds)
/// 當 VOD 播放清單被截取時，實際保留的第一個片段開始時間與期望開始時間的差值
/// When VOD playlist is trimmed, the difference between actual first segment start time and expected start time
/// 正值表示實際開始時間晚於期望時間，負值表示實際開始時間早於期望時間
/// Positive value means actual start time is later than expected, negative value means earlier
@property (nonatomic, assign) NSInteger actualStartTimeOffset;

/// 便利建構器 Convenience constructor
/// @param startTime 迴圈開始時間（毫秒）Loop start time (milliseconds)
/// @param duration 迴圈持續時長（毫秒）Loop duration (milliseconds)
+ (instancetype)configWithStartTime:(NSInteger)startTime duration:(NSInteger)duration;

/// 從字典建立配置 Create config from dictionary
+ (nullable instancetype)configFromDictionary:(NSDictionary *)dict;

/// 轉換為字典（用於持久化）Convert to dictionary (for persistence)
- (NSDictionary *)toDictionary;

@end

NS_ASSUME_NONNULL_END
