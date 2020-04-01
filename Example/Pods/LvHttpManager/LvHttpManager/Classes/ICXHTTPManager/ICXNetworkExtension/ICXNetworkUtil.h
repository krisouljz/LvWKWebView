//
//  ICXNetworkUtil.h
//  LvHttpManager
//
//  Created by 吕佳珍 on 2020/3/31.
//

#import <Foundation/Foundation.h>
#import "ICXNetworkMarco.h"
@interface ICXNetworkUtil : NSObject
+ (NSString *)requestMethod:(ICXNormalReqeustType)type;
@end
