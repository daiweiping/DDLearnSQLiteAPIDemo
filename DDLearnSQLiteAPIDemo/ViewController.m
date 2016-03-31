//
//  ViewController.m
//  DDLearnSQLiteAPIDemo
//
//  Created by MIMO on 16/3/31.
//  Copyright © 2016年 MIMO. All rights reserved.
//

#import "ViewController.h"
#import <sqlite3.h>

#define STEP 1

@interface ViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *tip;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *address;
@property (weak, nonatomic) IBOutlet UITextField *age;

@end

@implementation ViewController{
    sqlite3 *db;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).lastObject;
    NSString *dbPath = [documentPath stringByAppendingPathComponent:@"studyDB.db"];
    if(sqlite3_open(dbPath.UTF8String, &db) != SQLITE_OK) {
        self.tip.text = @"数据库打开失败";
        sqlite3_close(db);
        return;
    }
    
    NSString *create_table_stmt = @"create table if not exists people (id integer primary key autoincrement, name text, address text, age integer);";
#ifdef STEP
    [self step:create_table_stmt];
#else
    [self exec:create_table_stmt];
#endif
    
}

-(void)step:(NSString *)sql_stmt{
    sqlite3_stmt *stmt;
    sqlite3_prepare(db,sql_stmt.UTF8String,-1,&stmt,NULL);
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        self.tip.text = @"操作失败";
    }
    sqlite3_finalize(stmt);
    [self setup];
}

/*
 sqlite3_step 和 sqlite3_exec 都可以用于执行SQL语句
 他们的区别在于后者是sqlite3_prepare()、sqlite3_step() 和 sqlite3_finalize() 的封装
 能让程序多次执行sql语句而不要写许多重复的代码，然后提供一个回调函数进行结果的处理
 */
-(void)exec:(NSString *)sql_stmt{
    char *error;
    sqlite3_exec(db,sql_stmt.UTF8String,NULL,NULL,&error);
    if (error) {
        self.tip.text = [NSString stringWithFormat:@"操作失败:%s",error];
    }
    [self setup];
}

- (IBAction)insert:(id)sender {
    NSString *insert_stmt = [NSString stringWithFormat:
                             @"insert into people (name, address, age) values (\"%@\", \"%@\", %d)",
                             self.name.text,
                             self.address.text,
                             self.age.text.intValue
                             ];
#ifdef STEP
    [self step:insert_stmt];
#else
    [self exec:insert_stmt];
#endif
}

- (IBAction)delete:(id)sender {
    NSString *delete_stmt = [NSString stringWithFormat:
                             @"delete from people where name = \"%@\"",
                             self.name.text
                             ];
#ifdef STEP
    [self step:delete_stmt];
#else
    [self exec:delete_stmt];
#endif
}

- (IBAction)update:(id)sender {
    NSString *update_stmt = [NSString stringWithFormat:
                             @"update people set name = \"%@\", address = \"%@\", age = %d where name = \"%@\";",
                             self.name.text,
                             self.address.text,
                             self.age.text.intValue,
                             self.name.text
                             ];
#ifdef STEP
    [self step:update_stmt];
#else
    [self exec:update_stmt];
#endif
}

- (IBAction)select:(id)sender {
    NSString *select_stmt = [NSString stringWithFormat:
                             @"select * from people where name = \"%@\"",
                             self.name.text
                             ];
    
    sqlite3_stmt *stmt;
    sqlite3_prepare_v2(db,select_stmt.UTF8String,-1,&stmt,NULL);
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        NSString *name = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)];
        NSString *address = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)];
        NSString *age = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3)];
        self.name.text = name;
        self.address.text = address;
        self.age.text = age;
    }
    sqlite3_finalize(stmt);
}


-(void)setup{
    self.name.text = @"";
    self.address.text = @"";
    self.age.text = @"";
    self.tip.text = @"";
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    return [textField resignFirstResponder];
}

@end
