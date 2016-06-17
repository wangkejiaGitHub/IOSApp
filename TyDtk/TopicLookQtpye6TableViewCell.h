//
//  TopicLookQtpye6TableViewCell.h
//  TyDtk
//
//  Created by 天一文化 on 16/6/17.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnalysisQtype1And2TableViewCell.h"
@interface TopicLookQtpye6TableViewCell : UITableViewCell
//试题编号
@property (weak, nonatomic) IBOutlet UILabel *labTopicNumber;
//试题编号宽度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labNumberWidth;
//试题类型
@property (weak, nonatomic) IBOutlet UILabel *labTopicType;
//试题索引
@property (nonatomic,assign) NSInteger indexTopic;
//试题信息
@property (nonatomic,strong) NSDictionary *dicTopic;
//是否第一次加载
@property (nonatomic,assign) BOOL isFirstLoad;
//第一次加载webview
@property (nonatomic,assign) BOOL isWebFirstLoading;
@property (nonatomic,assign) CGFloat buttonOy;
@property (nonatomic,assign) CGFloat imageOy;
- (void)setvalueForCellModel:(NSDictionary *)dic topicIndex:(NSInteger)index;
@property (nonatomic,assign) id <TopicAnalysisCellDelegateTest> delegateAnalysisCellClick;
@end
