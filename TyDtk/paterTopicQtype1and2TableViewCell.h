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
- (void)topicCellSelectClickTest:(NSInteger)indexTpoic selectDone:(NSDictionary*)dicUserAnswer;
- (void)imageSaveQtype1Test:(UIImage *)image;
@end
@interface paterTopicQtype1and2TableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labTopicNumber;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labNumberWidth;
@property (weak, nonatomic) IBOutlet UILabel *labTopicType;
@property (weak, nonatomic) IBOutlet UIWebView *webViewTitle;
@property (weak, nonatomic) IBOutlet UIWebView *webVIewSelect;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webTitleHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webSelectHeight;

@property (weak, nonatomic) IBOutlet UIButton *buttonCollect;
@property (weak, nonatomic) IBOutlet UIImageView *imageVIewCollect;
@property (nonatomic,assign) NSInteger indexTopic;
@property (nonatomic,strong) NSDictionary *dicTopic;
@property (nonatomic,strong) NSString *selectContentQtype2;
@property (nonatomic,assign) NSInteger topicType;
@property (nonatomic,assign) id <TopicCellDelegateTest> delegateCellClick;
- (CGFloat)setvalueForCellModel:(NSDictionary *)dic topicIndex:(NSInteger)index;
@end
