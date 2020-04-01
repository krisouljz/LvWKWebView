//
//  ICXHTTPBaseManager.m
//  LvHttpManager
//
//  Created by 吕佳珍 on 2020/3/31.
//

#import "ICXHTTPBaseManager.h"
#import "ICXHTTPKit.h"
#import "ICXAuthModule.h"

@interface ICXHTTPBaseManager()
@property(strong,nonatomic) ICXRequest *apiRequest;
@property (nonatomic,strong) NSNumber *requestId;
@end

@implementation ICXHTTPBaseManager
#pragma mark - init methods

- (instancetype)init
{
    self = [super init];
    if (self) {
        //初始化的时候,让该类等于childManager,完成请求参数的传递
        if ([self conformsToProtocol:@protocol(ICXHTTPBaseManagerProtocol)]) {
            self.childManager = (ICXHTTPBaseManager<ICXHTTPBaseManagerProtocol> *)self;
        }
    }
    return self;
}
#pragma mark - system delegate

#pragma mark - custom delegate

#pragma mark - api methods
- (void)loadDataWithCompletion:(void (^)(id))completion
                        failed:(void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail{
    switch (self.childManager.requestType) {
        case ICXNormalReqeustTypeGET:
        {
            self.requestId = [ICXRequest requestByGetWithURL:self.childManager.requestURL params:[self networkInfo] success:completion failed:fail];
        }
            break;
        case ICXNormalReqeustTypePOST:
        {
            self.requestId = [ICXRequest requestByPostWithURL:self.childManager.requestURL params:[self networkInfo] success:completion failed:fail];
        }
            break;
        case ICXNormalReqeustTypePUT:
        {
            self.requestId = [ICXRequest requestByPutWithURL:self.childManager.requestURL params:[self networkInfo] success:completion failed:fail];
        }
            break;
        case ICXNormalReqeustTypeDELETE:
        {
            self.requestId = [ICXRequest requestByDeleteWithURL:self.childManager.requestURL params:[self networkInfo] success:completion failed:fail];
        }
            break;
    }
}








/**
 批量上传静态图片
 
 @param images 包含UIImage的图片数组
 @param progress 上传进度
 @param completion 上传成功的回调
 @param fail 上传失败的回调
 */
- (void)uploadImageWithImages:(NSArray<UIImage *> *)images
                     progress:(void(^)(NSProgress *uploadProgress))progress
                   completion:(void(^)(id responseObject))completion
                       failed:(void(^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail {
    self.requestId = [ICXRequest uploadImagesWithURLMethod:self.childManager.requestURL
                                                    images:images
                                                    params:[self networkInfo]
                                                  progress:progress
                                                   success:completion
                                                    failed:fail];
}











/**
 批量上传不同类型的图片，既包含静态图片又包含动态图片；如果只有静态图片请直接使用上面�的方法
 
 @param multiImages 包含ICXImageListModel模型的数组
 @param progress 上传进度
 @param completion 上传成功的回调
 @param fail 上传失败的回调
 */
- (void)uploadMultiImages:(NSArray<ICXImageListModel *> *)multiImages
                          progress:(void(^)(NSProgress *uploadProgress))progress
                        completion:(void(^)(id responseObject))completion
                            failed:(void(^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail {
    self.requestId = [ICXRequest uploadMultiImagesWithURLMethod:self.childManager.requestURL
                                               multiImages:multiImages
                                                    params:[self networkInfo]
                                                  progress:progress
                                                   success:completion
                                                    failed:fail];
}






/**
 上传文件
 
 @param data 文件的二进制流
 @param progress 上传进度
 @param completion 上传成功的回调
 @param fail 上传失败的回调
 */
- (void)uploadFileWithData:(NSData *)data
                  progress:(void(^)(NSProgress *uploadProgress))progress
                completion:(void(^)(id responseObject))completion
                    failed:(void(^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail {
    self.requestId = [ICXRequest uploadFileWithURLMethod:self.childManager.requestURL
                                                    data:data
                                                  params:[self networkInfo]
                                                progress:progress
                                                 success:completion
                                                  failed:fail];
    
}





#pragma mark - event response

#pragma mark - private

- (void)cancelTask {
    
    self.isCancel = YES;
    [self.apiRequest cancelTaskWithRequestId:self.requestId];
}
- (BOOL)childRespondsToSelector:(SEL)Selector{
    if ([self.childManager respondsToSelector:Selector]) {
        return YES;
    }
    return NO;
}

#pragma mark - getter / setter

- (NSDictionary *)networkInfo{
    
    AFHTTPSessionManager *manager = nil;
    if ([self childRespondsToSelector:@selector(customManager)]) {
        manager = self.childManager.customManager;
    }
    
    NSMutableDictionary *header = [[NSMutableDictionary alloc]init];
    if ([self childRespondsToSelector:@selector(customHeader)]) {
        header = [[NSMutableDictionary alloc]initWithDictionary:self.childManager.customHeader];
    }
    if (![[header allKeys] containsObject:@"Authorization"]) {
        [header setObject:ICX_Authrization forKey:@"Authorization"];
    }
    if (![[header allKeys] containsObject:@"User-Agent"]) {
        [header setObject:ICX_UserAgent forKey:@"User-Agent"];
    }
    
    
    NSDictionary *imageInfo = nil;
    if ([self childRespondsToSelector:@selector(imageInfo)]) {
        imageInfo = self.childManager.imageInfo;
    }
    ICXBaseFilter *filter = nil;
    if ([self childRespondsToSelector:@selector(baseFilter)]) {
        filter = self.childManager.baseFilter;
    }
    CGFloat radio = 0;
    if ([self childRespondsToSelector:@selector(radio)]) {
        radio = self.childManager.radio;
    }
    
    return @{
             ICXNetworkCustomManager : manager ? : [ICXHTTPKit httpKit].defaultManager,
             ICXNetworkCustomHeader : header ? : @{},
             ICXNetworkCustomFilter : filter ? : [ICXBaseFilter new],
             ICXNetworkCustomImageInfo : imageInfo ? :@{},
             ICXNetworkParams : self.childManager.params ? : @{},
             ICXNetworkDebugMode : @(self.debugModeOn),
             ICXNetworkImageRadio: @(radio)
             };
}

- (ICXRequest *)apiRequest{
    if (!_apiRequest) {
        _apiRequest = [ICXRequest request];
    }
    return _apiRequest;
}

@end
