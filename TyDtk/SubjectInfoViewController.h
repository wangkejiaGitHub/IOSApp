//
//  SubjectInfoViewController.h
//  TyDtk
//
//  Created by 天一文化 on 16/3/30.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubjectInfoViewController : UIViewController
@property (nonatomic ,strong) NSDictionary *dicSubject;
///用户判断用户是否登录
@property (nonatomic ,assign) BOOL isUserLogin;
@end
