//
//  ICXTokenAPIManager.m
//  LvHttpManager
//
//  Created by 吕佳珍 on 2020/3/31.
//

#import "ICXTokenAPIManager.h"

@implementation ICXTokenAPIManager

- (ICXNormalReqeustType)requestType {
    return _apiModel.reqeustType;
}


- (NSString *)requestURL {
    return _apiModel.url;
}


- (NSDictionary *)params {
    return _apiModel.parameters;
}


- (ICXBaseFilter *)baseFilter {
    return _apiModel.baseFilter;
}


- (NSDictionary *)customHeader {
    return _apiModel.customHeader;
}


- (AFHTTPSessionManager *)customManager {
    return _apiModel.customManager;
}


- (NSDictionary *)imageInfo {
    return _apiModel.imageInfo;
}


- (CGFloat)radio {
    return _apiModel.radio;
}

@end
