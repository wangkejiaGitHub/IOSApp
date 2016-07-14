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
@property (nonatomic,strong) NSUserDefaults *tyUser;

@property (nonatomic,strong) NSMutableArray *arrayImgUrl;
//自定义webview，显示标题和选项
@property (nonatomic,strong) UIWebView *webViewTitle;
//选项按钮起点坐标
@property (nonatomic,assign) CGFloat buttonOrginY;
@end
@implementation paterTopicQtype1and2TableViewCell

- (void)awakeFromNib {
    // Initialization code
    _webViewTitle = [[UIWebView alloc]initWithFrame:CGRectMake(50, 15, Scr_Width - 30, 30)];
    [_webViewTitle removeFromSuperview];
    [self.contentView addSubview:_webViewTitle];
    _imageVIewCollect.layer.masksToBounds = YES;
    _imageVIewCollect.layer.cornerRadius = 2;
    _buttonCollect.layer.masksToBounds = YES;
    _buttonCollect.layer.cornerRadius = 2;
    _webViewTitle.scrollView.scrollEnabled = NO;
//    _webVIewSelect.scrollView.scrollEnabled = NO;
    _webViewTitle.opaque = NO;
//    _webVIewSelect.opaque = NO;
    _webViewTitle.backgroundColor =[UIColor clearColor];
//    _webVIewSelect.backgroundColor = [UIColor clearColor];
    //多选答案默认为空
    _selectContentQtype2 = @"";
    _webViewTitle.delegate = self;
//    _webVIewSelect.delegate = self;
    _tyUser = [NSUserDefaults standardUserDefaults];
}
- (void)setvalueForCellModel:(NSDictionary *)dic topicIndex:(NSInteger)index{
    _indexTopic = index;
    _dicTopic = dic;
    //判断视图是否有图片
    NSInteger qtypeTopic = [dic[@"qtype"] integerValue];
    NSString *topicTitle = dic[@"title"];
    //试题编号
    _labTopicNumber.text = [NSString stringWithFormat:@"%ld、",index];
    //判断是否为一题多问下面的简答题
    NSInteger parentId = [dic[@"parentId"] integerValue];
    _buttonOrginY = _buttonOy;
    //一题多问下面的小题
    if (parentId != 0) {
        _buttonOrginY = _buttonSubOy;
        _labTopicNumber.text = [NSString stringWithFormat:@"(%ld)",index];
        _labTopicNumber.font = [UIFont systemFontOfSize:13.0];
        _labTopicNumber.textColor = [UIColor orangeColor];
        _labNumberWidth.constant = _labTopicNumber.text.length*10;
    }
    else{
        _labTopicNumber.font = [UIFont systemFontOfSize:15.0];
        _labNumberWidth.constant = _labTopicNumber.text.length*10+15;
    }
    //试题类型（单选，多选）
    _labTopicType.text = [NSString stringWithFormat:@"(%@)",dic[@"typeName"]];
    NSString *selectOptions = dic[@"options"];
    selectOptions = [selectOptions stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    NSData *dataSting = [selectOptions dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *arrayOptions = [NSJSONSerialization JSONObjectWithData:dataSting options:NSJSONReadingMutableLeaves error:nil];
    NSString *arraySelectString = [arrayOptions componentsJoinedByString:@""];
    topicTitle = [topicTitle stringByAppendingString:[NSString stringWithFormat:@"<br/><br/>%@",arraySelectString]];
    topicTitle = [topicTitle stringByReplacingOccurrencesOfString:@"/tiku/common/getAttachment" withString:[NSString stringWithFormat:@"%@/tiku/common/getAttachment",systemHttpsKaoLaTopicImg]];
    NSString *htmlString = [NSString stringWithFormat:@"<html><body><div id='conten' contenteditable='false' style='word-break:break-all;'>%@</div></body></html>",topicTitle];
    [_webViewTitle loadHTMLString:htmlString baseURL:nil];
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
    /****获取选项的首字母集合（A,B,C,D...）****/
    //选择题以图片形式展现，以文字形式展现的选项文字
    NSInteger seleNum = [dic[@"SelectNum"] integerValue];
    NSArray *arraySelectOp = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z"];
    /**************************************/
    //开始添加button按钮
    CGFloat btnSpa = 10;
    CGFloat btn_W = (Scr_Width - 20 - (seleNum-1)*btnSpa)/seleNum;
    for (int i =0; i<seleNum; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(10+(btn_W+btnSpa)*i, _buttonOrginY + 50, btn_W, 30);
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
        //是否有选过的选项
        NSString *indexString = [NSString stringWithFormat:@"%ld",index];
        //单选判断是否已选
        if (qtypeTopic == 1) {
            //先判断是否是继续做题已选
            NSString *userAnswer = dic[@"userAnswer"];
            if (userAnswer!=nil && [userAnswer isEqualToString:button.titleLabel.text]) {
                button.backgroundColor = ColorWithRGB(11, 141, 240);
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
          
            
            if ([_dicSelectDone.allKeys containsObject:indexString]) {
                NSString *selectString = _dicSelectDone[indexString];
                if ([button.titleLabel.text isEqualToString:selectString]) {
                    button.backgroundColor = ColorWithRGB(11, 141, 240);
                    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                }
                else{
                    [button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
                    button.backgroundColor = ColorWithRGB(200, 200, 200);

                }
            }
        }
        //多选判断是否已选
        else{
            //先判断是否是继续做题已选
            NSString *userAnswer = dic[@"userAnswer"];
            if (userAnswer!=nil && [userAnswer rangeOfString:button.titleLabel.text].length >0) {
                button.backgroundColor = ColorWithRGB(11, 141, 240);
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                _selectContentQtype2 = userAnswer;
            }
            
            if ([_dicSelectDone.allKeys containsObject:indexString]) {
                NSString *selectString = _dicSelectDone[indexString];
                NSRange ranSelect = [selectString rangeOfString:button.titleLabel.text];
                if (ranSelect.length > 0) {
                    button.backgroundColor = ColorWithRGB(11, 141, 240);
                    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                }
                else{
                    [button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
                    button.backgroundColor = ColorWithRGB(200, 200, 200);
                }
            }
            
        }
        ///////////////////////////////////////
        [self.contentView addSubview:button];
    }
    //如果是多项选择题，多添加一个提交多选答案的按钮
    NSInteger topicType = [dic[@"qtype"] integerValue];
    if (topicType == 2) {
        UIButton *btnSubmit = [UIButton buttonWithType:UIButtonTypeCustom];
        btnSubmit.frame = CGRectMake((Scr_Width - 133)/2, _buttonOrginY+110, 133, 23);
        [btnSubmit setTitle:@"保存答案跳转下一题" forState:UIControlStateNormal];
        if (_isLastTopic) {
            [btnSubmit setTitle:@"保存答案" forState:UIControlStateNormal];
        }
        btnSubmit.layer.masksToBounds = YES;
        btnSubmit.layer.cornerRadius = 3;
        btnSubmit.backgroundColor = [UIColor groupTableViewBackgroundColor];
        btnSubmit.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [btnSubmit setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
        [btnSubmit addTarget:self action:@selector(buttonSubmit:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:btnSubmit];
    }
//    else{
//        
//    }
    //最后分别添加笔记和纠错按钮
    //添加笔记按钮
    UIButton *buttonNotes = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonNotes.frame = CGRectMake(Scr_Width - 75, _buttonOrginY + 110, 60, 23);
    buttonNotes.backgroundColor = ColorWithRGB(200, 200, 200);
    buttonNotes.layer.masksToBounds = YES;
    buttonNotes.layer.cornerRadius = 2;
    [buttonNotes setImage:[UIImage imageNamed:@"bj01"] forState:UIControlStateNormal];
    [buttonNotes setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 25)];
    [buttonNotes setTitle:@"📓笔记" forState:UIControlStateNormal];
    buttonNotes.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [buttonNotes setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    buttonNotes.tag = 2222;
    [buttonNotes addTarget:self action:@selector(buttonNotesClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:buttonNotes];
    //添加纠错按钮
    UIButton *buttonError = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonError.frame = CGRectMake(15, _buttonOrginY + 110, 60, 23);
    buttonError.backgroundColor = ColorWithRGB(200, 200, 200);
    buttonError.layer.masksToBounds = YES;
    buttonError.layer.cornerRadius = 2;
    [buttonError setImage:[UIImage imageNamed:@"jc01"] forState:UIControlStateNormal];
    [buttonError setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 25)];
    [buttonError setTitle:@"🔧纠错" forState:UIControlStateNormal];
    buttonError.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [buttonError setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    buttonError.tag = 2222;
    [buttonError addTarget:self action:@selector(buttonErrorClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:buttonError];
    //判断是否是最一题，给用户提示
    if (_isLastTopic && topicType == 1) {
        UIButton *btnLastTopic =[UIButton buttonWithType:UIButtonTypeCustom];
        btnLastTopic.frame = CGRectMake((Scr_Width - 100)/2, _buttonOrginY + 110, 100, 23);
        btnLastTopic.tag = 2222;
        btnLastTopic.backgroundColor =ColorWithRGB(200, 200, 200);
        btnLastTopic.layer.masksToBounds = YES;
        btnLastTopic.layer.cornerRadius = 2;
        btnLastTopic.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [btnLastTopic setTitle:@"已是最后一题了" forState:UIControlStateNormal];
        [btnLastTopic setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
        [self.contentView addSubview:btnLastTopic];
        
    }
    self.backgroundColor = [UIColor clearColor];
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
    if (_selectContentQtype2.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"您还没有选择答案~"];
        return;
    }
    //添加已经选过的选项数组
    NSDictionary *dicTest = @{[NSString stringWithFormat:@"%ld",_indexTopic]:_selectContentQtype2};
    [self.delegateCellClick saveUserAnswerUseDictonary:dicTest];
    //////////////////////////////////////
    //////////////////////////////////////
    //判断是否是一题多问下面的选择题
    NSInteger topicParentId = [_dicTopic[@"parentId"] integerValue];
    BOOL isRefresh = NO;
    if (topicParentId == 0) {
        isRefresh = YES;
    }
    NSString *questionId =[NSString stringWithFormat:@"%ld",[_dicTopic[@"questionId"] integerValue]];
    //试题类型
    NSString *qtype =[NSString stringWithFormat:@"%ld",[_dicTopic[@"qtype"] integerValue]];
    //正确答案
    NSString *answer = _dicTopic[@"answer"];
    NSInteger score = [_dicTopic[@"score"] integerValue];
    NSDictionary *dicUserAnswer = @{@"QuestionID":questionId,@"QType":qtype,@"UserAnswer":_selectContentQtype2,@"TrueAnswer":answer,@"Score":[NSString stringWithFormat:@"%ld",score]};
    [self.delegateCellClick topicCellSelectClickTest:_indexTopic selectDone:dicUserAnswer isRefresh:isRefresh];
}
//点击选项按钮 11 141 240
- (void)buttonSelectClick:(UIButton *)sender{
    //单选模式
    if (_topicType == 1) {
        
        for (id subView in self.contentView.subviews) {
            if ([subView isKindOfClass:[UIButton class]]) {
                UIButton *btn = (UIButton *)subView;
                if (btn.tag != 1111&&btn.tag != 2222) {
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
        //        [_dicSelectDone setValue:btnString forKey:[NSString stringWithFormat:@"%ld",_indexTopic]];
        NSDictionary *dicTest = @{[NSString stringWithFormat:@"%ld",_indexTopic]:btnString};
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
        //试题分值
        NSInteger score = [_dicTopic[@"score"] integerValue];
        NSDictionary *dicUserAnswer = @{@"QuestionID":questionId,@"QType":qtype,@"UserAnswer":userAnswer,@"TrueAnswer":answer,@"Score":[NSString stringWithFormat:@"%ld",score]};
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
- (IBAction)collectBtnClick:(UIButton *)sender {
    if (![_tyUser objectForKey:tyUserUserInfo]) {
        [SVProgressHUD showInfoWithStatus:@"您还没有登录哦"];
        return;
    }
    
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
    [SVProgressHUD show];
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
        httpsErrorShow;
    }];
}
/**
 取消收藏
 */
- (void)cancelCollectTopic{
    [SVProgressHUD show];
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
        httpsErrorShow;
    }];
    
    
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
    webView.frame = CGRectMake(15, 50, Scr_Width - 30, documentHeight + 20);
    CGFloat cellHeightL = _webViewTitle.frame.origin.y + documentHeight;
    NSInteger dicpaperId = [_dicTopic[@"parentId"] integerValue];
    ////////////////////////////////////////////////////////////
    //获取页面高度（像素）
    NSString * clientheight_str = [webView stringByEvaluatingJavaScriptFromString: @"document.body.offsetHeight"];
    float clientheight = [clientheight_str floatValue];
    //设置到WebView上
    webView.frame = CGRectMake(15, 50, Scr_Width - 30, clientheight);
    //获取WebView最佳尺寸（点）
    CGSize frame = [webView sizeThatFits:webView.frame.size];
    //获取内容实际高度（像素）
    NSString * height_str= [webView stringByEvaluatingJavaScriptFromString: @"document.getElementById('conten').offsetHeight + parseInt(window.getComputedStyle(document.getElementsByTagName('body')[0]).getPropertyValue('margin-top'))  + parseInt(window.getComputedStyle(document.getElementsByTagName('body')[0]).getPropertyValue('margin-bottom'))"];
    float height = [height_str floatValue];
    //内容实际高度（像素）* 点和像素的比
    height = height * frame.height / clientheight;
    //再次设置WebView高度（点）
    webView.frame = CGRectMake(15, 50, Scr_Width - 30, height);
    
//    CGFloat cellHeightLL = _webViewTitle.frame.origin.y + height;
    ////////////////////////////////////////////////////////////
    
    if (dicpaperId == 0) {
        if (_isWebFirstLoading) {
            //非小题试题二次刷新
            [self.delegateCellClick isWebLoadingCellHeight:cellHeightL + 160 + 20 withButtonOy:cellHeightL];
        }
    }
    else{
        //小题试题二次刷新
        if (![_arrayFirstLoading containsObject:[NSString stringWithFormat:@"%ld",_indexTopic]]) {
            [self.delegateCellClick isWebLoadingCellHeight:cellHeightL +150 withButtonOy:cellHeightL withIndex:_indexTopic];
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
        [self.delegateCellClick imageTopicArray:_arrayImgUrl withImageIndex:imageClickIndex];
        return NO;
    }
    return YES;
}

//??????????????????????????????????????????????????

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
