//
//  ICXHTTPKit.h
//  LvHttpManager
//
//  Created by 吕佳珍 on 2020/3/31.
// 这个类只是对AFN做一个简单的封装,目的是为了将来如果需要更新网络库,那么只需要在这个类进行更改即可,更优的方式是用协议,但目前AFN很久估计都不会变

#import <Foundation/Foundation.h>
#import "ICXNetworkMarco.h"
#import "ICXNormalRequest.h"
#import "ICXUploadRequest.h"
#import "ICXCustomManagerProtocol.h"
@interface ICXHTTPKit : NSObject
//默认的manager
@property (nonatomic,strong) AFHTTPSessionManager *defaultManager;

+ (instancetype)httpKit;

/**
 Get请求

 @param URLMethod url
 @param success 成功的回调
 @param fail 失败回调
 */
+ (NSURLSessionTask *)requestByGetWithURLMethod:(NSString *)URLMethod
                                         params:(NSDictionary *)params
                                        success:(void(^)(id responseObject))success
                                         failed:(void(^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail;
/**
 Post请求
 
 @param URLMethod url
 @param success 成功的回调
 @param fail 失败回调
 */
+ (NSURLSessionTask *)requestByPostWithURLMethod:(NSString *)URLMethod
                                          params:(NSDictionary *)params
                                         success:(void(^)(id responseObject))success
                                          failed:(void(^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail;
/**
 Delete请求
 
 @param URLMethod url
 @param success 成功的回调
 @param fail 失败回调
 */
+ (NSURLSessionTask *)requestByDeleteWithURLMethod:(NSString *)URLMethod
                                            params:(NSDictionary *)params
                                           success:(void(^)(id responseObject))success
                                            failed:(void(^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail;
/**
 Put请求
 
 @param URLMethod rul
 @param success 成功的回调
 @param fail 失败回调
 */
+ (NSURLSessionTask *)requestByPutWithURLMethod:(NSString *)URLMethod
                                         params:(NSDictionary *)params
                                        success:(void(^)(id responseObject))success
                                         failed:(void(^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail;


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
                                        success:(void(^)(id responseObject))success
                                         failed:(void(^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail;



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
                                         params:(NSDictionary *)params
                                       progress:(void(^)(NSProgress *uploadProgress))progress
                                        success:(void(^)(id responseObject))success
                                         failed:(void(^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail;

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
                                       failed:(void(^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail;
@end
