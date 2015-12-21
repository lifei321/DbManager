//
//  DBBaseController.h
//  Navigatioin1
//
//  Created by quanchang fan on 12-3-7.
//  Copyright (c) 2012年 gdin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DATABASE_FILENAME @"data.sqlite"

@interface DBBaseController : NSObject
{
    @private
    NSString* _dbFilePath;
}

- (id) initWithDBDir:(NSString *)dir;
- (int) createTableWithObject:(id)modelObject withPrimaryKey:(NSString*)keyName;
- (int) insertDataWithObject:(id)modelOjbect;
- (NSMutableArray*) selectDataWithObject:(NSString*)modelObject;
- (NSMutableArray*) selectDataWithObject:(NSString*)modelObject withFilter:(NSString*)filter;
- (int) updateDataWithObject:(id)modelObject withKey:(NSString*)updateKeyName;
- (int) deleteDataWithObject:(id)modelObject withKey:(NSString*)key;


@end
