//
//  DBBaseController.m
//  Navigatioin1
//
//  Created by quanchang fan on 12-3-7.
//  Copyright (c) 2012年 gdin. All rights reserved.
//

#import "DBBaseController.h"
#import <objc/runtime.h>
#import "sqlite3.h"

@implementation DBBaseController

- (id) initWithDBDir:(NSString *)dir
{

    self = [super init];
    if (self) {
        if (dir == nil) {
            _dbFilePath = [NSHomeDirectory() stringByAppendingFormat:@"/%@", DATABASE_FILENAME];
        } else {
            _dbFilePath = [dir copy];
        }
    }
    return self;
}

- (int) insertDataWithObject:(id)modelObject
{
    Class cls = [modelObject class];
    int rval = 0;
    unsigned int ivarsCnt = 0;
    
    sqlite3 *sqlite = nil;
    sqlite3_stmt *stmt = nil;
 
    if (_dbFilePath == nil) {
        _dbFilePath = [NSHomeDirectory() stringByAppendingFormat:@"/%@", DATABASE_FILENAME];
    } 
    NSString *filePath = _dbFilePath;
    int result = sqlite3_open([filePath UTF8String], &sqlite);
    if (result != SQLITE_OK)
    {
        NSLog(@"open database success!");
        return -1;
    }
    
    Ivar *ivars = class_copyIvarList(cls, &ivarsCnt);
    
    NSMutableString* sqlString = [NSMutableString stringWithFormat:@"insert into %s (", object_getClassName(modelObject)];
    NSMutableString* sqlValuesString = [NSMutableString stringWithFormat:@"values ("];
    
    for (const Ivar *key = ivars; key < ivars + ivarsCnt; key++)
    {
        Ivar const ivarValue = *key;
        
        NSString* keyName = [NSString stringWithFormat:@"%s", ivar_getName(ivarValue)];
        [sqlString appendFormat:@"%@", keyName];
        if (1 == strlen(ivar_getTypeEncoding(ivarValue)))
        {

            NSNumber *nValue = [modelObject valueForKey:keyName];
            [sqlValuesString appendFormat:@"%@", nValue];

        }
        else
        {
            id oValue = [modelObject valueForKey:keyName];
            [sqlValuesString appendFormat:@"'%@'", oValue];
        }
        if ((key + 1) < (ivars + ivarsCnt))
        {
            [sqlString appendFormat:@", "];
            [sqlValuesString appendFormat:@", "];
        }
    }
    [sqlValuesString appendFormat:@")"];
    [sqlString appendFormat:@") %@ ;", sqlValuesString];

    NSLog(@"%@",sqlString);
    sqlite3_prepare_v2(sqlite, [sqlString UTF8String], -1, &stmt, NULL);
    result = sqlite3_step(stmt);
    if (result == SQLITE_ERROR || result == SQLITE_MISUSE) 
    {
        NSLog(@"exe  sql failed");
        rval = -1;
    }
    
    sqlite3_finalize(stmt);
    sqlite3_close(sqlite);
    
    //return -1 for failed, 0 for success
    return rval;
}

- (NSMutableArray*) selectDataWithObject:(NSString*)modelObject
{
    return [self selectDataWithObject:modelObject withFilter:nil];
}

- (int) updateDataWithObject:(id)modelObject withKey:(NSString*)updateKeyName
{
    sqlite3 *sqlite = nil;
    sqlite3_stmt *stmt = nil;
    int rval = 0;
    
    if (_dbFilePath == nil) {
        _dbFilePath = [NSHomeDirectory() stringByAppendingFormat:@"/%@", DATABASE_FILENAME];
    } 
    NSString *filePath = _dbFilePath;
    int result = sqlite3_open([filePath UTF8String], &sqlite);
    if (result != SQLITE_OK)
    {
        NSLog(@"open database success!");
        return -1;
    }
    
    Class cls = [modelObject class];
    unsigned int ivarsCnt = 0;
    Ivar *ivars = class_copyIvarList(cls, &ivarsCnt);

    NSMutableString* sqlString = [NSMutableString stringWithFormat:@"update %s set ", object_getClassName(modelObject)];
    
    NSMutableString* sqlFilterString = [NSMutableString stringWithFormat:@""];
    
    for (const Ivar *key = ivars; key < ivars + ivarsCnt; key++)
    {
        Ivar const ivarValue = *key;
        
        NSString* keyName = [NSString stringWithFormat:@"%s", ivar_getName(ivarValue)];
        
        if (0 == strcmp(ivar_getName(ivarValue), [updateKeyName UTF8String]))
        {
            if (1 == strlen(ivar_getTypeEncoding(ivarValue)))
            {
                NSNumber *nValue = [modelObject valueForKey:keyName];
                [sqlFilterString appendFormat:@"where %@ = %@", keyName,nValue];
                
            }
            else
            {
                id oValue = [modelObject valueForKey:keyName];
                [sqlFilterString appendFormat:@"where %@ = '%@'", keyName, oValue];
            }
        }
        else
        {
            if (1 == strlen(ivar_getTypeEncoding(ivarValue)))
            {
                NSNumber *nValue = [modelObject valueForKey:keyName];
//                [sqlFilterString appendFormat:@"where %@ = %@", keyName,nValue];
                [sqlString appendFormat:@" %@=%@", keyName,nValue];
                
            }
            else
            {
                id oValue = [modelObject valueForKey:keyName];
//                [sqlFilterString appendFormat:@"where %@ = '%@'", keyName, oValue];
                [sqlString appendFormat:@" %@='%@'", keyName, oValue];
            }
            
            if ((key + 1) < (ivars + ivarsCnt))
            {
                [sqlString appendFormat:@","];
            }
        }
    }
    
    [sqlString appendFormat:@" %@ ;", sqlFilterString];
    
    //NSLog(sqlString);
    sqlite3_prepare_v2(sqlite, [sqlString UTF8String], -1, &stmt, NULL);
    result = sqlite3_step(stmt);
    if (result == SQLITE_ERROR || result == SQLITE_MISUSE) 
    {
        //NSLog(@"exe  sql failed");
        rval = -1;
    }
    
    sqlite3_finalize(stmt);
    sqlite3_close(sqlite);
    
    // return -1 for failed, 0 for success
    return rval;
}

- (int) deleteDataWithObject:(id)modelObject withKey:(NSString*)delKeyName
{
    sqlite3 *sqlite = nil;
    sqlite3_stmt *stmt = nil;
    int rval = 0;
    
    if (_dbFilePath == nil) {
        _dbFilePath = [NSHomeDirectory() stringByAppendingFormat:@"/%@", DATABASE_FILENAME];
    } 
    NSString *filePath = _dbFilePath;
    int result = sqlite3_open([filePath UTF8String], &sqlite);
    if (result != SQLITE_OK)
    {
        NSLog(@"open database success!");
        return -1;
    }
    
    Class cls = [modelObject class];
    
    unsigned int ivarsCnt = 0;
    Ivar *ivars = class_copyIvarList(cls, &ivarsCnt);
    //    NSLog(@"get class member");
    
    NSMutableString* sqlString = [NSMutableString stringWithFormat:@"delete from %s ", object_getClassName(modelObject)];
    
    NSMutableString* sqlValuesString = [NSMutableString stringWithFormat:@""];
    
    for (const Ivar *key = ivars; key < ivars + ivarsCnt; key++)
    {
        Ivar const ivarValue = *key;
        
        NSString* keyName = [NSString stringWithFormat:@"%s", ivar_getName(ivarValue)];
        if (0 == strcmp(ivar_getName(ivarValue), [delKeyName UTF8String]))
        {
            if (1 == strlen(ivar_getTypeEncoding(ivarValue)))
            {
                NSNumber *nValue = [modelObject valueForKey:keyName];
                [sqlValuesString appendFormat:@"where %@ = %@", keyName,nValue];
            
            }
            else
            {
                id oValue = [modelObject valueForKey:keyName];
                [sqlValuesString appendFormat:@"where %@ = '%@'", keyName, oValue];
            }
        }
    }

    [sqlString appendFormat:@" %@ ;", sqlValuesString];
    
    //NSLog(sqlString);

    sqlite3_prepare_v2(sqlite, [sqlString UTF8String], -1, &stmt, NULL);
    result = sqlite3_step(stmt);
    if (result == SQLITE_ERROR || result == SQLITE_MISUSE) 
    {
        NSLog(@"exe  sql failed");
        rval = -1;
    }
    
    sqlite3_finalize(stmt);
    sqlite3_close(sqlite);
    
    // return -1 for failed, 0 for success
    return rval;
}

- (int) createTableWithObject:(id)modelObject withPrimaryKey:(NSString*)keyName;
{
    int rval = 0;
    Class cls = [modelObject class];
    sqlite3 *sqlite = nil;

    unsigned int ivarsCnt = 0;
    Ivar *ivars = class_copyIvarList(cls, &ivarsCnt);
    //    NSLog(@"get class member");
    
    if (_dbFilePath == nil) {
        _dbFilePath = [NSHomeDirectory() stringByAppendingFormat:@"/%@", DATABASE_FILENAME];
    } 
    NSString *filePath = _dbFilePath;
    NSMutableString* sqlString = [NSMutableString stringWithFormat:@"CREATE TABLE %s (", object_getClassName(modelObject)];
    int result = sqlite3_open([filePath UTF8String], &sqlite);
    if (result != SQLITE_OK)
    {
        NSLog(@"open database file failed!");
        return -1;
    }
    
    for (const Ivar *p = ivars; p < ivars + ivarsCnt; p++)
    {
        Ivar const ivarValue = *p;
        
        [sqlString appendFormat:@"%s ", ivar_getName(ivarValue)];
        if (1 == strlen(ivar_getTypeEncoding(ivarValue)))
        {
            if ('f' == (ivar_getTypeEncoding(ivarValue))[0] || 
                'd' == (ivar_getTypeEncoding(ivarValue))[0]) 
            {
                [sqlString appendFormat:@"REAL"];
            }
            else
            {
                [sqlString appendFormat:@"integer"];
            }
        }
        else
        {
            [sqlString appendFormat:@"TEXT"];
        }
        
        if (nil != keyName && 0 == strcmp([keyName UTF8String], ivar_getName(ivarValue))) 
        {
            [sqlString appendFormat:@" NOT NULL PRIMARY KEY UNIQUE"];
        }
        
        if ((p + 1) < (ivars + ivarsCnt))
        {
            [sqlString appendFormat:@","];
        }
    }
    [sqlString appendFormat:@");"];


    //NSLog(sqlString);
    
    char* error;
    result = sqlite3_exec(sqlite, [sqlString UTF8String], NULL, NULL, &error);
    if (result != SQLITE_OK) {
        NSLog(@"create database failed for %s", error);
        //sqlite3_close(sqlite);
        rval = -1;
    } else {
        NSLog(@"create table success!!");
        rval = 0;
    }
    
    sqlite3_close(sqlite);
    
    // return -1 for failed, 0 for success
    return rval;
}

- (NSMutableArray*) selectDataWithObject:(NSString*)modelObject withFilter:(NSString*)filter
{
    sqlite3 *sqlite = nil;
    sqlite3_stmt *stmt = nil;
    
    if (_dbFilePath == nil) {
        _dbFilePath = [NSHomeDirectory() stringByAppendingFormat:@"/%@", DATABASE_FILENAME];
    } 
    NSString *filePath = _dbFilePath;
    int result = sqlite3_open([filePath UTF8String], &sqlite);
    if (result != SQLITE_OK)
    {
        NSLog(@"open database success!");
        return nil;
    }
    
    id tmp = [[objc_getClass([modelObject UTF8String]) alloc] init];
    Class cls = [tmp class];
    NSMutableArray * reVal = [[NSMutableArray alloc] init];
    
    unsigned int ivarsCnt = 0;
    Ivar *ivars = class_copyIvarList(cls, &ivarsCnt);
    //    NSLog(@"get class member");
    
    NSMutableString* sqlString = [[NSMutableString alloc] init];
    [sqlString appendFormat:@"select "];
    for (const Ivar *p = ivars; p < ivars + ivarsCnt; p++)
    {
        Ivar const ivarValue = *p;
        
        [sqlString appendFormat:@" %s", ivar_getName(ivarValue)];
        if ((p + 1) < (ivars + ivarsCnt))
        {
            [sqlString appendFormat:@","];
        }
    }
    
    if (filter != nil && [filter length] > 0)
    {
        [sqlString appendFormat:@" from %@ where %@", modelObject, filter];
    }
    else
    {
        [sqlString appendFormat:@" from %@ ", modelObject];
    }
    
    //NSLog(sqlString);
    
    sqlite3_prepare_v2(sqlite, [sqlString UTF8String], -1, &stmt, NULL);
    result = sqlite3_step(stmt);
    
    while (result == SQLITE_ROW) {
        id objValue = [[objc_getClass([modelObject UTF8String]) alloc] init];
        
        unsigned int ivarsCnt = 0;
        int nCount = 0;
        Ivar *ivars = class_copyIvarList(cls, &ivarsCnt);
        
        for (const Ivar *p = ivars; p < ivars + ivarsCnt; p++)
        {
            Ivar const ivarValue = *p;
            NSString *forKey = [NSString stringWithFormat:@"%s", ivar_getName(ivarValue)];
            if (strlen(ivar_getTypeEncoding(ivarValue)) == 1)
            {
                if ('f' == ivar_getTypeEncoding(ivarValue)[0] ||
                    'd' == ivar_getTypeEncoding(ivarValue)[0])
                {
                    double fValue = sqlite3_column_double(stmt, nCount);
                    [objValue setValue:[NSNumber numberWithFloat:fValue] forKey:forKey];
                }
                else
                {
                    int nValue = sqlite3_column_int(stmt, nCount);
                    [objValue setValue:[NSNumber numberWithInt:nValue] forKey:forKey];
                }
                
            }
            else
            {
                NSString* strTmpValue = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(stmt, nCount)];
                [objValue setValue:strTmpValue forKey:forKey];
            }
            nCount++;
        }
        
        [reVal addObject:objValue];
        result = sqlite3_step(stmt);
    }
    
    sqlite3_finalize(stmt);
    sqlite3_close(sqlite);
    
    return reVal;
}

-(void) dealloc
{
}

@end
