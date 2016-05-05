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
@property (weak, nonatomic) IBOutlet UILabel *labNumber;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labNumberWidth;
@property (weak, nonatomic) IBOutlet UILabel *labTopicType;
@property (weak, nonatomic) IBOutlet UIImageView *imageCollect;
@property (weak, nonatomic) IBOutlet UIButton *buttonCollect;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonCollectWidth;

@property (weak, nonatomic) IBOutlet UIWebView *webViewTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webViewTitleHeight;
@property (weak, nonatomic) IBOutlet UITextView *textViewAnswer;
@property (weak, nonatomic) IBOutlet UIButton *buttonSaveAnswer;
@property (nonatomic,strong) NSDictionary *dicCollectDone;
@property (nonatomic,strong) NSDictionary *dicTopic;
@property (nonatomic,assign) NSInteger indexTopic;
@property (nonatomic,assign) BOOL isFirstLoad;
//已经选过的选项
@property (nonatomic,strong) NSDictionary *dicSelectDone;
@property (nonatomic,assign) id <TopicCellDelegateTest> delegateCellClick;
- (CGFloat)setvalueForCellModel:(NSDictionary *)dic topicIndex:(NSInteger)index;
@end
