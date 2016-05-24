//
//  AnalysisQtype5TableViewCell.h
//  TyDtk
//
//  Created by 天一文化 on 16/5/7.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnalysisQtype1And2TableViewCell.h"
@interface AnalysisQtype5TableViewCell : UITableViewCell
//试题编号
@property (weak, nonatomic) IBOutlet UILabel *labTopicNumber;
//试题编号宽度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labNumberWidth;
//试题类型
@property (weak, nonatomic) IBOutlet UILabel *labTopicType;
//试题标题
@property (weak, nonatomic) IBOutlet UIWebView *webViewTitle;
//试题标题高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webTitleHeight;
//收藏按钮
@property (weak, nonatomic) IBOutlet UIButton *buttonCollect;
//收藏按钮宽度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonCollectWidth;
//收藏图片
@property (weak, nonatomic) IBOutlet UIImageView *imageVIewCollect;

@property (weak, nonatomic) IBOutlet UIButton *buttonNotes;
@property (weak, nonatomic) IBOutlet UIButton *buttonError;
//是否是第一次加载，用于第二次刷新ui
@property (nonatomic,assign) BOOL isFirstLoad;
@property (nonatomic,assign) BOOL isWebFirstLoading;
@property (nonatomic,assign) BOOL isWebSubFirstLoading;
//是否包含第一次刷新的试题
@property (nonatomic,strong) NSArray *arrayFirstLoading;
@property (nonatomic,assign) CGFloat buttonOy;
@property (nonatomic,assign) CGFloat buttonSubOy;
////////////////////////////////////////////////////
//试题索引，用于显示试题编号
@property (nonatomic,assign) NSInteger indexTopic;
//试题信息
@property (nonatomic,strong) NSDictionary *dicTopic;
//试题类型
@property (nonatomic,assign) NSInteger topicType;
//已经收藏的试题
@property (nonatomic,strong) NSDictionary *dicCollectDone;
- (void)setvalueForCellModel:(NSDictionary *)dic topicIndex:(NSInteger)index;
@property (nonatomic,assign) id <TopicAnalysisCellDelegateTest> delegateAnalysisCellClick;
@end
