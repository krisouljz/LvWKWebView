//
//  ICXRequestCache.m
//  LvHttpManager
//
//  Created by 吕佳珍 on 2020/3/31.
//

#import "ICXRequestCache.h"

@implementation ICXRequestCache

+ (instancetype)shareInstance {
    static ICXRequestCache *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _allTaskQueue = [[NSMutableDictionary alloc]init];
        _blockArray = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)dealloc {
    [_allTaskQueue removeAllObjects];
    [_blockArray removeAllObjects];
}

@end
