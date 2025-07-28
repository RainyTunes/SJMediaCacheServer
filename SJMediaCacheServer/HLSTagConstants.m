//
//  HLSTagConstants.m
//  SJMediaCacheServer
//
//  Created by zywan on 28/7/2025.
//

#import "HLSTagConstants.h"

#pragma mark - HLS 播放列表标签常量实现

// MARK: - 播放列表头部标签

NSString *const kHLSTagPlaylistHeader = @"#EXTM3U";
NSString *const kHLSTagPrefix = @"#EXT";

// MARK: - 播放列表类型判断标签

NSString *const kHLSTagStreamInfo = @"#EXT-X-STREAM-INF";
NSString *const kHLSTagEndList = @"#EXT-X-ENDLIST";

// MARK: - 媒体片段标签

NSString *const kHLSTagSegmentInfo = @"#EXTINF:";
