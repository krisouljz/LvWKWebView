//
//  ICXNormalRequest.m
//  LvHttpManager
//
//  Created by 吕佳珍 on 2020/3/31.
//

#import "ICXNormalRequest.h"
#import "ICXNetworkUtil.h"
#import "ICXBaseFilter.h"
#import "ICXHTTPErrorManager.h"
#import "NSObject+RefreshToken.h"
#import "ICXAuthModule.h"
#import "ICXRequestCache.h"
#import <pthread/pthread.h>

static pthread_mutex_t theLock;
@implementation ICXNormalRequest


+ (NSURLSessionTask *)requestWithType:(ICXNormalReqeustType)type
                              manager:(AFHTTPSessionManager *)manager
                                  URL:(NSString *)URLMethod params:(NSDictionary *)params
                              success:(void (^)(id))success
                               failed:(void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail{
    
    pthread_mutex_init(&theLock, NULL);
    
    AFHTTPSessionManager *customManager = params[ICXNetworkCustomManager];
    //自定义的manager
    if (customManager) {
        manager = customManager;
    }
    
    //自定义header
    NSDictionary *header = params[ICXNetworkCustomHeader];
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
    
    //是否需要过滤
    __block ICXBaseFilter *filter = params[ICXNetworkCustomFilter] ? params[ICXNetworkCustomFilter] : @"";
    
    //请求参数
    id param = params[ICXNetworkParams];
    NSError *error = nil;
    
    //请求类型
    NSString *method = [ICXNetworkUtil requestMethod:type];
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:method URLString:URLMethod parameters:param error:&error];
    
    //存放取消掉的请求，在刷新token成功以后再对这些取消的请求进行重新发起
    NSMutableDictionary *taskQueue = [[NSMutableDictionary alloc]init];
    NSDictionary *oneRequest = @{
                                 @"manager":manager,
                                 @"debugMode":@(debugMode),
                                 @"request":request,
                                 @"filter":filter,
                                 @"success":[success copy],
                                 @"fail":[fail copy],
                                 };
    NSMutableDictionary *allTaskQueue = [ICXRequestCache shareInstance].allTaskQueue;
    pthread_mutex_lock(&theLock);
    [allTaskQueue setObject:oneRequest forKey:request.URL];
    pthread_mutex_unlock(&theLock);
    
    
    typeof(self) __weak weakSelf = self;
    NSURLSessionTask *dataTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if ([weakSelf responseObjectIsInValid:responseObject] ) {
            NSLog(@"request.URL 1 = %@",request.URL);
            
            //取消网络请求
            [manager.session getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
                
                NSLog(@"request.URL 2 = %@",request.URL);

                for (NSURLSessionTask *task in dataTasks) {
                    if ([[task.currentRequest.URL absoluteString] rangeOfString:@"oauth2/token"].location != NSNotFound) {
                        continue;
                    }
                    [taskQueue setObject:[task.currentRequest mutableCopy] forKey:task.currentRequest.URL];
                    [task cancel];
                }
                
                [taskQueue setObject:[request mutableCopy] forKey:request.URL];
                
                //去刷新token
                [weakSelf loginExpiredDealWithSuccess:^(id response) {
                    [weakSelf reRequestCanceledTask:allTaskQueue canceledQueue:taskQueue];
                } failed:fail];
                
            }];
        }
        else
        {
            [weakSelf dealResponseObject:response responseObject:responseObject error:error debugMode:debugMode filter:filter success:success failed:fail];
        }
    }];
    [dataTask resume];
    return dataTask;
}


+ (void)reRequestCanceledTask:(NSMutableDictionary *)allTaskQueue canceledQueue:(NSMutableDictionary *)taskQueue {
    
    NSLog(@"reRequestCanceledTask = %@",taskQueue);

    typeof(self) __weak weakSelf = self;

    //刷新成功以后重新对取消的网络请求进行再次发起
    __block NSInteger i = 0;
    for (NSMutableURLRequest *cancelRequest in [taskQueue allValues]) {
        if (!cancelRequest.URL) {
            continue;
        }
        //设置新的请求头
        [cancelRequest setValue:ICX_Authrization forHTTPHeaderField:@"Authorization"];
        [cancelRequest setValue:ICX_UserAgent forHTTPHeaderField:@"User-Agent"];
        
        NSDictionary *oneRequest = allTaskQueue[cancelRequest.URL];
        ICXBaseFilter *filterNew = oneRequest[@"filter"];
        void (^successBlock)(id) = oneRequest[@"success"];
        void (^failBlock)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error) = oneRequest[@"fail"];
        AFHTTPSessionManager *manager = oneRequest[@"manager"];
        BOOL debugMode = [oneRequest[@"debugMode"] boolValue];
        
        NSURLSessionTask *newTask = [manager dataTaskWithRequest:cancelRequest uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            NSLog(@"重新请求URL:%@ 返回结果:%@",cancelRequest.URL,responseObject);
            i ++;
            if (i == [taskQueue count] && response.URL) {
                pthread_mutex_lock(&theLock);
                [allTaskQueue removeAllObjects];
                pthread_mutex_unlock(&theLock);
            }
            [weakSelf dealResponseObject:response responseObject:responseObject error:error debugMode:debugMode filter:filterNew success:successBlock failed:failBlock];
        }];
        [newTask resume];
    }
}




+ (void)dealResponseObject:(NSURLResponse * _Nonnull)response responseObject:(id  _Nullable )responseObject error:(NSError * _Nullable) error  debugMode:(BOOL)debugMode filter:(ICXBaseFilter *)filter success:(void (^)(id))success failed:(void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))fail
{
    
//    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
//    NSDictionary *responseHeaders = responseH.allHeaderFields;
//    NSLog(@"%ld",(long)[httpResponse statusCode]);
//
//    NSLog(@"responseHeaders fail = %@",responseHeaders);
    
    
    if (error) {
        fail ? fail(response,responseObject,error) : nil;
        if (debugMode) {
            ALog(@"fail : %@",error.description);
        }
    } else{
        if (filter) {
            if ([filter respondsToSelector:@selector(filterData:)]) {
                success ? success([filter filterData:responseObject]) : nil;
            }else if ([filter respondsToSelector:@selector(filterData:modelClass:)]) {
                success ? success([filter filterData:responseObject modelClass:filter.modleClass]) : nil;
            }else{
                success ? success(responseObject) : nil;
            }
        }else{
            success ? success(responseObject) : nil;
        }
        if (debugMode) {
            ALog(@"success : %@",responseObject);
        }
    }
}




@end

