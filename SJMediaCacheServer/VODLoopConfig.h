//
//  VODLoopConfig.h
//  SJMediaCacheServer
//
//  Created by zywan on 28/7/2025.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VODLoopConfig : NSObject

/// 循环开始时间（毫秒）
@property (nonatomic, assign) NSInteger startLoopTime;

/// 循环持续时长（毫秒）
@property (nonatomic, assign) NSInteger loopDuration;

/// 截取后的实际开始时间偏移（毫秒）
/// 当VOD播放列表被截取时，实际保留的第一个片段开始时间与期望开始时间的差值
/// 正值表示实际开始时间晚于期望时间，负值表示实际开始时间早于期望时间
@property (nonatomic, assign) NSInteger actualStartTimeOffset;

/// 便利构造器
/// @param startTime 循环开始时间（毫秒）
/// @param duration 循环持续时长（毫秒）
+ (instancetype)configWithStartTime:(NSInteger)startTime duration:(NSInteger)duration;

/// 从字典创建配置
+ (nullable instancetype)configFromDictionary:(NSDictionary *)dict;

/// 转换为字典（用于持久化）
- (NSDictionary *)toDictionary;

@end

NS_ASSUME_NONNULL_END
