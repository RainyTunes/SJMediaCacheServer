//
//  HLSPlaylistChecker.m
//  SJMediaCacheServer
//
//  Created by zywan on 28/7/2025.
//

#import "HLSPlaylistChecker.h"
#import "HLSTagConstants.h"

@implementation HLSPlaylistChecker

+ (HLSPlaylistType)checkPlaylistType:(NSString *)playlist url:(NSURL *)url {
    if (![self isValidHLSPlaylist:playlist]) {
        return HLSPlaylistTypeUnknown;
    }
    
    if ([self isMasterPlaylist:playlist]) {
        return HLSPlaylistTypeMaster;
    }
    
    if ([self isLivePlaylist:playlist]) {
        return HLSPlaylistTypeLive;
    }
    
    if ([self isVODPlaylist:playlist]) {
        return HLSPlaylistTypeVOD;
    }
    
    return HLSPlaylistTypeUnknown;
}

+ (BOOL)isMasterPlaylist:(NSString *)playlist {
    // Master播放列表包含#EXT-X-STREAM-INF标签
    return [playlist containsString:kHLSTagStreamInfo];
}

+ (BOOL)isLivePlaylist:(NSString *)playlist {
    // Live播放列表：有效的HLS但不包含结束标记，且不是Master播放列表
    return [self isValidHLSPlaylist:playlist] && 
           ![playlist containsString:kHLSTagEndList] &&
           ![self isMasterPlaylist:playlist];
}

+ (BOOL)isVODPlaylist:(NSString *)playlist {
    // VOD播放列表：有效的HLS且包含结束标记，且不是Master播放列表
    return [self isValidHLSPlaylist:playlist] && 
           [playlist containsString:kHLSTagEndList] &&
           ![self isMasterPlaylist:playlist];
}

+ (BOOL)isValidHLSPlaylist:(NSString *)playlist {
    // 标准的HLS播放列表必须以#EXTM3U开头
    return playlist.length > 0 && [playlist hasPrefix:kHLSTagPlaylistHeader];
}

@end
