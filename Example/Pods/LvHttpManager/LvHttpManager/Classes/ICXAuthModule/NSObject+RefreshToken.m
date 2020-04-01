//
//  NSObject+RefreshToken.m
//  LvHttpManager
//
//  Created by 吕佳珍 on 2020/3/31.
//

#import "NSObject+RefreshToken.h"
#import "ICXAuthManager.h"
#import "ICXRequest.h"

@implementation NSObject (RefreshToken)

/**
 判断聚合接口的返回结果是否登录失效
 
 @param responseObject 聚合接口的返回结果
 @return YES表示登录失效，NO表示不处理
 */
+ (BOOL)responseObjectIsInValid:(NSDictionary *)responseObject {
    if (![responseObject isKindOfClass:[NSDictionary class]] || [responseObject count] == 0) {
        return NO;
    }
    
    //如果外层errorCode为1000，说明登录失效
    if ([responseObject isKindOfClass:[NSDictionary class]] && [responseObject[@"errorCode"] integerValue] == 1000) {
        return YES;
    }
    
    //如果内层有一个errorCode为1000，说明登录失效
    BOOL isInvalid = NO;
    NSArray *valueArray = [responseObject allValues];
    for (id value in valueArray) {
        if ([value isKindOfClass:[NSDictionary class]] && [value[@"errorCode"] integerValue] == 1000) {
            isInvalid = YES;
            break;
        }
    }
    return isInvalid;
}



+ (void)loginExpiredDealWithSuccess:(void (^)(id))success
                          failed:(void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail
{

    [ICXAuthManager refreshTokenWithBlock:^(NSURLResponse * _Nullable response, id  _Nullable responseObject, NSError * _Nullable error, BOOL isValid) {
        if (isValid) {
            //重新进行原先的网络请求-
            NSLog(@"刷新token成功,新的token是:%@", responseObject);
            if (success) {
                success(responseObject);
            }
        }
        else {
            fail(response,responseObject,error);
        }
    }];
}

@end








