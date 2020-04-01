//
//  ICXWebCookieManager.h
//  ICXWebViewModule_Example
//
//  Created by TYFanrong on 2018/2/12.
//  Copyright © 2018年  吕佳珍. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface ICXWebCookieManager : NSObject


@property (nonatomic,strong)WKProcessPool *processPool;


+ (instancetype)sharedInstance;


+ (void)clearCookie;

@end
