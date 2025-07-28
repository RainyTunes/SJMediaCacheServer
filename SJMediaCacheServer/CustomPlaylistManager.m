//
//  CustomPlaylistManager.m
//  SJMediaCacheServer
//
//  Created by zywan on 23/4/2025.
//

#import "CustomPlaylistManager.h"
#import "VODLoopConfigManager.h"
#import "VODLoopConfig.h"
#import "VODPlaylistProcessor.h"
#import "HLSPlaylistChecker.h"
#import "LiveShowPlaylistProcessor.h"
#import "HLSTagConstants.h"

@interface CustomPlaylistManager ()
/// VOD循环配置管理器
@property (nonatomic, strong) VODLoopConfigManager *vodLoopConfigManager;
@end

@implementation CustomPlaylistManager

#pragma mark - Singleton

+ (instancetype)shared {
    static CustomPlaylistManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _vodLoopConfigManager = [[VODLoopConfigManager alloc] init];
    }
    return self;
}

#pragma mark - VOD Loop Configuration

/// 获取VOD循环配置
- (nullable VODLoopConfig *)vodLoopConfigForURL:(NSURL *)originalURL {
    return [self.vodLoopConfigManager loopConfigForURL:originalURL];
}

/// 标记VOD循环参数
- (void)markVODLoop:(NSURL *)url startLoopTime:(NSInteger)startLoopTime loopDuration:(NSInteger)loopDuration {
    [self.vodLoopConfigManager markVODLoop:url startLoopTime:startLoopTime loopDuration:loopDuration];
}

#pragma mark - Playlist Processing

/**
 * 使用存储的循环参数裁剪HLS播放列表
 * 根据播放列表类型智能选择处理策略
 *
 * @param playlist    原始HLS播放列表字符串
 * @param originalURL 用于查找循环参数的URL
 * @return 处理后的播放列表字符串
 */
- (NSString *)processPlaylist:(NSString *)playlist forOriginalURL:(NSURL *)originalURL {
    // 检查播放列表类型
    HLSPlaylistType playlistType = [HLSPlaylistChecker checkPlaylistType:playlist url:originalURL];
    
    switch (playlistType) {
        case HLSPlaylistTypeLive:
            // LiveShow播放列表处理
            return [LiveShowPlaylistProcessor processLiveShowPlaylist:playlist originalURL:originalURL];
        case HLSPlaylistTypeMaster:
        case HLSPlaylistTypeUnknown:
            // 这些类型直接返回原播放列表
            return playlist;
            
        case HLSPlaylistTypeVOD: {
            // VOD播放列表处理
            VODLoopConfig *config = [self.vodLoopConfigManager loopConfigForURL:originalURL];
            
            if (config) {
                // 有循环配置，使用循环处理
                return [VODPlaylistProcessor processVODPlaylist:playlist 
                                                     withConfig:config 
                                                    originalURL:originalURL
                                                  configManager:self.vodLoopConfigManager];
            } else {
                // 无循环配置，降级处理（只保留第一个片段）
                return [VODPlaylistProcessor processFirstSegmentOnlyPlaylist:playlist];
            }
        }
    }
    
    return playlist;
}



@end
