//
//  PaperLookViewController.h
//  TyDtk
//
//  Created by 天一文化 on 16/6/17.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaperLookViewController : UIViewController
//每道题的字典
@property (nonatomic,strong) NSDictionary *dicTopic;
//每道题的索引
@property (nonatomic,assign) NSInteger topicIndex;
//是否是最后一题
@property (nonatomic,assign) BOOL isLastTopic;
@end
