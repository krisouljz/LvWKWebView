//
//  ICXRequest.h
//  LvHttpManager
//
//  Created by 吕佳珍 on 2020/3/31.
//
//  这个类是对ICXHTTPKit的再封装,在这里可以对数据进行处理

#import <UIKit/UIKit.h>
#import "ICXNetworkMarco.h"
#import "ICXHTTPKit.h"

@interface ICXRequest : NSObject
//存放所有进行的任务,什么时候清空?
@property (nonatomic,strong) NSMutableDictionary *allTasks;
+ (instancetype)request;
/**
 Get请求
 
 @param URL url
 @param success 成功的回调
 @param fail 失败回调
 */
+ (NSNumber *)requestByGetWithURL:(NSString *)URL
                           params:(NSDictionary *)params
                          success:(void(^)(id responseObject))success
                           failed:(void(^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail;
/**
 Post请求
 
 @param URL url
 @param success 成功的回调
 @param fail 失败回调
 */
+ (NSNumber *)requestByPostWithURL:(NSString *)URL
                            params:(NSDictionary *)params
                           success:(void(^)(id responseObject))success
                            failed:(void(^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail;
/**
 Delete请求
 
 @param URL url
 @param success 成功的回调
 @param fail 失败回调
 */
+ (NSNumber *)requestByDeleteWithURL:(NSString *)URL
                              params:(NSDictionary *)params
                             success:(void(^)(id responseObject))success
                              failed:(void(^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail;
/**
 Put请求
 
 @param URL url
 @param success 成功的回调
 @param fail 失败回调
 */
+ (NSNumber *)requestByPutWithURL:(NSString *)URL
                           params:(NSDictionary *)params
                          success:(void(^)(id responseObject))success
                           failed:(void(^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail;


/**
 批量上传静态图片

 @param URL 上传地址
 @param images 包含UIImage的图片数组
 @param params 上传参数
 @param progress 上传进度
 @param success 上传成功的回调
 @param fail 上传失败的回调
 @return requestID
 */
+ (NSNumber *)uploadImagesWithURLMethod:(NSString *)URL
                                 images:(NSArray<UIImage *> *)images
                                 params:(NSDictionary *)params
                               progress:(void(^)(NSProgress *uploadProgress))progress
                                success:(void(^)(id responseObject))success
                                 failed:(void(^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail;



/**
 批量上传不同类型的图片，既包含静态图片又包含动态图片；如果只有静态图片请直接使用上面�的方法

 @param URL 上传地址
 @param multiImages 包含ICXImageListModel模型的数组
 @param params 上传参数
 @param progress 上传进度
 @param success 上传成功的回调
 @param fail 上传失败的回调
 @return requestID
 */
+ (NSNumber *)uploadMultiImagesWithURLMethod:(NSString *)URL
                                 multiImages:(NSArray<ICXImageListModel *> *)multiImages
                                 params:(NSDictionary *)params
                               progress:(void(^)(NSProgress *uploadProgress))progress
                                success:(void(^)(id responseObject))success
                                 failed:(void(^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail;




/**
 上传文件

 @param URL 上传地址
 @param data 文件的二进制流
 @param params 上传参数
 @param progress 上传进度
 @param success 上传成功的回调
 @param fail 上传失败的回调
 @return requestID
 */
+ (NSNumber *)uploadFileWithURLMethod:(NSString *)URL
                                 data:(NSData *)data
                               params:(NSDictionary *)params
                             progress:(void(^)(NSProgress *uploadProgress))progress
                              success:(void (^)(id))success
                               failed:(void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail;

/**
 结束所有请求任务
 */
- (void)cancelAllTasks;

/**
 根据id取消某个任务

 @param requestId 任务id
 */
- (void)cancelTaskWithRequestId:(NSNumber *)requestId;

@end
