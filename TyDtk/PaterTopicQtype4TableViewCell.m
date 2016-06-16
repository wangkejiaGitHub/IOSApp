//
//  PaterTopicQtype4TableViewCell.m
//  TyDtk
//
//  Created by 天一文化 on 16/5/5.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "PaterTopicQtype4TableViewCell.h"
@interface PaterTopicQtype4TableViewCell()<UIWebViewDelegate,UIScrollViewDelegate>
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
@implementation PaterTopicQtype4TableViewCell

- (void)awakeFromNib {
    // Initialization code
    _imageCollect.layer.masksToBounds = YES;
    _imageCollect.layer.cornerRadius = 2;
    _buttonCollect.layer.masksToBounds = YES;
    _buttonCollect.layer.cornerRadius = 2;
    _webViewTitle.backgroundColor = [UIColor clearColor];
    _webViewTitle.scrollView.scrollEnabled = NO;
    _webViewTitle.opaque = NO;
    
    _tyUser = [NSUserDefaults standardUserDefaults];
}
- (CGFloat)setvalueForCellModel:(NSDictionary *)dic topicIndex:(NSInteger)index{
    CGFloat allowRet = 0;
    //判断视图是否有图片
    NSDictionary *dicImg = dic[@"ImageDictionary"];
    NSString *topicTitle = dic[@"title"];
    topicTitle = [topicTitle stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
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
    //判断是否为一题多问下面的简答题
    NSInteger parentId = [dic[@"parentId"] integerValue];
    //一题多问下面的小题
    if (parentId != 0) {
        _labNumber.text = [NSString stringWithFormat:@"(%ld)、",index];
        _labNumber.textColor = [UIColor orangeColor];
    }
    
    _labNumberWidth.constant = _labNumber.text.length*10+10;
    //试题类型
    _labTopicType.text = [NSString stringWithFormat:@"(%@)",dic[@"typeName"]];
    CGSize labSize = [labTest sizeThatFits:CGSizeMake(labTest.frame.size.width, MAXFLOAT)];
    [_webViewTitle loadHTMLString:topicTitle baseURL:nil];
    _webViewTitleHeight.constant = labSize.height;
    _webViewTitleHeight.constant = _webViewTitleHeight.constant + 50;
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
            __block UIImage *imageTop = [[UIImage alloc]init];
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            
            [manager downloadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",systemHttpsKaoLaTopicImg,imagUrl]] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                imageTop = image;
                //如果是第一次加载，再次刷新ui让图片显示出来
                if (parentId == 0) {
                    if (_isFirstLoad) {
                        [self.delegateCellClick IsFirstload:NO];
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
        viewImage.frame = CGRectMake(15, allowRet - 10, Scr_Width - 30, viewImgsH);
        _viewImageOy = viewImage.frame.origin.y;
        [self.contentView addSubview:viewImage];
        allowRet = allowRet + viewImgsH + 30;
    }
    else{
        viewImage = nil;
    }
    
    //最后分别添加笔记和纠错按钮
    //添加笔记按钮
    UIButton *buttonNotes = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonNotes.frame = CGRectMake(Scr_Width - 75, allowRet - 5, 60, 23);
    buttonNotes.backgroundColor = ColorWithRGB(200, 200, 200);
    buttonNotes.layer.masksToBounds = YES;
    buttonNotes.layer.cornerRadius = 2;
    [buttonNotes setTitle:@"📓笔记" forState:UIControlStateNormal];
    [buttonNotes setImage:[UIImage imageNamed:@"bj01"] forState:UIControlStateNormal];
    [buttonNotes setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 25)];
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
    [buttonError setTitle:@"🔧纠错" forState:UIControlStateNormal];
    [buttonError setImage:[UIImage imageNamed:@"jc01"] forState:UIControlStateNormal];
    [buttonError setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 25)];
    buttonError.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [buttonError setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    buttonError.tag = 1111;
    [buttonError addTarget:self action:@selector(buttonErrorClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:buttonError];
    allowRet = allowRet + 40;
    self.backgroundColor = [UIColor clearColor];
    _dicTopic = dic;
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
    
    //判断是否已经做过该题
    if ([_dicSelectDone.allKeys containsObject:[NSString stringWithFormat:@"%ld",index]]) {
        NSString *textString = _dicSelectDone[[NSString stringWithFormat:@"%ld",index]];
        _textViewAnswer.text = textString;
    }
    
    return allowRet;
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
            _buttonCollect.backgroundColor = [UIColor orangeColor];
            [_buttonCollect setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_buttonCollect setTitle:@"已收藏" forState:UIControlStateNormal];
            _buttonCollectWidth.constant = 50;
            //////////////////////////////////
            //保存临时收藏状态
            NSString *btnString = _buttonCollect.titleLabel.text;
            NSDictionary *dicColl = @{[NSString stringWithFormat:@"%ld",_indexTopic]:btnString};
            [self.delegateCellClick saveUserCollectTiopic:dicColl];
            ///////////////////////////////////
            [SVProgressHUD showSuccessWithStatus:@"收藏成功！"];
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
            [self.delegateCellClick saveUserCollectTiopic:dicColl];
            ///////////////////////////////////
            [SVProgressHUD showSuccessWithStatus:dicDatas[@"msg"]];
        }
        else{
            [SVProgressHUD showInfoWithStatus:@"操作失败!"];
        }
        
    } RequestFaile:^(NSError *error) {
        
    }];
    
    
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

//??????????????????????????????????????????????????
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
//        [self.delegateCellClick imageSaveQtype1Test:_selectTapView.image];
    }
    
}
//返回可缩放的视图
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.lastImageView;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    _webViewTitleHeight.constant = webView.scrollView.contentSize.height;
}

//保存答案按钮
- (IBAction)buttonSaveAnswerClick:(UIButton *)sender {
    //????????????????????????????????????
    //添加已经选过的选项数组
    NSString *answerString = _textViewAnswer.text;
    //    [_dicSelectDone setValue:answerString forKey:[NSString stringWithFormat:@"%ld",_indexTopic]];
    NSDictionary *dicTest = @{[NSString stringWithFormat:@"%ld",_indexTopic]:answerString};
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
    
    NSDictionary *dicUserAnswer = @{@"QuestionID":questionId,@"QType":qtype,@"UserAnswer":answerString,@"TrueAnswer":answer,@"Score":@"0"};
    [self.delegateCellClick topicCellSelectClickTest:_indexTopic selectDone:dicUserAnswer isRefresh:isRefresh];
    
}
//主要处理试题中的图片问题
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    //预览图片
    if ([request.URL.scheme isEqualToString:@"image-preview"]) {
        NSString *path = [request.URL.absoluteString substringFromIndex:[@"image-preview:" length]];
        //path 就是被点击图片的url
        NSLog(@"%@",path);
        
        return NO;
    }
    return YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
