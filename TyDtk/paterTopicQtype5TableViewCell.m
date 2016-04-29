//
//  paterTopicQtype5TableViewCell.m
//  TyDtk
//
//  Created by 天一文化 on 16/4/27.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "paterTopicQtype5TableViewCell.h"
@interface paterTopicQtype5TableViewCell()<UIWebViewDelegate,UIScrollViewDelegate>
//??????????????????????????????????????????????????????
@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) UIImageView *lastImageView;
@property (nonatomic, assign)CGRect originalFrame;
@property (nonatomic, assign)BOOL isDoubleTap;

@property (nonatomic,strong) UIImageView *selectTapView;
//??????????????????????????????????????????????????????
@property (nonatomic,assign) CGFloat viewImageOy;
@end
@implementation paterTopicQtype5TableViewCell

- (void)awakeFromNib {
    // Initialization code
    _imageCollect.layer.masksToBounds = YES;
    _imageCollect.layer.cornerRadius = 2;
    _webViewTitle.scrollView.scrollEnabled = NO;
    _webViewTitle.opaque = NO;
    _webViewTitle.backgroundColor =[UIColor clearColor];
    //多选答案默认为空
    _webViewTitle.delegate = self;
    _buttonCanDo.layer.masksToBounds = YES;
    _buttonCanDo.layer.cornerRadius = 3;
    _buttonCanDo.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [_buttonCanDo setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    _buttonCanDonot.layer.masksToBounds = YES;
    _buttonCanDonot.layer.cornerRadius = 3;
    _buttonCanDonot.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [_buttonCanDonot setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
}
- (CGFloat)setvalueForCellModel:(NSDictionary *)dic topicIndex:(NSInteger)index{
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
    _labNumber.text = [NSString stringWithFormat:@"%ld、",index];
    _labNumberWidth.constant = _labNumber.text.length*10+15;
    
    //试题类型
    _labTopicType.text = [NSString stringWithFormat:@"(%@)",dic[@"typeName"]];
    CGSize labSize = [labTest sizeThatFits:CGSizeMake(labTest.frame.size.width, MAXFLOAT)];
    [_webViewTitle loadHTMLString:topicTitle baseURL:nil];
    _webViewTitleHeight.constant = labSize.height;
    
    if (Scr_Width > 330) {
        _webViewTitleHeight.constant = _webViewTitleHeight.constant+20;
    }
    else{
        _webViewTitleHeight.constant = _webViewTitleHeight.constant+40;
    }
    allowRet = _webViewTitleHeight.constant + 50 +20;
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
    //?????????????????????????????????????
    //是否有选过的选项
    for (id subView in self.contentView.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subView;
            if (button.tag != 1111) {
                
                NSString *indexString = [NSString stringWithFormat:@"%ld",index];
                if ([_dicSelectDone.allKeys containsObject:indexString]) {
                    NSString *selectString = _dicSelectDone[indexString];
                    if ([button.titleLabel.text isEqualToString:selectString]) {
                        button.backgroundColor = ColorWithRGB(11, 141, 240);
                        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    }
                }
                
            }
        }
    }
    
    //?????????????????????????????????????
    ///////////////////////////////////////
    
    allowRet = allowRet + 75;
    //最后分别添加笔记和纠错按钮
    //添加笔记按钮
    UIButton *buttonNotes = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonNotes.frame = CGRectMake(Scr_Width - 75, allowRet - 5, 60, 23);
    buttonNotes.backgroundColor = ColorWithRGB(200, 200, 200);
    buttonNotes.layer.masksToBounds = YES;
    buttonNotes.layer.cornerRadius = 2;
    [buttonNotes setTitle:@"笔记" forState:UIControlStateNormal];
    buttonNotes.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [buttonNotes setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    buttonNotes.tag = 1111;
    [buttonNotes addTarget:self action:@selector(buttonNotesClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:buttonNotes];
    //添加纠错按钮
    UIButton *buttonError = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonError.frame = CGRectMake(15, allowRet - 5, 60, 23);
    buttonError.backgroundColor = ColorWithRGB(200, 200, 200);
    buttonError.layer.masksToBounds = YES;
    buttonError.layer.cornerRadius = 2;
    [buttonError setTitle:@"纠错" forState:UIControlStateNormal];
    buttonError.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [buttonError setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    buttonError.tag = 1111;
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
- (IBAction)buttonDoTopicClick:(UIButton *)sender {
    for (id subView in self.contentView.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)subView;
            if (btn.tag != 1111) {
                if (btn.tag == sender.tag) {
                    btn.backgroundColor = ColorWithRGB(11, 141, 240);
                    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                }
                else{
                    btn.backgroundColor = [UIColor groupTableViewBackgroundColor];
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
    [self.delegateCellClick saveUserAnswerUseDictonary:dicTest];
    //////////////////////////////////////
    
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
//    NSString *answer = _dicTopic[@"answer"];
    //用户答案
    NSString *userAnswer = sender.titleLabel.text;
    if ([userAnswer isEqualToString:@"会作答"]) {
        userAnswer = @"1";
    }
    else{
        userAnswer = @"0";
    }
    NSDictionary *dicUserAnswer = @{@"QuestionID":questionId,@"QType":qtype,@"UserAnswer":userAnswer,@"Score":@"0"};
    //        [self.delegateCellClick topicCellSelectClickTest:_indexTopic selectDone:dicUserAnswer       ];
    [self.delegateCellClick topicCellSelectClickTest:_indexTopic selectDone:dicUserAnswer isRefresh:isRefresh];
    

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
    //    if (longTap.state == UIGestureRecognizerStateBegan) {
    //        [_scrollView removeFromSuperview];
    //        [self.delegateCellClick imageSaveQtype1:_selectTapView.image];
    //    }
}
//返回可缩放的视图
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.lastImageView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
