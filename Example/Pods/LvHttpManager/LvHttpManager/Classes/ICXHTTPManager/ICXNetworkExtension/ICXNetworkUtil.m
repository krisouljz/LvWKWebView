//
//  ICXNetworkUtil.m
//  LvHttpManager
//
//  Created by 吕佳珍 on 2020/3/31.
//

#import "ICXNetworkUtil.h"

@implementation ICXNetworkUtil
+ (NSString *)requestMethod:(ICXNormalReqeustType)type{
    return [self methodDict][@(type)];
}
+ (NSDictionary *)methodDict{
    return @{
             @(ICXNormalReqeustTypeGET) : @"GET",
             @(ICXNormalReqeustTypePOST) : @"POST",
             @(ICXNormalReqeustTypeDELETE) : @"DELETE",
             @(ICXNormalReqeustTypePUT) : @"PUT",
             };
}
@end
