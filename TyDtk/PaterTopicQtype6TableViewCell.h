//
//  PaterTopicQtype6TableViewCell.h
//  TyDtk
//
//  Created by 天一文化 on 16/4/19.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "paterTopicQtype1and2TableViewCell.h"
@interface PaterTopicQtype6TableViewCell : UITableViewCell
//试题编号
@property (weak, nonatomic) IBOutlet UILabel *labNumber;
//试题编号宽度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labNumberWidth;
//试题类型
@property (weak, nonatomic) IBOutlet UILabel *labTitleType;
//试题标题
@property (weak, nonatomic) IBOutlet UIWebView *webViewTitle;
//试题标题高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webTitleHeight;
//试题索引
@property (nonatomic,assign) NSInteger indexTopic;
//试题信息
@property (nonatomic,strong) NSDictionary *dicTopic;
//是否第一次加载
@property (nonatomic,assign) BOOL isFirstLoad;
@property (nonatomic,assign) id <TopicCellDelegateTest> delegateCellClick;
- (CGFloat)setvalueForCellModel:(NSDictionary *)dic topicIndex:(NSInteger)index;
@end
