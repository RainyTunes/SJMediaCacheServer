//
//  SafeMutableDictionary.m
//  SJMediaCacheServer
//
//  Created by zywan on 28/7/2025.
//

#import "SafeMutableDictionary.h"

@interface SafeMutableDictionary ()
@property (nonatomic, strong) NSMutableDictionary *internalDictionary;
@end

@implementation SafeMutableDictionary

- (instancetype)initWithDictionary:(nullable NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.internalDictionary = dictionary ? [dictionary mutableCopy] : [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSDictionary *)copy {
    @synchronized (self) {
        return [self.internalDictionary copy];
    }
}

#pragma mark - Subscript Support

- (nullable id)objectForKeyedSubscript:(id)key {
    @synchronized (self) {
        return self.internalDictionary[key];
    }
}

- (void)setObject:(nullable id)object forKeyedSubscript:(id)key {
    @synchronized (self) {
        if (object) {
            self.internalDictionary[key] = object;
        } else {
            [self.internalDictionary removeObjectForKey:key];
        }
    }
}

@end
