//
//  PaterTopicQtype4TableViewCell.h
//  TyDtk
//
//  Created by 天一文化 on 16/5/5.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "paterTopicQtype1and2TableViewCell.h"
@interface PaterTopicQtype4TableViewCell : UITableViewCell
//试题编号
@property (weak, nonatomic) IBOutlet UILabel *labNumber;
//试题编号宽度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labNumberWidth;
//试题类型
@property (weak, nonatomic) IBOutlet UILabel *labTopicType;
//收藏图片
@property (weak, nonatomic) IBOutlet UIImageView *imageCollect;
//收藏按钮
@property (weak, nonatomic) IBOutlet UIButton *buttonCollect;
//收藏按钮宽度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonCollectWidth;
//试题标题
@property (weak, nonatomic) IBOutlet UIWebView *webViewTitle;
//试题标题高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webViewTitleHeight;
//试题答题区
@property (weak, nonatomic) IBOutlet UITextView *textViewAnswer;
//第一次加载webview
@property (nonatomic,assign) BOOL isWebFirstLoading;
@property (nonatomic,assign) BOOL isWebSubFirstLoading;
//已经收藏过的试题
@property (nonatomic,strong) NSDictionary *dicCollectDone;
//试题信息
@property (nonatomic,strong) NSDictionary *dicTopic;
//试题索引
@property (nonatomic,assign) NSInteger indexTopic;
//是否第一次加载
@property (nonatomic,assign) BOOL isFirstLoad;
//是否包含第一次刷新的试题
@property (nonatomic,strong) NSArray *arrayFirstLoading;
@property (nonatomic,assign) CGFloat buttonOy;
@property (nonatomic,assign) CGFloat buttonSubOy;
//已经做过的试题
@property (nonatomic,strong) NSDictionary *dicSelectDone;
//是否是最后一题
@property (nonatomic,assign) BOOL isLastTopic;
@property (nonatomic,assign) id <TopicCellDelegateTest> delegateCellClick;
- (void)setvalueForCellModel:(NSDictionary *)dic topicIndex:(NSInteger)index;
@end
