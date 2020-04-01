//
//  ICXUploadRequest.h
//  LvHttpManager
//
//  Created by 吕佳珍 on 2020/3/31.
//

#import <Foundation/Foundation.h>
#import "ICXNetworkMarco.h"
#import "ICXCustomManagerProtocol.h"
@class ICXImageListModel;
@interface ICXUploadRequest : NSObject


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
                                  failed:(void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail;






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
                                  failed:(void(^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail;





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
                                  failed:(void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail;

@end


@interface ICXImageListModel : NSObject

@property (nonatomic,assign) BOOL isGIF; //是否是GIF图片

@property (nonatomic,strong) NSData *imageData; //GIF图片不能用UIImage来表示，用UIImage取得是GIF的第一帧图片

@property (nonatomic,strong) UIImage *image; //静态图就用这个存储啦

@property (nonatomic,strong) NSString *name; //对应AFN的name参数

@property (nonatomic,strong) NSString *fileName; //对应AFN的fileName参数

@property (nonatomic,strong) NSString *mimeType; //对应AFN的mimeType

@end
