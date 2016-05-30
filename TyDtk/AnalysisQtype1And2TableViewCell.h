//
//  AnalysisQtype1And2TableViewCell.h
//  TyDtk
//
//  Created by 天一文化 on 16/5/6.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TopicAnalysisCellDelegateTest<NSObject>

///保存用户已经收藏过的试题
- (void)saveUserCollectTiopic:(NSDictionary *)dic;
///提交笔记或纠错
- (void)saveNotesOrErrorClick:(NSInteger)questionId executeParameter:(NSInteger)parameterId;
///第一次加载
- (void)IsFirstload:(BOOL)isFirstLoad;
///非小题webview二次刷新
- (void)isWebLoadingCellHeight:(CGFloat)cellHeight withButtonOy:(CGFloat)buttonOy;
///小题webview二次刷新
- (void)isWebLoadingCellHeight:(CGFloat)cellHeight withButtonOy:(CGFloat)buttonOy withIndex:(NSInteger)index;
///将试题中所有的图片数组传递出去
- (void)imageTopicArray:(NSArray *)imageArray withImageIndex:(NSInteger)imageIndex;
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
//试题标题高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webTitleHeight;
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

@property (weak, nonatomic) IBOutlet UIView *viewLine;
//下划线
//@property (weak, nonatomic) IBOutlet UIView *viewLiness;
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
- (void)setvalueForCellModel:(NSDictionary *)dic topicIndex:(NSInteger)index;
@property (nonatomic,assign) id <TopicAnalysisCellDelegateTest> delegateAnalysisCellClick;
@end
