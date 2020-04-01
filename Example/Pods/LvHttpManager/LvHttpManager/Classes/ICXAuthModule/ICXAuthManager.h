//
//  ICXAuthManager.h
//  LvHttpManager
//
//  Created by 吕佳珍 on 2020/3/31.
//

#import <Foundation/Foundation.h>

typedef void(^authReturnBlock)(NSURLResponse * _Nullable response, id _Nullable responseObject,  NSError * _Nullable error,BOOL isValid);

//Token刷新成功发送一个通知
#define ICXToken_Refresh_Succeed_Notification @"ICXToken_Refresh_Succeed_Notification"

@interface ICXAuthManager : NSObject

+ (NSString *_Nullable)getToken;

+ (NSString *_Nonnull)getRefreshToken;

+ (void)refreshTokenWithBlock:(authReturnBlock _Nullable )block;


+ (BOOL)isTokenValid;

+ (BOOL)isRefreshTokenValid;

+ (NSString *_Nullable)getUserAgent;

+ (NSString *_Nonnull)getBasicAuthorization;

@end
