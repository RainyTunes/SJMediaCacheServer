//
//  VODLoopConfigManager.m
//  SJMediaCacheServer
//
//  Created by zywan on 28/7/2025.
//

#import "VODLoopConfigManager.h"

@interface VODLoopConfigManager ()
/// 内存缓存
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSDictionary *> *loopCache;
@end

@implementation VODLoopConfigManager

/// UserDefaults 存储的 key
static NSString *const kVODLoopConfigCacheKey = @"VODLoopConfigManager.loopCache";

- (instancetype)init {
    self = [super init];
    if (self) {
        [self _initializeCacheIfNeeded];
    }
    return self;
}

#pragma mark - Private Methods

/// 初始化缓存，确保内存缓存与 UserDefaults 同步
- (void)_initializeCacheIfNeeded {
    if (self.loopCache) { 
        return; 
    }
    
    NSDictionary *saved = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kVODLoopConfigCacheKey];
    self.loopCache = saved ? [saved mutableCopy] : [NSMutableDictionary dictionary];
}

/// 将URL规范化为缓存key（去除最后一个路径组件）
/// example:  https://vod-edge.hktvmall.com/shoaltervod/_definist_/smil:local/07a96b1f61097ccb54be14d6a47439b0/b056eb1587586b71e2da9acfe4fbd19e/6512bd43d9caa6e02c990b0a82652dca/1174b68b-5470-48a2-90b8-a8ba42323257/1174b68b-5470-48a2-90b8-a8ba42323257.smil/playlist.m3u8
- (nullable NSString *)_normalizedKeyFromURL:(NSURL *)url {
    if (!url) { 
        return nil; 
    }
    
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    components.query = nil;
    return components.URL.absoluteString;
}

/// 保存缓存到 UserDefaults
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
    
    // 检查是否需要更新（对于整数类型，直接比较）
    if (oldDict &&
        [oldDict[@"startLoopTime"] integerValue] == startLoopTime &&
        [oldDict[@"loopDuration"] integerValue] == loopDuration) {
        return; // 相同参数，跳过更新
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
