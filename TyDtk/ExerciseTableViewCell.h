//
//  ExerciseTableViewCell.h
//  TyDtk
//  练习记录的cell
//  Created by 天一文化 on 16/6/7.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ExerciseDelegate<NSObject>
- (void)cellAnalysisWithDictionary:(NSDictionary *)dicModel;
- (void)cellTopicWithDictionary:(NSDictionary *)dicModel parameterInt:(NSInteger)parameter;
@end
@interface ExerciseTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labTime;
@property (weak, nonatomic) IBOutlet UILabel *labRightOrError;
@property (weak, nonatomic) IBOutlet UILabel *labState;
@property (weak, nonatomic) IBOutlet UIButton *buttonDoTopic;
@property (weak, nonatomic) IBOutlet UIButton *buttonAnalysis;
@property (nonatomic,strong) NSDictionary *dicExercise;
@property (nonatomic,assign) id <ExerciseDelegate> delegateExercise;
- (void)setCellModelValueWithDictionary:(NSDictionary *)dicModel;
@end
