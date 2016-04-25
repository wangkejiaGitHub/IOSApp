//
//  PaterTopicTableViewCell.m
//  TyDtk
//  单选和多选的试题展示cell类，用于试题信息展示，cell上的控件适配
//  Created by 天一文化 on 16/4/11.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "PaterTopicTableViewCell.h"
@interface PaterTopicTableViewCell()<UIWebViewDelegate>
@property (nonatomic,strong) UIWebView *webViewSelectCustom;
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
    //多选答案默认为空
    _selectContentQtype2 = @"";
    _webViewTitle.delegate = self;
    _webVIewSelect.delegate = self;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (CGFloat)setvalueForCellModel:(NSDictionary *)dic topicIndex:(NSInteger)index{
    if (index == 9) {
        NSLog(@"%@",dic);
    }
    NSLog(@"topicIndex == %ld",index);
    CGFloat allowRet = 0;
    //判断视图是否有图片
    NSDictionary *dicImg = dic[@"ImageDictionary"];
    NSString *topicTitle = dic[@"title"];
    for (int i =0 ; i<4; i++) {
        topicTitle = [topicTitle stringByReplacingOccurrencesOfString:@"\n A" withString:@"<br/>A."];
        topicTitle = [topicTitle stringByReplacingOccurrencesOfString:@"\nA" withString:@"<br/>A."];
        topicTitle = [topicTitle stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        topicTitle = [topicTitle stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        topicTitle = [topicTitle stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    }
    
    if (dicImg.allKeys.count>0) {
        NSString *keysFirst = [NSString stringWithFormat:@"[%@]",[dicImg.allKeys firstObject]];
        NSRange ranFirst = [topicTitle rangeOfString:keysFirst];
        NSString *keysLast = [NSString stringWithFormat:@"[%@]",[dicImg.allKeys lastObject]];
        NSRange ranLast = [topicTitle rangeOfString:keysLast];
        topicTitle = [topicTitle stringByReplacingCharactersInRange:NSMakeRange(ranFirst.location, ranLast.location - ranFirst.location + keysLast.length) withString:@""];
    }
    
    ///////////////////////////////
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
    else{
        _webTitleHeight.constant = _webTitleHeight.constant+40;
    }
    allowRet = _webTitleHeight.constant + 50 +20;
    ////////////////////////////////////////////
    ///////////////////////////////////////////
    /// 如果试题有图片，就加载图片显示
    ////////////////////////////////////////////
    //防止图片试图复用时重复加载
    for (id subView in self.contentView.subviews) {
        if ([subView isKindOfClass:[UIView class]]) {
            UIView *vvv = (UIView *)subView;
            if (vvv.tag == 6666) {
                [vvv removeFromSuperview];
            }
        }
    }
    //用于展示图片的view层
    UIView *viewImage =[[UIView alloc]initWithFrame:CGRectMake(15, 0, Scr_Width-30, 50)];
    viewImage.backgroundColor =[UIColor clearColor];
    viewImage.tag = 6666;
    
    /**
     有关cell的高 viewImgsH
     */
    CGFloat viewImgsH = 0;
    if (dicImg.allKeys.count>0) {
        for (NSString *keyImg in dicImg.allKeys) {
            NSString *imagUrl = dicImg[keyImg];
            NSData *dataImg = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",systemHttpsKaoLaTopicImg,imagUrl]]];
            UIImage *imageTop = [UIImage imageWithData:dataImg];
            CGSize sizeImg = imageTop.size;
            
            if (sizeImg.width>Scr_Width - 30) {
                CGFloat wHBL = sizeImg.height/sizeImg.width;
                sizeImg.width = Scr_Width-30;
                sizeImg.height = (Scr_Width-30)*wHBL;
            }
            UIImageView *imgViewTop = [[UIImageView alloc]initWithFrame:CGRectMake(0, viewImgsH, sizeImg.width, sizeImg.height)];
            imgViewTop.image = imageTop;
            [viewImage addSubview:imgViewTop];
            viewImgsH = viewImgsH+sizeImg.height;
        }
        viewImage.frame = CGRectMake(15, allowRet - 10, Scr_Width - 30, viewImgsH);
        [self.contentView addSubview:viewImage];
        allowRet = allowRet + viewImgsH + 30;
    }
    else{
        viewImage = nil;
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
        arraySelect = [arraySelect stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
        //如果既有图片，也有选项的话，就用自己自定义的webView
        if (dicImg.allKeys.count>0 && arrayOptions.count > 0) {
            [_webViewSelectCustom removeFromSuperview];
            [_webVIewSelect removeFromSuperview];
            _webViewSelectCustom = [[UIWebView alloc]initWithFrame:CGRectMake(10, allowRet, Scr_Width - 20, labSize.height)];
            _webViewSelectCustom.opaque = NO;
            _webViewSelectCustom.scrollView.scrollEnabled = NO;
            _webViewSelectCustom.backgroundColor = [UIColor clearColor];
            [_webViewSelectCustom loadHTMLString:arraySelect baseURL:nil];
            [self.contentView addSubview:_webViewSelectCustom];
            allowRet = _webViewSelectCustom.frame.origin.y + labSize.height+10;
            NSLog(@"fsffdsfs");
//            _webViewSelectCustom = 
        }//有图片或者只有选项的时候用原来的
        else{
            
            _webSelectHeight.constant = labSize.height;
            [_webVIewSelect loadHTMLString:arraySelect baseURL:nil];
                       allowRet = allowRet + _webSelectHeight.constant+20;
        }
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
        CGFloat btnSelectOriginy = allowRet;
        /****获取选项的首字母集合（A,B,C,D...）****/
        //选择题以图片形式展现，以文字形式展现的选项文字
        NSArray *arraySelectOp = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z"];
        /**************************************/
        //开始添加button按钮
        CGFloat btnSpa = 10;
        CGFloat btn_W = (Scr_Width - 20 - (seleNum-1)*btnSpa)/seleNum;
        for (int i =0; i<seleNum; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(10+(btn_W+btnSpa)*i, btnSelectOriginy, btn_W, 30);
            button.tag = 100+i;
            [button setTitle:arraySelectOp[i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
            button.backgroundColor = ColorWithRGB(200, 200, 200);
            button.layer.borderWidth = 1;
            button.layer.borderColor = [[UIColor lightGrayColor] CGColor];
            button.layer.masksToBounds = YES;
            button.layer.cornerRadius = 3;
            button.titleLabel.font = [UIFont systemFontOfSize:19.0];
            [button addTarget:self action:@selector(buttonSelectClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:button];
        }
        //如果是多项选择题，多添加一个提交多选答案的按钮
        NSInteger topicType = [dic[@"qtype"] integerValue];
        if (topicType == 2) {
            allowRet = btnSelectOriginy+30 +50;
            UIButton *btnSubmit = [UIButton buttonWithType:UIButtonTypeCustom];
            btnSubmit.frame = CGRectMake(Scr_Width-140, btnSelectOriginy+30+15, 120, 25);
            [btnSubmit setTitle:@"保存并跳到下一题" forState:UIControlStateNormal];
            btnSubmit.layer.masksToBounds = YES;
            btnSubmit.layer.cornerRadius = 3;
            btnSubmit.backgroundColor = [UIColor groupTableViewBackgroundColor];
            btnSubmit.titleLabel.font = [UIFont systemFontOfSize:13.0];
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
    //试题Id
    NSString *questionId =[NSString stringWithFormat:@"%ld",[_dicTopic[@"questionId"] integerValue]];
    //试题类型
    NSString *qtype =[NSString stringWithFormat:@"%ld",[_dicTopic[@"qtype"] integerValue]];
    //正确答案
    NSString *answer = _dicTopic[@"answer"];
    
    NSDictionary *dicUserAnswer = @{@"QuestionID":questionId,@"QType":qtype,@"UserAnswer":_selectContentQtype2,@"TrueAnswer":answer,@"Score":@"0"};
    
    [self.delegateCellClick topicCellSelectClick:_indexTopic selectDone:dicUserAnswer];
}
//点击选项按钮 11 141 240
- (void)buttonSelectClick:(UIButton *)sender{
    //单选模式
    if (_topicType == 1) {
        
        for (id subView in self.contentView.subviews) {
            if ([subView isKindOfClass:[UIButton class]]) {
                UIButton *btn = (UIButton *)subView;
                if (btn.tag != 1111) {
                    if (btn.tag == sender.tag) {
                        btn.backgroundColor = ColorWithRGB(11, 141, 240);
                        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    }
                    else{
                        btn.backgroundColor = ColorWithRGB(200, 200, 200);
                        [btn setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
                    }
                    
                }
            }
        }
        //试题Id
        NSString *questionId =[NSString stringWithFormat:@"%ld",[_dicTopic[@"questionId"] integerValue]];
        //试题类型
        NSString *qtype =[NSString stringWithFormat:@"%ld",[_dicTopic[@"qtype"] integerValue]];
        //正确答案
        NSString *answer = _dicTopic[@"answer"];
        //用户答案
        NSString *userAnswer = sender.titleLabel.text;
        
        NSDictionary *dicUserAnswer = @{@"QuestionID":questionId,@"QType":qtype,@"UserAnswer":userAnswer,@"TrueAnswer":answer,@"Score":@"0"};
        [self.delegateCellClick topicCellSelectClick:_indexTopic selectDone:dicUserAnswer];
        
    }
    //多选模式
    else{
        
        sender.selected = !sender.selected;
        if (sender.selected) {
            sender.backgroundColor = ColorWithRGB(11, 141, 240);
            [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _selectContentQtype2 = [_selectContentQtype2 stringByAppendingString:sender.titleLabel.text];
            
        }
        else{
            [sender setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
            sender.backgroundColor = ColorWithRGB(200, 200, 200);
            _selectContentQtype2 = [_selectContentQtype2 stringByReplacingOccurrencesOfString:sender.titleLabel.text withString:@""];
        }
    }
}
//收藏按钮
- (IBAction)collectBtnClick:(id)sender {
    //    NSLog(@"fsfsffsfdsff");
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    if (webView.tag == 10) {
        _webTitleHeight.constant = webView.scrollView.contentSize.height;
    }
    else if (webView.tag == 11){
        _webSelectHeight.constant = webView.scrollView.contentSize.height;
    }
}
- (void)submitNotes{
    NSLog(@"submit");
}
@end