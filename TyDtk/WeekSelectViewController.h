//
//  WeekSelectViewController.h
//  TyDtk
//
//  Created by 天一文化 on 16/5/18.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeekSelectViewController : UIViewController
@property (nonatomic,strong) NSString *subjectId;
//是否允许授权
@property (nonatomic,assign) BOOL allowToken;
@end
