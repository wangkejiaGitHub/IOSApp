//
//  AnalysisQtype1And2TableViewCell.h
//  TyDtk
//
//  Created by 天一文化 on 16/5/6.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TopicAnalysisCellDelegateTest<NSObject>
//传递选项参数，用于同步答题卡
/**
 indexTpoic 需要刷新的答题卡索引
 dicUserAnswer 试题id，用户答案等信息
 isResfresh 是否刷新答题卡
 */
//保存试题中的图片
- (void)imageSaveQtype1Test:(UIImage *)image;
//保存用户已经做过试题的答案
//- (void)saveUserAnswerUseDictonary:(NSDictionary *)dic;
//保存用户已经收藏过的试题
- (void)saveUserCollectTiopic:(NSDictionary *)dic;
//提交笔记或纠错
- (void)saveNotesOrErrorClick:(NSInteger)questionId executeParameter:(NSInteger)parameterId;
//第一次加载
- (void)IsFirstload:(BOOL)isFirstLoad;
- (void)isWebLoadingCellHeight:(CGFloat)cellHeight withImageOy:(CGFloat)imageOy;
@end
@interface AnalysisQtype1And2TableViewCell : UITableViewCell
//试题编号
@property (weak, nonatomic) IBOutlet UILabel *labTopicNumber;
//试题编号宽度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labNumberWidth;
//试题类型
@property (weak, nonatomic) IBOutlet UILabel *labTopicType;
//试题标题
@property (weak, nonatomic) IBOutlet UIWebView *webViewTitle;
//试题选项
@property (weak, nonatomic) IBOutlet UIWebView *webVIewSelect;
//试题标题高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webTitleHeight;
//试题选项高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webSelectHeight;
//收藏按钮
@property (weak, nonatomic) IBOutlet UIButton *buttonCollect;
//收藏按钮宽度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonCollectWidth;
//收藏图片
@property (weak, nonatomic) IBOutlet UIImageView *imageVIewCollect;
//已经收藏的试题
@property (nonatomic,strong) NSDictionary *dicCollectDone;
@property (weak, nonatomic) IBOutlet UIButton *buttonNote;
@property (weak, nonatomic) IBOutlet UIButton *buttonError;

//显示是否答题正确
@property (weak, nonatomic) IBOutlet UILabel *labAnswerStatus;
//用户答案
@property (weak, nonatomic) IBOutlet UILabel *labUserAnswer;
//正确答案
@property (weak, nonatomic) IBOutlet UILabel *labTureAnswer;
//试题解析
@property (weak, nonatomic) IBOutlet UIWebView *webAnalysis;
//试题解析高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webAnalysisHeight;
@property (weak, nonatomic) IBOutlet UIView *viewLine;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webSelectUpLaout;

//下划线
//@property (weak, nonatomic) IBOutlet UIView *viewLiness;
//是否是第一次加载，用于第二次刷新ui
@property (nonatomic,assign) BOOL isFirstLoad;
//试题索引，用于显示试题编号
@property (nonatomic,assign) NSInteger indexTopic;
//试题信息
@property (nonatomic,strong) NSDictionary *dicTopic;

//试题类型
@property (nonatomic,assign) NSInteger topicType;
- (CGFloat)setvalueForCellModel:(NSDictionary *)dic topicIndex:(NSInteger)index;
@property (nonatomic,assign) id <TopicAnalysisCellDelegateTest> delegateAnalysisCellClick;
@end
