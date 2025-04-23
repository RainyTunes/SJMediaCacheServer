//
//  RainyHLSHooker.h
//  SJMediaCacheServer
//
//  Created by zywan on 23/4/2025.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RainyHLSHooker : NSObject
+ (NSString *)hookPlaylist:(NSString *)playlist startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime;
@end

NS_ASSUME_NONNULL_END
