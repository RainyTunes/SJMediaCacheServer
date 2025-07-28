//
//  HLSPlaylistChecker.h
//  SJMediaCacheServer
//
//  Created by zywan on 28/7/2025.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// HLS播放列表类型枚举
typedef NS_ENUM(NSUInteger, HLSPlaylistType) {
    HLSPlaylistTypeUnknown = 0,     ///< 未知类型
    HLSPlaylistTypeMaster,          ///< Master播放列表
    HLSPlaylistTypeVOD,             ///< VOD播放列表
    HLSPlaylistTypeLive,            ///< Live播放列表  
};

@interface HLSPlaylistChecker : NSObject

/// 检查播放列表类型
/// @param playlist 播放列表内容
/// @param url 播放列表URL
/// @return 播放列表类型
+ (HLSPlaylistType)checkPlaylistType:(NSString *)playlist url:(NSURL *)url;

/// 检查是否是Master播放列表
/// @param playlist 播放列表内容
/// @return YES表示是Master播放列表
+ (BOOL)isMasterPlaylist:(NSString *)playlist;

/// 检查是否是Live播放列表
/// @param playlist 播放列表内容
/// @return YES表示是Live播放列表
+ (BOOL)isLivePlaylist:(NSString *)playlist;

/// 检查是否是VOD播放列表
/// @param playlist 播放列表内容
/// @return YES表示是VOD播放列表
+ (BOOL)isVODPlaylist:(NSString *)playlist;

/// 检查播放列表是否有效
/// @param playlist 播放列表内容
/// @return YES表示是有效的HLS播放列表
+ (BOOL)isValidHLSPlaylist:(NSString *)playlist;

@end

NS_ASSUME_NONNULL_END
