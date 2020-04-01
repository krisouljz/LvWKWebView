//
//  ICXDataSaveManager.h
//  LvHttpManager
//
//  Created by 吕佳珍 on 2020/3/31.
//

#import <Foundation/Foundation.h>

@interface ICXDataSaveManager : NSObject

+ (void)saveModel:(id)model path:(NSString *)path;

+ (id)getModelWithPath:(NSString *)path;

@end
