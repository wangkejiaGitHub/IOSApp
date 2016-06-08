//
//  MKSelectArray.m
//  MKTreeTest
//
//  Created by 张平 on 15/12/25.
//  Copyright © 2015年 zhangping. All rights reserved.
//

#import "MKSelectArray.h"

static MKSelectArray * sharedSingleton = nil;

@implementation MKSelectArray

- (MKSelectArray *)initObject
{
    if (_selectArray == nil) {
        _selectArray = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (MKSelectArray *) sharedInstance
{
    if (sharedSingleton == nil)
    {
        sharedSingleton = [[MKSelectArray alloc] init];
    }
    return sharedSingleton;
}

@end
