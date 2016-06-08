//
//  MKSelectArray.h
//  MKTreeTest
//
//  Created by 张平 on 15/12/25.
//  Copyright © 2015年 zhangping. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKSelectArray : NSObject

@property (strong, nonatomic) NSMutableArray *selectArray;

+ (MKSelectArray *) sharedInstance;
- (MKSelectArray *)initObject;

@end
