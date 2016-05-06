//
//  paterTopicQtype5TableViewCell.h
//  TyDtk
//
//  Created by 天一文化 on 16/4/27.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "paterTopicQtype1and2TableViewCell.h"
@interface paterTopicQtype5TableViewCell : UITableViewCell
//会做按钮
@property (weak, nonatomic) IBOutlet UIButton *buttonCanDo;
//不会做按钮
@property (weak, nonatomic) IBOutlet UIButton *buttonCanDonot;
//试题编号
@property (weak, nonatomic) IBOutlet UILabel *labNumber;
//试题编号宽度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labNumberWidth;
//试题类型
@property (weak, nonatomic) IBOutlet UILabel *labTopicType;
//试题标题
@property (weak, nonatomic) IBOutlet UIWebView *webViewTitle;
//试题标题高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webViewTitleHeight;
//收藏图片
@property (weak, nonatomic) IBOutlet UIImageView *imageCollect;
//收藏按钮
@property (weak, nonatomic) IBOutlet UIButton *buttonCollect;
//收藏按钮宽度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonCollectWidth;
//试题信息
@property (nonatomic,strong) NSDictionary *dicTopic;
//试题索引
@property (nonatomic,assign) NSInteger indexTopic;
//已经做过的试题
@property (nonatomic,strong) NSDictionary *dicSelectDone;
//已经收藏的试题
@property (nonatomic,strong) NSDictionary *dicCollectDone;
//是否第一次加载
@property (nonatomic,assign) BOOL isFirstLoad;
@property (nonatomic,assign) id <TopicCellDelegateTest> delegateCellClick;
- (CGFloat)setvalueForCellModel:(NSDictionary *)dic topicIndex:(NSInteger)index;
@end
