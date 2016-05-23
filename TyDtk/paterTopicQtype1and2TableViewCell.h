//
//  paterTopicQtype1and2TableViewCell.h
//  TyDtk
//
//  Created by 天一文化 on 16/4/27.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TopicCellDelegateTest<NSObject>
//传递选项参数，用于同步答题卡
/**
 indexTpoic 需要刷新的答题卡索引
 dicUserAnswer 试题id，用户答案等信息
 isResfresh 是否刷新答题卡
 */
- (void)topicCellSelectClickTest:(NSInteger)indexTpoic selectDone:(NSDictionary*)dicUserAnswer isRefresh:(BOOL)isResfresh;
//保存试题中的图片
- (void)imageSaveQtype1Test:(UIImage *)image;
//保存用户已经做过试题的答案
- (void)saveUserAnswerUseDictonary:(NSDictionary *)dic;
//保存用户已经收藏过的试题
- (void)saveUserCollectTiopic:(NSDictionary *)dic;
//提交笔记或纠错
- (void)saveNotesOrErrorClick:(NSInteger)questionId executeParameter:(NSInteger)parameterId;
//第一次加载
- (void)IsFirstload:(BOOL)isFirstLoad;

//非小题webview二次刷新
- (void)isWebLoadingCellHeight:(CGFloat)cellHeight withButtonOy:(CGFloat)buttonOy;
//小题webview二次刷新
- (void)isWebLoadingCellHeight:(CGFloat)cellHeight withButtonOy:(CGFloat)buttonOy withIndex:(NSInteger)index;
@end
@interface paterTopicQtype1and2TableViewCell : UITableViewCell
//已经做过的试题
@property (nonatomic,strong) NSDictionary *dicSelectDone;
//已经收藏的试题
@property (nonatomic,strong) NSDictionary *dicCollectDone;
//试题编号
@property (weak, nonatomic) IBOutlet UILabel *labTopicNumber;
//试题编号宽度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labNumberWidth;
//试题类型
@property (weak, nonatomic) IBOutlet UILabel *labTopicType;
//收藏按钮
@property (weak, nonatomic) IBOutlet UIButton *buttonCollect;
//收藏按钮宽度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonCollectWidth;
//收藏图片
@property (weak, nonatomic) IBOutlet UIImageView *imageVIewCollect;

//是否是第一次加载，用于第二次刷新ui
@property (nonatomic,assign) BOOL isFirstLoad;
//第一次加载webview
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
//多选题的答案
@property (nonatomic,strong) NSString *selectContentQtype2;
//试题类型
@property (nonatomic,assign) NSInteger topicType;
//是否是最后一题
@property (nonatomic,assign) BOOL isLastTopic;
//用户刷新做题主页信息的代理
@property (nonatomic,assign) id <TopicCellDelegateTest> delegateCellClick;
- (void)setvalueForCellModel:(NSDictionary *)dic topicIndex:(NSInteger)index;
@end
