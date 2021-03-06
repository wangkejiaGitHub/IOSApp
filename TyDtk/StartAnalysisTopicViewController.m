//
//  StartAnalysisTopicViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/5/6.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "StartAnalysisTopicViewController.h"
#import "PaperTopicAnalysisViewController.h"
#import "NotesViewController.h"
#import "AnalysisErrorTopicViewController.h"
@interface StartAnalysisTopicViewController ()<TopicAnalysisCardDelegate,persentNotesDelegate,UIScrollViewDelegate>
//所有展示试题的容器
//@property (weak, nonatomic) IBOutlet UIButton *buttonRight;

@property (nonatomic,strong) UIScrollView *scrollViewPater;
@property (weak, nonatomic) IBOutlet UIButton *lastButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (weak, nonatomic) IBOutlet UIButton *buttonAnalysis;
@property (weak, nonatomic) IBOutlet UIButton *buttonErrorTopic;

@property (nonatomic,strong) UIBarButtonItem *buttonItemR;
@property (nonatomic,strong) NSUserDefaults *tyUser;
@property (nonatomic,strong) TopicAnalysisCardView *cardView;
@property (nonatomic,assign) BOOL isShowTopicCard;
//令牌
@property (nonatomic,strong) NSString *accessToken;
//试卷所有试题数组
@property (nonatomic,strong) NSArray *arrayPaterAnalysisData;
//scrollview 的宽度，单位是以屏宽的个数去计算(所有试题的个数)
@property (nonatomic,assign) NSInteger scrollContentWidth;
/////////////////////////////////////////////////////////
//试卷做题情况
//试题总数（只包含大题）
@property (nonatomic,assign) NSInteger intTpoicCount;
//总做题数
@property (nonatomic,assign) NSInteger intDoTopic;
//做错题数
@property (nonatomic,assign) NSInteger intWrongTopic;
//做对题数
@property (nonatomic,assign) NSInteger intRightTopic;
//正确率
@property (nonatomic,assign) NSInteger intAccuracy;
//总的得分（只有模拟试卷有得分）
@property (nonatomic,assign) NSInteger intScore;
//用于展示试卷分析数据的view（总题，错题，对题，正确率等概要）
@property (nonatomic,strong) UIView *viewAnalysis;
@end

@implementation StartAnalysisTopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.tabBar.hidden = YES;
    self.title = @"试卷解析";
    _intRightTopic = 0;
    _intWrongTopic = 0;
    _intDoTopic = 0;
    _intAccuracy = 0;
    _scrollViewPater = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, Scr_Width, Scr_Height - 45 - 64)];
    _scrollViewPater.delegate = self;
    _scrollViewPater.pagingEnabled = YES;
    [self.view addSubview:_scrollViewPater];
     _tyUser = [NSUserDefaults standardUserDefaults];
    _accessToken = [_tyUser objectForKey:tyUserAccessToken];
//    _buttonRight.userInteractionEnabled = NO;
//    [_buttonRight setTitle:@"试卷答题卡" forState:UIControlStateNormal];
    ///////
    _buttonItemR = [[UIBarButtonItem alloc]initWithTitle:@"答题卡" style:UIBarButtonItemStylePlain target:self action:@selector(buttonItemRClick:)];
    self.navigationItem.rightBarButtonItem = _buttonItemR;
    ///////
    _buttonAnalysis.userInteractionEnabled = NO;
    _buttonAnalysis.layer.masksToBounds = YES;
    _buttonAnalysis.layer.cornerRadius = 3;
//    _buttonAnalysis.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [_buttonAnalysis setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    
    _buttonErrorTopic.userInteractionEnabled = NO;
    _buttonErrorTopic.layer.masksToBounds = YES;
    _buttonErrorTopic.layer.cornerRadius = 3;
//    _buttonErrorTopic.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [_buttonErrorTopic setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    
    [self getTopicAnalysisPaper];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
//pop到做题页面的上一层view,跳过页做题页面防止重复做题
- (IBAction)buttonLiftItemClick:(UIBarButtonItem *)sender {
    //先判断是否给过用户提示
    //没有给过提示
    if (![_tyUser objectForKey:tyUserShowOutAnalysis]) {
        LXAlertView *alertPop = [[LXAlertView alloc]initWithTitle:@"温馨提示" message:@"确定退出试题解析吗？退出后可在练习记录中查看相关解析" cancelBtnTitle:@"不在提醒" otherBtnTitle:@"退出" clickIndexBlock:^(NSInteger clickIndex) {
            if (clickIndex == 0) {
                [_tyUser setObject:@"yes" forKey:tyUserShowOutAnalysis];
            }
            else{
                if (_isFromTiKu) {
                    NSInteger index = (NSInteger)[[self.navigationController viewControllers]indexOfObject:self];
                    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:(index -2)] animated:YES];
                }
                else{
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
        }];
        
        alertPop.animationStyle = LXASAnimationTopShake;
        [alertPop showLXAlertView];
    }
    //给过提示直接退出
    else{
        if (_isFromTiKu) {
            NSInteger index = (NSInteger)[[self.navigationController viewControllers]indexOfObject:self];
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:(index -2)] animated:YES];
        }
        else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

//键盘出现
- (void)keyboardShow:(NSNotification *)note{
    NSDictionary *userInfo = [note userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    //键盘高度
    CGFloat keyBoardHeight = keyboardRect.size.height;
    if (keyBoardHeight != 0) {
        CGRect rect = self.view.frame;;
        if (Scr_Width <= 320) {
            rect.origin.y = rect.origin.y - 100;
        }
        else if (Scr_Width == 375){
            rect.origin.y = rect.origin.y - 50;
        }
        self.navigationController.view.frame = rect;
    }
}
/////////////
////键盘监听//
////键盘消失//
- (void)keyboardHide:(NSNotification *)note{
    CGRect rect = self.view.frame;
    self.navigationController.view.frame = rect;
}
/////////////////////试卷试题分析（公共）//////////////////////////////
/////////////////////试卷试题分析（公共）//////////////////////////////
/**
 获取试卷试题分析(章节练习，模拟试卷，每周精选，智能做题)
 */
- (void)getTopicAnalysisPaper{
    [SVProgressHUD showWithStatus:@"正在获取试题分析..."];
    ///模拟试卷模块的解析试题
    NSString *urlString = [NSString stringWithFormat:@"%@api/Resolve/GetPaperResolveQuestions/%ld?access_token=%@&rid=%@",systemHttps,_PaperId,_accessToken,_rId];
    ///测试填空题的令牌
//    NSString *urlString = [NSString stringWithFormat:@"%@api/Resolve/GetPaperResolveQuestions/278?access_token=%@&rid=%@",systemHttps,@"1Ak0ePXnVNoeh7MfuxD3yYUxNzyFQoDee5Ehh1%2BdoNgqCCeWsjZBwU0QCLmsv6vaC1eyTdsatHcThK621xUl%2BcYXvV5%2B2sClbhWdkCo9Wf%2BGxVgPN6EGZeD3KgkIOfUxP0pTyXF6ZsAcpkmSgiU7i2Zcqo3JchyjBdbUe8Ukw654WQ9e/SupJgFxoc/QB3b2",_rId];
    
    if (_paperAnalysisParameter != 2) {
        ///章节考点、每周精选、智能出题等板块的解析试题
        urlString = [NSString stringWithFormat:@"%@api/Resolve/GetResolveQuestions?access_token=%@&rid=%@",systemHttps,_accessToken,_rId];
    }
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicAnalysis = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dicAnalysis[@"code"] integerValue];
        if (codeId == 1) {
            _arrayPaterAnalysisData = dicAnalysis[@"datas"];
            _scrollContentWidth = 0;
            ///模拟试卷模块
            if (_paperAnalysisParameter == 2) {
                for (NSDictionary *dicNum in _arrayPaterAnalysisData) {
                    NSArray *arrayDic = dicNum[@"Questions"];
                    _scrollContentWidth = _scrollContentWidth + arrayDic.count;
                }
            }
            else if (_paperAnalysisParameter == 3 | _paperAnalysisParameter == 1 | _paperAnalysisParameter == 4){
                _scrollContentWidth = _arrayPaterAnalysisData.count;
            }
            _intTpoicCount = _scrollContentWidth;
            //设置scrollView的容量
            _scrollViewPater.contentSize = CGSizeMake(_scrollContentWidth*Scr_Width, _scrollViewPater.bounds.size.height);
            
            [self addChildViewWithTopicForSelf];
//            _buttonRight.userInteractionEnabled = YES;
            [self addAnalysisTpoicCard];
            ///添加分析报告
            if (_paperAnalysisParameter == 1) {
                [self getChaperPaperAnalysisReportInfo];
            }
            else if (_paperAnalysisParameter == 2) {
                [self getSimulatePaperAnalysisReportInfo];
            }
            else if (_paperAnalysisParameter == 3){
                [self getWeekPaperAnalysisReportInfo];
            }
            else if (_paperAnalysisParameter == 4){
                [self getIntelligentPaperAnalysisReportInfo];
            }
            _buttonAnalysis.userInteractionEnabled = YES;
            _buttonErrorTopic.userInteractionEnabled = YES;
            [SVProgressHUD dismiss];
        }
        else{
            [SVProgressHUD showInfoWithStatus:dicAnalysis[@"errmsg"]];
        }
        
    } RequestFaile:^(NSError *error) {
        [SVProgressHUD showInfoWithStatus:@"请求异常！"];
    }];
}
/////////////////////试卷试题分析（公共）//////////////////////////////
/////////////////////试卷试题分析（公共）//////////////////////////////
///////////2016-05-13进度记录 /////试题分析报告

/////////////////////模拟试卷模块分析报告//////////////////////////////
/**
 获取模拟试卷模块分析报告
 */
- (void)getSimulatePaperAnalysisReportInfo{
    NSString *urlString = [NSString stringWithFormat:@"%@api/Paper/LookReportInfo?access_token=%@&rid=%@",systemHttps,_accessToken,_rId];
    [HttpTools postHttpRequestURL:urlString RequestPram:nil RequestSuccess:^(id respoes) {
        NSDictionary *dicReport = (NSDictionary *)respoes;
        NSInteger codeId = [dicReport[@"code"] integerValue];
        if (codeId == 1) {
            NSDictionary *dicDatas = dicReport[@"datas"];
            _intDoTopic = [dicDatas[@"DoneNum"] integerValue];
            _intRightTopic = [dicDatas[@"RightNum"]integerValue];
            _intWrongTopic = [dicDatas[@"ErrorNum"] integerValue];
            _intAccuracy = [dicDatas[@"Accuracy"] integerValue];
            _intScore = [dicDatas[@"Score"] integerValue];
            [self addViewAnalysisForAnalysis];
        }
    } RequestFaile:^(NSError *erro) {
        
    }];
}
/////////////////////模拟试卷模块分析报告//////////////////////////////
//05-25 0.5记录
/////////////////////每周精选模块分析报告//////////////////////////////
- (void)getWeekPaperAnalysisReportInfo{
    NSString *urlString = [NSString stringWithFormat:@"%@api/Weekly/GetWeeklyReport?access_token=%@&rid=%@",systemHttps,_accessToken,_rId];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicAnalysis = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dicAnalysis[@"code"] integerValue];
        if (codeId == 1) {
            NSDictionary *dicDatas = dicAnalysis[@"datas"];
            _intDoTopic = [dicDatas[@"DoneNum"] integerValue];
            _intRightTopic = [dicDatas[@"RightNum"] integerValue];
            _intWrongTopic = [dicDatas[@"ErrorNum"] integerValue];
            _intAccuracy = [dicDatas[@"Accuracy"] integerValue];
            _intScore = [dicDatas[@"Score"] integerValue];
            [self addViewAnalysisForAnalysis];
        }
    } RequestFaile:^(NSError *error) {
        
    }];
    
}
/////////////////////每周精选模块分析报告//////////////////////////////

/////////////////////章节练习模块分析报告//////////////////////////////
/**
 章节练习分析报告
 */
- (void)getChaperPaperAnalysisReportInfo{
    NSString *urlString = [NSString stringWithFormat:@"%@api/Chapter/GetReportInfo?access_token=%@&rid=%@",systemHttps,_accessToken,_rId];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicAnalysis = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        if ([dicAnalysis[@"code"] integerValue] == 1) {
            NSDictionary *dicDatas = dicAnalysis[@"datas"];
            _intDoTopic = [dicDatas[@"DoneNum"] integerValue];
            _intRightTopic = [dicDatas[@"RightNum"] integerValue];
            _intWrongTopic = [dicDatas[@"ErrorNum"] integerValue];
            _intAccuracy = [dicDatas[@"Accuracy"] integerValue];
            _intScore = [dicDatas[@"Score"] integerValue];
            [self addViewAnalysisForAnalysis];

        }
    } RequestFaile:^(NSError *error) {
        
    }];
}
/////////////////////章节练习模块分析报告//////////////////////////////

/////////////////////智能做题模块分析报告//////////////////////////////
/**
 获取智能做题分析报告
 */
- (void)getIntelligentPaperAnalysisReportInfo{
//    api/Smart/GetSmartReport?access_token={access_token}&rid={rid}
    NSString *urlString = [NSString stringWithFormat:@"%@api/Smart/GetSmartReport?access_token=%@&rid=%@",systemHttps,_accessToken,_rId];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicAnalysis = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        if ([dicAnalysis[@"code"] integerValue] == 1) {
            NSDictionary *dicDatas = dicAnalysis[@"datas"];
            _intDoTopic = [dicDatas[@"DoneNum"] integerValue];
            _intRightTopic = [dicDatas[@"RightNum"] integerValue];
            _intWrongTopic = [dicDatas[@"ErrorNum"] integerValue];
            _intAccuracy = [dicDatas[@"Accuracy"] integerValue];
            _intScore = [dicDatas[@"Score"] integerValue];
            [self addViewAnalysisForAnalysis];
        }

    } RequestFaile:^(NSError *error) {
        
    }];
}
/////////////////////智能做题模块分析报告//////////////////////////////
/**
添加数据分析报告试图
 */
- (void)addViewAnalysisForAnalysis{
    [_viewAnalysis removeFromSuperview];
    //试题统计总试图
    _viewAnalysis = [[UIView alloc]initWithFrame:CGRectMake(0, Scr_Height, Scr_Width, Scr_Height - 190)];
    _viewAnalysis.layer.masksToBounds = YES;
    _viewAnalysis.layer.cornerRadius = 10;
    _viewAnalysis.backgroundColor = [UIColor groupTableViewBackgroundColor];
    //添加关闭按钮
    UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCancel.frame = CGRectMake(Scr_Width - 30, 0, 30, 30);
    [btnCancel setImage:[UIImage imageNamed:@"icon_close"] forState:UIControlStateNormal];
    btnCancel.highlighted = YES;
    [btnCancel addTarget:self action:@selector(buttonHidenViewAnalysisClick:) forControlEvents:UIControlEventTouchUpInside];
    [_viewAnalysis addSubview:btnCancel];
    //添加绘制图表
    ZFPieChart *pieChartAnalysis = [[ZFPieChart alloc]initWithFrame:CGRectMake(Scr_Width/2, 70, Scr_Width/2, _viewAnalysis.frame.size.height - 233)];
//    pieChartAnalysis.title = @"试题分析";
    pieChartAnalysis.valueArray = [NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"%ld",_intRightTopic], [NSString stringWithFormat:@"%ld",_intWrongTopic], nil];
    pieChartAnalysis.nameArray = [NSMutableArray arrayWithObjects:@"答对", @"答错", nil];
    pieChartAnalysis.colorArray = [NSMutableArray arrayWithObjects:ZFColor(71, 204, 255, 1), ZFColor(253, 203, 76, 1), ZFColor(214, 205, 153, 1), ZFColor(78, 250, 188, 1), ZFColor(16, 140, 39, 1), ZFColor(45, 92, 34, 1), nil];
    [_viewAnalysis addSubview:pieChartAnalysis];
    [pieChartAnalysis strokePath];
    //添加正确率等数据
    //试题总数
    UILabel *labTopicCount = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, Scr_Width - 20, 25)];
    labTopicCount.font = [UIFont systemFontOfSize:15.0];
//    labTopicCount.textAlignment = NSTextAlignmentCenter;
    //属性字符串试题的总数
    NSMutableAttributedString *attrTopicCount = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"该试卷共【%ld】题(所指大题数)",_intTpoicCount]];
    [attrTopicCount addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(5,[NSString stringWithFormat:@"%ld",_intTpoicCount].length)];
    [labTopicCount setAttributedText:attrTopicCount];
    [_viewAnalysis addSubview:labTopicCount];
    //做题数
    UILabel *labDoTopic = [[UILabel alloc]initWithFrame:CGRectMake(20, 50, Scr_Width - 20, 25)];
    labDoTopic.font = [UIFont systemFontOfSize:15.0];
    //属性字符串试题的总数
    NSMutableAttributedString *attrDoTopic = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"您共做了【%ld】题(包含所有大题下面的小题)",_intDoTopic]];
    [attrDoTopic addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(5,[NSString stringWithFormat:@"%ld",_intDoTopic].length)];
    [labDoTopic setAttributedText:attrDoTopic];
    [_viewAnalysis addSubview:labDoTopic];
    
    //正确率试图
    UIView *viewAccuracy = [[UIView alloc]initWithFrame:CGRectMake(20, 123, Scr_Width/2 - 60, Scr_Width/2 - 60)];
    CGRect rectVV = viewAccuracy.frame;
    if (Scr_Width == 320) {
        rectVV.origin.y = 90;
    }
    else if (Scr_Width == 375){
        rectVV.origin.y = 123;
    }
    else{
        rectVV.origin.y = 150;
    }
    viewAccuracy.frame = rectVV;
    viewAccuracy.layer.masksToBounds = YES;
    viewAccuracy.layer.cornerRadius = viewAccuracy.frame.size.height/2;
    viewAccuracy.backgroundColor = [UIColor clearColor];
    viewAccuracy.layer.borderWidth = 5;
    viewAccuracy.layer.borderColor = [[UIColor orangeColor] CGColor];
    [_viewAnalysis addSubview:viewAccuracy];
    //试图中的数字，显示百分比
    CGFloat labX = viewAccuracy.frame.origin.x+(viewAccuracy.frame.size.width)/2;
    CGFloat labY = viewAccuracy.frame.origin.y + (viewAccuracy.frame.size.width)/2;
    UILabel *labViewAccuracy = [[UILabel alloc]initWithFrame:CGRectMake(labX - 25, labY - 15, 50, 30)];
    labViewAccuracy.text = [NSString stringWithFormat:@"%ld",_intAccuracy];
    labViewAccuracy.font = [UIFont systemFontOfSize:18.0];
    labViewAccuracy.textAlignment = NSTextAlignmentCenter;
    [_viewAnalysis addSubview:labViewAccuracy];
    //百分号
    UILabel *labBfh = [[UILabel alloc] initWithFrame:CGRectMake(viewAccuracy.frame.origin.x+viewAccuracy.frame.size.width - 40, viewAccuracy.frame.origin.y+viewAccuracy.frame.size.height - 40, 40, 40)];
    labBfh.layer.masksToBounds = YES;
    labBfh.layer.cornerRadius = 20;
    labBfh.backgroundColor =[UIColor orangeColor];
    labBfh.textColor = [UIColor whiteColor];
    labBfh.textAlignment = NSTextAlignmentCenter;
    labBfh.text = @"%";
    labBfh.font = [UIFont systemFontOfSize:23.0];
    [_viewAnalysis addSubview:labBfh];
    
    //正确率
    UILabel *labAccuracy = [[UILabel alloc]initWithFrame:CGRectMake(20, viewAccuracy.frame.origin.y + viewAccuracy.frame.size.height + 50, Scr_Width/2 - 40, 30)];
    labAccuracy.font = [UIFont systemFontOfSize:15.0];
    NSMutableAttributedString *attrAccuracy = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"正确率：%ld%%",_intAccuracy]];
    [attrAccuracy addAttribute:NSForegroundColorAttributeName value:[UIColor purpleColor] range:NSMakeRange(4,[NSString stringWithFormat:@"%ld",_intAccuracy].length+1)];
    [labAccuracy setAttributedText:attrAccuracy];
    [_viewAnalysis addSubview:labAccuracy];
//    //所用时间
//    UILabel *labTime =[[UILabel alloc]initWithFrame:CGRectMake(20, viewAccuracy.frame.origin.y + viewAccuracy.frame.size.height + 80, Scr_Width/2 - 40, 30)];
//    labTime.font = [UIFont systemFontOfSize:15.0];
//    NSMutableAttributedString *attrTime = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"答题时间：%@",@"0"]];
//    [attrTime addAttribute:NSForegroundColorAttributeName value:[UIColor purpleColor] range:NSMakeRange(5,1)];
//    [labTime setAttributedText:attrTime];
//    [_viewAnalysis addSubview:labTime];
    //如果是模拟试卷做题，添加得分
    if (_paperAnalysisParameter == 2) {
        ///得分
        UILabel *labScore = [[UILabel alloc]initWithFrame:CGRectMake(20, labAccuracy.frame.origin.y+30, Scr_Width/2 - 40, 30)];
        labScore.font = [UIFont systemFontOfSize:15.0];
        NSMutableAttributedString *attrScore = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"得分：【%ld】分",_intScore]];
        [attrScore addAttribute:NSForegroundColorAttributeName value:[UIColor purpleColor] range:NSMakeRange(4,[NSString stringWithFormat:@"%ld",_intScore].length)];
        [labScore setAttributedText:attrScore];
        [_viewAnalysis addSubview:labScore];
    }
    [self.view addSubview:_viewAnalysis];
    UISwipeGestureRecognizer *swipeView = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(viewAnalysisHiden:)];
    swipeView.direction = UISwipeGestureRecognizerDirectionDown;
    [_viewAnalysis addGestureRecognizer:swipeView];
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rectAna =_viewAnalysis.frame;
        rectAna.origin.y =200;
        _viewAnalysis.frame = rectAna;
    }];
    
}
//向下滑动隐藏试题分析
- (void)viewAnalysisHiden:(UISwipeGestureRecognizer *)swipe{
     [self hidenViewAnalysis];
}
///只看错题
- (IBAction)buttonLookErrorTopic:(UIButton *)sender {
    [self performSegueWithIdentifier:@"errortopic" sender:_rId];
}

//显示分析报告试图
- (IBAction)buttonAnalysisClick:(UIButton *)sender {
    [self addViewAnalysisForAnalysis];
}

//隐藏试卷解析报告试图
- (void)buttonHidenViewAnalysisClick:(UIButton *)sender{
    [self hidenViewAnalysis];
}
/**
 隐藏数据分析报告试图
 */
- (void)hidenViewAnalysis{
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rectAna =_viewAnalysis.frame;
        rectAna.origin.y = Scr_Height;
        _viewAnalysis.frame = rectAna;
    }];
}
///////////2016-05-13进度记录
//上一题
- (IBAction)buttonLastClick:(UIButton *)sender {
    if (_scrollViewPater.contentOffset.x>=Scr_Width) {
        _lastButton.userInteractionEnabled = NO;
        _nextButton.userInteractionEnabled =NO;
        [_scrollViewPater setContentOffset:CGPointMake(_scrollViewPater.contentOffset.x - Scr_Width, 0) animated:YES];
    }
    else{
        [SVProgressHUD showInfoWithStatus:@"前面没有试题了~"];
    }
    [self topicCardHiden];
}
//下一题
- (IBAction)buttonNextClick:(UIButton *)sender {
    if (_scrollViewPater.contentOffset.x < _scrollContentWidth*Scr_Width - Scr_Width) {
        _lastButton.userInteractionEnabled = NO;
        _nextButton.userInteractionEnabled =NO;
        [_scrollViewPater setContentOffset:CGPointMake(_scrollViewPater.contentOffset.x + Scr_Width, 0) animated:YES];
    }
    else{
        [SVProgressHUD showInfoWithStatus:@"已经到最后一题了~"];
    }
    [self topicCardHiden];
}

//隐藏或显示答题卡
//- (IBAction)buttonRightClick:(UIButton *)sender {
//    _isShowTopicCard = !_isShowTopicCard;
//    if (_isShowTopicCard) {
//        [self topicCardShow];
//    }
//    else{
//        [self topicCardHiden];
//    }
//}
- (void)buttonItemRClick:(UIBarButtonItem *)item{
    _isShowTopicCard = !_isShowTopicCard;
    if (_isShowTopicCard) {
        [self topicCardShow];
    }
    else{
        [self topicCardHiden];
    }
}
/**
 添加解析答题卡信息
 */
- (void)addAnalysisTpoicCard{
    if (!_cardView) {
        _cardView = [[TopicAnalysisCardView alloc]initWithFrame:CGRectMake(Scr_Width, 64, Scr_Width,Scr_Height/2) arrayTopic:_arrayPaterAnalysisData paperParameter:_paperAnalysisParameter];
        _cardView.delegateCellClick = self;
        [self.view addSubview:_cardView];
    }
}
/**
 显示答题卡
 */
- (void)topicCardShow{
//    [_buttonRight setTitle:@"隐藏答题卡" forState:UIControlStateNormal];
    _buttonItemR.title = @"隐藏答题卡";
    //    [_collectionViewTopicCard setContentOffset:CGPointMake(0, 0) animated:YES];
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = _cardView.frame;
        rect.origin.x = 0;
        _cardView.frame = rect;
    }];
}
/**
 隐藏答题卡
 */
- (void)topicCardHiden{
    _isShowTopicCard = NO;
    _buttonItemR.title = @"";
//    [_buttonRight setTitle:@"试卷答题卡" forState:UIControlStateNormal];
    _buttonItemR.title = @"答题卡";
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = _cardView.frame;
        rect.origin.x = Scr_Width;
        _cardView.frame = rect;
    }];
}
/**
 添加子试图，（每一个子试图相当于一道题）并依次在scrollView中显示出来
 */
- (void)addChildViewWithTopicForSelf{
    for (int i =0; i<_scrollContentWidth; i++) {
        PaperTopicAnalysisViewController *chVc = [[PaperTopicAnalysisViewController alloc]init];
        [self addChildViewController:chVc];
    }
    for (int i = 0; i<_scrollContentWidth; i++) {
        PaperTopicAnalysisViewController *paterVc = self.childViewControllers[i];
        paterVc.topicTitle = nil;
        ///模拟试卷模块
        if(_paperAnalysisParameter == 2) {
            paterVc.dicTopic = [self getTopicDictionary:i];
            NSString *topString = [self topicTitle:i];
            if (topString != nil) {
                paterVc.topicTitle = topString;
            }
        }
        //每周精选模块
        else if (_paperAnalysisParameter == 3 | _paperAnalysisParameter == 1 | _paperAnalysisParameter == 4){
            paterVc.dicTopic = _arrayPaterAnalysisData[i];
        }
        if (i == _scrollContentWidth - 1) {
            paterVc.isLastTopic = YES;
        }
        else{
            paterVc.isLastTopic = NO;
        }

        paterVc.topicIndex = i+1;
        paterVc.delegatePersent = self;
        paterVc.view.frame = CGRectMake(i*Scr_Width, 0, Scr_Width, Scr_Height - 45 - 64);
        [_scrollViewPater addSubview:paterVc.view];
    }
}
/**
 传递题干信息，每一类试题的第一道题，传递题干信息
 */
- (NSString *)topicTitle:(NSInteger)topicIndex{
    NSInteger countDicF = 0;
    NSInteger countDicL = 0;
    for (NSDictionary *dic in _arrayPaterAnalysisData) {
        NSArray *array = dic[@"Questions"];
        countDicL = array.count + countDicF;
        if (topicIndex >= countDicF && topicIndex <= countDicL-1) {
            if (topicIndex == countDicF) {
                NSDictionary *dicCaption = dic[@"Caption"];
                NSString *topicTitle = dicCaption[@"Names"];
                return topicTitle;
            }
        }
        countDicF = countDicL;
    }
    return nil;
}
/**
 根据索引获取所对应的题目字典
 */
- (NSDictionary *)getTopicDictionary:(NSInteger)index{
    NSInteger countDicF = 0;
    NSInteger countDicL = 0;
    for (NSDictionary *dic in _arrayPaterAnalysisData) {
        NSArray *array = dic[@"Questions"];
        countDicL = array.count + countDicF;
        if (index >= countDicF && index <= countDicL - 1) {
            NSDictionary *diccc = array[index - countDicF];
            return diccc;
        }
        countDicF = countDicL;
    }
    return nil;
}
//点击答题卡上，转到指定试题
- (void)topicCollectonViewCellClick:(NSInteger)indexScroll{
    [_scrollViewPater setContentOffset:CGPointMake((indexScroll-1)*Scr_Width, 0) animated:YES];
    [self topicCardHiden];

}
//跳转到笔记界面代理
- (void)persentNotesViewController:(NSString *)questionId{
//    [self performSegueWithIdentifier:@"notesdata" sender:questionId];
    NotesViewController *noteVc = [[NotesViewController alloc]initWithNibName:@"NotesViewController" bundle:nil];
    noteVc.questionId = questionId;
    [self.navigationController pushViewController:noteVc animated:YES];
}
//跳转到只看错题页面
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"errortopic"]) {
        AnalysisErrorTopicViewController *errorTp = segue.destinationViewController;
        errorTp.ridError = _rId;
    }
}
//scrollView代理
//动画结束，控制不让‘上一题’，‘下一题’连续点击
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    _lastButton.userInteractionEnabled = YES;
    _nextButton.userInteractionEnabled =YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
