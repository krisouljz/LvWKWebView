//
//  ICXHTTPKit.m
//  LvHttpManager
//
//  Created by 吕佳珍 on 2020/3/31.
//

#import "ICXHTTPKit.h"

@implementation ICXHTTPKit

+ (instancetype)httpKit{
    static ICXHTTPKit *http = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        http = [[self alloc] init];
    });
    return http;
}

+ (NSURLSessionTask *)requestByGetWithURLMethod:(NSString *)URLMethod
                                         params:(NSDictionary *)params
                                        success:(void(^)(id responseObject))success
                                         failed:(void(^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail {
    
    AFHTTPSessionManager *manager =  [[ICXHTTPKit httpKit] defaultManager];
    return [ICXNormalRequest requestWithType:ICXNormalReqeustTypeGET manager:manager URL:URLMethod params:params success:success failed:fail];
}

+ (NSURLSessionTask *)requestByPostWithURLMethod:(NSString *)URLMethod
                                          params:(NSDictionary *)params
                                         success:(void (^)(id))success
                                          failed:(void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail {
    
    AFHTTPSessionManager *manager =  [[ICXHTTPKit httpKit] defaultManager];
    return [ICXNormalRequest requestWithType:ICXNormalReqeustTypePOST manager:manager URL:URLMethod params:params success:success failed:fail];
}

+ (NSURLSessionTask *)requestByPutWithURLMethod:(NSString *)URLMethod
                                         params:(NSDictionary *)params
                                        success:(void (^)(id))success
                                         failed:(void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail {
    
    AFHTTPSessionManager *manager =  [[ICXHTTPKit httpKit] defaultManager];
    return [ICXNormalRequest requestWithType:ICXNormalReqeustTypePUT manager:manager URL:URLMethod params:params success:success failed:fail];
}

+ (NSURLSessionTask *)requestByDeleteWithURLMethod:(NSString *)URLMethod
                                            params:(NSDictionary *)params
                                           success:(void (^)(id))success
                                            failed:(void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail {
    
    AFHTTPSessionManager *manager =  [[ICXHTTPKit httpKit] defaultManager];
    return [ICXNormalRequest requestWithType:ICXNormalReqeustTypeDELETE manager:manager URL:URLMethod params:params success:success failed:fail];
}


/**
 批量上传静态图片
 
 @param URLMethod 上传地址
 @param images 包含UIImage的图片数组
 @param params 上传参数
 @param progress 上传进度
 @param success 成功回调
 @param fail 失败回调
 @return NSURLSessionTask
 */
+ (NSURLSessionTask *)uploadImagesWithURLMethod:(NSString *)URLMethod
                                         images:(NSArray<UIImage *> *)images
                                         params:(NSDictionary *)params
                                       progress:(void(^)(NSProgress *uploadProgress))progress
                                        success:(void (^)(id))success
                                         failed:(void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail
{
    
    AFHTTPSessionManager *manager =  [[ICXHTTPKit httpKit] defaultManager];
    return [ICXUploadRequest requestWithManager:manager
                                         images:images
                                            URL:URLMethod
                                         params:params
                                       progress:progress
                                        success:success
                                         failed:fail];
}


/**
 批量上传不同类型的图片，既包含静态图片又包含动态图片；如果只有静态图片请直接使用上面�的方法
 
 @param URLMethod 上传地址
 @param multiImages 包含ICXImageListModel模型的数组
 @param params 上传参数
 @param progress 上传进度
 @param success 成功回调
 @param fail 失败回调
 @return NSURLSessionTask
 */
+ (NSURLSessionTask *)uploadMultiImagesWithURLMethod:(NSString *)URLMethod
                                    multiImages:(NSArray<ICXImageListModel *> *)multiImages
                                         params:(NSDictionary *)params progress:(void(^)(NSProgress *uploadProgress))progress
                                        success:(void(^)(id responseObject))success
                                         failed:(void(^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail {
    
    AFHTTPSessionManager *manager =  [[ICXHTTPKit httpKit] defaultManager];
    return [ICXUploadRequest requestWithManager:manager
                                    multiImages:multiImages
                                            URL:URLMethod
                                         params:params
                                       progress:progress
                                        success:success
                                         failed:fail];
}

/**
 上传单个文件
 
 @param URLMethod url
 @param data 文件转化为NSdata
 @param params 参数
 @param progress 上传进度
 @param success 成功回调
 @param fail 失败回调
 @return NSURLSessionTask
 */
+ (NSURLSessionTask *)uploadFileWithURLMethod:(NSString *)URLMethod
                                         data:(NSData *)data
                                       params:(NSDictionary *)params
                                     progress:(void(^)(NSProgress *uploadProgress))progress
                                      success:(void(^)(id responseObject))success
                                       failed:(void(^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail {
    
    AFHTTPSessionManager *manager =  [[ICXHTTPKit httpKit] defaultManager];
    return [ICXUploadRequest requestWithManager:manager
                                           data:data
                                            URL:URLMethod
                                         params:params
                                       progress:progress
                                        success:success
                                         failed:fail];
}




#pragma mark - prviate

#pragma mark - getter

- (AFHTTPSessionManager *)defaultManager{
    if (!_defaultManager) {
        _defaultManager = [AFHTTPSessionManager manager];
        _defaultManager.responseSerializer = [AFJSONResponseSerializer serializer];
        _defaultManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"application/json", nil];
        _defaultManager.requestSerializer.timeoutInterval = 60;
    }
    //ALog(@"默认的manager : %@",_defaultManager);
    return _defaultManager;
}
@end
