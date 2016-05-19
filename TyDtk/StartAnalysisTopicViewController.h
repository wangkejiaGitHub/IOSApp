//
//  StartAnalysisTopicViewController.h
//  TyDtk
//
//  Created by 天一文化 on 16/5/6.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartAnalysisTopicViewController : UIViewController
//试卷id
@property (nonatomic,assign) NSInteger PaperId;
//记录id
@property (nonatomic,strong) NSString *rId;
/**
 是哪个模块的试卷（1章节练习，2模拟试卷，3每周精选，4智能出题）等
 */
@property (nonatomic,assign) NSInteger paperAnalysisParameter;
@end
