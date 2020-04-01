//
//  ICXCustomManagerProtocol.h
//  LvHttpManager
//
//  Created by 吕佳珍 on 2020/3/31.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
@protocol ICXCustomManagerProtocol <NSObject>
@optional
- (AFHTTPSessionManager *)customManager;
@end
