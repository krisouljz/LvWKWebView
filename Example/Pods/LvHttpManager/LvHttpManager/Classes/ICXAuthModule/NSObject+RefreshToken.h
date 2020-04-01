//
//  NSObject+RefreshToken.h
//  LvHttpManager
//
//  Created by 吕佳珍 on 2020/3/31.
//

#import <Foundation/Foundation.h>
#import "ICXNetworkMarco.h"
#import "ICXAuthModule.h"


@interface NSObject (RefreshToken)

/**
 判断聚合接口的返回结果是否登录失效
 
 @param responseObject 聚合接口的返回结果
 @return YES表示登录失效，NO表示不处理
 */
+ (BOOL)responseObjectIsInValid:(NSDictionary *_Nullable)responseObject;

+ (void)loginExpiredDealWithSuccess:(void (^_Nullable)(id _Nullable ))success
                             failed:(void (^_Nullable)(NSURLResponse * _Nullable response, id _Nullable responseObject,  NSError * _Nullable error))fail;

@end
