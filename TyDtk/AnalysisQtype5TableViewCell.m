//
//  AnalysisQtype5TableViewCell.m
//  TyDtk
//
//  Created by 天一文化 on 16/5/7.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "AnalysisQtype5TableViewCell.h"
@interface AnalysisQtype5TableViewCell()<UIWebViewDelegate,UIScrollViewDelegate>
@property (nonatomic,strong) NSUserDefaults *tyUser;
//??????????????????????????????????????????????????????
@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) UIImageView *lastImageView;
@property (nonatomic, assign)CGRect originalFrame;
@property (nonatomic, assign)BOOL isDoubleTap;

@property (nonatomic,strong) UIImageView *selectTapView;
//??????????????????????????????????????????????????????
@property (nonatomic,assign) CGFloat viewImageOy;
@end
@implementation AnalysisQtype5TableViewCell

- (void)awakeFromNib {
    // Initialization code
    _imageVIewCollect.layer.masksToBounds = YES;
    _imageVIewCollect.layer.cornerRadius = 2;
    _buttonCollect.layer.masksToBounds = YES;
    _buttonCollect.layer.cornerRadius = 2;
    _buttonNotes.backgroundColor = ColorWithRGB(200, 200, 200);
    _buttonNotes.layer.masksToBounds = YES;
    _buttonNotes.layer.cornerRadius = 2;
    _buttonError.backgroundColor = ColorWithRGB(200, 200, 200);
    _buttonError.layer.masksToBounds = YES;
    _buttonError.layer.cornerRadius = 2;
    _webViewTitle.scrollView.scrollEnabled = NO;
    
    _webViewTitle.opaque = NO;
    _webAnalysis.backgroundColor = [UIColor clearColor];
    _webAnalysis.scrollView.scrollEnabled = NO;
    _webAnalysis.opaque = NO;
    _webViewTitle.backgroundColor =[UIColor clearColor];
    _tyUser = [NSUserDefaults standardUserDefaults];
    _webViewTitle.delegate = self;
    _labAnswerStatus.textColor = [UIColor redColor];
}
- (CGFloat)setvalueForCellModel:(NSDictionary *)dic topicIndex:(NSInteger)index{
    _dicTopic = dic;
    _indexTopic = index;
    if (index == 3) {
        NSLog(@"%@",dic);
    }
    CGFloat allowRet = 0;
    //判断视图是否有图片
    //    NSInteger qtypeTopic = [dic[@"qtype"] integerValue];
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
    //判断是否为一题多问下面的简答题
    NSInteger parentId = [dic[@"parentId"] integerValue];
    //一题多问下面的小题
    if (parentId != 0) {
        _labTopicNumber.text = [NSString stringWithFormat:@"(%ld)、",index];
        _labTopicNumber.textColor = [UIColor orangeColor];
    }
    
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
    //记录返回或者用到的高
    allowRet = _webTitleHeight.constant +_webViewTitle.frame.origin.y + 15;
    ////////////////////////////////////////////
    /// 如果试题有图片，就加载图片显示
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
            __block UIImage *imageTop = [[UIImage alloc]init];
            
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager downloadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",systemHttpsKaoLaTopicImg,imagUrl]] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                NSLog(@"dsfasffasf");
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                NSLog(@"fsfafafaf");
                if (image) {
                    imageTop = image;
                    //如果是第一次加载，再次刷新ui让图片显示出来
                    if (_isFirstLoad) {
                        [self.delegateAnalysisCellClick IsFirstload:NO];
                    }
                    
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
            //??????????????????????????????
            UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showZoomImageView:)];
            imgViewTop.userInteractionEnabled = YES;
            [imgViewTop addGestureRecognizer:tapImage];
            //??????????????????????????????
            [viewImage addSubview:imgViewTop];
            viewImgsH = viewImgsH+sizeImg.height;
        }
        viewImage.frame = CGRectMake(15, allowRet, Scr_Width - 30, viewImgsH);
        _viewImageOy = viewImage.frame.origin.y;
        [self.contentView addSubview:viewImage];
        allowRet = allowRet + viewImage.frame.size.height + 60;
    }
    else{
        viewImage = nil;
        
    }
    //判断是否已经收藏试题
    NSInteger collectId = [dic[@"collectId"] integerValue];
    //已收藏
    if (collectId>0) {
        _buttonCollect.backgroundColor = [UIColor orangeColor];
        [_buttonCollect setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_buttonCollect setTitle:@"已收藏" forState:UIControlStateNormal];
        _buttonCollectWidth.constant = 50;
    }
    
    /////////////////////////////////////
    if ([_dicCollectDone.allKeys containsObject:[NSString stringWithFormat:@"%ld",_indexTopic]]) {
        NSString *collectString = _dicCollectDone[[NSString stringWithFormat:@"%ld",_indexTopic]];
        if ([collectString isEqualToString:@"已收藏"]) {
            _buttonCollect.backgroundColor = [UIColor orangeColor];
            [_buttonCollect setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_buttonCollect setTitle:@"已收藏" forState:UIControlStateNormal];
            _buttonCollectWidth.constant = 50;
        }
        else{
            _buttonCollect.backgroundColor = [UIColor whiteColor];
            [_buttonCollect setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
            [_buttonCollect setTitle:@"收藏" forState:UIControlStateNormal];
            _buttonCollectWidth.constant = 40;
        }
        
    }
    
    
    // 160 目前选项下面的内容
    allowRet = allowRet+160+20;
    //设置答题状态和解析数据
    //正确答案
//    _labTureAnswer.text = dic[@"answer"];
    //用户答案
//    _labUserAnswer.text = dic[@"userAnswer"];
//    //作答状态
    NSInteger levelTopic = [dic[@"level"] integerValue];
    if (levelTopic == 0) {
        _labAnswerStatus.text = @"未作答";
    }
    else if (levelTopic == 1){
        _labAnswerStatus.text = @"答题正确";
        _labAnswerStatus.textColor = [UIColor purpleColor];
    }
    else if (levelTopic == 2){
        _labAnswerStatus.text = @"答题错误";
    }
    //试题解析
    UILabel *labWebAna = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, Scr_Width - 40, 30)];
    labWebAna.numberOfLines = 0;
    labWebAna.text = dic[@"analysis"];
    CGSize labWebAnaSize = [labWebAna sizeThatFits:CGSizeMake(labWebAna.bounds.size.width, MAXFLOAT)];
    _webAnalysisHeight.constant = labWebAnaSize.height+ 30+50;
    NSString *webString = [NSString stringWithFormat:@"<font color='#8080c0' size = '2'>试题解析>></font><br/><br/><font color='#8080c0' size = '3'>%@</font>",labWebAna.text];
    [_webAnalysis loadHTMLString:webString baseURL:nil];
    
    allowRet = allowRet + _webAnalysisHeight.constant - 30;
    return allowRet;
    
}
//笔记按钮
- (IBAction)buttonNoteClick:(UIButton *)sender {
    NSInteger questionId = [_dicTopic[@"questionId"] integerValue];
    [self.delegateAnalysisCellClick saveNotesOrErrorClick:questionId executeParameter:1];
}
//纠错按钮
- (IBAction)buttonErrorClick:(UIButton *)sender {
    NSInteger questionId = [_dicTopic[@"questionId"] integerValue];
    [self.delegateAnalysisCellClick saveNotesOrErrorClick:questionId executeParameter:0];
}
//收藏按钮
- (IBAction)buttonCollectClick:(UIButton *)sender {
    NSString *buttonString = sender.titleLabel.text;
    //收藏
    if ([buttonString isEqualToString:@"收藏"]) {
        [self collectTopic];
    }
    //取消收藏
    else{
        [self cancelCollectTopic];
    }
    
}
/**
 收藏试题
 */
- (void)collectTopic{
    NSString *accessToken = [_tyUser objectForKey:tyUserAccessToken];
    NSInteger questionId = [_dicTopic[@"questionId"] integerValue];
    NSString *urlString = [NSString stringWithFormat:@"%@api/Collection/Add/%ld?access_token=%@",systemHttps,questionId,accessToken];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicCollect = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dicCollect[@"code"] integerValue];
        if (codeId == 1) {
            NSDictionary *dicDatas = dicCollect[@"datas"];
            _buttonCollect.backgroundColor = [UIColor orangeColor];
            [_buttonCollect setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_buttonCollect setTitle:@"已收藏" forState:UIControlStateNormal];
            _buttonCollectWidth.constant = 50;
            //////////////////////////////////
            //保存临时收藏状态
            NSString *btnString = _buttonCollect.titleLabel.text;
            NSDictionary *dicColl = @{[NSString stringWithFormat:@"%ld",_indexTopic]:btnString};
            [self.delegateAnalysisCellClick saveUserCollectTiopic:dicColl];
            ///////////////////////////////////
            
            
            [SVProgressHUD showSuccessWithStatus:dicDatas[@"msg"]];
            if (![_tyUser objectForKey:tyUserShowCollectAlert]) {
                LXAlertView *collectAlert = [[LXAlertView alloc]initWithTitle:@"温馨提示" message:@"再次点击'已收藏'可取消收藏哦" cancelBtnTitle:@"我知道了" otherBtnTitle:@"不再提示" clickIndexBlock:^(NSInteger clickIndex) {
                    if (clickIndex == 1) {
                        [_tyUser setObject:@"yes" forKey:tyUserShowCollectAlert];
                    }
                }];
                collectAlert.animationStyle = LXASAnimationTopShake;
                [collectAlert showLXAlertView];
            }
        }
        else{
            [SVProgressHUD showInfoWithStatus:@"操作失败!"];
        }
    } RequestFaile:^(NSError *error) {
        
    }];
}
/**
 取消收藏
 */
- (void)cancelCollectTopic{
    
    NSString *accessToken = [_tyUser objectForKey:tyUserAccessToken];
    NSInteger questionId = [_dicTopic[@"questionId"] integerValue];
    NSString *urlString = [NSString stringWithFormat:@"%@api/Collection/Del/%ld?access_token=%@",systemHttps,questionId,accessToken];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicCollect = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dicCollect[@"code"] integerValue];
        if (codeId == 1) {
            NSDictionary *dicDatas = dicCollect[@"datas"];
            _buttonCollect.backgroundColor = [UIColor whiteColor];
            [_buttonCollect setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
            [_buttonCollect setTitle:@"收藏" forState:UIControlStateNormal];
            _buttonCollectWidth.constant = 40;
            //////////////////////////////////
            //保存临时收藏状态
            NSString *btnString = _buttonCollect.titleLabel.text;
            NSDictionary *dicColl = @{[NSString stringWithFormat:@"%ld",_indexTopic]:btnString};
            [self.delegateAnalysisCellClick saveUserCollectTiopic:dicColl];
            ///////////////////////////////////
            
            [SVProgressHUD showSuccessWithStatus:dicDatas[@"msg"]];
        }
        else{
            [SVProgressHUD showInfoWithStatus:@"操作失败!"];
        }
        
    } RequestFaile:^(NSError *error) {
        
    }];
    
    
}

//图片点击手势，放大图片
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
    
    if (![_tyUser objectForKey:tyUserShowSaveImgAlert]) {
        LXAlertView *alertIms = [[LXAlertView alloc]initWithTitle:@"温馨提示" message:@"长按图片可将图片保存到手机相册哦" cancelBtnTitle:@"我知道了" otherBtnTitle:@"不在提醒" clickIndexBlock:^(NSInteger clickIndex) {
            if (clickIndex == 1) {
                [_tyUser setObject:@"yes" forKey:tyUserShowSaveImgAlert];
            }
        }];
        alertIms.animationStyle = LXASAnimationLeftShake;
        [alertIms showLXAlertView];
    }
}
//再次点击图片
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
        [self.delegateAnalysisCellClick imageSaveQtype1Test:_selectTapView.image];
    }
}
//返回可缩放的视图
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.lastImageView;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
