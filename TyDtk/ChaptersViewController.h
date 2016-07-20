//
//  ChaptersViewController.h
//  TyDtk
//
//  Created by 天一文化 on 16/4/6.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface ChaptersViewController : UIViewController
@property (nonatomic,strong) NSString *subjectId;
///科目信息
@property (nonatomic,strong) NSDictionary *dicSubject;
///判断从某个页面push过来进行页面适配 0:题库进入、1.练习中心进入
@property (nonatomic, assign) NSInteger intPushWhere;
///科目是否激活或者可做
@property (nonatomic,assign) BOOL isActiveSubject;
@end
