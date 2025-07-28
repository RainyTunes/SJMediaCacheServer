//
//  VODLoopConfig.m
//  SJMediaCacheServer
//
//  Created by zywan on 28/7/2025.
//

#import "VODLoopConfig.h"

@implementation VODLoopConfig

+ (instancetype)configWithStartTime:(NSInteger)startTime duration:(NSInteger)duration {
    VODLoopConfig *config = [[self alloc] init];
    config.startLoopTime = startTime;
    config.loopDuration = duration;
    config.actualStartTimeOffset = 0;
    return config;
}

+ (nullable instancetype)configFromDictionary:(NSDictionary *)dict {
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    VODLoopConfig *config = [[self alloc] init];
    config.startLoopTime = [dict[@"startLoopTime"] integerValue];
    config.loopDuration = [dict[@"loopDuration"] integerValue];
    config.actualStartTimeOffset = [dict[@"actualStartTimeOffset"] integerValue];
    
    return config;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"startLoopTime"] = @(self.startLoopTime);
    dict[@"loopDuration"] = @(self.loopDuration);
    
    if (self.actualStartTimeOffset != 0) {
        dict[@"actualStartTimeOffset"] = @(self.actualStartTimeOffset);
    }
    
    return [dict copy];
}

@end
