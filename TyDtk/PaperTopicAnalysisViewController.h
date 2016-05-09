//
//  PaperTopicAnalysisViewController.h
//  TyDtk
//
//  Created by 天一文化 on 16/5/6.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol persentNotesDelegate<NSObject>
- (void)persentNotesViewController:(NSString *)questionId;
@end
@interface PaperTopicAnalysisViewController : UIViewController
//题干信息
@property (nonatomic,strong) NSString *topicTitle;
//每道题的字典
@property (nonatomic,strong) NSDictionary *dicTopic;
//每道题的索引
@property (nonatomic,assign) NSInteger topicIndex;
@property (nonatomic,assign) id <persentNotesDelegate> delegatePersent;
@end
