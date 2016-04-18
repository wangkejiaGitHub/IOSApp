//
//  PaterTopicTableViewCell.m
//  TyDtk
//  单选和多选的试题展示cell类，用于试题信息展示，cell上的控件适配
//  Created by 天一文化 on 16/4/11.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "PaterTopicTableViewCell.h"

@implementation PaterTopicTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (void)setvalueForCellModel:(NSDictionary *)dic topicIndex:(NSInteger)index{
    CGFloat allowRet = 0;
    
    //    for (NSString *keys in dic.allKeys) {
    //        NSLog(@"%@ == %@",keys,dic[keys]);
    //    }
    
    //    NSInteger topicType = [dic[@"qtype"] integerValue];
    //    NSLog(@"%ld",topicType);
    if (index == 1) {
        //        NSInteger topicType = [dic[@"qtype"] integerValue];
        //        NSLog(@"%ld",topicType);
        //        NSLog(@"fsf");
        //        NSLog(@"%f",Scr_Width);
    }
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
    _labTopicTitle.text = topicTitle;
    //试题编号
    _labTopicNumber.text = [NSString stringWithFormat:@"%ld、",index];
    _labNumberWidth.constant = _labTopicNumber.text.length*10+15;
    //试题类型（单选，多选）
    _labTopicType.text = [NSString stringWithFormat:@"(%@)",dic[@"typeName"]];
    CGSize labSize = [_labTopicTitle sizeThatFits:CGSizeMake(_labTopicTitle.frame.size.width, MAXFLOAT)];
    _labTitleHeight.constant = labSize.height;
    if (Scr_Width < 330) {
        _labTitleHeight.constant = _labTitleHeight.constant+20;
    }
    //添加选项(添加之前先删除所有手动添加的控件)
    //开始添加
    NSInteger seleNum = [dic[@"SelectNum"] integerValue];
    if (seleNum > 0) {
        NSString *selectOptions = dic[@"options"];
        selectOptions = [selectOptions stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        NSData *dataSting = [selectOptions dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *arrayOptions = [NSJSONSerialization JSONObjectWithData:dataSting options:NSJSONReadingMutableLeaves error:nil];
        /****获取选项的首字母集合（A,B,C,D...）****/
        NSMutableArray *arraySelectLetter = [NSMutableArray array];
        for (int i = 0; i<arrayOptions.count; i++) {
            NSString *selectStr = arrayOptions[i];
            selectStr = [selectStr substringToIndex:1];
            [arraySelectLetter addObject:selectStr];
        }
        /**************************************/
        NSString *arraySelect = [arrayOptions componentsJoinedByString:@""];
        arraySelect = [arraySelect stringByReplacingOccurrencesOfString:@" " withString:@""];
        arraySelect = [arraySelect stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        arraySelect = [arraySelect stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        arraySelect = [arraySelect stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        arraySelect = [arraySelect stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
        arraySelect = [arraySelect stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n\n"];
        _labSelectOp.text = arraySelect;
        CGSize sizeLabSelect = [_labSelectOp sizeThatFits:CGSizeMake(Scr_Width-30, MAXFLOAT)];
        _labSelectHeight.constant = sizeLabSelect.height;
        //添加button按钮选项
        /****先删除所有的button按钮，防止叠加*****/
        for (id subView in self.contentView.subviews) {
            if ([subView isKindOfClass:[UIButton class]]) {
                [subView removeFromSuperview];
            }
        }
        //        NSLog(@"%f",_labSelectOp.frame.origin.y);
        //button 按钮的Y坐标起点
        CGFloat btnSelectOriginy =_labTopicTitle.frame.origin.y + _labTitleHeight.constant+25+_labSelectHeight.constant+10;
        allowRet = btnSelectOriginy+30 +50;
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
        
        //添加笔记，纠错，收藏按钮
        for (int i = 0; i<3; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(10+(10+60)*i, btnSelectOriginy+30+20, 60, 20);
            if (i == 0) {
                [btn setTitle:@"笔记" forState:UIControlStateNormal];
            }
            else if (i == 1){
                [btn setTitle:@"纠错" forState:UIControlStateNormal];
            }
            else{
                [btn setTitle:@"收藏" forState:UIControlStateNormal];
            }
            
            btn.titleLabel.font = [UIFont systemFontOfSize:13.0];
            [btn setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
            btn.tag = 10+i;
            [btn addTarget:self action:@selector(buttonUserClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:btn];
        }
        
    }
    self.backgroundColor = [UIColor clearColor];
    _selfHeight = allowRet;
}
//点击选项按钮 11 141 240
- (void)buttonSelectClick:(UIButton *)sender{
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
        [self.delegateCellClick topicCellSelectClick:_indexTopic selectDone:sender.titleLabel.text];
    }
}
//点击 笔记、纠错、收藏按钮
- (void)buttonUserClick:(UIButton *)sender{
    [self.delegateCellClick cellHetghtChangeWithNE:sender.tag - 10];
}
/**
 添加笔记试图
 */
- (void)addNotesView:(CGFloat)viewOY{
    if (!_viewNotes) {
        _viewNotes = [[UIView alloc]initWithFrame:CGRectMake(10, viewOY - 120, Scr_Width - 20, 120)];
        _viewNotes.backgroundColor = [UIColor clearColor];
        UILabel *labText = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, 50, 20)];
        labText.text = @"笔记>>";
        labText.font = [UIFont systemFontOfSize:12.0];
        [_viewNotes addSubview:labText];
        UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(0, 30, _viewNotes.frame.size.width, 60)];
        textView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        textView.layer.masksToBounds = YES;
        textView.layer.cornerRadius = 5;
        textView.layer.borderWidth = 1;
        textView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        [_viewNotes addSubview:textView];
    }
    [self.contentView addSubview:_viewNotes];
}
/**
 添加纠错试图
 */
- (void)addErrorView:(CGFloat)viewOY{
    if (!_viewError) {
        _viewError = [[UIView alloc]initWithFrame:CGRectMake(10, viewOY-120, Scr_Width-20, 120)];
        _viewError.backgroundColor= [UIColor clearColor];
        UILabel *labText = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, 50, 20)];
        labText.text = @"纠错>>";
        labText.font = [UIFont systemFontOfSize:12.0];
        [_viewError addSubview:labText];
        UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(0, 30, _viewError.frame.size.width, 60)];
        textView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        textView.layer.masksToBounds = YES;
        textView.layer.cornerRadius = 5;
        textView.layer.borderWidth = 1;
        textView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        [_viewError addSubview:textView];
        
    }
    [self.contentView addSubview:_viewError];
}
@end