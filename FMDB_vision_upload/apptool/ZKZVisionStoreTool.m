//
//  ZKZVisionStoreTool.m
//  FMDB_vision_upload
//
//  Created by 张凯泽 on 16/7/28.
//  Copyright © 2016年 rytong_zkz. All rights reserved.
//

#import "ZKZVisionStoreTool.h"
#define ZKZVisionFile [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:@"visionnumber.text"]
@implementation ZKZVisionStoreTool
+(BOOL)StroeVisionNumberWith:(NSString*)visionValue;
{
    return[NSKeyedArchiver archiveRootObject:visionValue toFile:ZKZVisionFile];
    
}
+(NSString*)AchieveVisionNuber
{
    return[NSKeyedUnarchiver unarchiveObjectWithFile:ZKZVisionFile];
    
}
+(void)RemoveVisionNumCompleteHandle:( void (^)(NSString * fileString, NSError *  error,BOOL isStoreSuccess))completionHandler
{
    NSError * error;
    NSFileManager * filemanager = [NSFileManager defaultManager];
    BOOL storebool = [filemanager removeItemAtPath:ZKZVisionFile error:&error];
    
    completionHandler(ZKZVisionFile,error,storebool);
    
    
}
@end
