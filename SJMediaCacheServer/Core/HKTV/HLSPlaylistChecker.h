//
//  HLSPlaylistChecker.h
//  SJMediaCacheServer
//
//  Created by zywan on 28/7/2025.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// HLS 播放清單類型列舉 HLS playlist type enumeration
typedef NS_ENUM(NSUInteger, HLSPlaylistType) {
    HLSPlaylistTypeUnknown = 0,     ///< 未知類型 Unknown type
    HLSPlaylistTypeMaster,          ///< Master 播放清單 Master playlist
    HLSPlaylistTypeVOD,             ///< VOD 播放清單 VOD playlist
    HLSPlaylistTypeLive,            ///< Live 播放清單 Live playlist
};

/**
 * HLS 播放清單檢查器 HLS Playlist Checker
 * 負責識別和檢查 HLS 播放清單的類型和有效性
 * Responsible for identifying and checking the type and validity of HLS playlists
 */
@interface HLSPlaylistChecker : NSObject

/// 檢查播放清單類型 Check playlist type
/// @param playlist 播放清單內容 Playlist content
/// @param url 播放清單 URL Playlist URL
/// @return 播放清單類型 Playlist type
+ (HLSPlaylistType)checkPlaylistType:(NSString *)playlist url:(NSURL *)url;

/// 檢查是否是 Master 播放清單 Check if it's a Master playlist
/// @param playlist 播放清單內容 Playlist content
/// @return YES 表示是 Master 播放清單 YES indicates it's a Master playlist
+ (BOOL)isMasterPlaylist:(NSString *)playlist;

/// 檢查是否是 Live 播放清單 Check if it's a Live playlist
/// @param playlist 播放清單內容 Playlist content
/// @return YES 表示是 Live 播放清單 YES indicates it's a Live playlist
+ (BOOL)isLivePlaylist:(NSString *)playlist;

/// 檢查是否是 VOD 播放清單 Check if it's a VOD playlist
/// @param playlist 播放清單內容 Playlist content
/// @return YES 表示是 VOD 播放清單 YES indicates it's a VOD playlist
+ (BOOL)isVODPlaylist:(NSString *)playlist;

/// 檢查播放清單是否有效 Check if playlist is valid
/// @param playlist 播放清單內容 Playlist content
/// @return YES 表示是有效的 HLS 播放清單 YES indicates it's a valid HLS playlist
+ (BOOL)isValidHLSPlaylist:(NSString *)playlist;

@end

NS_ASSUME_NONNULL_END
