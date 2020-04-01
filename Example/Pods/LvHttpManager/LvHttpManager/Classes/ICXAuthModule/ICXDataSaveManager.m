//
//  ICXDataSaveManager.m
//  LvHttpManager
//
//  Created by 吕佳珍 on 2020/3/31.
//
#import "ICXDataSaveManager.h"

@implementation ICXDataSaveManager

+ (void)saveModel:(id)model path:(NSString *)path
{
    NSString *accountPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:path];
    [NSKeyedArchiver archiveRootObject:model toFile:accountPath];
}

+ (id)getModelWithPath:(NSString *)path
{
    NSString *accountPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:path];
    return [NSKeyedUnarchiver unarchiveObjectWithFile:accountPath];
}


@end
