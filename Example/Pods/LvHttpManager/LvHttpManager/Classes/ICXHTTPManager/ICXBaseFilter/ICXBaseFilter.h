//
//  ICXBaseFilter.h
//  LvHttpManager
//
//  Created by 吕佳珍 on 2020/3/31.
//  用作数据过滤,需要新建一个filter的类,其实可以单独用协议,但是考虑方便书写,就写一个基类即可

#import <Foundation/Foundation.h>
@protocol ICXRequestFilterProtocol<NSObject>
@optional
/*
 * 自定义过滤规则
 */
- (id)filterData:(id)data;
/*
 * 传入模型进行过滤
 */
- (id)filterData:(id)data modelClass:(NSString *)modelClass;
@end

@interface ICXBaseFilter : NSObject<ICXRequestFilterProtocol>
@property(strong,nonatomic) NSString *modleClass;
@end
