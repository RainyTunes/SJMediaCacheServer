//
//  SafeMutableDictionary.h
//  SJMediaCacheServer
//
//  Created by zywan on 28/7/2025.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Thread-safe dictionary for VODLoopConfigManager
 * Uses @synchronized to ensure thread safety
 */
@interface SafeMutableDictionary<KeyType, ObjectType> : NSObject

/// Initialize with existing dictionary
- (instancetype)initWithDictionary:(nullable NSDictionary<KeyType, ObjectType> *)dictionary;

/// Get dictionary copy for saving to UserDefaults
- (NSDictionary<KeyType, ObjectType> *)copy;

/// Subscript access support
- (nullable ObjectType)objectForKeyedSubscript:(KeyType)key;
- (void)setObject:(nullable ObjectType)object forKeyedSubscript:(KeyType)key;

@end

NS_ASSUME_NONNULL_END
