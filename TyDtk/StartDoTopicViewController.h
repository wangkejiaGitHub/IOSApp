//
//  StartDoTopicViewController.h
//  TyDtk
//
//  Created by 天一文化 on 16/4/11.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartDoTopicViewController : UIViewController
/**
 是哪个模块的试卷（1章节练习，2模拟试卷，3每周精选，4智能出题）等
 */
@property (nonatomic,assign) NSInteger paperParameter;
/**
 模拟试卷所需参数
 dic
 试卷信息
 */
@property (nonatomic,assign) NSDictionary *dicPater;
/**
 每周精选所需参数
 rid
 */
@property (nonatomic,strong) NSString *rIdString;
@end
