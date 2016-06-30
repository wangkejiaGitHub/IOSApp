//
//  ActiveSubjectViewController.h
//  TyDtk
//
//  Created by 天一文化 on 16/6/29.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActiveSubjectViewController : UIViewController
@property (nonatomic,assign) NSInteger subjectId;
///判断是购买还是直接激活（0.激活、1.下单）
@property (nonatomic,assign) NSInteger payParameter;
@end
