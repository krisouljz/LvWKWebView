//
//  ICXAuthManager.m
//  LvHttpManager
//
//  Created by 吕佳珍 on 2020/3/31.
//

#import "ICXAuthManager.h"
#import "ICXDataSaveManager.h"
#import "ICXAuthModule.h"
#import "ICXAuthModel.h"
#import "ICXTokenAPIManager.h"
#import <sys/utsname.h>
#import "CTMediator.h"
#import "ICXRequestCache.h"



static NSString *Login_Path = @"oauth2/token";
#define Login_URL ICXAuthURLString(Login_Path)
#define Basic_Authorization_Headers @{@"Authorization":ICX_Basic_Authorization}






@interface ICXAuthManager ()


@end


@implementation ICXAuthManager


+ (NSString *)getToken
{
    ICXAuthModel *model = [ICXDataSaveManager getModelWithPath:ICX_Token_Save_Path];
    NSLog(@"access_token = %@",model.access_token);
    return model.access_token;
    
    //    if ([self isTokenValid]) {
    //        return model.access_token;
    //    }
    //    else
    //    {
    //        return nil;
    //    }
}

+ (NSString *)getRefreshToken
{
    ICXAuthModel *model = [ICXDataSaveManager getModelWithPath:ICX_Token_Save_Path];
    return model.refresh_token;
    
    //    if ([self isRefreshTokenValid]) {
    //        return model.refresh_token;
    //    }
    //    else
    //    {
    //        //说明refreshToken过期,需要重新登录
    //        return nil;
    //    }
}


+ (void)refreshTokenWithBlock:(authReturnBlock)block
{
    ICXRequestCache *cacheManager = [ICXRequestCache shareInstance];
    [cacheManager.blockArray addObject:[block copy]];
    
    if (cacheManager.isRefreshingToken) {
        return;
    }

//    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
//    if (currentTime - cacheManager.lastRefreshTokenTime <= 300) {
//        return;
//    }
    
    
    //设置标记
    cacheManager.isRefreshingToken = YES;
//    cacheManager.lastRefreshTokenTime = currentTime;

    //开始请求
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [infoDictionary objectForKey:@"ICXAppName"];
    
    ICXTokenAPIModel *model = [ICXTokenAPIModel new];
    ICXTokenAPIManager *manager = [ICXTokenAPIManager new];
    NSMutableDictionary *newDic = [NSMutableDictionary dictionary];
    newDic[@"grant_type"] = @"refresh_token";
    newDic[@"refresh_token"] = [self getRefreshToken];
    newDic[@"appName"] = appName;
    model.reqeustType = ICXNormalReqeustTypePOST;
    model.url = Login_URL;
    model.parameters = newDic;
    model.customHeader = Basic_Authorization_Headers;
    manager.apiModel = model;
    
//    NSLog(@"开始刷新token");
    NSLog(@"开始刷新token");
    [manager loadDataWithCompletion:^(id responseObject) {
        
        
        
        NSLog(@"refreshToken succeed : %@",responseObject);
        
        //这句代码原本是不需要的，但是PR版本有新老网络请求工具，如果这里刷新了token,但是PR版本旧的那一套存储token没有刷新，就会有问题，所以这里把token传出去，需要用的可以实现该方法更新
        [[CTMediator sharedInstance] performTarget:@"ICXTokenMediator" action:@"saveToken" params:responseObject shouldCacheTarget:YES];
        //将新的token存储起来
        ICXAuthModel *authModel = [ICXAuthModel modelWithDictionary:responseObject];
        authModel.create_time = [NSDate date];
        [ICXDataSaveManager saveModel:authModel path:ICX_Token_Save_Path];
        
        
        for (authReturnBlock oldBlock in cacheManager.blockArray) {
            if (oldBlock) {
                oldBlock(nil,authModel.access_token,nil,YES);
            }
        }
        if (cacheManager.blockArray.count) {
            [cacheManager.blockArray removeAllObjects];
        }
        cacheManager.isRefreshingToken = NO;

        //发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:ICXToken_Refresh_Succeed_Notification object:nil];
        
    } failed:^(NSURLResponse *response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        cacheManager.lastRefreshTokenTime = 0;
        cacheManager.isRefreshingToken = NO;

        NSLog(@"refreshToken failed : %@",error);
        
        NSString *des = [NSString stringWithFormat:@"旧的token:%@\n旧的refreshToken:%@",[ICXAuthManager getToken],[ICXAuthManager getRefreshToken]];
        NSData *data = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        
        
        //可能是网络等原因导致的刷新失败，这个没必要跳到登录，可能下次网络好了就自己刷新成功了
        if (data.length > 0) {
            id errorBody = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if ([errorBody isKindOfClass:[NSDictionary class]] && [errorBody[@"error"] isEqualToString:@"invalid_grant"]) {
                NSLog(@"刷新token失败:\n【%@】\n【%@】\n说明refreshToken不能用，跳转登录页", des,errorBody);
                [[CTMediator sharedInstance] performTarget:@"ICXLoginMediator" action:@"jumpToLoginVC" params:nil shouldCacheTarget:YES];
            }
        }
        
        for (authReturnBlock oldBlock in cacheManager.blockArray) {
            if (oldBlock) {
                oldBlock(response,responseObject,error,NO);
            }
        }
        if (cacheManager.blockArray.count) {
            [cacheManager.blockArray removeAllObjects];
        }
        
    }];
    
    
    
    
}


+ (BOOL)isTokenValid
{
    ICXAuthModel *model = [ICXDataSaveManager getModelWithPath:ICX_Token_Save_Path];
    if (fabs([model.create_time timeIntervalSinceNow]) >= [model.expires_in longValue]) {
        //说明token过期，需要刷新token
        return NO;
    }
    return YES;
}


+ (BOOL)isRefreshTokenValid
{
    ICXAuthModel *model = [ICXDataSaveManager getModelWithPath:ICX_Token_Save_Path];
    if (fabs([model.create_time timeIntervalSinceNow]) >= 3600 * 24 * 30) {
        //说明refreshToken过期，需要重新登录
        return NO;
    }
    return YES;
}


+ (NSString *)getUserAgent
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // 当前应用软件版本 ----- 比如：1.0.1
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *appName = [infoDictionary objectForKey:@"ICXAppName"];
    NSString *CFBundleSupportedPlatforms = [infoDictionary objectForKey:@"DTPlatformName"];
    NSString *DTPlatformVersion = [infoDictionary objectForKey:@"DTPlatformVersion"];
    NSString *phoneModel = [self iphoneType];
    NSString *simpleModel = [[UIDevice currentDevice] model];
    NSString *userAgent = [NSString stringWithFormat:@"%@/%@ %@/%@ %@ %@",appName,appCurVersion,CFBundleSupportedPlatforms,DTPlatformVersion,phoneModel,[simpleModel isEqualToString:@"iPhone"]?@"Mobile":@""];
    
    return userAgent;
}


+ (NSString *)getBasicAuthorization
{
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // 当前应用软件版本 ----- 比如：1.0.1
    NSString *appID = [infoDictionary objectForKey:@"ICXAppID"];
    NSString *appSecret = [infoDictionary objectForKey:@"ICXSecret"];
    //先将string转换成data
    NSString *needEncodeStr = [NSString stringWithFormat:@"%@:%@",appID,appSecret];
    NSData *data = [needEncodeStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *base64Data = [data base64EncodedDataWithOptions:0];
    
    NSString *baseString = [[NSString alloc]initWithData:base64Data encoding:NSUTF8StringEncoding];
    
    return [NSString stringWithFormat:@"Basic %@",baseString];
}




+ (NSString*)iphoneType {
    
    //需要导入头文件：#import <sys/utsname.h>
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString*platform = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if([platform isEqualToString:@"iPhone1,1"])  return@"iPhone/2G";
    
    if([platform isEqualToString:@"iPhone1,2"])  return@"iPhone/3G";
    
    if([platform isEqualToString:@"iPhone2,1"])  return@"iPhone/3GS";
    
    if([platform isEqualToString:@"iPhone3,1"])  return@"iPhone/4";
    
    if([platform isEqualToString:@"iPhone3,2"])  return@"iPhone/4";
    
    if([platform isEqualToString:@"iPhone3,3"])  return@"iPhone/4";
    
    if([platform isEqualToString:@"iPhone4,1"])  return@"iPhone/4S";
    
    if([platform isEqualToString:@"iPhone5,1"])  return@"iPhone/5";
    
    if([platform isEqualToString:@"iPhone5,2"])  return@"iPhone/5";
    
    if([platform isEqualToString:@"iPhone5,3"])  return@"iPhone/5c";
    
    if([platform isEqualToString:@"iPhone5,4"])  return@"iPhone/5c";
    
    if([platform isEqualToString:@"iPhone6,1"])  return@"iPhone/5s";
    
    if([platform isEqualToString:@"iPhone6,2"])  return@"iPhone/5s";
    
    if([platform isEqualToString:@"iPhone7,1"])  return@"iPhone/6 Plus";
    
    if([platform isEqualToString:@"iPhone7,2"])  return@"iPhone/6";
    
    if([platform isEqualToString:@"iPhone8,1"])  return@"iPhone/6s";
    
    if([platform isEqualToString:@"iPhone8,2"])  return@"iPhone/6s Plus";
    
    if([platform isEqualToString:@"iPhone8,4"])  return@"iPhone/SE";
    
    if([platform isEqualToString:@"iPhone9,1"])  return@"iPhone/7";
    
    if([platform isEqualToString:@"iPhone9,3"])  return@"iPhone/7";
    
    if([platform isEqualToString:@"iPhone9,2"])  return@"iPhone/7 Plus";
    
    if([platform isEqualToString:@"iPhone9,4"])  return@"iPhone/7 Plus";
    
    if([platform isEqualToString:@"iPhone10,1"]) return@"iPhone/8";
    
    if([platform isEqualToString:@"iPhone10,4"]) return@"iPhone/8";
    
    if([platform isEqualToString:@"iPhone10,2"]) return@"iPhone/8 Plus";
    
    if([platform isEqualToString:@"iPhone10,5"]) return@"iPhone/8 Plus";
    
    if([platform isEqualToString:@"iPhone10,3"]) return@"iPhone/X";
    
    if([platform isEqualToString:@"iPhone10,6"]) return@"iPhone/X";
    
    if([platform isEqualToString:@"iPhone11,2"])  return@"iPhone/XS";
    
    if([platform isEqualToString:@"iPhone11,4"] || [platform isEqualToString:@"iPhone11,6"])  return@"iPhone/XSMax";

    if([platform isEqualToString:@"iPhone11,8"])  return@"iPhone/XR";
    
    //iPod
    if([platform isEqualToString:@"iPod1,1"])  return@"iPod/Touch 1G";
    
    if([platform isEqualToString:@"iPod2,1"])  return@"iPod/Touch 2G";
    
    if([platform isEqualToString:@"iPod3,1"])  return@"iPod/Touch 3G";
    
    if([platform isEqualToString:@"iPod4,1"])  return@"iPod/Touch 4G";
    
    if([platform isEqualToString:@"iPod5,1"])  return@"iPod/Touch 5G";
    
    //iPad
    if([platform isEqualToString:@"iPad1,1"])  return@"iPad/1G";
    
    if([platform isEqualToString:@"iPad2,1"])  return@"iPad/2";
    
    if([platform isEqualToString:@"iPad2,2"])  return@"iPad/2";
    
    if([platform isEqualToString:@"iPad2,3"])  return@"iPad/2";
    
    if([platform isEqualToString:@"iPad2,4"])  return@"iPad/2";
    
    if([platform isEqualToString:@"iPad2,5"])  return@"iPad/Mini 1G";
    
    if([platform isEqualToString:@"iPad2,6"])  return@"iPad/Mini 1G";
    
    if([platform isEqualToString:@"iPad2,7"])  return@"iPad/Mini 1G";
    
    if([platform isEqualToString:@"iPad3,1"])  return@"iPad/3";
    
    if([platform isEqualToString:@"iPad3,2"])  return@"iPad/3";
    
    if([platform isEqualToString:@"iPad3,3"])  return@"iPad/3";
    
    if([platform isEqualToString:@"iPad3,4"])  return@"iPad/4";
    
    if([platform isEqualToString:@"iPad3,5"])  return@"iPad/4";
    
    if([platform isEqualToString:@"iPad3,6"])  return@"iPad/4";
    
    if([platform isEqualToString:@"iPad4,1"])  return@"iPad/Air";
    
    if([platform isEqualToString:@"iPad4,2"])  return@"iPad/Air";
    
    if([platform isEqualToString:@"iPad4,3"])  return@"iPad/Air";
    
    if([platform isEqualToString:@"iPad4,4"])  return@"iPad/Mini 2G";
    
    if([platform isEqualToString:@"iPad4,5"])  return@"iPad/Mini 2G";
    
    if([platform isEqualToString:@"iPad4,6"])  return@"iPad/Mini 2G";
    
    if([platform isEqualToString:@"iPad4,7"])  return@"iPad/Mini 3";
    
    if([platform isEqualToString:@"iPad4,8"])  return@"iPad/Mini 3";
    
    if([platform isEqualToString:@"iPad4,9"])  return@"iPad/Mini 3";
    
    if([platform isEqualToString:@"iPad5,1"])  return@"iPad/Mini 4";
    
    if([platform isEqualToString:@"iPad5,2"])  return@"iPad/Mini 4";
    
    if([platform isEqualToString:@"iPad5,3"])  return@"iPad/Air 2";
    
    if([platform isEqualToString:@"iPad5,4"])  return@"iPad/Air 2";
    
    if([platform isEqualToString:@"iPad6,3"])  return@"iPad/Pro 9.7";
    
    if([platform isEqualToString:@"iPad6,4"])  return@"iPad/Pro 9.7";
    
    if([platform isEqualToString:@"iPad6,7"])  return@"iPad/Pro 12.9";
    
    if([platform isEqualToString:@"iPad6,8"])  return@"iPad/Pro 12.9";
    
    if([platform isEqualToString:@"i386"])  return@"iPhone/Simulator";
    
    if([platform isEqualToString:@"x86_64"])  return@"iPhone/Simulator";
    
    if ([platform rangeOfString:@","].location != NSNotFound) {
        platform = [platform stringByReplacingOccurrencesOfString:@"," withString:@"/"];
    }
    
    return platform;
    
}







@end

