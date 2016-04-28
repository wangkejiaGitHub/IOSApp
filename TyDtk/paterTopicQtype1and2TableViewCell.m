//
//  paterTopicQtype1and2TableViewCell.m
//  TyDtk
//
//  Created by 天一文化 on 16/4/27.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "paterTopicQtype1and2TableViewCell.h"
@interface paterTopicQtype1and2TableViewCell()<UIWebViewDelegate,UIScrollViewDelegate>
@property (nonatomic,strong) UIWebView *webViewSelectCustom;
//??????????????????????????????????????????????????????
@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) UIImageView *lastImageView;
@property (nonatomic, assign)CGRect originalFrame;
@property (nonatomic, assign)BOOL isDoubleTap;

@property (nonatomic,strong) UIImageView *selectTapView;
//??????????????????????????????????????????????????????
@property (nonatomic,assign) CGFloat viewImageOy;

@end
@implementation paterTopicQtype1and2TableViewCell

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
            [imgViewTop sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",systemHttpsKaoLaTopicImg,imagUrl]]];
            imgViewTop.image = imageTop;
            //??????????????????????????????
            UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showZoomImageView:)];
            imgViewTop.userInteractionEnabled = YES;
            [imgViewTop addGestureRecognizer:tapImage];
            //??????????????????????????????
            [viewImage addSubview:imgViewTop];
            viewImgsH = viewImgsH+sizeImg.height;
        }
        viewImage.frame = CGRectMake(15, allowRet - 10, Scr_Width - 30, viewImgsH);
        _viewImageOy = viewImage.frame.origin.y;
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
        arraySelect = [arraySelect stringByReplacingOccurrencesOfString:@"<br/><br/>" withString:@"<br/>"];
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
            //?????????????????????????????????????
            //是否有选过的选项
            NSString *indexString = [NSString stringWithFormat:@"%ld",index];
            if ([_dicSelectDone.allKeys containsObject:indexString]) {
                NSString *selectString = _dicSelectDone[indexString];
                if ([button.titleLabel.text isEqualToString:selectString]) {
                    button.backgroundColor = ColorWithRGB(11, 141, 240);
                    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                }
            }
            //?????????????????????????????????????
            ///////////////////////////////////////
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
    //最后分别添加笔记和纠错按钮
    //添加笔记按钮
    UIButton *buttonNotes = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonNotes.frame = CGRectMake(Scr_Width - 70, allowRet, 60, 25);
    buttonNotes.backgroundColor = ColorWithRGB(200, 200, 200);
    buttonNotes.layer.masksToBounds = YES;
    buttonNotes.layer.cornerRadius = 2;
    [buttonNotes setTitle:@"笔记" forState:UIControlStateNormal];
    buttonNotes.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [buttonNotes setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [buttonNotes addTarget:self action:@selector(buttonNotesClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:buttonNotes];
    //添加纠错按钮
    UIButton *buttonError = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonError.frame = CGRectMake(10, allowRet, 60, 25);
    buttonError.backgroundColor = ColorWithRGB(200, 200, 200);
    buttonError.layer.masksToBounds = YES;
    buttonError.layer.cornerRadius = 2;
    [buttonError setTitle:@"纠错" forState:UIControlStateNormal];
    buttonError.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [buttonError setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [buttonError addTarget:self action:@selector(buttonErrorClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:buttonError];
    allowRet = allowRet + 40;
    self.backgroundColor = [UIColor clearColor];
    _dicTopic = dic;
    return allowRet;
}

//????????????????????????????????
//????????????????????????????????
// 笔记按钮
- (void)buttonNotesClick:(UIButton *)sender{
    NSInteger questionId = [_dicTopic[@"questionId"] integerValue];
    [self.delegateCellClick saveNotesOrErrorClick:questionId executeParameter:1];
}
// 纠错按钮
- (void)buttonErrorClick:(UIButton *)sender{
    NSInteger questionId = [_dicTopic[@"questionId"] integerValue];
    [self.delegateCellClick saveNotesOrErrorClick:questionId executeParameter:0];
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
    
    //    [self.delegateCellClick topicCellSelectClickTest:_indexTopic selectDone:dicUserAnswer];
    [self.delegateCellClick topicCellSelectClickTest:_indexTopic selectDone:dicUserAnswer isRefresh:YES];
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
        
        //????????????????????????????????????
        //添加已经选过的选项数组
        NSString *btnString = sender.titleLabel.text;
        //        [_arraySelectDone removeAllObjects];
        //        [_arraySelectDone addObject:btnString];
        [_dicSelectDone setValue:btnString forKey:[NSString stringWithFormat:@"%ld",_indexTopic]];
        NSDictionary *dicTest = @{[NSString stringWithFormat:@"%ld",_indexTopic]:btnString};
        NSLog(@"%@",dicTest);
        [self.delegateCellClick saveUserAnswerUseDictonary:dicTest];
        
        //////////////////////////////////////
        //判断是否是一题多问下面的选择题
        NSInteger topicParentId = [_dicTopic[@"parentId"] integerValue];
        BOOL isRefresh = NO;
        if (topicParentId == 0) {
            isRefresh = YES;
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
        //        [self.delegateCellClick topicCellSelectClickTest:_indexTopic selectDone:dicUserAnswer       ];
        [self.delegateCellClick topicCellSelectClickTest:_indexTopic selectDone:dicUserAnswer isRefresh:isRefresh];
        
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
//??????????????????????????????????????????????????
-(void)showZoomImageView:(UITapGestureRecognizer *)tap
{
    
    if (![(UIImageView *)tap.view image]) {
        return;
    }
    _selectTapView = (UIImageView *)tap.view;
    
    //scrollView作为背景
    UIScrollView *bgView = [[UIScrollView alloc] init];
    bgView.frame = [UIScreen mainScreen].bounds;
    bgView.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *tapBg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBgView:)];
    //
    UILongPressGestureRecognizer *tapmy = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longGestTap:)];
    tapmy.minimumPressDuration = 1.0;
    //    tapmy.numberOfTapsRequired = 1;
    tapmy.numberOfTouchesRequired = 1;
    [bgView addGestureRecognizer:tapmy];
    //
    [bgView addGestureRecognizer:tapBg];
    
    UIImageView *picView = (UIImageView *)tap.view;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = picView.image;
    imageView.frame = [bgView convertRect:picView.frame fromView:self.contentView];
    CGRect rectImg = imageView.frame;
    rectImg.origin.y = rectImg.origin.y + _viewImageOy;
    rectImg.origin.x = 15.0;
    imageView.frame = rectImg;
    [bgView addSubview:imageView];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:bgView];
    
    self.lastImageView = imageView;
    self.originalFrame = imageView.frame;
    self.scrollView = bgView;
    //最大放大比例
    self.scrollView.maximumZoomScale = 1.5;
    self.scrollView.delegate = self;
    
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = imageView.frame;
        frame.size.width = bgView.frame.size.width;
        frame.size.height = frame.size.width * (imageView.image.size.height / imageView.image.size.width);
        frame.origin.x = 0;
        frame.origin.y = (bgView.frame.size.height - frame.size.height) * 0.5;
        imageView.frame = frame;
    }];
}

-(void)tapBgView:(UITapGestureRecognizer *)tapBgRecognizer
{
    self.scrollView.contentOffset = CGPointZero;
    [UIView animateWithDuration:0.5 animations:^{
        self.lastImageView.frame = self.originalFrame;
        tapBgRecognizer.view.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [tapBgRecognizer.view removeFromSuperview];
        self.scrollView = nil;
        self.lastImageView = nil;
    }];
}
//长按保存图片
- (void)longGestTap:(UILongPressGestureRecognizer *)longTap{
    if (longTap.state == UIGestureRecognizerStateBegan) {
        [_scrollView removeFromSuperview];
        [self.delegateCellClick imageSaveQtype1Test:_selectTapView.image];
    }
}
//返回可缩放的视图
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.lastImageView;
}

//??????????????????????????????????????????????????

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
