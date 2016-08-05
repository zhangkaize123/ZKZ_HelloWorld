//
//  ViewController.m
//  FMDB_vision_upload
//
//  Created by 张凯泽 on 16/7/27.
//  Copyright © 2016年 rytong_zkz. All rights reserved.
//
/*
 工具类问题:
 0.如果表中使用sex字段名，如果想增加SEx这个字段无法进行判断，待工具🔧类完成后解决。(所以在表中各字段不许使用大写)
 
 */
#import "ViewController.h"
//#import "FMDB.h"
#import "ZKZVisionStoreTool.h"
#import "ZKZFmdbManager.h"
//static NSString * VisionNum = @"v1.1.0";
//获取版本好
#define VisionNum [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
@interface ViewController ()
@property (nonatomic, strong) FMDatabase *db;
@property(nonatomic,strong)ZKZFmdbManager *fmdbManager;
@end

@implementation ViewController
- (IBAction)RenameClick:(id)sender {

    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    [dic setObject:@"ALTER TABLE t_student ADD COLUMN xingming text;" forKey:@"add"];
    [dic setObject:@"update t_student set xingming = name" forKey:@"update"];
    [dic setObject:@"create table temp as select id, xingming,age,sex from t_student;"  forKey:@"create"];
    [dic setObject:@"drop table t_student;" forKey:@"drop"];
    [dic setObject:@"alter table temp rename to t_student;" forKey:@"rename"];
    //[self UpdataFormWithTableName:@"t_student" SomeOneRowOldValue:@"name" NewValue:@"xingming" AndWithSqlite:dic];
    [_fmdbManager UpdataFormWithTableName:@"t_student" SomeOneRowOldValue:@"name" NewValue:@"xingming" AndWithSqlite:dic];
}
- (IBAction)DeleteClick:(id)sender {
    NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
    [dic setObject:@"create table temp as select id, name, age from t_student;" forKey:@"create"];
    [dic setObject:@"drop table t_student;" forKey:@"drop"];
    [dic setObject:@"alter table temp rename to t_student;" forKey:@"rename"];
    //[self DeleteFormSomeOneRow:@"sex" AndWithSqlite:dic];
    //[self DeleteFormWithTableName:@"t_student" SomeOneCol:@"sex" AndWithSqlite:dic];
    [_fmdbManager DeleteFormWithTableName:@"t_student" SomeOneCol:@"sex" AndWithSqlite:dic];
}
- (IBAction)AddClick:(id)sender {
    NSString * sql = @"ALTER TABLE t_student ADD COLUMN visionN text;";
    [_fmdbManager AddFormWithTableName:@"t_student" SomeOneCol:@"vision" AndWithSqlite:@"ALTER TABLE t_student ADD COLUMN vision text;"];
    //[self AddFormWithTableName:@"t_student" SomeOneCol:@"vision" AndWithSqlite:sql];
}
//删除的沙盒中存储的vision版本号
- (IBAction)DeleleStoreVision:(id)sender {
    [ZKZVisionStoreTool RemoveVisionNumCompleteHandle:^(NSString *fileString, NSError *error, BOOL isStoreSuccess) {
        NSLog(@"%@----%d",error,isStoreSuccess);
    }];
}
- (IBAction)FindClick:(id)sender {
   NSArray *a = [self.fmdbManager CheckTableWithSql:@"select * from t_student where age>20", nil];
    for (NSString * s in a) {
        NSLog(@"%@",s);
    }
            /*
    // 1.查询数据
    FMResultSet *rs = [self.db executeQuery:@"select * from t_student"];
    NSLog(@"rs = %@",rs.columnNameToIndexMap);
   BOOL b = [rs columnIsNull:@"Sex"];
    NSLog(@"b = %d",b);
    //[self SearchFormIsExist:rs];
//    [self SearchFormIsExist:rs RequireCompareValue:@"sex" andCompleteHandle:^(NSString *key, BOOL isExist) {
//        NSLog(@"key = %@,isexist = %d",key,isExist);
//    }];
    // 2.遍历结果集
    while (rs.next) {
        //[rs col]
        //NSLog(@"ID = %d name = %@ age = %d visionNum = %d", ID, name, age,vision);
    }

     
     
     */
}


//插入数据
- (IBAction)InsertClick:(id)sender {
    
    NSLog(@"插入数据");
//[self mutableParamList11111:@"gggg", @"zhang", @"ttttt",@"rrrrr"];
    //for (int i = 0; i<40; i++) {
        NSString *name = [NSString stringWithFormat:@"rose-%d", arc4random() % 1000];
        NSNumber *age = @(arc4random() % 100 + 1);
        NSNumber * visionnum = @(1);
       //[self.db executeUpdate:@"insert into t_student (name, age) values (?, ?);", @"zhang", @(34)];
    //[self.db executeUpdate:@"insert into t_student (name, age) values ('zhagn111', '32');",nil ];
        //[self.fmdbManager mutableParamList1:@"rrrr", @"zhang", @"li"];
    
   // }
    //[self.fmdbManager InsertDataWith:@"insert into t_student (name, age) values (?, ?);", @"zhang", @(34)];
    //[self.fmdbManager InsertDataWith:@"insert into t_student (name, age) values (?, ?);",@"zhang",@(22), nil];
    [self.fmdbManager InsertNumWith:2 DataWith:@"insert into t_student (name,age) values (:name,:age);",@"zhangrrrrr11", @(555555),nil];
    
}




- (void)viewDidLoad {
    [super viewDidLoad];
    NSString * ss = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSLog(@"%@",ss);
    //判断是否存储了版本好
    if ([ZKZVisionStoreTool AchieveVisionNuber] == nil) {
        //记录这个app的版本号
        if(![ZKZVisionStoreTool StroeVisionNumberWith:VisionNum])//存储失败
        {
            NSLog(@"存储版本号失败");
        }
    }
    
    // 0.获得沙盒中的数据库文件名
    NSString *filename = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"student.sqlite"];
    NSLog(@"filename = %@",filename);
    self.fmdbManager = [ZKZFmdbManager sharedFmdbManagerWithFilePath:filename];
   
    //创建表格
    BOOL result = [self.fmdbManager CreateTableWith:@"create table if not exists t_student (id integer primary key autoincrement, name text, age integer,sex text);"];
    
    /*
    // 1.创建数据库实例对象
    self.db = [FMDatabase databaseWithPath:filename];
    
    // 2.打开数据库
    if ( [self.db open] ) {
        NSLog(@"数据库打开成功");
#pragma mark---zkz----在版本1.0的时候
        // 创表
        //BOOL result = [self.db executeUpdate:@"create table if not exists t_student (id integer primary key autoincrement, name text, age integer,visionNum interger);"];
#pragma mark---zkz----在版本为2.0的时候  删除vision字段 并增加sex字段
        BOOL result = [self.db executeUpdate:@"create table if not exists t_student (id integer primary key autoincrement, name text, age integer ,sex text );"];
        if (result) {
            NSLog(@"创表成功");
            
            //建完表格后存储版本好
#pragma mark --zkz-- 在版本2.0的时候添加sex一列
            if (![[ZKZVisionStoreTool AchieveVisionNuber] isEqualToString:VisionNum]) {
                //[self AddFormSomeOneRow:@"name"];
                //修改表结构中某个字段名
               // [self DeleteFormSomeOneRow];
                 //添加成功后把旧的版本号更新到最新版本
                [ZKZVisionStoreTool StroeVisionNumberWith:VisionNum];
            }
            
            
        } else {
            NSLog(@"创表失败");
        }
    } else {
        NSLog(@"数据库打开失败");
    }
    */

}
//修改表格中某个字段名updata
/*
 oldvalue 为被替换的字段
 newvalue 为更新后的值
 */
-(void)UpdataFormWithTableName:(NSString*)tableName SomeOneRowOldValue:(NSString*)oldvalue NewValue:(NSString*)newvalue AndWithSqlite:(NSDictionary*)sql
{
    /*
    //判断表中是否有这个字段但是无法区分大小写
    BOOL b = [self.db columnExists:oldvalue inTableWithName:tableName];
    if (b) {//存在这个字段
       
        [self AddFormWithTableName:tableName SomeOneCol:newvalue AndWithSqlite:sql[@"add"]];
        //[self.db executeUpdate:@"alter table t_student Add column xingming text  not null AFTER name"];
        //1.将字段a的内容拷贝到c
        [self.db executeUpdate:sql[@"update"]];
        //[self.db executeUpdate:@"update t_student set xingming = ?",oldvalue];
        //2 删除字段a;
//        NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
//        [dic setObject:@"create table temp as select id, xingming,age,sex from t_student;" forKey:@"create"];
//        [dic setObject:@"drop table t_student;" forKey:@"drop"];
//        [dic setObject:@"alter table temp rename to t_student;" forKey:@"rename"];
        //[self DeleteFormSomeOneRow:@"name" AndWithSqlite:dic];
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        [dic setObject:sql[@"create"] forKey:@"create"];
        [dic setObject:sql[@"drop"] forKey:@"drop"];
        [dic setObject:sql[@"rename"] forKey:@"rename"];
        [self DeleteFormWithTableName:tableName SomeOneCol:oldvalue AndWithSqlite:dic];
    }else{
        NSLog(@"不存在这个字段");
    }
     */
}
//在表格中添加某个字段
/**
 tableName:表格的名字
 ColName:需要增加的类
 sql:在表格中增加列的sql 语句(ALTER TABLE [tablename] ADD COLUMN [addcolname] [colname type];)
 */
-(void)AddFormWithTableName:(NSString*)tableName SomeOneCol:(NSString*)ColName AndWithSqlite:(NSString*)sql
{
    /*
    //先判断表格中是否含有这个字段
    [self SearchFormIsExistWithTableName:tableName RequireCompareValue:ColName andCompleteHandle:^(NSString *key, BOOL isExist) {
        if (isExist == NO) {//不存在这个字段
           // BOOL b =[self.db executeQuery:@"ALTER TABLE t_student ADD COLUMN visionN text;"];
            //@"ALTER TABLE t_student ADD COLUMN visionn text;"
            BOOL b = [self.db executeUpdate:sql];
            //BOOL b = [self.db executeUpdateWithFormat:@"ALTER TABLE t_student ADD COLUMN visionN text;"];
            if (b) {
                NSLog(@"增加字段成功");
            }else{
                NSLog(@"添加字段失败");
            }
        }else{//表格中原来就有这个字段
            NSLog(@"表格中原来就有这个字段");
        }
    }];
*/
}
//删除表格中的某一列
/**
 tableName:表格的名字
 ColName:需要增加的类
 attributes :create
 */
-(void)DeleteFormWithTableName:(NSString*)tableName SomeOneCol:(NSString*)ColName AndWithSqlite:(NSDictionary*)attributes
{
    /*
    [self SearchFormIsExistWithTableName:tableName RequireCompareValue:ColName andCompleteHandle:^(NSString *key, BOOL isExist) {
        if (isExist == NO) {//表格中不存在这个字段无法删除
            NSLog(@"表格中不存在这个字段无法删除");
        }else{
            //0.复制一个表格和缺少你想删除的字段（本demo中想删除vision字段）
//    [self.db executeUpdate:@"create table temp as select id, name, age, sex from t_student;"];
//    //1.删除原来的表格
//    [self.db executeUpdate:@"drop table t_student;"];
//    // 给临时表格重新命名为原来的名字
//    [self.db executeUpdate:@"alter table temp rename to t_student;"];
            [self.db executeUpdate:attributes[@"create"]];
            //1.删除原来的表格
            [self.db executeUpdate:attributes[@"drop"]];
            // 给临时表格重新命名为原来的名字
            [self.db executeUpdate:attributes[@"rename"]];
        }
    }];
    
    
    */
    //
}
//判断表格中是否存在某个字段
-(void)SearchFormIsExistWithTableName:(NSString*)tableName RequireCompareValue:(NSString*)Value andCompleteHandle:(void (^)(NSString * key,BOOL isExist))completehandle
{
    //NSLog(@"----resultDictionary = %@",set.resultDictionary);
    //获取表中的字段名
//    NSMutableSet * setOld = [NSMutableSet setWithArray:[set.columnNameToIndexMap allKeys]];
//    NSMutableSet * setNew = [setOld mutableCopy];
//    [setNew addObject:Value];
//    BOOL isexist;
//    if (setOld.count<setNew.count) {//表格中没有这个字段
//        isexist = NO;
//        
//    }else{//表格中原来就有这个字段
//        isexist = YES;
//    }
//    completehandle(Value,isexist);

    
   /*
    
    BOOL b = [self.db columnExists:Value inTableWithName:tableName];
    completehandle(Value,b);
    */
}

@end
