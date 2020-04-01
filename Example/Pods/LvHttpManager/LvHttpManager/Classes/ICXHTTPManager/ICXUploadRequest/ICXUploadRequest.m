//
//  ICXUploadRequest.m
//  LvHttpManager
//
//  Created by 吕佳珍 on 2020/3/31.
//

#import "ICXUploadRequest.h"
#import "ICXHTTPErrorManager.h"
#import "NSObject+RefreshToken.h"
#import "ICXRequestCache.h"


@implementation ICXUploadRequest




/**
 批量上传静态图片
 
 @param manager AFHTTPSessionManager
 @param images 包含UIImage的图片数组
 @param URLMethod 上传地址
 @param params 上传参数
 @param progress 上传进度
 @param success 上传成功的回调
 @param fail 上传失败的回调
 @return NSURLSessionTask
 */
+ (NSURLSessionTask *)requestWithManager:(AFHTTPSessionManager *)manager
                                  images:(NSArray<UIImage *> *)images
                                     URL:(NSString *)URLMethod
                                  params:(NSDictionary *)params
                                progress:(void(^)(NSProgress *uploadProgress))progress
                                 success:(void (^)(id))success
                                  failed:(void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail {
    
    AFHTTPSessionManager *customManager = params[ICXNetworkCustomManager];
    //自定义的manager
    if (customManager) {
        manager = customManager;
    }
    
    NSDictionary *imageInfo = params[ICXNetworkCustomImageInfo];
    if ([imageInfo allKeys].count == 0) {
        ALog(@"null image info")
        return nil;
    }
    
    NSDictionary *header = params[ICXNetworkCustomHeader];
    //自定义header
    if (header && [header allKeys].count != 0) {
        [header enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [manager.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
    
    // 加入x-im-appkey
    if ([URLMethod rangeOfString:@"eim.icarbonx.com"].location != NSNotFound) {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *key = [infoDictionary objectForKey:@"EIMAppKey"];
        if (key.length > 0) {
            [manager.requestSerializer setValue:key forHTTPHeaderField:@"x-im-appkey"];
        }
    }
    
    
    //是否需要debug打印
    __block BOOL debugMode = [params[ICXNetworkDebugMode] boolValue];
    
    //图片压缩率
    __block CGFloat radio = [params[ICXNetworkImageRadio] floatValue];
    
    id param = params[ICXNetworkParams];
    
    typeof(self) __weak weakSelf = self;
    
    return [manager POST:URLMethod parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSData *imageData = nil;
            if (![imageInfo[FileType] hasSuffix:@"gif"]) {
                imageData = UIImageJPEGRepresentation(obj, (radio <= 0 || radio > 1) ? 1 : radio);
            }
            
            [formData appendPartWithFileData:imageData name:imageInfo[FileName] fileName:imageInfo[FileType] mimeType:imageInfo[MimeType]];
        }];
    } progress:^(NSProgress *uploadProgress){
        progress ? progress(uploadProgress) : nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if ([weakSelf responseObjectIsInValid:responseObject]) {
            [weakSelf loginExpiredDealWithSuccess:^(id response) {
                //这里要更新token请求头
                
                NSMutableDictionary *mutParams = [[NSMutableDictionary alloc]initWithDictionary:params];
                NSMutableDictionary *header = [[NSMutableDictionary alloc]initWithDictionary:params[ICXNetworkCustomHeader]];
                [header setObject:ICX_Authrization forKey:@"Authorization"];
                [header setObject:ICX_UserAgent forKey:@"User-Agent"];
                [mutParams setObject:header forKey:ICXNetworkCustomHeader];
                
                
                [weakSelf requestWithManager:manager
                                      images:images
                                         URL:URLMethod
                                      params:mutParams
                                    progress:progress
                                     success:success
                                      failed:fail];
            } failed:fail];
        }
        else
        {
            success ? success(responseObject) : nil;
            if (debugMode) {
                ALog(@"success : %@",responseObject);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        if (debugMode) {
            ALog(@"fail : %@",error.description);
        }
        fail ? fail(task.response,nil,error) : nil;
    }];
}




/**
 批量上传不同类型的图片，既包含静态图片又包含动态图片；如果只有静态图片请直接使用上面�的方法
 
 @param manager AFHTTPSessionManager
 @param multiImages 包含ICXImageListModel模型的数组
 @param URLMethod 上传地址
 @param params 上传参数
 @param progress 上传进度
 @param success 上传成功的回调
 @param fail 上传失败的回调
 @return NSURLSessionTask
 */
+ (NSURLSessionTask *)requestWithManager:(AFHTTPSessionManager *)manager
                             multiImages:(NSArray<ICXImageListModel *> *)multiImages
                                     URL:(NSString *)URLMethod params:(NSDictionary *)params
                                progress:(void(^)(NSProgress *uploadProgress))progress
                                 success:(void(^)(id responseObject))success
                                  failed:(void(^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail {
    
    AFHTTPSessionManager *customManager = params[ICXNetworkCustomManager];
    //自定义的manager
    if (customManager) {
        manager = customManager;
    }
    
    NSDictionary *header = params[ICXNetworkCustomHeader];
    //自定义header
    if (header && [header allKeys].count != 0) {
        [header enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [manager.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
    
    // 加入x-im-appkey
    if ([URLMethod rangeOfString:@"eim.icarbonx.com"].location != NSNotFound) {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *key = [infoDictionary objectForKey:@"EIMAppKey"];
        if (key.length > 0) {
            [manager.requestSerializer setValue:key forHTTPHeaderField:@"x-im-appkey"];
        }
    }
    
    //是否需要debug打印
    __block BOOL debugMode = [params[ICXNetworkDebugMode] boolValue];
    
    //图片压缩率
    __block CGFloat radio = [params[ICXNetworkImageRadio] floatValue];
    
    id param = params[ICXNetworkParams];
    
    typeof(self) __weak weakSelf = self;
    
    return [manager POST:URLMethod
              parameters:param
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {

        [multiImages enumerateObjectsUsingBlock:^(ICXImageListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.isGIF) {
                [formData appendPartWithFileData:obj.imageData name:obj.name fileName:obj.fileName mimeType:obj.mimeType];
            } else {
                if (obj.imageData) {
                    [formData appendPartWithFileData:obj.imageData
                                                name:obj.name
                                            fileName:obj.fileName
                                            mimeType:obj.mimeType];
                } else if (obj.image) {
                    [formData appendPartWithFileData:UIImageJPEGRepresentation(obj.image, (radio <= 0 || radio > 1) ? 1 : radio)
                                                name:obj.name
                                            fileName:obj.fileName
                                            mimeType:obj.mimeType];
                }
            }
        }];
    } progress:^(NSProgress *uploadProgress){
        progress ? progress(uploadProgress) : nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if ([weakSelf responseObjectIsInValid:responseObject]) {
            [weakSelf loginExpiredDealWithSuccess:^(id response) {
                //这里要更新token请求头
                
                NSMutableDictionary *mutParams = [[NSMutableDictionary alloc]initWithDictionary:params];
                NSMutableDictionary *header = [[NSMutableDictionary alloc]initWithDictionary:params[ICXNetworkCustomHeader]];
                [header setObject:ICX_Authrization forKey:@"Authorization"];
                [header setObject:ICX_UserAgent forKey:@"User-Agent"];
                [mutParams setObject:header forKey:ICXNetworkCustomHeader];
                
                
                [weakSelf requestWithManager:manager
                                 multiImages:multiImages
                                         URL:URLMethod
                                      params:mutParams
                                    progress:progress
                                     success:success
                                      failed:fail];
            } failed:fail];
        }
        else
        {
            success ? success(responseObject) : nil;
            if (debugMode) {
                ALog(@"success : %@",responseObject);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        if (debugMode) {
            ALog(@"fail : %@",error.description);
        }
        fail ? fail(task.response,nil,error) : nil;
    }];
}



/**
 上传文件
 
 @param manager AFHTTPSessionManager
 @param data 文件的二进制流
 @param URLMethod 上传地址
 @param params 上传参数
 @param progress 上传进度
 @param success 上传成功的回调
 @param fail 上传失败的回调
 @return NSURLSessionTask
 */
+ (NSURLSessionTask *)requestWithManager:(AFHTTPSessionManager *)manager
                                    data:(NSData *)data
                                     URL:(NSString *)URLMethod
                                  params:(NSDictionary *)params
                                progress:(void(^)(NSProgress *uploadProgress))progress
                                 success:(void (^)(id))success
                                  failed:(void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail {
    
    AFHTTPSessionManager *customManager = params[ICXNetworkCustomManager];
    //自定义的manager
    if (customManager) {
        manager = customManager;
    }
    
    
    NSDictionary *header = params[ICXNetworkCustomHeader];
    //自定义header
    if (header && [header allKeys].count != 0) {
        [header enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [manager.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
    
    if ([URLMethod rangeOfString:@"eim.icarbonx.com"].location != NSNotFound) {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *key = [infoDictionary objectForKey:@"EIMAppKey"];
        if (key.length > 0) {
            [manager.requestSerializer setValue:key forHTTPHeaderField:@"x-im-appkey"];
        }
    }
    
    //是否需要debug打印
    __block BOOL debugMode = [params[ICXNetworkDebugMode] boolValue];
    
    id param = params[ICXNetworkParams];
    typeof(self) __weak weakSelf = self;
    
    
    return [manager POST:URLMethod parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:data name:param[FileName] fileName:param[FileType] mimeType:param[MimeType]];
    } progress:^(NSProgress *uploadProgress){
        progress ? progress(uploadProgress) : nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if ([weakSelf responseObjectIsInValid:responseObject]) {
            [weakSelf loginExpiredDealWithSuccess:^(id response) {
                
                //这里要更新token请求头
                
                NSMutableDictionary *mutParams = [[NSMutableDictionary alloc]initWithDictionary:params];
                NSMutableDictionary *header = [[NSMutableDictionary alloc]initWithDictionary:params[ICXNetworkCustomHeader]];
                [header setObject:ICX_Authrization forKey:@"Authorization"];
                [header setObject:ICX_UserAgent forKey:@"User-Agent"];
                [mutParams setObject:header forKey:ICXNetworkCustomHeader];
                
                [weakSelf requestWithManager:manager data:data URL:URLMethod params:mutParams progress:progress success:success failed:fail];
                
            } failed:fail];
        }
        else
        {
            success ? success(responseObject) : nil;
            if (debugMode) {
                ALog(@"success : %@",responseObject);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        if (debugMode) {
            ALog(@"fail : %@",error.description);
        }
        fail ? fail(task.response,nil,error) : nil;
    }];
}




@end

@implementation ICXImageListModel

@end
