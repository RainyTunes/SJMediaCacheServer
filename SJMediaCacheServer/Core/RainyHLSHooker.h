//
//  RainyHLSHooker.h
//  SJMediaCacheServer
//
//  Created by zywan on 23/4/2025.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RainyHLSHooker : NSObject
/// Return loop params in seconds, or nil on miss.
/// dict keys: @"startTime", @"endTime" (NSNumber, double seconds)
+ (nullable NSDictionary<NSString *, NSNumber *> *)loopParamsForOriginalURL:(NSURL *)originalURL;

+ (void)markVODLoop:(NSURL *)url startLoopTime:(double)startLoopTime loopDuration:(double)loopDuration;
+ (NSString *)hookPlaylist:(NSString *)playlist forOriginalURL:(NSURL *)originalURL;
@end

NS_ASSUME_NONNULL_END
