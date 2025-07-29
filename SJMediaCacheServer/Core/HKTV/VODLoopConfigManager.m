//
//  VODLoopConfigManager.m
//  SJMediaCacheServer
//
//  Created by zywan on 28/7/2025.
//

#import "VODLoopConfigManager.h"

@interface VODLoopConfigManager ()
/// 記憶體快取 Memory cache
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSDictionary *> *loopCache;
@end

@implementation VODLoopConfigManager

/// UserDefaults 儲存的 key UserDefaults storage key
static NSString *const kVODLoopConfigCacheKey = @"VODLoopConfigManager.loopCache";

- (instancetype)init {
    self = [super init];
    if (self) {
        [self _initializeCacheIfNeeded];
    }
    return self;
}

#pragma mark - Private Methods

/// 初始化快取，確保記憶體快取與 UserDefaults 同步 Initialize cache, ensure memory cache syncs with UserDefaults
- (void)_initializeCacheIfNeeded {
    if (self.loopCache) { 
        return; 
    }
    
    NSDictionary *saved = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kVODLoopConfigCacheKey];
    self.loopCache = saved ? [saved mutableCopy] : [NSMutableDictionary dictionary];
}

/// 將 URL 規範化為快取鍵（去除最後一個路徑組件）Normalize URL to cache key (remove last path component)
/// example:  https://vod-edge.hktvmall.com/shoaltervod/_definist_/smil:local/07a96b1f61097ccb54be14d6a47439b0/b056eb1587586b71e2da9acfe4fbd19e/6512bd43d9caa6e02c990b0a82652dca/1174b68b-5470-48a2-90b8-a8ba42323257/1174b68b-5470-48a2-90b8-a8ba42323257.smil/playlist.m3u8
- (nullable NSString *)_normalizedKeyFromURL:(NSURL *)url {
    if (!url) { 
        return nil; 
    }
    
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    components.query = nil;
    return components.URL.absoluteString;
}

/// 儲存快取到 UserDefaults Save cache to UserDefaults
- (void)_saveCache {
    [[NSUserDefaults standardUserDefaults] setObject:self.loopCache forKey:kVODLoopConfigCacheKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Public Methods

- (BOOL)hasLoopConfigForURL:(NSURL *)url {
    [self _initializeCacheIfNeeded];
    
    NSString *key = [self _normalizedKeyFromURL:url];
    return (self.loopCache[key] != nil);
}

- (nullable VODLoopConfig *)loopConfigForURL:(NSURL *)url {
    [self _initializeCacheIfNeeded];
    
    NSString *key = [self _normalizedKeyFromURL:url];
    NSDictionary *dict = self.loopCache[key];
    
    return [VODLoopConfig configFromDictionary:dict];
}

- (void)setLoopConfig:(VODLoopConfig *)config forURL:(NSURL *)url {
    if (!config || !url) {
        return;
    }
    
    [self _initializeCacheIfNeeded];
    
    NSString *key = [self _normalizedKeyFromURL:url];
    self.loopCache[key] = [config toDictionary];
    
    [self _saveCache];
}

- (void)markVODLoop:(NSURL *)url startLoopTime:(NSInteger)startLoopTime loopDuration:(NSInteger)loopDuration {
    if (!url) {
        return;
    }
    
    [self _initializeCacheIfNeeded];
    
    NSString *key = [self _normalizedKeyFromURL:url];
    NSDictionary *oldDict = self.loopCache[key];
    
    // 檢查是否需要更新（對於整數類型，直接比較）Check if update is needed (for integer types, direct comparison)
    if (oldDict &&
        [oldDict[@"startLoopTime"] integerValue] == startLoopTime &&
        [oldDict[@"loopDuration"] integerValue] == loopDuration) {
        return; // 相同參數，跳過更新 Same parameters, skip update
    }
    
    VODLoopConfig *config = [VODLoopConfig configWithStartTime:startLoopTime duration:loopDuration];
    [self setLoopConfig:config forURL:url];
}

- (void)updateActualStartTimeOffset:(NSInteger)actualStartTimeOffset forURL:(NSURL *)url {
    VODLoopConfig *config = [self loopConfigForURL:url];
    if (config) {
        config.actualStartTimeOffset = actualStartTimeOffset;
        [self setLoopConfig:config forURL:url];
    }
}

@end
