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
/// VOD 迴圈配置管理器 VOD loop configuration manager
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

/// 獲取 VOD 迴圈配置 Get VOD loop configuration
- (nullable VODLoopConfig *)vodLoopConfigForURL:(NSURL *)originalURL {
    return [self.vodLoopConfigManager loopConfigForURL:originalURL];
}

/// 標記 VOD 迴圈參數 Mark VOD loop parameters
- (void)markVODLoop:(NSURL *)url startLoopTime:(NSInteger)startLoopTime loopDuration:(NSInteger)loopDuration {
    [self.vodLoopConfigManager markVODLoop:url startLoopTime:startLoopTime loopDuration:loopDuration];
}

#pragma mark - Playlist Processing

/**
 * 使用儲存的迴圈參數裁剪 HLS 播放清單
 * Use stored loop parameters to trim HLS playlist
 * 根據播放清單類型智慧選擇處理策略
 * Intelligently select processing strategy based on playlist type
 *
 * @param playlist    原始 HLS 播放清單字串 Original HLS playlist string
 * @param originalURL 用於查找迴圈參數的 URL URL for finding loop parameters
 * @return 處理後的播放清單字串 Processed playlist string
 */
- (NSString *)processPlaylist:(NSString *)playlist forOriginalURL:(NSURL *)originalURL {
    // 檢查播放清單類型 Check playlist type
    HLSPlaylistType playlistType = [HLSPlaylistChecker checkPlaylistType:playlist url:originalURL];
    
    switch (playlistType) {
        case HLSPlaylistTypeLive:
            // LiveShow 播放清單處理 LiveShow playlist processing
            return [LiveShowPlaylistProcessor processLiveShowPlaylist:playlist originalURL:originalURL];
        case HLSPlaylistTypeMaster:
        case HLSPlaylistTypeUnknown:
            // 這些類型直接返回原播放清單 These types return original playlist directly
            return playlist;
            
        case HLSPlaylistTypeVOD: {
            // VOD 播放清單處理 VOD playlist processing
            VODLoopConfig *config = [self.vodLoopConfigManager loopConfigForURL:originalURL];
            
            if (config) {
                // 有迴圈配置，使用迴圈處理 Has loop config, use loop processing
                return [VODPlaylistProcessor processVODPlaylist:playlist 
                                                     withConfig:config 
                                                    originalURL:originalURL
                                                  configManager:self.vodLoopConfigManager];
            } else {
                // 無迴圈配置，降級處理（只保留第一個片段）No loop config, fallback processing (keep only first segment)
                return [VODPlaylistProcessor processFirstSegmentOnlyPlaylist:playlist];
            }
        }
    }
    
    return playlist;
}

@end
