//
//  ICXAuthModel.h
//  LvHttpManager
//
//  Created by 吕佳珍 on 2020/3/31.
//

#import <Foundation/Foundation.h>

@interface ICXAuthModel : NSObject<NSCoding>

@property (nonatomic,copy) NSString *access_token;

@property (nonatomic,copy) NSString *refresh_token;

@property (nonatomic,copy) NSString *token_type;

@property (nonatomic,strong) NSNumber *expires_in;

@property (nonatomic,copy) NSString *scope;

@property (nonatomic,strong) NSDate *create_time;

+ (instancetype)modelWithDictionary:(NSDictionary *)dict;

@end
