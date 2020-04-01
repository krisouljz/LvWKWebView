//
//  ICXHTTPBaseManager.h
//  LvHttpManager
//
//  Created by 吕佳珍 on 2020/3/31.
//

#import <Foundation/Foundation.h>
#import "ICXNetworkMarco.h"
#import "ICXBaseFilter.h"
#import "ICXCustomManagerProtocol.h"
#import "ICXRequest.h"


@protocol ICXHTTPBaseManagerProtocol <NSObject>
//请求方式
- (ICXNormalReqeustType)requestType;
//请求的参数
- (id _Nullable )params;
//请求的url
- (NSString *_Nullable)requestURL;
@optional
//custom header
- (NSDictionary *_Nullable)customHeader;
//custom manager
- (AFHTTPSessionManager *_Nullable)customManager;
//过滤装置
- (ICXBaseFilter *_Nullable)baseFilter;
//imageInfo
- (NSDictionary *_Nullable)imageInfo;
//图片压缩率
- (CGFloat)radio;
@end

@interface ICXHTTPBaseManager : NSObject
//遵守协议的子类,须遵守ICXHTTPBaseManagerProtocol协议
@property (nonatomic , weak) ICXHTTPBaseManager<ICXHTTPBaseManagerProtocol> * _Nullable childManager;
//外部传入的参数
@property (strong,nonatomic) NSMutableDictionary * _Nullable outerParams;
//整合自定义的参数
@property(strong,nonatomic) NSDictionary * _Nullable networkInfo;

//是否需要打印回调结果
@property(assign,nonatomic) BOOL debugModeOn;

@property (assign,nonatomic) BOOL isCancel;

/**
 * 加载数据
 */
- (void)loadDataWithCompletion:(void(^_Nullable)(id _Nullable responseObject))completion
                        failed:(void(^_Nullable)(NSURLResponse * _Nullable response, id _Nullable responseObject,  NSError * _Nullable error))fail;





/**
 批量上传静态图片

 @param images 包含UIImage的图片数组
 @param progress 上传进度
 @param completion 上传成功的回调
 @param fail 上传失败的回调
 */
- (void)uploadImageWithImages:(NSArray<UIImage *> *_Nullable)images
                     progress:(void(^_Nullable)(NSProgress * _Nullable uploadProgress))progress
                   completion:(void(^_Nullable)(id _Nullable responseObject))completion
                       failed:(void(^_Nullable)(NSURLResponse * _Nullable response, id _Nullable responseObject,  NSError * _Nullable error))fail;



/**
 批量上传不同类型的图片，既包含静态图片又包含动态图片；如果只有静态图片请直接使用上面�的方法

 @param multiImages 包含ICXImageListModel模型的数组
 @param progress 上传进度
 @param completion 上传成功的回调
 @param fail 上传失败的回调
 */
- (void)uploadMultiImages:(NSArray<ICXImageListModel *> *_Nullable)multiImages
                 progress:(void(^_Nullable)(NSProgress * _Nullable uploadProgress))progress
               completion:(void(^_Nullable)(id _Nullable responseObject))completion
                   failed:(void(^_Nullable)(NSURLResponse * _Nullable response, id _Nullable responseObject,  NSError * _Nullable error))fail;


/**
 上传文件

 @param data 文件的二进制流
 @param progress 上传进度
 @param completion 上传成功的回调
 @param fail 上传失败的回调
 */
- (void)uploadFileWithData:(NSData *_Nullable)data
                  progress:(void(^_Nullable)(NSProgress * _Nullable uploadProgress))progress
                completion:(void(^_Nullable)(id _Nullable responseObject))completion
                    failed:(void(^_Nullable)(NSURLResponse * _Nullable response, id _Nullable responseObject,  NSError * _Nullable error))fail;

- (void)cancelTask;




@end
