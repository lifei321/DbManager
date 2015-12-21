//
//  ViewController.m
//  DataBaseManager
//
//  Created by shancheli on 15/12/21.
//  Copyright © 2015年 shancheli. All rights reserved.
//

#import "ViewController.h"


#import "DBBaseController.h"
#import "MyClass.h"

#import "User.h"
#import "EGODatabase.h"



@interface ViewController ()

@property(nonatomic,copy)NSString* filePath;

@end

@implementation ViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    _filePath = [NSHomeDirectory() stringByAppendingFormat: @"/Documents/%@", @"sqlite.rdb"];
    
    [self EGODatabase];
}


-(void)EGODatabase
{
    
    [self CreatTab];
    
    
    User* user = [[User alloc]init];
    user.userAge = 10;
    user.userId = @"100";
    user.userName = @"zhangsan";
    
    
    [self addUser:user];
    
    [self findUser:^(NSArray *ModelArr) {
        
        for (User* model in ModelArr) {
            NSLog(@"Age ---- %d",model.userAge);
            NSLog(@"Id ---- %@",model.userId);
            NSLog(@"Name ---- %@",model.userName);
        }
    }];
}

-(void)CreatTab
{
    //用数据库文件构造数据库操作对象
    EGODatabase *dataBase = [[EGODatabase alloc] initWithPath:_filePath];
    
    //1.打开数据库
    [dataBase open];
    
    //2.操作数据库中的表
    NSString *sql = @"CREATE TABLE IF NOT EXISTS t_user(userId text UNIQUE,userName text,userAge integer)";
    
    [dataBase executeQuery:sql];
    
    [dataBase close];
}


- (void)addUser:(User *)user {
    
    //用数据库文件构造数据库操作对象
    EGODatabase *dataBase = [[EGODatabase alloc] initWithPath:_filePath];
    
    //1.打开数据库
    [dataBase open];
    
    //2.操作数据库中的表
    NSString *sql = @"INSERT INTO t_user(userId,userName,userAge) VALUES(?,?,?)";
    
    NSArray *params = @[user.userId,user.userName,@(user.userAge)];
    
    //同步添加数据到t_user表中
    [dataBase executeUpdate:sql parameters:params];
    
    //3.关闭数据库
    [dataBase close];
    
}

//异步查询
- (void)findUser:(void (^)(NSArray *))completionBlock {
    
    EGODatabase *dataBase = [[EGODatabase alloc] initWithPath:_filePath];
    
    [dataBase open];
    
    NSString *sql = @"SELECT * from t_user";
    
    //异步查询
    EGODatabaseRequest *request = [dataBase requestWithQuery:sql];
    
    [request setCompletion:^(EGODatabaseRequest *request, EGODatabaseResult *result, NSError *error) {
        
        //查询成功后回调的block
        
        NSMutableArray *userArray = [NSMutableArray array];
        
        for (int i = 0; i<result.count; i++) {
            
            //获取当前这一条数据
            EGODatabaseRow *row = result.rows[i];
            
            //创建Model
            User *user = [[User alloc] init];
            
            //获取到当前数据的每个字段的值
            user.userId = [row stringForColumn:@"userId"];
            user.userName = [row stringForColumnAtIndex:1];
            user.userAge = [row intForColumnAtIndex:2];
            
            [userArray addObject:user];
            
            
        }
        
        //回调传入的block
        completionBlock(userArray);
        
    }];
    
    
    //创建线程队列，将线程对象加入到队列中执行
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:request];
    
    
    //关闭数据库
    [dataBase close];
    
    
}


/***********************************************************************
 
                        DBBaseController
 
***********************************************************************/

-(void)DBBaseController
{
    DBBaseController* dbController = [[DBBaseController alloc]initWithDBDir:nil];
    
    MyClass *tmp2 = [[MyClass alloc] init];
    tmp2.myID = 2;
    tmp2.myCoin = 2;
    tmp2.myAge = 2;
    tmp2.myMoney = 2.522f;
    tmp2.myName = @"2fqc";
    tmp2.myTime = 22.2;
    
    for (int i = 0; i<20; i++) {
        [dbController insertDataWithObject:tmp2];
        
    }
    //[dbController updateDataWithObject:tmp2 withKey:@"myID"];
    //    [dbController deleteDataWithObject:tmp2 withKey:@"myID"];
    NSMutableArray *dataSet = [dbController selectDataWithObject:@"MyClass" withFilter:@"myID=2"];
    
    int index = 1;
    for (MyClass *mytmp in dataSet) {
        NSLog(@"%d, myid = %d, mymoney=%0.3f,myname=%@", index++, mytmp.myID, mytmp.myMoney, mytmp.myName);
    }
}

@end
