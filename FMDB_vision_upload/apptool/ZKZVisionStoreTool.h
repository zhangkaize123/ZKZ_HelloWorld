//
//  ZKZVisionStoreTool.h
//  FMDB_vision_upload
//
//  Created by 张凯泽 on 16/7/28.
//  Copyright © 2016年 rytong_zkz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZKZVisionStoreTool : NSObject
+(BOOL)StroeVisionNumberWith:(NSString *)visionValue;
+(NSString *)AchieveVisionNuber;
+(void)RemoveVisionNumCompleteHandle:( void (^)(NSString * fileString, NSError *  error,BOOL isStoreSuccess))completionHandler;
@end
