//
//  LiveShowPlaylistProcessor.m
//  SJMediaCacheServer
//
//  Created by zywan on 28/7/2025.
//

#import "LiveShowPlaylistProcessor.h"
#import "HLSTagConstants.h"

@implementation LiveShowPlaylistProcessor

+ (NSString *)processLiveShowPlaylist:(NSString *)playlist originalURL:(NSURL *)originalURL {
    // LiveShow处理逻辑：简单地添加结束标记
    return [self addEndListToPlaylist:playlist];
}

+ (NSString *)addEndListToPlaylist:(NSString *)playlist {
    if (!playlist || playlist.length == 0) {
        return playlist;
    }
    
    NSMutableString *result = [playlist mutableCopy];
    
    // 如果播放列表还没有结束标记，则添加
    if (![playlist containsString:kHLSTagEndList]) {
        [result appendFormat:@"%@\n", kHLSTagEndList];
    }
    
    return result;
}

@end
