//
//  ExerciseTableViewCell.m
//  TyDtk
//
//  Created by 天一文化 on 16/6/7.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "ExerciseTableViewCell.h"

@implementation ExerciseTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _buttonDoTopic.layer.borderWidth = 1;
    _buttonDoTopic.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _buttonDoTopic.backgroundColor = ColorWithRGB(200, 200, 200);
    
    _buttonAnalysis.layer.borderWidth = 1;
    _buttonAnalysis.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _buttonAnalysis.backgroundColor = ColorWithRGB(200, 200, 200);
    
    _labState.layer.masksToBounds = YES;
    _labState.layer.cornerRadius = 3;
    _labState.backgroundColor = ColorWithRGB(200, 200, 200);
    
    [_buttonAnalysis setTitle:@"查看解析" forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}
- (void)setCellModelValueWithDictionary:(NSDictionary *)dicModel{
    _labTitle.text = dicModel[@"Title"];
    _labTime.text = [DateStringCompare dataStringCompareWithNowTime:dicModel[@"AddTime"]];
        NSString *labREtext = [NSString stringWithFormat:@"正确数:【%ld】 错误数:【%ld】",[dicModel[@"RightNum"]integerValue],[dicModel[@"ErrorNum"] integerValue]];
    _labRightOrError.text = labREtext;
    if ([dicModel[@"State"] integerValue] == 0 | [dicModel[@"State"] integerValue] == 2){
        _labState.text = @"未完成";
        _labState.backgroundColor = ColorWithRGB(243, 55, 48);
        _labState.textColor = [UIColor whiteColor];
        _buttonAnalysis.hidden = YES;
        [_buttonDoTopic setTitle:@"继续做题" forState:UIControlStateNormal];
//        _labState.backgroundColor = [UIColor redColor];
    }
    else if([dicModel[@"State"] integerValue] == 1){
        _labState.text = @"已完成";
        [_buttonDoTopic setTitle:@"再做一次" forState:UIControlStateNormal];
        _buttonAnalysis.hidden = NO;
        _labState.backgroundColor = ColorWithRGB(200, 200, 200);
        _labState.textColor = [UIColor lightGrayColor];
    }
}
///查看解析按钮
- (IBAction)buttonAnalysisClick:(UIButton *)sender {
    [self.delegateExercise cellAnalysisWithDictionary:_dicExercise];
}
///做题按钮
- (IBAction)buttonTopicClick:(UIButton *)sender {
    NSInteger stateId = [_dicExercise[@"State"] integerValue];
    [self.delegateExercise cellTopicWithDictionary:_dicExercise parameterInt:stateId];
}

@end
