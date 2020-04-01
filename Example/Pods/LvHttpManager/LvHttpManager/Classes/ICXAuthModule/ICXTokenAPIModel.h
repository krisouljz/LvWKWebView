//
//  ICXTokenAPIModel.h
//  LvHttpManager
//
//  Created by 吕佳珍 on 2020/3/31.
//

#import <Foundation/Foundation.h>
#import "ICXNetworkMarco.h"
#import "ICXBaseFilter.h"
#import "AFNetworking.h"


@interface ICXTokenAPIModel : NSObject

//必须赋值
@property (nonatomic,assign) ICXNormalReqeustType reqeustType;

//必须赋值
@property (nonatomic,copy) NSString *url;

//必须赋值
@property (nonatomic,strong) NSDictionary *parameters;

//可选
@property (nonatomic,strong) NSDictionary *customHeader;

//可选
@property (nonatomic,strong) AFHTTPSessionManager *customManager;

//可选
@property (nonatomic,strong) ICXBaseFilter *baseFilter;

//可选
@property (nonatomic,strong) NSDictionary *imageInfo;

//可选
@property (nonatomic,assign) CGFloat radio;

@end
