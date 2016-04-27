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
@property (nonatomic,assign) CGFloat viewImageOy;
@end
@implementation PaterTopicQtype6TableViewCell

- (void)awakeFromNib {
    // Initialization code
    _webViewTitle.backgroundColor = [UIColor clearColor];
    _webViewTitle.scrollView.scrollEnabled = NO;
    _webViewTitle.opaque = NO;
    _webViewTitle.delegate = self;
}

- (CGFloat)setvalueForCellModel:(NSDictionary *)dic topicIndex:(NSInteger)index{
    CGFloat allowRet = 0;
    if (index == 86) {
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
        UILabel *labTitleTest = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, Scr_Width-30, 0)];
        labTitleTest.text = topicTitle;
//        NSLog(@"%@ ====== %ld",topicTitle,topicTitle.length);
        labTitleTest.numberOfLines = 0;
        labTitleTest.font = [UIFont systemFontOfSize:19];
        if (Scr_Width > 320) {
            labTitleTest.font = [UIFont systemFontOfSize:18.5];
        }
        CGSize labSize = [labTitleTest sizeThatFits:CGSizeMake(labTitleTest.frame.size.width, MAXFLOAT)];
        _webTitleHeight.constant = labSize.height;
    }
    [_webViewTitle loadHTMLString:topicTitle baseURL:nil];
    //试题编号
    _labNumber.text = [NSString stringWithFormat:@"%ld、",index];
    _labNumberWidth.constant = _labNumber.text.length*10+15;
    //试题类型（案例分析）
    _labTitleType.text = [NSString stringWithFormat:@"(%@)",dic[@"typeName"]];
    
    //？？？？？随时记录要返回的cell的高度??????????????
    allowRet = _webViewTitle.frame.origin.y+_webTitleHeight.constant+50;
    
//    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(10, allowRet, Scr_Width-20, 30)];
//    view.backgroundColor = [UIColor redColor];
//    [self.contentView addSubview:view];
    //http://www.kaola100.com/tiku/common/getAttachment?filePath=img/20151229/20151229095609_916.png
    
//    NSLog(@"%@",dic);
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
            
            //??????????????????????????????
            UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showZoomImageView:)];
            imgViewTop.userInteractionEnabled = YES;
            [imgViewTop addGestureRecognizer:tapImage];
            //??????????????????????????????
            
            [viewImage addSubview:imgViewTop];
            viewImgsH = viewImgsH+sizeImg.height;
        }
        viewImage.frame = CGRectMake(15, allowRet - 10, Scr_Width - 30, viewImgsH);
        [self.contentView addSubview:viewImage];
        
        UIView *viewLineImgDown = [[UIView alloc]initWithFrame:CGRectMake(10, allowRet+viewImgsH+10, Scr_Width-20, 1)];
        viewLineImgDown.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:viewLineImgDown];
        //？？？？？随时记录要返回的cell的高度
        _viewImageOy = viewImage.frame.origin.y;
        allowRet = allowRet + viewImgsH + 30;
    }
    else{
        viewImage = nil;
    }
    //？？？？？随时记录要返回的cell的高度
    return allowRet;
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
        [self.delegateTopic imageSaveQtype1:_selectTapView.image];
    }
}
//返回可缩放的视图
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.lastImageView;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    CGFloat webViewScrolHeight = webView.scrollView.contentSize.height;
    _webTitleHeight.constant = webViewScrolHeight +5;
//    NSLog(@"%f",webViewScrolHeight);
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
