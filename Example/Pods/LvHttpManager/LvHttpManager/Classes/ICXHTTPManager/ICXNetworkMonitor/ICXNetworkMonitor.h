//
//  ICXNetworkMonitor.h
//  LvHttpManager
//
//  Created by 吕佳珍 on 2020/3/31.
//

#import <Foundation/Foundation.h>

@interface ICXNetworkMonitor : NSObject
/*
 * 开始检测
 */
+ (void)startMonitoring;
/*
 * 是否有网络
 */
+ (BOOL)networkOn;
@end
