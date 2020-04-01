//
//  ICXRequest.m
//  LvHttpManager
//
//  Created by 吕佳珍 on 2020/3/31.
//

#import "ICXRequest.h"
#import "ICXAuthModule.h"
#import "ICXAuthModel.h"
#import "ICXAuthManager.h"
#import "ICXNetworkMarco.h"
#define Request(Type)\
__block NSNumber *requestId = nil;\
NSURLSessionTask *dataTask = [ICXHTTPKit requestBy##Type##WithURLMethod:URL params:params success:^(id responseObject)\
{success ? success(responseObject) : nil;\
[[ICXRequest request].allTasks removeObjectForKey:requestId];\
} failed:fail];\
requestId = @(dataTask.taskIdentifier);\
[ICXRequest request].allTasks[requestId] = dataTask;\
return requestId;
@implementation ICXRequest

+ (instancetype)request{
    static ICXRequest *req = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        req = [[self alloc] init];
    });
    return req;
}

+ (NSNumber *)requestByGetWithURL:(NSString *)URL
                           params:(NSDictionary *)params
                          success:(void (^)(id))success
                           failed:(void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail{
        Request(Get);
}
+ (NSNumber *)requestByPostWithURL:(NSString *)URL
                            params:(NSDictionary *)params
                           success:(void (^)(id))success
                            failed:(void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail{
    Request(Post);
}
+ (NSNumber *)requestByPutWithURL:(NSString *)URL
                           params:(NSDictionary *)params
                          success:(void (^)(id))success
                           failed:(void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail{
    Request(Put);
}
+ (NSNumber *)requestByDeleteWithURL:(NSString *)URL
                              params:(NSDictionary *)params
                             success:(void (^)(id))success
                              failed:(void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail{
    Request(Delete);
}




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
                                 failed:(void(^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail {
    __block NSNumber *requestId = nil;
    NSURLSessionTask *dataTask = [ICXHTTPKit uploadImagesWithURLMethod:URL
                                                                images:images
                                                                params:params
                                                              progress:^(NSProgress *uploadProgress) {
        progress ? progress(uploadProgress) : nil;
    } success:^(id responseObject) {
        success ? success(responseObject) : nil;
        [[ICXRequest request].allTasks removeObjectForKey:requestId];
    } failed:^(NSURLResponse *response, id  _Nullable responseObject, NSError * _Nullable error) {
        fail ? fail(response,responseObject,error) : nil;
    }];
    requestId = @(dataTask.taskIdentifier);
    [ICXRequest request].allTasks[requestId] = dataTask;
    return requestId;
}




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
                                 failed:(void(^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail {
    __block NSNumber *requestId = nil;
    NSURLSessionTask *dataTask = [ICXHTTPKit uploadMultiImagesWithURLMethod:URL
                                                                multiImages:multiImages
                                                                     params:params
                                                                   progress:^(NSProgress *uploadProgress) {
        progress ? progress(uploadProgress) : nil;
    } success:^(id responseObject) {
        success ? success(responseObject) : nil;
        [[ICXRequest request].allTasks removeObjectForKey:requestId];
    }failed:^(NSURLResponse *response, id  _Nullable responseObject, NSError * _Nullable error) {
        fail ? fail(response,responseObject,error) : nil;
    }];
    requestId = @(dataTask.taskIdentifier);
    [ICXRequest request].allTasks[requestId] = dataTask;
    return requestId;
}









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
                               failed:(void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail {
    __block NSNumber *requestId = nil;
    
    NSURLSessionTask *dataTask = [ICXHTTPKit uploadFileWithURLMethod:URL
                                                                data:data
                                                              params:params
                                                            progress:^(NSProgress *uploadProgress) {
        progress ? progress(uploadProgress) : nil;
    } success:^(id responseObject) {
        success ? success(responseObject) : nil;
        [[ICXRequest request].allTasks removeObjectForKey:requestId];
    } failed:^(NSURLResponse *response, id  _Nullable responseObject, NSError * _Nullable error) {
        fail ? fail(response,responseObject,error) : nil;
    }];
    
    
    
    requestId = @(dataTask.taskIdentifier);
    [ICXRequest request].allTasks[requestId] = dataTask;
    return requestId;
}









#pragma mark - private

- (void)cancelAllTasks{
    if (self.allTasks) {
        [self.allTasks enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSURLSessionTask *dataTask = obj;
            [dataTask cancel];
            ALog(@"already cancel all tasks");
        }];
    }
}
- (void)cancelTaskWithRequestId:(NSNumber *)requestId{
    if (self.allTasks[requestId]) {
        NSURLSessionTask *dataTask = self.allTasks[requestId];
        [dataTask cancel];
        ALog(@"cancel task %@",requestId);
    }
}
#pragma mark - getter

- (NSMutableDictionary *)allTasks{
    if (!_allTasks) {
        _allTasks = [[NSMutableDictionary alloc] init];
    }
    return _allTasks;
}
@end
