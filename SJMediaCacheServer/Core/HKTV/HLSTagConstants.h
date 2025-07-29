//
//  HLSTagConstants.h
//  SJMediaCacheServer
//
//  Created by zywan on 28/7/2025.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - HLS 播放列表标签常量

/**
 * HLS (HTTP Live Streaming) 协议相关标签常量
 * 参考规范: https://datatracker.ietf.org/doc/html/rfc8216
 */

// MARK: - 播放列表头部标签

/// HLS播放列表文件头标识 - 每个有效的HLS播放列表必须以此开头
/// 用于识别文件为M3U8格式
extern NSString *const kHLSTagPlaylistHeader;

/// HLS标签通用前缀 - 所有HLS标签都以"#EXT"开头
/// 用于快速判断是否为HLS相关内容
extern NSString *const kHLSTagPrefix;

// MARK: - 播放列表类型判断标签

/// Master播放列表标识标签 - 包含多个变体流信息
/// Master播放列表用于提供不同码率/分辨率的流选择
/// 格式: #EXT-X-STREAM-INF:BANDWIDTH=800000,RESOLUTION=640x360
extern NSString *const kHLSTagStreamInfo;

/// 播放列表结束标签 - 表示这是一个完整的播放列表（VOD）
/// Live播放列表没有此标签，VOD播放列表必须有此标签
/// 出现在播放列表末尾
extern NSString *const kHLSTagEndList;

// MARK: - 媒体片段标签

/// 媒体片段信息标签 - 定义每个媒体片段的时长和描述
/// 格式: #EXTINF:10.0,（10.0秒时长的片段）
/// 每个媒体片段URI前必须有对应的EXTINF标签
extern NSString *const kHLSTagSegmentInfo;

#pragma mark - HLS 播放列表类型说明

/**
 * HLS播放列表主要分为三种类型：
 *
 * 1. Master Playlist (主播放列表)
 *    - 包含 #EXT-X-STREAM-INF 标签
 *    - 提供多个变体流的信息（不同码率、分辨率等）
 *    - 不直接包含媒体片段，而是指向具体的Media Playlist
 *
 * 2. VOD Playlist (点播播放列表)
 *    - 包含 #EXT-X-ENDLIST 标签
 *    - 内容固定，播放完毕后结束
 *    - 支持任意时间点的seek操作
 *
 * 3. Live Playlist (直播播放列表)
 *    - 不包含 #EXT-X-ENDLIST 标签
 *    - 内容动态更新，客户端需要定期刷新
 *    - 通常只能从最新的片段开始播放
 */

NS_ASSUME_NONNULL_END
