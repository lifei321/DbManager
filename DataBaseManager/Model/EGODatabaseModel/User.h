//
//  User.h
//  DataBaseManager
//
//  Created by shancheli on 15/12/21.
//  Copyright © 2015年 shancheli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property(nonatomic,copy)NSString *userId;

@property(nonatomic,copy)NSString *userName;

@property(nonatomic,assign)int userAge;

@end
