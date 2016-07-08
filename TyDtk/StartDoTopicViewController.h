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
 每周精选、章节练习、智能做题所需参数rid,
 rid
 */
@property (nonatomic,strong) NSString *rIdString;

///**
// 章节练习所需参数字典
// */
//@property (nonatomic,strong) NSDictionary *dicChaper;

/*********继续做题模块参数**********/
/////从练习记录中继续做题进来
//@property (nonatomic,assign) BOOL isContinueDoTopic;
///继续做题的rid
@property (nonatomic,strong) NSString *ridContinue;
/*********继续做题模块参数**********/

@end
