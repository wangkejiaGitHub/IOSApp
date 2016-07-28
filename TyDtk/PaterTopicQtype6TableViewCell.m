//
//  PaterTopicQtype6TableViewCell.m
//  TyDtk
//
//  Created by 天一文化 on 16/4/19.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "PaterTopicQtype6TableViewCell.h"
@interface PaterTopicQtype6TableViewCell()<UIWebViewDelegate,UIScrollViewDelegate>
@property (nonatomic,strong) NSMutableArray *arrayImgUrl;
@property (nonatomic,strong) UIWebView *webViewTitle;
@end
@implementation PaterTopicQtype6TableViewCell

- (void)awakeFromNib {
    // Initialization code
    _webViewTitle = [[UIWebView alloc]initWithFrame:CGRectMake(15, 50, Scr_Width - 30, 30)];
    [_webViewTitle removeFromSuperview];
    [self.contentView addSubview:_webViewTitle];
    _webViewTitle.backgroundColor = [UIColor clearColor];
    _webViewTitle.scrollView.scrollEnabled = NO;
    _webViewTitle.opaque = NO;
    _webViewTitle.delegate = self;
}

- (void)setvalueForCellModel:(NSDictionary *)dic topicIndex:(NSInteger)index{
    NSString *topicTitle = dic[@"title"];
    topicTitle = [topicTitle stringByReplacingOccurrencesOfString:@"/tiku/common/getAttachment" withString:[NSString stringWithFormat:@"%@/tiku/common/getAttachment",systemHttpsKaoLaTopicImg]];
    NSString *htmlString = [NSString stringWithFormat:@"<html><body><div style='word-break:break-all;' id='content' contenteditable='false' >%@</div></body></html>",topicTitle];
    [_webViewTitle loadHTMLString:htmlString baseURL:nil];
    //试题编号
    _labNumber.text = [NSString stringWithFormat:@"%ld、",index];
    _labNumberWidth.constant = _labNumber.text.length*10+15;
    //试题类型（案例分析）
    _labTitleType.text = [NSString stringWithFormat:@"(%@)",dic[@"typeName"]];
    /////////////进度节点///////////////////////////////
    /////////////删除button 防止复用////////////////////
    for (id subView in self.contentView.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)subView;
            if (btn.tag != 1111) {
                [btn removeFromSuperview];
            }
        }
    }
    
    //添加保存试题按钮，主要用同步答题卡
    //    UIButton *buttonSave = (UIButton *)[self.contentView viewWithTag:102];
    UIButton *buttonSaveAnswer = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonSaveAnswer.tag = 1111;
    buttonSaveAnswer.frame = CGRectMake(Scr_Width-170, _buttonOy + 20, 160, 25);
    [buttonSaveAnswer setTitle:@"保存本题答案并跳转下一题" forState:UIControlStateNormal];
    if (_isLastTopic) {
        buttonSaveAnswer.frame = CGRectMake(Scr_Width-110, _buttonOy + 20, 100, 25);
        [buttonSaveAnswer setTitle:@"保存本题答案" forState:UIControlStateNormal];
    }
    buttonSaveAnswer.titleLabel.font = [UIFont systemFontOfSize:13.0];
    buttonSaveAnswer.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [buttonSaveAnswer setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    buttonSaveAnswer.layer.masksToBounds = YES;
    buttonSaveAnswer.layer.cornerRadius = 3;
    [buttonSaveAnswer addTarget:self action:@selector(buttonSubmitClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:buttonSaveAnswer];
    
    //判断是否是最一题，给用户提示
    if (_isLastTopic) {
        UIButton *btnLastTopic =[UIButton buttonWithType:UIButtonTypeCustom];
        btnLastTopic.frame = CGRectMake(Scr_Width - 110, _buttonOy - 5, 100, 20);
        btnLastTopic.tag = 1111;
        btnLastTopic.backgroundColor =ColorWithRGB(200, 200, 200);
        btnLastTopic.layer.masksToBounds = YES;
        btnLastTopic.layer.cornerRadius = 2;
        btnLastTopic.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [btnLastTopic setTitle:@"已是最后一题了" forState:UIControlStateNormal];
        [btnLastTopic setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
        [self.contentView addSubview:btnLastTopic];
        
    }
}
//保存答案按钮
- (void)buttonSubmitClick:(UIButton *)button{
    //保存答案，刷新答题卡
    [self.delegateCellClick topicCellSelectClickTest:_indexTopic selectDone:nil isRefresh:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
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
    //urlResurlt 就是获取到得所有图片的url的拼接；mUrlArray就是所有Url的数组
    
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
    /////////////////////////////////////////////////////////////////////
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
    //获取页面高度（像素）
    NSString * clientheight_str = [webView stringByEvaluatingJavaScriptFromString: @"document.body.offsetHeight"];
    float clientheight = [clientheight_str floatValue];
    //设置到WebView上
    webView.frame = CGRectMake(15, 50, Scr_Width - 30, clientheight);
    //获取WebView最佳尺寸（点）
    CGSize frame = [webView sizeThatFits:webView.frame.size];
    //获取内容实际高度（像素）
    NSString * height_str= [webView stringByEvaluatingJavaScriptFromString: @"document.getElementById('content').offsetHeight + parseInt(window.getComputedStyle(document.getElementsByTagName('body')[0]).getPropertyValue('margin-top'))  + parseInt(window.getComputedStyle(document.getElementsByTagName('body')[0]).getPropertyValue('margin-bottom'))"];
    float height = [height_str floatValue];
    //内容实际高度（像素）* 点和像素的比
    height = height * frame.height / clientheight;
    //再次设置WebView高度（点）
    webView.frame = CGRectMake(15, 50, Scr_Width - 30, height);
    
    CGFloat cellHeightL = _webViewTitle.frame.origin.y + height;
    if (_isWebFirstLoading) {
        [self.delegateCellClick isWebLoadingCellHeight:cellHeightL + 60 withButtonOy:cellHeightL];
    }
    
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    //预览图片
    if ([request.URL.scheme isEqualToString:@"image-preview"]) {
        NSString *path = [request.URL.absoluteString substringFromIndex:[@"image-preview:" length]];
        //path 就是被点击图片的url

        NSInteger imageClickIndex = [_arrayImgUrl indexOfObject:path];

        [self.delegateCellClick imageTopicArray:_arrayImgUrl withImageIndex:imageClickIndex];
        return NO;
    }
    return YES;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
