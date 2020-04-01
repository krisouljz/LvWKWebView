//
//  ICXRequestCache.h
//  LvHttpManager
//
//  Created by 吕佳珍 on 2020/3/31.
//

#import <Foundation/Foundation.h>

@interface ICXRequestCache : NSObject

@property (nonatomic,strong) NSMutableDictionary *allTaskQueue;

@property (nonatomic,assign) BOOL isRefreshingToken; //是否正在刷新token

@property (nonatomic,assign) NSTimeInterval lastRefreshTokenTime; //上次刷新token的时间

@property (nonatomic,strong) NSMutableArray *blockArray;

+ (instancetype)shareInstance;

@end
