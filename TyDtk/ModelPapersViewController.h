//
//  ModelPapersViewController.h
//  TyDtk
//
//  Created by 天一文化 on 16/4/6.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface ModelPapersViewController : UIViewController
@property (nonatomic,strong) NSString *subjectId;
//是否允许授权
@property (nonatomic,assign) BOOL allowToken;
//判断从某个页面push过来进行页面适配
@property (nonatomic,assign) NSInteger intPushWhere;
@end
