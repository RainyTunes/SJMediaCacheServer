//
//  RainyHLSHooker.h
//  SJMediaCacheServer
//
//  Created by zywan on 23/4/2025.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RainyHLSHooker : NSObject
+ (void)markLoop:(NSURL *)url startLoopTime:(double)startLoopTime loopDuration:(double)loopDuration;
+ (NSString *)hookPlaylist:(NSString *)playlist forURL:(NSURL *)url;
@end

NS_ASSUME_NONNULL_END
