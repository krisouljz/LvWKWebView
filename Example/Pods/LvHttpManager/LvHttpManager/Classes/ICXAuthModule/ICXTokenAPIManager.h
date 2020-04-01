//
//  ICXTokenAPIManager.h
//  LvHttpManager
//
//  Created by 吕佳珍 on 2020/3/31.
//

#import "ICXHTTPBaseManager.h"
#import "ICXTokenAPIModel.h"

@interface ICXTokenAPIManager : ICXHTTPBaseManager<ICXHTTPBaseManagerProtocol>

@property (nonatomic,strong) ICXTokenAPIModel *apiModel;

@end
