//
//  PaterTopicQtype3TableViewCell.m
//  TyDtk
//
//  Created by 天一文化 on 16/5/3.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "PaterTopicQtype3TableViewCell.h"
@interface PaterTopicQtype3TableViewCell()<UIScrollViewDelegate,UIWebViewDelegate>
@property (nonatomic,strong) NSUserDefaults *tyUser;
////??????????????????????????????????????????????????????
//@property (weak, nonatomic) UIScrollView *scrollView;
//@property (weak, nonatomic) UIImageView *lastImageView;
//@property (nonatomic, assign)CGRect originalFrame;
//@property (nonatomic, assign)BOOL isDoubleTap;
//
//@property (nonatomic,strong) UIImageView *selectTapView;
////??????????????????????????????????????????????????????
@property (nonatomic,assign) CGFloat viewImageOy;

@property (nonatomic,strong) NSMutableArray *arrayImgUrl;
//选项按钮起点坐标
@property (nonatomic,assign) CGFloat buttonOrginY;
@end
@implementation PaterTopicQtype3TableViewCell

- (void)awakeFromNib {
    _imageCollect.layer.masksToBounds = YES;
    _imageCollect.layer.cornerRadius = 2;
    _buttonCollect.layer.masksToBounds = YES;
    _buttonCollect.layer.cornerRadius = 2;
    _buttonRight.layer.masksToBounds = YES;
    _buttonRight.layer.cornerRadius = 3;
    _buttonRight.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [_buttonRight setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    _buttonWrong.layer.masksToBounds = YES;
    _buttonWrong.layer.cornerRadius = 3;
    _buttonWrong.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [_buttonWrong setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    _webViewTitle.backgroundColor = [UIColor clearColor];
    _webViewTitle.scrollView.scrollEnabled = NO;
    _webViewTitle.delegate = self;
    _webViewTitle.opaque = NO;
    _tyUser = [NSUserDefaults standardUserDefaults];
    
}
- (void)setvalueForCellModel:(NSDictionary *)dic topicIndex:(NSInteger)index{
    _indexTopic = index;
    _dicTopic = dic;
    //判断视图是否有图片
//    NSInteger qtypeTopic = [dic[@"qtype"] integerValue];
    NSString *topicTitle = dic[@"title"];
    //试题编号
    _labNumber.text = [NSString stringWithFormat:@"%ld、",index];
    //判断是否为一题多问下面的简答题
    NSInteger parentId = [dic[@"parentId"] integerValue];
    _buttonOrginY = _buttonOy;
    //一题多问下面的小题
    if (parentId != 0) {
        _buttonOrginY = _buttonSubOy;
        _labNumber.text = [NSString stringWithFormat:@"(%ld)",index];
        _labNumber.textColor = [UIColor orangeColor];
        _labNumber.font = [UIFont systemFontOfSize:13.0];
        _labNumberWidth.constant = _labNumber.text.length*10;
    }
    else{
        _labNumber.font = [UIFont systemFontOfSize:15.0];
        _labNumberWidth.constant = _labNumber.text.length*10+15;
    }
    
    //试题类型（单选，多选）
    _labTopicType.text = [NSString stringWithFormat:@"(%@)",dic[@"typeName"]];
    topicTitle = [topicTitle stringByReplacingOccurrencesOfString:@"/tiku/common/getAttachment" withString:[NSString stringWithFormat:@"%@/tiku/common/getAttachment",systemHttpsKaoLaTopicImg]];
    NSString *htmlString = [NSString stringWithFormat:@"<html><body><div id='conten' contenteditable='false' style='word-break:break-all;'>%@</div></body></html>",topicTitle];
    [_webViewTitle loadHTMLString:htmlString baseURL:nil];

    /////////////进度节点///////////////////////////////
    /////////////删除button 防止复用////////////////////
    for (id subView in self.contentView.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)subView;
            if (btn.tag == 2222) {
                [btn removeFromSuperview];
            }
        }
    }
    ///////////////////////////////////////////////
    //是否有做过的试题，防止cell复用的时候做过的试题标记消失
    for (id subView in self.contentView.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subView;
            if (button.tag != 1111) {
                //先判断是否是继续做题已做
                if (dic[@"userAnswer"]) {
                    if ([dic[@"userAnswer"] isEqualToString:@"1"]) {
                        if ([button.titleLabel.text isEqualToString:@"√"]) {
                            button.backgroundColor = ColorWithRGB(11, 141, 240);
                            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        }
                        else{
                            button.backgroundColor = [UIColor groupTableViewBackgroundColor];
                            [button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
                        }
                    }
                    else{
                        if ([button.titleLabel.text isEqualToString:@"×"]) {
                            button.backgroundColor = ColorWithRGB(11, 141, 240);
                            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        }
                        else{
                            button.backgroundColor = [UIColor groupTableViewBackgroundColor];
                            [button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
                        }
                        
                    }
                }
                
                NSString *indexString = [NSString stringWithFormat:@"%ld",index];
                if ([_dicSelectDone.allKeys containsObject:indexString]) {
                    NSString *selectString = _dicSelectDone[indexString];
                    if ([button.titleLabel.text isEqualToString:selectString]) {
                        button.backgroundColor = ColorWithRGB(11, 141, 240);
                        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    }
                    else{
                        button.backgroundColor = [UIColor groupTableViewBackgroundColor];
                        [button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
                    }
                }
                
            }
        }
    }
    ///////////////////////////////////////
    
    //最后分别添加笔记和纠错按钮
    //添加笔记按钮
    UIButton *buttonNotes = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonNotes.frame = CGRectMake(Scr_Width - 75, _buttonOrginY + 30, 60, 23);
    buttonNotes.backgroundColor = ColorWithRGB(200, 200, 200);
    buttonNotes.layer.masksToBounds = YES;
    buttonNotes.layer.cornerRadius = 2;
    [buttonNotes setTitle:@"📓笔记" forState:UIControlStateNormal];
    [buttonNotes setImage:[UIImage imageNamed:@"bj01"] forState:UIControlStateNormal];
    [buttonNotes setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 25)];
    buttonNotes.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [buttonNotes setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    buttonNotes.tag = 2222;
    [buttonNotes addTarget:self action:@selector(buttonNotesClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:buttonNotes];
    //添加纠错按钮
    UIButton *buttonError = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonError.frame = CGRectMake(15, _buttonOrginY + 30, 60, 23);
    buttonError.backgroundColor = ColorWithRGB(200, 200, 200);
    buttonError.layer.masksToBounds = YES;
    buttonError.layer.cornerRadius = 2;
    [buttonError setTitle:@"🔧纠错" forState:UIControlStateNormal];
    [buttonError setImage:[UIImage imageNamed:@"jc01"] forState:UIControlStateNormal];
    [buttonError setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 25)];
    buttonError.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [buttonError setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    buttonError.tag = 2222;
    [buttonError addTarget:self action:@selector(buttonErrorClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:buttonError];
    self.backgroundColor = [UIColor clearColor];
    _dicTopic = dic;
    
    //判断是否是最一题，给用户提示
    if (_isLastTopic) {
        UIButton *btnLastTopic =[UIButton buttonWithType:UIButtonTypeCustom];
        btnLastTopic.frame = CGRectMake((Scr_Width - 100)/2, _buttonOrginY + 30, 100, 23);
        btnLastTopic.tag = 1111;
        btnLastTopic.backgroundColor =ColorWithRGB(200, 200, 200);
        btnLastTopic.layer.masksToBounds = YES;
        btnLastTopic.layer.cornerRadius = 2;
        btnLastTopic.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [btnLastTopic setTitle:@"已是最后一题了" forState:UIControlStateNormal];
        [btnLastTopic setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
        [self.contentView addSubview:btnLastTopic];
        
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
}
//'对','错'的选项按钮
- (IBAction)buttonSelect:(UIButton *)sender {
    
    for (id subView in self.contentView.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)subView;
            if (btn.tag != 1111 && btn.tag != 2222) {
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
    if ([userAnswer isEqualToString:@"√"]) {
        userAnswer = @"1";
    }
    else{
        userAnswer = @"0";
    }
    NSInteger score = [_dicTopic[@"score"] integerValue];
    NSDictionary *dicUserAnswer = @{@"QuestionID":questionId,@"QType":qtype,@"UserAnswer":userAnswer,@"Score":[NSString stringWithFormat:@"%ld",score],@"trueAnswer":answer};
    //        [self.delegateCellClick topicCellSelectClickTest:_indexTopic selectDone:dicUserAnswer       ];
    [self.delegateCellClick topicCellSelectClickTest:_indexTopic selectDone:dicUserAnswer isRefresh:isRefresh];
}
//收藏按钮
- (IBAction)buttonCollectClick:(UIButton *)sender {
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
//    webView.frame = CGRectMake(15, 50, Scr_Width - 30, documentHeight + 20);
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
//    webView.frame = CGRectMake(15, 50, Scr_Width - 30, height);
    _webViewTitleHeight.constant = height;
    cellHeightL = _webViewTitle.frame.origin.y+height;
//    CGFloat cellHeightLL = _webViewTitle.frame.origin.y + height;
    ////////////////////////////////////////////////////////////
    
    if (dicpaperId == 0) {
        if (_isWebFirstLoading) {
            //非小题试题二次刷新
            [self.delegateCellClick isWebLoadingCellHeight:cellHeightL + 150 withButtonOy:cellHeightL + 50];
        }
    }
    else{
        //小题试题二次刷新
        if (![_arrayFirstLoading containsObject:[NSString stringWithFormat:@"%ld",_indexTopic]]) {
            [self.delegateCellClick isWebLoadingCellHeight:cellHeightL +150 withButtonOy:cellHeightL +50 withIndex:_indexTopic];
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
