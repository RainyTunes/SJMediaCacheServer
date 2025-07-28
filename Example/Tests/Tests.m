//
//  SJMediaCacheServerTests.m
//  SJMediaCacheServerTests
//
//  Created by changsanjiang@gmail.com on 05/30/2020.
//  Copyright (c) 2020 changsanjiang@gmail.com. All rights reserved.
//

@import XCTest;
#import "CustomPlaylistManager.h"
#import "VODLoopConfig.h"

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp
{
    [super setUp];
    
    // 清理测试环境，确保每个测试开始时状态一致
}

- (void)tearDown
{
    // 清理测试后的状态
    [super tearDown];
}

#pragma mark - 单例测试

- (void)testCustomPlaylistManagerSingleton
{
    // 测试单例的一致性
    CustomPlaylistManager *instance1 = [CustomPlaylistManager shared];
    CustomPlaylistManager *instance2 = [CustomPlaylistManager shared];
    
    XCTAssertNotNil(instance1, @"单例实例不应为nil");
    XCTAssertNotNil(instance2, @"单例实例不应为nil");
    XCTAssertEqual(instance1, instance2, @"单例实例应该相同");
}

#pragma mark - VOD循环配置测试

- (void)testVODLoopConfigurationBasic
{
    // 测试基本的VOD循环配置功能
    NSURL *testURL = [NSURL URLWithString:@"https://example.com/test/playlist.m3u8"];
    NSInteger startTime = 5000; // 5秒，以毫秒为单位
    NSInteger duration = 10000; // 10秒，以毫秒为单位
    
    // 设置循环配置
    [[CustomPlaylistManager shared] markVODLoop:testURL startLoopTime:startTime loopDuration:duration];
    
    // 获取配置并验证
    VODLoopConfig *config = [[CustomPlaylistManager shared] vodLoopConfigForURL:testURL];
    
    XCTAssertNotNil(config, @"应该能够获取到配置");
    XCTAssertEqual(config.startLoopTime, startTime, @"开始时间应该匹配");
    XCTAssertEqual(config.loopDuration, duration, @"持续时长应该匹配");
    XCTAssertEqual(config.actualStartTimeOffset, 0, @"初始偏移应该为0");
}

- (void)testVODLoopConfigurationInstance
{
    // 测试实例方法的功能
    NSURL *testURL = [NSURL URLWithString:@"https://example.com/test2/playlist.m3u8"];
    NSInteger startTime = 3000; // 3秒
    NSInteger duration = 8000; // 8秒
    
    // 使用实例方法设置配置
    [[CustomPlaylistManager shared] markVODLoop:testURL startLoopTime:startTime loopDuration:duration];
    
    // 使用实例方法获取配置
    VODLoopConfig *config = [[CustomPlaylistManager shared] vodLoopConfigForURL:testURL];
    
    XCTAssertNotNil(config, @"实例方法应该能够获取到配置");
    XCTAssertEqual(config.startLoopTime, startTime, @"开始时间应该匹配");
    XCTAssertEqual(config.loopDuration, duration, @"持续时长应该匹配");
}

#pragma mark - 播放列表处理测试

- (void)testProcessPlaylistBasic
{
    // 测试基本的播放列表处理功能
    NSString *testPlaylist = @"#EXTM3U\n#EXT-X-VERSION:3\n#EXT-X-TARGETDURATION:10\n#EXTINF:10.0,\nsegment1.ts\n#EXT-X-ENDLIST\n";
    NSURL *testURL = [NSURL URLWithString:@"https://example.com/test3/playlist.m3u8"];
    
    // 处理播放列表
    NSString *processedPlaylist = [[CustomPlaylistManager shared] processPlaylist:testPlaylist forOriginalURL:testURL];
    
    XCTAssertNotNil(processedPlaylist, @"处理后的播放列表不应为nil");
    XCTAssertTrue([processedPlaylist containsString:@"#EXTM3U"], @"应该包含M3U标头");
    XCTAssertTrue([processedPlaylist containsString:@"#EXT-X-ENDLIST"], @"应该包含结束标记");
}

- (void)testProcessPlaylistWithInvalidInput
{
    // 测试无效输入的处理
    NSURL *testURL = [NSURL URLWithString:@"https://example.com/test/playlist.m3u8"];
    
    // 测试nil播放列表
    NSString *result1 = [[CustomPlaylistManager shared] processPlaylist:nil forOriginalURL:testURL];
    XCTAssertNil(result1, @"nil输入应该返回nil");
    
    // 测试空字符串
    NSString *result2 = [[CustomPlaylistManager shared] processPlaylist:@"" forOriginalURL:testURL];
    XCTAssertEqualObjects(result2, @"", @"空字符串应该返回空字符串");
    
    // 测试非HLS内容
    NSString *nonHLS = @"This is not an HLS playlist";
    NSString *result3 = [[CustomPlaylistManager shared] processPlaylist:nonHLS forOriginalURL:testURL];
    XCTAssertEqualObjects(result3, nonHLS, @"非HLS内容应该原样返回");
}

@end

