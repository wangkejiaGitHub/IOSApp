//
//  PaterTopicTableViewCell.m
//  TyDtk
//  单选和多选的试题展示cell类，用于试题信息展示，cell上的控件适配
//  Created by 天一文化 on 16/4/11.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "PaterTopicTableViewCell.h"
@interface PaterTopicTableViewCell()

@end
@implementation PaterTopicTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _imageVIewCollect.layer.masksToBounds = YES;
    _imageVIewCollect.layer.cornerRadius = 2;
    _webViewTitle.scrollView.scrollEnabled = NO;
    _webVIewSelect.scrollView.scrollEnabled = NO;
    _webViewTitle.opaque = NO;
    _webVIewSelect.opaque = NO;
    _webViewTitle.backgroundColor =[UIColor clearColor];
    _webVIewSelect.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (CGFloat)setvalueForCellModel:(NSDictionary *)dic topicIndex:(NSInteger)index{
    CGFloat allowRet = 0;
    //判断视图是否有图片
    NSDictionary *dicImg = dic[@"ImageDictionary"];
    NSString *topicTitle = dic[@"title"];

    for (int i =0 ; i<4; i++) {
        topicTitle = [topicTitle stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        topicTitle = [topicTitle stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        topicTitle = [topicTitle stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    }
    if (dicImg.allKeys.count>0) {
        NSString *keysFirst = [dicImg.allKeys firstObject];
        NSRange ran = [topicTitle rangeOfString:keysFirst];
        topicTitle = [topicTitle substringToIndex:ran.location-4];
    }
    //题目
    UILabel *labTest = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, Scr_Width - 30, 30)];
    labTest.numberOfLines = 0;
    labTest.font = [UIFont systemFontOfSize:17.0];
    if (Scr_Width > 320) {
        labTest.font = [UIFont systemFontOfSize:19.0];
    }
    labTest.text = topicTitle;
    //试题编号
    _labTopicNumber.text = [NSString stringWithFormat:@"%ld、",index];
    _labNumberWidth.constant = _labTopicNumber.text.length*10+15;
    //试题类型（单选，多选）
    _labTopicType.text = [NSString stringWithFormat:@"(%@)",dic[@"typeName"]];
    CGSize labSize = [labTest sizeThatFits:CGSizeMake(labTest.frame.size.width, MAXFLOAT)];
    [_webViewTitle loadHTMLString:topicTitle baseURL:nil];
    _webTitleHeight.constant = labSize.height;
    if (Scr_Width > 330) {
        _webTitleHeight.constant = _webTitleHeight.constant+20;
    }
    //添加选项(添加之前先删除所有手动添加的控件)
    //开始添加
    NSInteger seleNum = [dic[@"SelectNum"] integerValue];
    if (seleNum > 0) {
        NSString *selectOptions = dic[@"options"];
        selectOptions = [selectOptions stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        NSData *dataSting = [selectOptions dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *arrayOptions = [NSJSONSerialization JSONObjectWithData:dataSting options:NSJSONReadingMutableLeaves error:nil];

        NSString *arraySelect = [arrayOptions componentsJoinedByString:@""];
        
        arraySelect = [arraySelect stringByReplacingOccurrencesOfString:@" " withString:@""];
        arraySelect = [arraySelect stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        arraySelect = [arraySelect stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        arraySelect = [arraySelect stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        arraySelect = [arraySelect stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
        arraySelect = [arraySelect stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n\n"];
        UILabel *labTestSelect = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, Scr_Width-40, 30)];
        labTestSelect.numberOfLines = 0;
        labTestSelect.text = arraySelect;
        CGSize labSize = [labTestSelect sizeThatFits:CGSizeMake(labTestSelect.frame.size.width, MAXFLOAT)];
        
        _webSelectHeight.constant = labSize.height;
        arraySelect = [arraySelect stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
        [_webVIewSelect loadHTMLString:arraySelect baseURL:nil];
//        //添加button按钮选项
        /****先删除所有的button按钮，防止叠加*****/
        for (id subView in self.contentView.subviews) {
            if ([subView isKindOfClass:[UIButton class]]) {
                UIButton *btn = (UIButton*)subView;
                if (btn.tag!=1111) {
                    [subView removeFromSuperview];
                }
               
            }
        }
        //button 按钮的Y坐标起点
        CGFloat btnSelectOriginy =_webViewTitle.frame.origin.y + _webTitleHeight.constant+25+_webSelectHeight.constant+20;
        
        /****获取选项的首字母集合（A,B,C,D...）****/
        NSMutableArray *arraySelectLetter = [NSMutableArray array];
        for (int i = 0; i<arrayOptions.count; i++) {
            NSString *selectStr = arrayOptions[i];
            selectStr = [selectStr substringToIndex:1];
            [arraySelectLetter addObject:selectStr];
        }
        /**************************************/
        //开始添加button按钮
        CGFloat btnSpa = 10;
        CGFloat btn_W = (Scr_Width - 20 - (arraySelectLetter.count-1)*btnSpa)/arraySelectLetter.count;
        for (int i =0; i<arraySelectLetter.count; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(10+(btn_W+btnSpa)*i, btnSelectOriginy, btn_W, 30);
            button.tag = 100+i;
            [button setTitle:arraySelectLetter[i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
            button.backgroundColor = ColorWithRGB(200, 200, 200);
            button.layer.borderWidth = 1;
            button.layer.borderColor = [[UIColor lightGrayColor] CGColor];
            button.layer.masksToBounds = YES;
            button.layer.cornerRadius = 3;
            [button addTarget:self action:@selector(buttonSelectClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:button];
        }
        //如果是多项选择题，多添加一个提交多选答案的按钮
        NSInteger topicType = [dic[@"qtype"] integerValue];
        if (topicType == 2) {
            allowRet = btnSelectOriginy+30 +50;
            UIButton *btnSubmit = [UIButton buttonWithType:UIButtonTypeCustom];
            btnSubmit.frame = CGRectMake(Scr_Width-140, btnSelectOriginy+30+15, 130, 20);
            [btnSubmit setTitle:@"提交并跳到下一题" forState:UIControlStateNormal];
            btnSubmit.titleLabel.font = [UIFont systemFontOfSize:13.0];
            btnSubmit.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            [btnSubmit setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
            [btnSubmit addTarget:self action:@selector(buttonSubmit:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:btnSubmit];
        }
        else{
            allowRet = btnSelectOriginy+30 +20;
        }
    }
    
    self.backgroundColor = [UIColor clearColor];
     _dicTopic = dic;
     return allowRet;
}
//多项选择题的提交按钮
- (void)buttonSubmit:(UIButton *)sender{
//    [self.delegateCellClick topicCellSelectClick:_indexTopic selectDone:sender.titleLabel.text];
}
//点击选项按钮 11 141 240
- (void)buttonSelectClick:(UIButton *)sender{
    //单选模式
    if (_topicType == 1) {
        
        for (id subView in self.contentView.subviews) {
            if ([subView isKindOfClass:[UIButton class]]) {
                UIButton *btn = (UIButton *)subView;
                if (btn.tag == sender.tag) {
                    btn.backgroundColor = ColorWithRGB(11, 141, 240);
                }
                else{
                    btn.backgroundColor = ColorWithRGB(200, 200, 200);
                }
            }
        }
        //试题Id
        NSInteger questionId = [_dicTopic[@"questionId"] integerValue];
        //试题类型
        NSInteger qtype = [_dicTopic[@"qtype"] integerValue];
        //正确答案
        NSString *answer = _dicTopic[@"answer"];
        //用户答案
        NSString *userAnswer = sender.titleLabel.text;
        
        NSDictionary *dicUserAnswer = @{@"QuestionID":@"",@"QType":@"",@"UserAnswer":@"",@"TrueAnswer":@"",@"Score":@""};
//        NSInteger ewf = _topicType[@"questionId"]
//        [self.delegateCellClick topicCellSelectClick:_indexTopic selectDone:sender.titleLabel.text];
        [self.delegateCellClick topicCellSelectClick:_indexTopic selectDone:nil];
        
    }
    //多选模式
    else{
        sender.selected = !sender.selected;
        if (sender.selected) {
            sender.backgroundColor = ColorWithRGB(11, 141, 240);
        }
        else{
            sender.backgroundColor = ColorWithRGB(200, 200, 200);
        }
    }
}
//收藏按钮
- (IBAction)collectBtnClick:(id)sender {
    NSLog(@"fsfsffsfdsff");
}

@end