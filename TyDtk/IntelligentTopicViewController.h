//
//  IntelligentTopicViewController.h
//  TyDtk
//   
//  Created by 天一文化 on 16/5/24.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntelligentTopicViewController : UIViewController
@property (nonatomic,strong) NSDictionary *dicSubject;
///判断从某个页面push过来进行页面适配 0:题库进入、1.练习中心进入
@property (nonatomic, assign) NSInteger intPushWhere;
////是否允许授权
//@property (nonatomic,assign) BOOL allowToken;
@end
