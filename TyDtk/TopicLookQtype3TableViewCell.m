//
//  TopicLookQtype3TableViewCell.m
//  TyDtk
//
//  Created by 天一文化 on 16/6/17.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "TopicLookQtype3TableViewCell.h"
@interface TopicLookQtype3TableViewCell()<UIWebViewDelegate,UIScrollViewDelegate>
@property (nonatomic,strong) NSUserDefaults *tyUser;
@property (nonatomic,assign) CGFloat viewImageOy;
@property (nonatomic,strong) NSMutableArray *arrayImgUrl;
@end
@implementation TopicLookQtype3TableViewCell

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
    _webViewTitle.backgroundColor =[UIColor clearColor];
    _tyUser = [NSUserDefaults standardUserDefaults];
    _webViewTitle.delegate = self;

}
- (void)setvalueForCellModel:(NSDictionary *)dic topicIndex:(NSInteger)index{
    _indexTopic = index;
    _dicTopic = dic;
    if (index == 19) {
        NSLog(@"11");
    }
    //判断视图是否有图片
    NSString *topicTitle = dic[@"title"];
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
    
    topicTitle = [topicTitle stringByReplacingOccurrencesOfString:@"/tiku/common/getAttachment" withString:[NSString stringWithFormat:@"%@/tiku/common/getAttachment",systemHttpsKaoLaTopicImg]];
    //用户作答情况
    //???????????修改pl
    //作答状态
    NSString *answer;
    
    answer = [NSString stringWithFormat:@"<br/><table cellpadding ='0' cellspacing = '0' width = '100%%' align = 'center'>"
              "<tr>"
              "<td width = '80px' align = 'left'><font size='2' color = 'purple'>正确答案：</font></td><td width = '70%%' align = 'left'><font color = 'purple'>%@</font></td>"
              "</tr>"
              "</table><br/>",dic[@"answer"]];
    
    ///////////解析
    NSString *analysisString = dic[@"analysis"];
    analysisString = [analysisString stringByReplacingOccurrencesOfString:@"/tiku/common/getAttachment" withString:[NSString stringWithFormat:@"%@/tiku/common/getAttachment",systemHttpsKaoLaTopicImg]];
    analysisString = [NSString stringWithFormat:@"<font color='#8080c0' size = '2'>试题解析>></font><br/><font color='#8080c0' size = '3'>%@</font>",analysisString];
    
    NSString *webString = [NSString stringWithFormat:@"<html><body><div id='conten' contenteditable='false' style='word-break:break-all;'>%@%@%@</div></body></html>",topicTitle,answer,analysisString];
    [_webViewTitle loadHTMLString:webString baseURL:nil];
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
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSInteger dicpaperId = [_dicTopic[@"parentId"] integerValue];
    //这里是js，主要目的实现对url的获取
    static  NSString * const jsGetImages =
    @"function getImages(){\
    var objs = document.getElementsByTagName(\"img\");\
    var imgScr = '';\
    for(var i=0;i<objs.length;i++){\
    imgScr = imgScr + objs[i].src + '+';\
    };\
    return imgScr;\
    };";
    
    [webView stringByEvaluatingJavaScriptFromString:jsGetImages];//注入js方法
    NSString *urlResurlt = [webView stringByEvaluatingJavaScriptFromString:@"getImages()"];
    _arrayImgUrl = [NSMutableArray arrayWithArray:[urlResurlt componentsSeparatedByString:@"+"]];
    if (_arrayImgUrl.count >= 2) {
        [_arrayImgUrl removeLastObject];
    }
    //mUrlArray就是所有Url的数组
    //添加图片可点击js
    [webView stringByEvaluatingJavaScriptFromString:@"function registerImageClickAction(){\
     var imgs=document.getElementsByTagName('img');\
     var length=imgs.length;\
     for(var i=0;i<length;i++){\
     img=imgs[i];\
     img.onclick=function(){\
     window.location.href='image-preview:'+this.src}\
     }\
     }"];
    [webView stringByEvaluatingJavaScriptFromString:@"registerImageClickAction();"];
    NSString *imgS = [NSString stringWithFormat:@"var script = document.createElement('script');"
                      "script.type = 'text/javascript';"
                      "script.text = \"function ResizeImages() { "
                      "var myimg,oldwidth,oldheight;"
                      "var maxwidth=%f;"// 图片宽度(屏宽)
                      "for(i=0;i <document.images.length;i++){"
                      "myimg = document.images[i];"
                      //判断webview上的图片是否超过屏宽，进行适配
                      "if(myimg.width > maxwidth){"
                      "myimg.width = maxwidth - 50;"
                      "}"
                      "}"
                      "}\";"
                      "document.getElementsByTagName('head')[0].appendChild(script);",Scr_Width];
    [webView stringByEvaluatingJavaScriptFromString:imgS];
    [webView stringByEvaluatingJavaScriptFromString:@"ResizeImages();"];
    CGFloat documentHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"conten\").offsetHeight;"] floatValue];
    CGFloat cellHeightL = _webViewTitle.frame.origin.y + documentHeight;
    ////////////////////////////////////////////////////////////
    //获取页面高度（像素）
    NSString * clientheight_str = [webView stringByEvaluatingJavaScriptFromString: @"document.body.offsetHeight"];
    float clientheight = [clientheight_str floatValue];
    //获取WebView最佳尺寸（点）
    CGSize frame = [webView sizeThatFits:webView.frame.size];
    //获取内容实际高度（像素）
    NSString * height_str= [webView stringByEvaluatingJavaScriptFromString: @"document.getElementById('conten').offsetHeight + parseInt(window.getComputedStyle(document.getElementsByTagName('body')[0]).getPropertyValue('margin-top'))  + parseInt(window.getComputedStyle(document.getElementsByTagName('body')[0]).getPropertyValue('margin-bottom'))"];
    float height = [height_str floatValue];
    //内容实际高度（像素）* 点和像素的比
    height = height * frame.height / clientheight;
    _webTitleHeight.constant = height;
    if (dicpaperId == 0) {
        if (_isWebFirstLoading) {
            //非小题试题二次刷新
            [self.delegateAnalysisCellClick isWebLoadingCellHeight:cellHeightL + 123 withButtonOy:cellHeightL];
        }
    }
    else{
        //小题试题二次刷新
        if (![_arrayFirstLoading containsObject:[NSString stringWithFormat:@"%ld",_indexTopic]]) {
            [self.delegateAnalysisCellClick isWebLoadingCellHeight:cellHeightL +123 withButtonOy:cellHeightL withIndex:_indexTopic];
        }
    }
    
}
//主要处理试题中的图片问题
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    //预览图片
    if ([request.URL.scheme isEqualToString:@"image-preview"]) {
        NSString *path = [request.URL.absoluteString substringFromIndex:[@"image-preview:" length]];
        //path 就是被点击图片的url
        NSLog(@"%@",path);
        NSInteger imageClickIndex = [_arrayImgUrl indexOfObject:path];
        [self.delegateAnalysisCellClick imageTopicArray:_arrayImgUrl withImageIndex:imageClickIndex];
        return NO;
    }
    return YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
