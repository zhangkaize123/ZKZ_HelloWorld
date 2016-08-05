//
//  ZKZFmdbManager.h
//  FMDB_vision_upload
//
//  Created by 张凯泽 on 16/7/30.
//  Copyright © 2016年 rytong_zkz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
@interface ZKZFmdbManager : NSObject
//@property(nonatomic,strong)NSString *pathStr;//表格在沙盒的路径

+ (instancetype)sharedFmdbManagerWithFilePath:(NSString*)pathStr;
#pragma mark--zkz----对表进行操作
//创建表格
-(BOOL)CreateTableWith:(NSString*)sql;
//删除某一列
-(void)DeleteFormWithTableName:(NSString*)tableName SomeOneCol:(NSString*)ColName AndWithSqlite:(NSDictionary*)attributes;
//增加某一列
-(void)AddFormWithTableName:(NSString*)tableName SomeOneCol:(NSString*)ColName AndWithSqlite:(NSString*)sql;
 //更新某一列的名字（rename）
-(void)UpdataFormWithTableName:(NSString*)tableName SomeOneRowOldValue:(NSString*)oldvalue NewValue:(NSString*)newvalue AndWithSqlite:(NSDictionary*)sql;
#pragma mark---zkz----对数据进行操作
-(BOOL)InsertNumWith:(NSInteger)num DataWith:(NSString*)sql, ... NS_REQUIRES_NIL_TERMINATION;
-(NSArray*)CheckTableWithSql:(NSString*)sql,... NS_REQUIRES_NIL_TERMINATION;
@end
