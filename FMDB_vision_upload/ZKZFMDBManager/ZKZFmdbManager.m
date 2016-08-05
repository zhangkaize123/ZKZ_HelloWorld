//
//  ZKZFmdbManager.m
//  FMDB_vision_upload
//
//  Created by 张凯泽 on 16/7/30.
//  Copyright © 2016年 rytong_zkz. All rights reserved.
//

#import "ZKZFmdbManager.h"
@interface ZKZFmdbManager()
@property(nonatomic,strong) FMDatabaseQueue *queue;//fmdb 队列
@end
@implementation ZKZFmdbManager
+ (instancetype)sharedFmdbManagerWithFilePath:(NSString*)pathStr {
    if (pathStr == nil) {
        NSLog(@"文件路径为空");
        return nil;
    }
    static ZKZFmdbManager *_sharedFmdbManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedFmdbManager = [[[self class]alloc]initWithFilePath:pathStr];
    });
    
    return _sharedFmdbManager;
}
-(instancetype)initWithFilePath:(NSString*)pathStr
{
    self = [super init];
    if (self) {
        if (pathStr) {
            _queue = [[FMDatabaseQueue alloc]initWithPath:pathStr];
        }
    }
    return self;
}
#pragma mark---zkz-----对表的列进行处理
//创建表格
-(BOOL)CreateTableWith:(NSString*)sql
{
   __block BOOL result;
    [self.queue inDatabase:^(FMDatabase *db) {
         result = [db executeUpdate:sql];
        
        if (result) {
            NSLog(@"创表成功");
            
        } else {
            NSLog(@"创表失败");
        }
        
    }];
    return result;
}

//更新表格中的某一列
-(void)UpdataFormWithTableName:(NSString*)tableName SomeOneRowOldValue:(NSString*)oldvalue NewValue:(NSString*)newvalue AndWithSqlite:(NSDictionary*)sql
{
    [self SearchFormIsExistWithTableName:tableName RequireCompareValue:oldvalue andCompleteHandle:^(NSString *key, BOOL isExist) {
        if (isExist) {//存在这个字段
            [self AddFormWithTableName:tableName SomeOneCol:newvalue AndWithSqlite:sql[@"add"]];
            //1.将字段a的内容拷贝到c
            [self.queue inDatabase:^(FMDatabase *db) {
                [db executeUpdate:sql[@"update"]];
            }];
            NSMutableDictionary * dic = [NSMutableDictionary dictionary];
            [dic setObject:sql[@"create"] forKey:@"create"];
            [dic setObject:sql[@"drop"] forKey:@"drop"];
            [dic setObject:sql[@"rename"] forKey:@"rename"];
            [self DeleteFormWithTableName:tableName SomeOneCol:oldvalue AndWithSqlite:dic];
        }else{
            NSLog(@"不存在这个字段");
        }
    }];
    
}
/**
 tableName:表格的名字
 ColName:需要增加的类
 attributes :create
 */
-(void)DeleteFormWithTableName:(NSString*)tableName SomeOneCol:(NSString*)ColName AndWithSqlite:(NSDictionary*)attributes
{
    [self SearchFormIsExistWithTableName:tableName RequireCompareValue:ColName andCompleteHandle:^(NSString *key, BOOL isExist) {
        if (isExist == NO) {
            NSLog(@"表格中不存在这个字段无法删除");
        }else{
            
            [self.queue inDatabase:^(FMDatabase *db) {
                [db executeUpdate:attributes[@"create"]];
                //1.删除原来的表格
                [db executeUpdate:attributes[@"drop"]];
                // 给临时表格重新命名为原来的名字
                [db executeUpdate:attributes[@"rename"]];
            }];
        }
    }];
}

//在表格中添加某个字段
/**
 tableName:表格的名字
 ColName:需要增加的类
 sql:在表格中增加列的sql 语句(ALTER TABLE [tablename] ADD COLUMN [addcolname] [colname type];)
 */
-(void)AddFormWithTableName:(NSString*)tableName SomeOneCol:(NSString*)ColName AndWithSqlite:(NSString*)sql
{
    if (_queue) {
        [self SearchFormIsExistWithTableName:tableName RequireCompareValue:ColName andCompleteHandle:^(NSString *key, BOOL isExist) {
            if (isExist == NO) {
                [self.queue inDatabase:^(FMDatabase *db) {
                    NSLog(@"----------%@",[NSThread currentThread]);
                    if(![db executeUpdate:sql])
                    {
                        NSLog(@"添加字段失败");
                    }
                }];
            }else{
                NSLog(@"表格中原来就有这个字段");
            }
        }];
        
    }
}

//判断表格中是否存在某个字段
-(void)SearchFormIsExistWithTableName:(NSString*)tableName RequireCompareValue:(NSString*)Value andCompleteHandle:(void (^)(NSString * key,BOOL isExist))completehandle
{
    //BOOL b = [self.db columnExists:Value inTableWithName:tableName];
    //completehandle(Value,b);
    if (_queue) {
        __block BOOL b;
        [self.queue inDatabase:^(FMDatabase *db) {
            b = [db columnExists:Value inTableWithName:tableName];
            
        }];
        completehandle(Value,b);
    }
    
    
}
#pragma mark---zkz-----对表中的数据进行处理
/**
   sql 语句:insert into t_student (name) values (:name);
 */
-(BOOL)InsertNumWith:(NSInteger)num DataWith:(NSString*)sql, ... NS_REQUIRES_NIL_TERMINATION
{
    NSMutableArray * arr = [NSMutableArray array];
    va_list arguments;
    id eachObject;
    if (sql) {
        va_start(arguments, sql);
        while ((eachObject = va_arg(arguments, id))) {
            NSLog(@"%@",eachObject);
            
            [arr addObject:eachObject];
        }
        va_end(arguments);
    }
    __block BOOL b;
    [self.queue inDatabase:^(FMDatabase *db) {
        b = [db executeUpdate:sql withArgumentsInArray:arr];
    }];
    return b;
}
//查询记录
-(NSArray*)CheckTableWithSql:(NSString*)sql,... NS_REQUIRES_NIL_TERMINATION
{
    NSMutableArray * arr = [NSMutableArray array];
    va_list arguments;
    id eachObject;
    if (sql) {
        va_start(arguments, sql);
        while ((eachObject = va_arg(arguments, id))) {
            NSLog(@"%@",eachObject);
            
            [arr addObject:eachObject];
        }
        va_end(arguments);
    }

    __block NSMutableArray * arrsave = [NSMutableArray array];
    [self.queue inDatabase:^(FMDatabase *db) {
      FMResultSet * set = [db executeQuery:sql withArgumentsInArray:arr];
        while([set next]){
//            NSLog(@"%@",[set stringForColumn:@"name"]);
            [arrsave addObject:[set stringForColumn:@"name"]];
        }
        [set close];
    }];
    NSArray * array = [arrsave copy];
    arrsave = nil;
    
    return array;
}
@end
