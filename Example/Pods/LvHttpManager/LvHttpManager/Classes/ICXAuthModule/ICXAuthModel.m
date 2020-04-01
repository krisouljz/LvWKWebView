//
//  ICXAuthModel.m
//  LvHttpManager
//
//  Created by 吕佳珍 on 2020/3/31.
//

#import "ICXAuthModel.h"

@implementation ICXAuthModel

- (instancetype)initWithDictionary:(NSDictionary *)dict

{
    if (self = [super init]) {
        
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

+ (instancetype)modelWithDictionary:(NSDictionary *)dict

{
    return [[self alloc] initWithDictionary:dict];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.access_token = [aDecoder decodeObjectForKey:@"access_token"];
        self.expires_in = [aDecoder decodeObjectForKey:@"expires_in"];
        self.create_time = [aDecoder decodeObjectForKey:@"created_time"];
        self.refresh_token = [aDecoder decodeObjectForKey:@"refresh_token"];
        self.token_type = [aDecoder decodeObjectForKey:@"token_type"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.access_token forKey:@"access_token"];
    [aCoder encodeObject:self.expires_in forKey:@"expires_in"];
    [aCoder encodeObject:self.create_time forKey:@"created_time"];
    [aCoder encodeObject:self.refresh_token forKey:@"refresh_token"];
    [aCoder encodeObject:self.token_type forKey:@"token_type"];
}

- (NSString *)description {
    return [NSString stringWithFormat:@" access_token = %@\n refresh_token = %@\n",
            self.access_token,self.refresh_token];
}






@end
