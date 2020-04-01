//
//  ICXNormalRequest.h
//  LvHttpManager
//
//  Created by 吕佳珍 on 2020/3/31.
//

#import <Foundation/Foundation.h>
#import "ICXNetworkMarco.h"
#import "ICXCustomManagerProtocol.h"
@interface ICXNormalRequest : NSObject
+ (NSURLSessionTask *)requestWithType:(ICXNormalReqeustType)type
                              manager:(AFHTTPSessionManager *)manager
                                  URL:(NSString *)URLMethod
                               params:(NSDictionary *)params
                              success:(void(^)(id responseObject))success
                               failed:(void(^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail;
@end
