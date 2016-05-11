//
//  PaterTopicQtype6TableViewCell.m
//  TyDtk
//
//  Created by 天一文化 on 16/4/19.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "PaterTopicQtype6TableViewCell.h"
@interface PaterTopicQtype6TableViewCell()<UIWebViewDelegate,UIScrollViewDelegate>
//??????????????????????????????????????????????????????
@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) UIImageView *lastImageView;
@property (nonatomic, assign)CGRect originalFrame;
@property (nonatomic, assign)BOOL isDoubleTap;

@property (nonatomic,strong) UIImageView *selectTapView;
//??????????????????????????????????????????????????????
//存放图片的view的高度
@property (nonatomic,assign) CGFloat viewImageOy;
//存放图片的view
@property (nonatomic,strong) UIView *viewImage;
@end
@implementation PaterTopicQtype6TableViewCell

- (void)awakeFromNib {
    // Initialization code
    _webViewTitle.backgroundColor = [UIColor clearColor];
    _webViewTitle.scrollView.scrollEnabled = NO;
    _webViewTitle.opaque = NO;
    _webViewTitle.delegate = self;
    _viewImage = nil;
}

- (void)setvalueForCellModel:(NSDictionary *)dic topicIndex:(NSInteger)index{
    if (index == 7) {
        NSLog(@"fsf");
    }
    NSLog(@"topicIndex = %ld",index);
    //判断视图是否有图片
    NSDictionary *dicImg = dic[@"ImageDictionary"];
    NSString *topicTitle = dic[@"title"];
    for (int i =0 ; i<4; i++) {
        topicTitle = [topicTitle stringByReplacingOccurrencesOfString:@"\n\r\n\t" withString:@""];
        topicTitle = [topicTitle stringByReplacingOccurrencesOfString:@"\r\n\n" withString:@"\n"];
        topicTitle = [topicTitle stringByReplacingOccurrencesOfString:@"\n\r" withString:@"\n"];
        topicTitle = [topicTitle stringByReplacingOccurrencesOfString:@"\n\n" withString:@"<br/>"];
        topicTitle = [topicTitle stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
        topicTitle = [topicTitle stringByReplacingOccurrencesOfString:@" " withString:@""];
        topicTitle = [topicTitle stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        topicTitle = [topicTitle stringByReplacingOccurrencesOfString:@"<br/><br/>" withString:@"<br/>"];
        
    }
    if (dicImg.allKeys.count>0) {
        //获取参数字符串长度
        NSInteger imgCount = 0;
        for (NSString *keyLength in dicImg.allKeys) {
            imgCount = imgCount + keyLength.length + 2;
        }
        //第一个需要去除的位置和长度
        NSString *keyImageFirst = [dicImg.allKeys firstObject];
        keyImageFirst = [keyImageFirst stringByReplacingOccurrencesOfString:@"[" withString:@""];
        keyImageFirst = [keyImageFirst stringByReplacingOccurrencesOfString:@"]" withString:@""];
        keyImageFirst = [NSString stringWithFormat:@"[%@]",keyImageFirst];
        NSRange ranFirst = [topicTitle rangeOfString:keyImageFirst];
        //最后一个需要去除的位置和长度
        NSString *keyImageLast = [dicImg.allKeys lastObject];
        keyImageLast = [keyImageLast stringByReplacingOccurrencesOfString:@"[" withString:@""];
        keyImageLast = [keyImageLast stringByReplacingOccurrencesOfString:@"]" withString:@""];
        keyImageLast = [NSString stringWithFormat:@"[%@]",keyImageLast];
        NSRange ranLast = [topicTitle rangeOfString:keyImageLast];
        
        NSRange str = NSMakeRange(ranFirst.location - 6, ranLast.location-ranFirst.location+keyImageLast.length+6);
        //试题题目里面只有image标签
        if (ranFirst.location < 25) {
            for (NSString *keys in dicImg.allKeys) {
                NSString *keysS = [NSString stringWithFormat:@"[%@]",keys];
                topicTitle = [topicTitle stringByReplacingOccurrencesOfString:keysS withString:@""];
            }
        }
        else{
            topicTitle = [topicTitle stringByReplacingCharactersInRange:str withString:@""];
        }
        
    }
    //主要针对医学题目进行适配
    NSInteger leng = topicTitle.length;
    if ([topicTitle rangeOfString:@"A"].location == 0 && [topicTitle rangeOfString:@"B"].length>0 && [topicTitle rangeOfString:@"C"].length>0 && [topicTitle rangeOfString:@"C"].length>0) {
        if (leng>80) {
            _webTitleHeight.constant = 153;
        }
        else{
            _webTitleHeight.constant = 130;
        }
    }
    else{
        //题目
        UILabel *labTitleTest = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, Scr_Width-30, 30)];
        labTitleTest.text = topicTitle;
        labTitleTest.numberOfLines = 0;
        labTitleTest.font = [UIFont systemFontOfSize:19];
        if (Scr_Width > 320) {
            labTitleTest.font = [UIFont systemFontOfSize:18.5];
        }
        //        CGSize labSize = [labTitleTest sizeThatFits:CGSizeMake(labTitleTest.frame.size.width, MAXFLOAT)];
        //        _webTitleHeight.constant = labSize.height;
    }
    NSString *htmlString = [NSString stringWithFormat:@"<html><body><div style='word-break:break-all;'>%@</div></body></html>",topicTitle];
    [_webViewTitle loadHTMLString:htmlString baseURL:nil];
    
    //试题编号
    _labNumber.text = [NSString stringWithFormat:@"%ld、",index];
    _labNumberWidth.constant = _labNumber.text.length*10+15;
    //试题类型（案例分析）
    _labTitleType.text = [NSString stringWithFormat:@"(%@)",dic[@"typeName"]];
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
    _viewImage =[[UIView alloc]initWithFrame:CGRectMake(15, 0, Scr_Width-30, 50)];
    _viewImage.backgroundColor =[UIColor clearColor];
    _viewImage.tag = 6666;
    /**
     有关cell的高 viewImgsH
     */
    CGFloat viewImgsH = 0;
    if (dicImg.allKeys.count>0) {
        for (NSString *keyImg in dicImg.allKeys) {
            NSString *imagUrl = dicImg[keyImg];
            __block UIImage *imageTop = [[UIImage alloc]init];
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            
            [manager downloadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",systemHttpsKaoLaTopicImg,imagUrl]] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                imageTop = image;
                //如果是第一次加载，再次刷新ui让图片显示出来
                if (_isFirstLoad) {
                    [self.delegateCellClick IsFirstload:NO];
                }
            }];
            
            CGSize sizeImg = imageTop.size;
            
            if (sizeImg.width>Scr_Width - 30) {
                CGFloat wHBL = sizeImg.height/sizeImg.width;
                sizeImg.width = Scr_Width-30;
                sizeImg.height = (Scr_Width-30)*wHBL;
            }
            UIImageView *imgViewTop = [[UIImageView alloc]initWithFrame:CGRectMake(0, viewImgsH, sizeImg.width, sizeImg.height)];
            imgViewTop.image = imageTop;
            //???????????图片手势???????????????????
            UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showZoomImageView:)];
            imgViewTop.userInteractionEnabled = YES;
            [imgViewTop addGestureRecognizer:tapImage];
            //???????????图片手势??????????????????？
            [_viewImage addSubview:imgViewTop];
            viewImgsH = viewImgsH+sizeImg.height;
        }
        UIView *viewLineImgDown = [[UIView alloc]initWithFrame:CGRectMake(10,_imageOy+5, Scr_Width-20, 1)];
        viewLineImgDown.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:viewLineImgDown];

        _viewImage.frame = CGRectMake(15, _imageOy+10, Scr_Width - 30, viewImgsH);
        [self.contentView addSubview:_viewImage];

        //？？？？？随时记录要返回的cell的高度
        _viewImageOy = _viewImage.frame.origin.y;
    }
    else{
        _viewImage = nil;
    }
    //添加保存试题按钮，主要用同步答题卡
    UIButton *buttonSave = (UIButton *)[self.contentView viewWithTag:102];
    if (buttonSave) {
        [buttonSave removeFromSuperview];
    }
    UIButton *buttonSaveAnswer = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonSaveAnswer.tag = 102;
    buttonSaveAnswer.frame = CGRectMake(Scr_Width-170, _imageOy + _viewImage.bounds.size.height+20, 160, 25);
    [buttonSaveAnswer setTitle:@"保存本题答案并跳转下一题" forState:UIControlStateNormal];
    buttonSaveAnswer.titleLabel.font = [UIFont systemFontOfSize:13.0];
    buttonSaveAnswer.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [buttonSaveAnswer setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    buttonSaveAnswer.layer.masksToBounds = YES;
    buttonSaveAnswer.layer.cornerRadius = 3;
    [buttonSaveAnswer addTarget:self action:@selector(buttonSubmitClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:buttonSaveAnswer];
    //随时记录要返回的cell的高度
    
}
//保存答案按钮
- (void)buttonSubmitClick:(UIButton *)button{
    //保存答案，刷新答题卡
    [self.delegateCellClick topicCellSelectClickTest:_indexTopic selectDone:nil isRefresh:YES];
}
//图片的点击手势
-(void)showZoomImageView:(UITapGestureRecognizer *)tap{
    if (![(UIImageView *)tap.view image]) {
        return;
    }
    _selectTapView = (UIImageView *)tap.view;
    //scrollView作为背景
    UIScrollView *bgView = [[UIScrollView alloc] init];
    bgView.frame = [UIScreen mainScreen].bounds;
    bgView.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *tapBg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBgView:)];
    UILongPressGestureRecognizer *tapmy = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longGestTap:)];
    tapmy.minimumPressDuration = 1.0;
    tapmy.numberOfTouchesRequired = 1;
    [bgView addGestureRecognizer:tapmy];
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
    self.scrollView.maximumZoomScale = 2.0;
    self.scrollView.delegate = self;
    
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = imageView.frame;
        frame.size.width = bgView.frame.size.width;
        frame.size.height = frame.size.width * (imageView.image.size.height / imageView.image.size.width);
        frame.origin.x = 0;
        frame.origin.y = (bgView.frame.size.height - frame.size.height) * 0.5;
        imageView.frame = frame;
    }];
    
    NSUserDefaults *tyUser = [NSUserDefaults standardUserDefaults];
    if (![tyUser objectForKey:tyUserShowSaveImgAlert]) {
        LXAlertView *alertIms = [[LXAlertView alloc]initWithTitle:@"温馨提示" message:@"长按图片可将图片保存到手机相册哦" cancelBtnTitle:@"我知道了" otherBtnTitle:@"不在提醒" clickIndexBlock:^(NSInteger clickIndex) {
            if (clickIndex == 1) {
                [tyUser setObject:@"yes" forKey:tyUserShowSaveImgAlert];
            }
        }];
        alertIms.animationStyle = LXASAnimationLeftShake;
        [alertIms showLXAlertView];
    }
    
}
-(void)tapBgView:(UITapGestureRecognizer *)tapBgRecognizer{
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
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.lastImageView;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    CGFloat webViewScrolHeight = webView.scrollView.contentSize.height;
    _webTitleHeight.constant = webViewScrolHeight;
    CGFloat cellHeightL = _webViewTitle.frame.origin.y + webViewScrolHeight;
    if (_isWebFirstLoading) {
        if (_indexTopic == 7) {
            NSLog(@"faas");
        }
        [self.delegateCellClick isWebLoadingCellHeight:cellHeightL+_viewImage.frame.size.height + 60 withImageOy:cellHeightL];
    }
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
