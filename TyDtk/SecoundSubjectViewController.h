//
//  SecoundSubjectViewController.h
//  TyDtk
//
//  Created by 天一文化 on 16/3/22.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecoundSubjectViewController : UIViewController
//选中的第一大科目索引
@property (nonatomic,assign) NSInteger selectSubject;
//所有第一大科目数组
@property (nonatomic,strong) NSArray *arraySubject;
//所有第二大科目数组（主要参数）
@property (nonatomic,strong) NSArray *arraySecoundSubject;
@end
