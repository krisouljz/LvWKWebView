//
//  ICXHTTPErrorManager.h
//  LvHttpManager
//
//  Created by 吕佳珍 on 2020/3/31.
//

#import <Foundation/Foundation.h>

@interface ICXHTTPErrorManager : NSObject
/*
 * 这个方法用来统一处理错误码,如果说有未知的错误,则通过block抛给外界来实现具体的处理
 **/
@property(strong,nonatomic) void(^errorCodeBlock)(NSInteger errorCode);
- (instancetype)initWithError:(NSError *)error;
- (void)handleErrorMessage;
@end
