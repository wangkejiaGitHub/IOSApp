//
//  StartDoTopicViewController.m
//  TyDtk
//  用户展示所有试题界面，把所有试题都加载在scrollView上进行展示
//  Created by 天一文化 on 16/4/11.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//
#import "StartDoTopicViewController.h"
#import "PatersTopicViewController.h"
#import "StartAnalysisTopicViewController.h"
@interface StartDoTopicViewController ()<UIScrollViewDelegate,TopicCardDelegate,TopicCardRefreshDelegate>
///判断用户是否登录
@property (nonatomic,assign) BOOL isUserLogin;
//ScrollView所有展示试题的容器
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewPater;
@property (weak, nonatomic) IBOutlet UIButton *buttonRight;
//navigationitem上的试图
@property (weak, nonatomic) IBOutlet UIView *viewNaviHeardView;

@property (weak, nonatomic) IBOutlet UIButton *lastButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *labTime;
@property (weak, nonatomic) IBOutlet UILabel *labSurplus;
@property (weak, nonatomic) IBOutlet UIButton *buttonSubPater;
@property (weak, nonatomic) IBOutlet UIButton *buttonSaveSch;

/**
 用户储存用户每道试题的答案
 */
@property (nonatomic,strong) NSMutableArray *arrayUserAnswer;
//用户已做过的题的数量
@property (nonatomic,assign) NSInteger intUserDidTopic;
//本地信息存储
@property (nonatomic,strong) NSUserDefaults *tyUser;
//令牌
@property (nonatomic,strong) NSString *accessToken;
//试卷试题信息数组
@property (nonatomic,strong) NSArray *arrayPaterData;
///scrollview 的宽度，单位是以屏宽的个数去计算:(单位：屏宽/个)
@property (nonatomic,assign) NSInteger scrollContentWidth;
//答题卡
@property (nonatomic,strong) TopicCardCollectionView *collectionViewTopicCard;
@property (nonatomic,assign) BOOL isShowTopicCard;
@property (nonatomic,strong) NSTimer *timeLong;
@property (nonatomic,assign) NSInteger timeHo;
@property (nonatomic,assign) NSInteger timeMin;
@property (nonatomic,assign) NSInteger timeSe;

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

@implementation StartDoTopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _arrayUserAnswer = [NSMutableArray array];
    _tyUser = [NSUserDefaults standardUserDefaults];
    _accessToken = [_tyUser objectForKey:tyUserAccessToken];
    ///判断用户是否登录
    if ([_tyUser objectForKey:tyUserUserInfo]) {
        _isUserLogin = YES;
    }
    else{
        _isUserLogin = NO;
    }
    _buttonRight.userInteractionEnabled = NO;
    [_buttonRight setTitle:@"答题卡" forState:UIControlStateNormal];
    [_buttonSubPater setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    _buttonSubPater.layer.masksToBounds = YES;
    _buttonSubPater.layer.cornerRadius = 3;
    [_buttonSaveSch setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    _buttonSaveSch.layer.masksToBounds = YES;
    _buttonSaveSch.layer.cornerRadius = 3;
    _buttonSaveSch.userInteractionEnabled = NO;
    [self setTimeForTopic];
    //章节练习
    if (self.paperParameter == 1) {
        self.navigationItem.titleView = nil;
        self.title = @"章节练习";
        _buttonSaveSch.userInteractionEnabled = YES;
        [self getChaperPaperData];
    }
    //模拟试卷
    else if (self.paperParameter == 2){
        _buttonSaveSch.userInteractionEnabled = YES;
        [self getPaterDatas];
    }
    //每周精选
    else if (self.paperParameter == 3){
        _buttonSaveSch.backgroundColor = [UIColor lightGrayColor];
        //去掉剩余时间显示字段
        self.navigationItem.titleView = nil;
        self.title = @"每周精选";
        [_buttonSubPater setTitle:@"结束答题" forState:UIControlStateNormal];
        [self getWeekPaperData];
    }
    //智能出题
    else if (self.paperParameter == 4){
         _buttonSaveSch.backgroundColor = [UIColor lightGrayColor];
        self.navigationItem.titleView = nil;
        self.title = @"智能出题";
        [_buttonSubPater setTitle:@"结束答题" forState:UIControlStateNormal];
        [self getIntelligentPaperData];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    if (![_tyUser objectForKey:tyUserShowUpdateAnswer]) {
        LXAlertView *alert = [[LXAlertView alloc]initWithTitle:@"温馨提示" message:@"在未提交卷之前，您可以修改已经做过或者已保存答案的试题" cancelBtnTitle:@"我知道了" otherBtnTitle:@"不在提醒" clickIndexBlock:^(NSInteger clickIndex) {
            if (clickIndex == 1) {
                [_tyUser setObject:@"yes" forKey:tyUserShowUpdateAnswer];
            }
        }];
        alert.animationStyle = LXASAnimationTopShake;
        [alert showLXAlertView];
    }
    
}
- (void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [_timeLong invalidate];
    [_collectionViewTopicCard.timerCard invalidate];
}
//pop
- (IBAction)popButtonClick:(UIBarButtonItem *)sender {
    if (_intUserDidTopic > 0) {
        LXAlertView *aleveAlert = [[LXAlertView alloc]initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"您已经做了%ld道题，确认放弃做题离开吗？",_intUserDidTopic]cancelBtnTitle:@"放弃" otherBtnTitle:@"继续做题" clickIndexBlock:^(NSInteger clickIndex) {
            if (clickIndex == 0) {
//                if (_isFromTiKu) {
//                    //当前的Viewcontrol在本栈列的位置
//                    NSInteger index = (NSInteger)[[self.navigationController viewControllers]indexOfObject:self];
//                    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:(index -2)] animated:YES];
//                }
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
        aleveAlert.animationStyle = LXASAnimationTopShake;
        [aleveAlert showLXAlertView];
    }
    else{
         [self.navigationController popViewControllerAnimated:YES];
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
//////////////////////////////模拟试卷模块//////////////////////////////
//****************************模拟试卷模块****************************//
/**
 获取试卷试题
 */
- (void)getPaterDatas{
    [SVProgressHUD showWithStatus:@"试卷加载中..."];
    NSInteger paterId = [_dicPater[@"Id"] integerValue];
    NSString *urlString = [NSString stringWithFormat:@"%@api/Paper/GetPaperQuestions/%ld?access_token=%@",systemHttps,paterId,_accessToken];
    //判断是否是继续做题，如果是，rid有值
    if (_ridContinue.length > 0) {
        urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"&rid=%@",_ridContinue]];
    }
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicPater = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        _arrayPaterData = dicPater[@"datas"];
        _scrollContentWidth = 0;
        for (NSDictionary *dicNum in _arrayPaterData) {
            NSArray *arrayDic = dicNum[@"Questions"];
            _scrollContentWidth = _scrollContentWidth + arrayDic.count;
        }
        _scrollViewPater.contentSize = CGSizeMake(_scrollContentWidth*Scr_Width, _scrollViewPater.bounds.size.height);
        
        //判断是否是继续做题，如果是，ridContinue有值,将用户做过的题的数量和已做过的试题存放起来
        if (_ridContinue.length > 0) {
            for (NSDictionary *dicAllTopic in _arrayPaterData) {
                NSArray *arrayTypeTopic = dicAllTopic[@"Questions"];
                for (NSDictionary *dicTopic in arrayTypeTopic) {
                    NSInteger qType = [dicTopic[@"qtype"] integerValue];
                    ///用于存放用于保存记录里面已经做过的试题
                    NSDictionary *dicUserAnswer = [[NSDictionary alloc]init];
                    ///不是一题多问的情况
                    if (qType != 6) {
                        if ([dicTopic objectForKey:@"userAnswer"]) {
                            //试题Id
                            NSString *questionId =[NSString stringWithFormat:@"%ld",[dicTopic[@"questionId"] integerValue]];
                            //试题类型
                            NSString *qtype =[NSString stringWithFormat:@"%ld",[dicTopic[@"qtype"] integerValue]];
                            //正确答案
                            NSString *answer = dicTopic[@"answer"];
                            //用户答案
                            NSString *userAnswer = dicTopic[@"userAnswer"];
                            //试题分值
                            NSInteger score = [dicTopic[@"score"] integerValue];
                            dicUserAnswer = @{@"QuestionID":questionId,@"QType":qtype,@"UserAnswer":userAnswer,@"TrueAnswer":answer,@"Score":[NSString stringWithFormat:@"%ld",score]};
                            [_arrayUserAnswer addObject:dicUserAnswer];
                            _intUserDidTopic = _intUserDidTopic +1;
                        }
                    }
                    ///一题多问的情况
                    else{
                        ///所有一题多问下面的小题
                        NSArray *arraySubQuestion = dicTopic[@"subQuestion"];
//                        NSInteger didTopicCountType6 = 0;
                        for (NSDictionary *dicSubQuestion in arraySubQuestion) {
                            if ([dicSubQuestion objectForKey:@"userAnswer"]) {
                                //试题Id
                                NSString *questionId =[NSString stringWithFormat:@"%ld",[dicSubQuestion[@"questionId"] integerValue]];
                                //试题类型
                                NSString *qtype =[NSString stringWithFormat:@"%ld",[dicSubQuestion[@"qtype"] integerValue]];
                                //正确答案
                                NSString *answer = dicSubQuestion[@"answer"];
                                //用户答案
                                NSString *userAnswer = dicSubQuestion[@"userAnswer"];
                                //试题分值
                                NSInteger score = [dicSubQuestion[@"score"] integerValue];
                                dicUserAnswer = @{@"QuestionID":questionId,@"QType":qtype,@"UserAnswer":userAnswer,@"TrueAnswer":answer,@"Score":[NSString stringWithFormat:@"%ld",score]};
                                [_arrayUserAnswer addObject:dicUserAnswer];
//                                if (didTopicCountType6 == 0) {
//                                    _intUserDidTopic = _intUserDidTopic + 1;
//                                }
//                                didTopicCountType6 = didTopicCountType6 + 1;
                            }
                        }
                    }
                }
            }
        }
        
        [self addChildViewWithTopicForSelf];
        [self addTimerForPater];
        _buttonRight.userInteractionEnabled = YES;
        //////////////////////////////////////////
        //实例化答题卡
        if (!_collectionViewTopicCard) {
            UICollectionViewFlowLayout *la =[[UICollectionViewFlowLayout alloc]init];
            _collectionViewTopicCard = [[TopicCardCollectionView alloc]initWithFrame:CGRectMake(Scr_Width, 64, Scr_Width,Scr_Height/2) collectionViewLayout:la withTopicArray:_arrayPaterData paperParameter:_paperParameter];
            _collectionViewTopicCard.delegateCellClick = self;
            [self.view addSubview:_collectionViewTopicCard];
        }
        /////////////////////////////////////////////////////////////
        [SVProgressHUD dismiss];
    } RequestFaile:^(NSError *error) {
        httpsErrorShow;
    }];
}
//倒计时时间时分秒设置
- (void)setTimeForTopic{
    NSInteger timeLong = [_dicPater[@"TimeLong"] integerValue];
    if (timeLong % 60 == 0) {
        _timeHo = timeLong/60;
        _timeMin = 0;
        _timeMin = 0;
    }
    else{
        _timeHo = timeLong/60;
        _timeMin = timeLong%60;
    }
    _timeSe = 0;
}
/**
 添加试卷剩余时间定时器
 */
- (void)addTimerForPater{
    _timeLong = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeClick:) userInfo:nil repeats:YES];
    ///开始定时器
    _timeLong.fireDate = [NSDate distantPast];
    _labSurplus.text = @"剩余时间";
}
/**
 时间倒计时
 */
- (void)timeClick:(NSTimer*)timer{
    //先判断秒为0
    if (_timeSe == 0) {
        //判断分钟是否同时为0
        if (_timeMin == 0) {
            
            //判断小时是否为0
            if (_timeHo == 0) {
                //倒计时结束
                _timeLong.fireDate = [NSDate distantFuture];
            }
            else{
                _timeSe = 59;
                _timeMin = 59;
                _timeHo = _timeHo - 1;
            }
        }
        else{
            _timeSe =59;
            _timeMin = _timeMin - 1;
        }
    }
    else{
        _timeSe = _timeSe - 1;
    }
    NSString *hTime;
    NSString *MinTime;
    NSString *seTIme;
    hTime = [NSString stringWithFormat:@"%ld",_timeHo];
    MinTime = [NSString stringWithFormat:@"%ld",_timeMin];
    seTIme = [NSString stringWithFormat:@"%ld",_timeSe];
    if (hTime.length == 1) {
        hTime = [NSString stringWithFormat:@"0%@",hTime];
    }
    if (MinTime.length == 1) {
        MinTime = [NSString stringWithFormat:@"0%@",MinTime];
    }
    if (seTIme.length == 1) {
        seTIme = [NSString stringWithFormat:@"0%@",seTIme];
    }
    _labTime.text = [NSString stringWithFormat:@"%@:%@:%@",hTime,MinTime,seTIme];
    ///如果时间倒计时走完，让其暂停（此时_labTime的显示值为：00:00:00）
    if (_timeHo == 0 && _timeMin == 0 && _timeSe == 0) {
        [SVProgressHUD showInfoWithStatus:@"预计答题时间已过，您可以继续做题并交卷"];
        //暂停定时器
        [timer setFireDate:[NSDate distantFuture]];
        ///释放定时器
        // [timer invalidate];
//        return;
    }

}

//传递题干信息，每一类试题的第一道题，传递题干信息
- (NSString *)topicTitle:(NSInteger)topicIndex{
    NSInteger countDicF = 0;
    NSInteger countDicL = 0;
    for (NSDictionary *dic in _arrayPaterData) {
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
    for (NSDictionary *dic in _arrayPaterData) {
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
/**
 模拟试题交卷
 */
- (void)submitSimulatePater{
    // api/Paper/SubmitPaper?access_token={access_token}?Id=?Title=?PostStr=
    //试卷id
    [SVProgressHUD show];
    NSString *paterId =[NSString stringWithFormat:@"%ld",[_dicPater[@"Id"] integerValue]];
    //试卷标题
    NSString *paterTitle = _dicPater[@"Names"];
    //讲用户答过的试题信息进行编码转json
    NSData *dataPostStr = [NSJSONSerialization dataWithJSONObject:_arrayUserAnswer options:NSJSONWritingPrettyPrinted error:nil];
    NSString *postStr = [[NSString alloc]initWithData:dataPostStr encoding:NSUTF8StringEncoding];
    //参数字典
    //????????????????????????????????????????????
    NSDictionary *dicPost = @{@"Id":paterId,@"Title":paterTitle,@"PostStr":postStr};
    NSString *urlString = [NSString stringWithFormat:@"%@api/Paper/SubmitPaper?access_token=%@",systemHttps,_accessToken];
    [HttpTools postHttpRequestURL:urlString RequestPram:dicPost RequestSuccess:^(id respoes) {
        NSDictionary *dic =(NSDictionary *)respoes;
        NSInteger codeId = [dic[@"code"] integerValue];
        if (codeId == 1) {
            NSDictionary *dicDatas = dic[@"datas"];
            if (_isUserLogin) {
                NSString *rId = dicDatas[@"rid"];
                [self performSegueWithIdentifier:@"topicAnalysis" sender:rId];
            }
            else{
                [SVProgressHUD dismiss];
                _rIdString = dicDatas[@"rid"];
                [self getSimulatePaperAnalysisReportInfoWithRid:dicDatas[@"rid"]];
            }
        }
        else{
            [SVProgressHUD showInfoWithStatus:@"提交失败"];
        }
    } RequestFaile:^(NSError *erro) {
        httpsErrorShow;
    }];
}

//****************************模拟试卷模块****************************//
//////////////////////////////模拟试卷模块//////////////////////////////
//******************************************************************//
//******************************************************************//
//////////////////////////////每周精选模块//////////////////////////////
//****************************每周精选模块****************************//
/**
 获取每周精选试卷试题
 */
- (void)getWeekPaperData{
    [SVProgressHUD showWithStatus:@"试卷加载中..."];
    //api/Weekly/GetWeeklyQuestions?access_token={access_token}&rid={rid}
    if (_ridContinue.length > 0) {
        _rIdString = _ridContinue;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@api/Weekly/GetWeeklyQuestions?access_token=%@&rid=%@",systemHttps,_accessToken,self.rIdString];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicWeekPaper = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dicWeekPaper[@"code"] integerValue];
        if (codeId == 1) {
            _arrayPaterData = dicWeekPaper[@"datas"];
            _scrollContentWidth = _arrayPaterData.count;
            _scrollViewPater.contentSize = CGSizeMake(_scrollContentWidth*Scr_Width, _scrollViewPater.bounds.size.height);
            
            //            //判断是否是继续做题，如果是，rid有值,将用户做过的题的数量和已做过的试题存放起来
            //            if (_ridContinue.length > 0) {
            //                for (NSDictionary *dicAllTopic in _arrayPaterData) {
            //                    NSArray *arrayTypeTopic = dicAllTopic[@"Questions"];
            //                    for (NSDictionary *dicTopic in arrayTypeTopic) {
            //                        NSInteger qType = [dicTopic[@"qtype"] integerValue];
            //                        ///用于存放用于保存记录里面已经做过的试题
            //                        NSDictionary *dicUserAnswer = [[NSDictionary alloc]init];
            //                        ///不是一题多问的情况
            //                        if (qType != 6) {
            //                            if ([dicTopic objectForKey:@"userAnswer"]) {
            //                                //试题Id
            //                                NSString *questionId =[NSString stringWithFormat:@"%ld",[dicTopic[@"questionId"] integerValue]];
            //                                //试题类型
            //                                NSString *qtype =[NSString stringWithFormat:@"%ld",[dicTopic[@"qtype"] integerValue]];
            //                                //正确答案
            //                                NSString *answer = dicTopic[@"answer"];
            //                                //用户答案
            //                                NSString *userAnswer = dicTopic[@"userAnswer"];
            //                                //试题分值
            //                                NSInteger score = [dicTopic[@"score"] integerValue];
            //                                dicUserAnswer = @{@"QuestionID":questionId,@"QType":qtype,@"UserAnswer":userAnswer,@"TrueAnswer":answer,@"Score":[NSString stringWithFormat:@"%ld",score]};
            //                                [_arrayUserAnswer addObject:dicUserAnswer];
            //                                _intUserDidTopic = _intUserDidTopic +1;
            //                            }
            //                        }
            //                        ///一题多问的情况
            //                        else{
            //                            ///所有一题多问下面的小题
            //                            NSArray *arraySubQuestion = dicTopic[@"subQuestion"];
            //                            NSInteger didTopicCountType6 = 0;
            //                            for (NSDictionary *dicSubQuestion in arraySubQuestion) {
            //                                if ([dicSubQuestion objectForKey:@"userAnswer"]) {
            //                                    //试题Id
            //                                    NSString *questionId =[NSString stringWithFormat:@"%ld",[dicSubQuestion[@"questionId"] integerValue]];
            //                                    //试题类型
            //                                    NSString *qtype =[NSString stringWithFormat:@"%ld",[dicSubQuestion[@"qtype"] integerValue]];
            //                                    //正确答案
            //                                    NSString *answer = dicSubQuestion[@"answer"];
            //                                    //用户答案
            //                                    NSString *userAnswer = dicSubQuestion[@"userAnswer"];
            //                                    //试题分值
            //                                    NSInteger score = [dicSubQuestion[@"score"] integerValue];
            //                                    dicUserAnswer = @{@"QuestionID":questionId,@"QType":qtype,@"UserAnswer":userAnswer,@"TrueAnswer":answer,@"Score":[NSString stringWithFormat:@"%ld",score]};
            //                                    [_arrayUserAnswer addObject:dicUserAnswer];
            //                                    if (didTopicCountType6 == 0) {
            //                                        _intUserDidTopic = _intUserDidTopic + 1;
            //                                    }
            //                                    didTopicCountType6 = didTopicCountType6 + 1;
            //                                }
            //                            }
            //                        }
            //                    }
            //                }
            //            }
            
            [self addChildViewWithTopicForSelf];
            for (id subView in _viewNaviHeardView.subviews) {
                [subView removeFromSuperview];
            }
            _buttonRight.userInteractionEnabled = YES;
            //////////////////////////////////////////
            //实例化答题卡
            if (!_collectionViewTopicCard) {
                UICollectionViewFlowLayout *la =[[UICollectionViewFlowLayout alloc]init];
                _collectionViewTopicCard = [[TopicCardCollectionView alloc]initWithFrame:CGRectMake(Scr_Width, 64, Scr_Width,Scr_Height/2) collectionViewLayout:la withTopicArray:_arrayPaterData paperParameter:_paperParameter];
                _collectionViewTopicCard.delegateCellClick = self;
                [self.view addSubview:_collectionViewTopicCard];
            }
            /////////////////////////////////////////////////////////////
            [SVProgressHUD dismiss];
        }
        else{
            
            [SVProgressHUD showInfoWithStatus:dicWeekPaper[@"errmsg"]];
        }
    } RequestFaile:^(NSError *error) {
        httpsErrorShow;
    }];
}
/**
 每周精选试卷提交
 */
- (void)submitWeekPater{
    //api/Weekly/Submit?access_token={access_token}
    NSString *urlString = [NSString stringWithFormat:@"%@api/Weekly/Submit?access_token=%@",systemHttps,_accessToken];
    //讲用户答过的试题信息进行编码转json
    NSData *dataPostStr = [NSJSONSerialization dataWithJSONObject:_arrayUserAnswer options:NSJSONWritingPrettyPrinted error:nil];
    NSString *postStr = [[NSString alloc]initWithData:dataPostStr encoding:NSUTF8StringEncoding];
    NSDictionary *dicPost = @{@"Rid":_rIdString,@"PostStr":postStr};
    [HttpTools postHttpRequestURL:urlString RequestPram:dicPost RequestSuccess:^(id respoes) {
        NSDictionary *dicWeekR = (NSDictionary *)respoes;
        NSInteger codeId = [dicWeekR[@"code"] integerValue];
        if (codeId == 1) {
            NSDictionary *dicDatas = dicWeekR[@"datas"];
            if (_isUserLogin) {
                NSString *rId = dicDatas[@"rid"];
                [self performSegueWithIdentifier:@"topicAnalysis" sender:rId];
            }
            else{
                _rIdString = dicDatas[@"rid"];
                [self getWeekPaperAnalysisReportInfoWithRid:dicDatas[@"rid"]];
            }
            
        }
    } RequestFaile:^(NSError *erro) {
        httpsErrorShow;
    }];
}
//****************************每周精选模块****************************//
//////////////////////////////每周精选模块//////////////////////////////

//////////////////////////////章节练习模块//////////////////////////////
//****************************章节练习模块****************************//

/**
 获取章节考点试卷试题
 */
- (void)getChaperPaperData{
    [SVProgressHUD showWithStatus:@"试卷加载中..."];
    //如果是继续做题，改变rid的值
    if (_ridContinue.length > 0) {
        _rIdString = _ridContinue;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@api/Chapter/GetChapterQuestions?access_token=%@&rid=%@",systemHttps,_accessToken,_rIdString];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicChaperPaper = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        if ([dicChaperPaper[@"code"] integerValue] == 1) {
            _arrayPaterData = dicChaperPaper[@"datas"];
            if (_arrayPaterData.count == 0) {
                [SVProgressHUD showInfoWithStatus:@"没有更多试题啦~"];
                return;
            }
            _scrollContentWidth = _arrayPaterData.count;
            _scrollViewPater.contentSize = CGSizeMake(_scrollContentWidth*Scr_Width, _scrollViewPater.bounds.size.height);
            //判断是否是继续做题，如果是，rid有值,将用户做过的题的数量和已做过的试题存放起来
            if (_ridContinue.length > 0) {
                for (NSDictionary *dicAllTopic in _arrayPaterData) {
                    NSInteger qType = [dicAllTopic[@"qtype"] integerValue];
                    ///用于存放用于保存记录里面已经做过的试题
                    NSDictionary *dicUserAnswer = [[NSDictionary alloc]init];
                    ///不是一题多问的情况
                    if (qType != 6) {
                        if ([dicAllTopic objectForKey:@"userAnswer"]) {
                            //试题Id
                            NSString *questionId =[NSString stringWithFormat:@"%ld",[dicAllTopic[@"questionId"] integerValue]];
                            //试题类型
                            NSString *qtype =[NSString stringWithFormat:@"%ld",[dicAllTopic[@"qtype"] integerValue]];
                            //正确答案
                            NSString *answer = dicAllTopic[@"answer"];
                            //用户答案
                            NSString *userAnswer = dicAllTopic[@"userAnswer"];
                            //试题分值
                            NSInteger score = [dicAllTopic[@"score"] integerValue];
                            dicUserAnswer = @{@"QuestionID":questionId,@"QType":qtype,@"UserAnswer":userAnswer,@"TrueAnswer":answer,@"Score":[NSString stringWithFormat:@"%ld",score]};
                            [_arrayUserAnswer addObject:dicUserAnswer];
                            _intUserDidTopic = _intUserDidTopic +1;
                        }
                    }
                    ///一题多问的情况
                    else{
                        ///所有一题多问下面的小题
                        NSArray *arraySubQuestion = dicAllTopic[@"subQuestion"];
//                        NSInteger didTopicCountType6 = 0;
                        for (NSDictionary *dicSubQuestion in arraySubQuestion) {
                            if ([dicSubQuestion objectForKey:@"userAnswer"]) {
                                //试题Id
                                NSString *questionId =[NSString stringWithFormat:@"%ld",[dicSubQuestion[@"questionId"] integerValue]];
                                //试题类型
                                NSString *qtype =[NSString stringWithFormat:@"%ld",[dicSubQuestion[@"qtype"] integerValue]];
                                //正确答案
                                NSString *answer = dicSubQuestion[@"answer"];
                                //用户答案
                                NSString *userAnswer = dicSubQuestion[@"userAnswer"];
                                //试题分值
                                NSInteger score = [dicSubQuestion[@"score"] integerValue];
                                dicUserAnswer = @{@"QuestionID":questionId,@"QType":qtype,@"UserAnswer":userAnswer,@"TrueAnswer":answer,@"Score":[NSString stringWithFormat:@"%ld",score]};
                                [_arrayUserAnswer addObject:dicUserAnswer];
//                                if (didTopicCountType6 == 0) {
//                                    _intUserDidTopic = _intUserDidTopic + 1;
//                                }
//                                didTopicCountType6 = didTopicCountType6 + 1;
                            }
                        }
                    }
                }
            }
            
            [self addChildViewWithTopicForSelf];
            for (id subView in _viewNaviHeardView.subviews) {
                [subView removeFromSuperview];
            }
            _buttonRight.userInteractionEnabled = YES;
            //////////////////////////////////////////
            //实例化答题卡
            if (!_collectionViewTopicCard) {
                UICollectionViewFlowLayout *la =[[UICollectionViewFlowLayout alloc]init];
                _collectionViewTopicCard = [[TopicCardCollectionView alloc]initWithFrame:CGRectMake(Scr_Width, 64, Scr_Width,Scr_Height/2) collectionViewLayout:la withTopicArray:_arrayPaterData paperParameter:_paperParameter];
                _collectionViewTopicCard.delegateCellClick = self;
                [self.view addSubview:_collectionViewTopicCard];
            }
            /////////////////////////////////////////////////////////////
            [SVProgressHUD dismiss];
            
        }
        else{
            [SVProgressHUD showInfoWithStatus:dicChaperPaper[@"errmsg"]];
        }
    } RequestFaile:^(NSError *error) {
        httpsErrorShow;
    }];
}
/**
 章节考点提交试卷
 */
- (void)submitChaperPaper{
//    [SVProgressHUD showWithStatus:@"正在提交..."];
    
    NSString *urlString = [NSString stringWithFormat:@"%@api/Chapter/Submit?access_token=%@",systemHttps,_accessToken];
    //讲用户答过的试题信息进行编码转json
    NSData *dataPostStr = [NSJSONSerialization dataWithJSONObject:_arrayUserAnswer options:NSJSONWritingPrettyPrinted error:nil];
    NSString *postStr = [[NSString alloc]initWithData:dataPostStr encoding:NSUTF8StringEncoding];
    NSDictionary *dicPost = @{@"rid":_rIdString,@"postStr":postStr};
    
    [HttpTools postHttpRequestURL:urlString RequestPram:dicPost RequestSuccess:^(id respoes) {
        NSDictionary *dicChaper =(NSDictionary *)respoes;
        if ([dicChaper[@"code"] integerValue] == 1 ) {
            NSDictionary *dicDatas = dicChaper[@"datas"];
            if (_isUserLogin) {
                [SVProgressHUD showSuccessWithStatus:dicDatas[@"msg"]];
                [self performSegueWithIdentifier:@"topicAnalysis" sender:dicDatas[@"rid"]];
            }
            else{
                _rIdString = dicDatas[@"rid"];
                if (self.paperParameter == 1) {
                    [self getChaperPaperAnalysisReportInfoWithRid:dicDatas[@"rid"]];
                }
                else if (self.paperParameter == 4){
                    [self getIntelligentPaperAnalysisReportInfoWithRid:dicDatas[@"rid"]];
                }

            }
        }
    } RequestFaile:^(NSError *erro) {
        httpsErrorShow;
    }];
    
}
//****************************章节练习模块****************************//
//////////////////////////////章节练习模块//////////////////////////////

//////////////////////////////智能做题模块//////////////////////////////
//****************************智能做题模块****************************//
///获取智能出题试题
- (void)getIntelligentPaperData{
    //如果是继续做题，改变rid的值
    if (_ridContinue.length > 0) {
        _rIdString = _ridContinue;
    }
    [SVProgressHUD showWithStatus:@"试卷加载中..."];
    NSString *urlString = [NSString stringWithFormat:@"%@api/Smart/GetSmartQuestions?access_token=%@&rid=%@",systemHttps,_accessToken,_rIdString];
    
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicIntelligent = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dicIntelligent[@"code"] integerValue];
        if (codeId == 1) {
            _arrayPaterData = dicIntelligent[@"datas"];
            _scrollContentWidth = _arrayPaterData.count;
            _scrollViewPater.contentSize = CGSizeMake(_scrollContentWidth*Scr_Width, _scrollViewPater.bounds.size.height);
            //判断是否是继续做题，如果是，rid有值,将用户做过的题的数量和已做过的试题存放起来
            if (_ridContinue.length > 0) {
                for (NSDictionary *dicAllTopic in _arrayPaterData) {
                    NSInteger qType = [dicAllTopic[@"qtype"] integerValue];
                    ///用于存放用于保存记录里面已经做过的试题
                    NSDictionary *dicUserAnswer = [[NSDictionary alloc]init];
                    ///不是一题多问的情况
                    if (qType != 6) {
                        if ([dicAllTopic objectForKey:@"userAnswer"]) {
                            //试题Id
                            NSString *questionId =[NSString stringWithFormat:@"%ld",[dicAllTopic[@"questionId"] integerValue]];
                            //试题类型
                            NSString *qtype =[NSString stringWithFormat:@"%ld",[dicAllTopic[@"qtype"] integerValue]];
                            //正确答案
                            NSString *answer = dicAllTopic[@"answer"];
                            //用户答案
                            NSString *userAnswer = dicAllTopic[@"userAnswer"];
                            //试题分值
                            NSInteger score = [dicAllTopic[@"score"] integerValue];
                            dicUserAnswer = @{@"QuestionID":questionId,@"QType":qtype,@"UserAnswer":userAnswer,@"TrueAnswer":answer,@"Score":[NSString stringWithFormat:@"%ld",score]};
                            [_arrayUserAnswer addObject:dicUserAnswer];
                            _intUserDidTopic = _intUserDidTopic +1;
                        }
                    }
                    ///一题多问的情况
                    else{
                        ///所有一题多问下面的小题
                        NSArray *arraySubQuestion = dicAllTopic[@"subQuestion"];
                        //                        NSInteger didTopicCountType6 = 0;
                        for (NSDictionary *dicSubQuestion in arraySubQuestion) {
                            if ([dicSubQuestion objectForKey:@"userAnswer"]) {
                                //试题Id
                                NSString *questionId =[NSString stringWithFormat:@"%ld",[dicSubQuestion[@"questionId"] integerValue]];
                                //试题类型
                                NSString *qtype =[NSString stringWithFormat:@"%ld",[dicSubQuestion[@"qtype"] integerValue]];
                                //正确答案
                                NSString *answer = dicSubQuestion[@"answer"];
                                //用户答案
                                NSString *userAnswer = dicSubQuestion[@"userAnswer"];
                                //试题分值
                                NSInteger score = [dicSubQuestion[@"score"] integerValue];
                                dicUserAnswer = @{@"QuestionID":questionId,@"QType":qtype,@"UserAnswer":userAnswer,@"TrueAnswer":answer,@"Score":[NSString stringWithFormat:@"%ld",score]};
                                [_arrayUserAnswer addObject:dicUserAnswer];
                                //                                if (didTopicCountType6 == 0) {
                                //                                    _intUserDidTopic = _intUserDidTopic + 1;
                                //                                }
                                //                                didTopicCountType6 = didTopicCountType6 + 1;
                            }
                        }
                    }
                }
            }
            

            [self addChildViewWithTopicForSelf];
            for (id subView in _viewNaviHeardView.subviews) {
                [subView removeFromSuperview];
            }
            _buttonRight.userInteractionEnabled = YES;
            //////////////////////////////////////////
            //实例化答题卡
            if (!_collectionViewTopicCard) {
                UICollectionViewFlowLayout *la =[[UICollectionViewFlowLayout alloc]init];
                _collectionViewTopicCard = [[TopicCardCollectionView alloc]initWithFrame:CGRectMake(Scr_Width, 64, Scr_Width,Scr_Height/2) collectionViewLayout:la withTopicArray:_arrayPaterData paperParameter:_paperParameter];
                _collectionViewTopicCard.delegateCellClick = self;
                [self.view addSubview:_collectionViewTopicCard];
            }
            /////////////////////////////////////////////////////////////
            [SVProgressHUD dismiss];
        }
        else{
            
            [SVProgressHUD showInfoWithStatus:dicIntelligent[@"errmsg"]];
        }
    } RequestFaile:^(NSError *error) {
        httpsErrorShow;
    }];

    
}
///智能出题交卷
- (void)submitIntelligentPaper{
    [self submitChaperPaper];
}
//****************************智能做题模块****************************//
//////////////////////////////智能做题模块//////////////////////////////

/**
 添加子试图，（每一个子试图相当于一道题）并依次在scrollView中显示出来
 */
- (void)addChildViewWithTopicForSelf{
    for (int i =0; i<_scrollContentWidth; i++) {
        PatersTopicViewController *chVc = [[PatersTopicViewController alloc]init];
        [self addChildViewController:chVc];
    }
    for (int i = 0; i<_scrollContentWidth; i++) {
        PatersTopicViewController *paterVc = self.childViewControllers[i];
        paterVc.delegateRefreshTiopicCard =self;
        paterVc.topicTitle = nil;
        if (_paperParameter == 2) {
            paterVc.dicTopic = [self getTopicDictionary:i];
            NSString *topString = [self topicTitle:i];
            if (topString != nil) {
                paterVc.topicTitle = topString;
            }
        }
        else if (_paperParameter == 3 | _paperParameter == 1 | _paperParameter ==4){
            paterVc.dicTopic = _arrayPaterData[i];
        }
        if (i == _scrollContentWidth - 1) {
            paterVc.isLastTopic = YES;
        }
        else{
            paterVc.isLastTopic = NO;
        }
        paterVc.topicIndex = i+1;
        paterVc.view.frame = CGRectMake(i*Scr_Width, 0, Scr_Width, self.view.frame.size.height - 64 - 45);
        [_scrollViewPater addSubview:paterVc.view];
    }
}
//打开答题卡
- (IBAction)topicCardClick:(UIButton *)sender {
    _isShowTopicCard = !_isShowTopicCard;
    if (_isShowTopicCard) {
        [self topicCardShow];
    }
    else{
        [self topicCardHiden];
    }
}
//上一题
- (IBAction)lastBtnClick:(UIButton *)sender {
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
- (IBAction)nextBtnClick:(UIButton *)sender {
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
//scrollView代理
//动画结束，控制不让‘上一题’，‘下一题’连续点击
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    _lastButton.userInteractionEnabled = YES;
    _nextButton.userInteractionEnabled =YES;
}

/**
 添加答题卡
 */
- (void)topicCardShow{
    [_buttonRight setTitle:@"隐藏答题卡" forState:UIControlStateNormal];
    //    [_collectionViewTopicCard setContentOffset:CGPointMake(0, 0) animated:YES];
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = _collectionViewTopicCard.frame;
        rect.origin.x = 0;
        _collectionViewTopicCard.frame = rect;
    }];
}
/**
 隐藏答题卡
 */
- (void)topicCardHiden{
    _isShowTopicCard = NO;
    [_buttonRight setTitle:@"答题卡" forState:UIControlStateNormal];
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = _collectionViewTopicCard.frame;
        rect.origin.x = Scr_Width;
        _collectionViewTopicCard.frame = rect;
    }];
}
//点击答题卡题号跳到对应试题
- (void)topicCollectonViewCellClick:(NSInteger)indexScroll{
    [_scrollViewPater setContentOffset:CGPointMake((indexScroll-1)*Scr_Width, 0) animated:YES];
    [self topicCardHiden];
}
/**
 刷新设置答题信息，用于显示做过的题和未做题的信息 并保存用户试题答案信息
 */
- (void)refreshTopicCard:(NSInteger)topicIndex selectDone:(NSDictionary *)dicUserAnswer isRefresh:(BOOL)isRefresh{
    NSString *indexString = [NSString stringWithFormat:@"%ld",topicIndex];
    //是否刷新答题卡，并自动跳到下一题
    if (isRefresh) {
        if (![_collectionViewTopicCard.arrayisMakeTopic containsObject:indexString]) {
            [_collectionViewTopicCard.arrayisMakeTopic addObject:indexString];
            _intUserDidTopic = _intUserDidTopic + 1;
        }
        if (_scrollViewPater.contentOffset.x < _scrollContentWidth*Scr_Width - Scr_Width) {
            _lastButton.userInteractionEnabled = NO;
            _nextButton.userInteractionEnabled =NO;
            [_scrollViewPater setContentOffset:CGPointMake(_scrollViewPater.contentOffset.x + Scr_Width, 0) animated:YES];
        }
    }
    [_collectionViewTopicCard reloadData];
    if (dicUserAnswer != nil) {
        NSString *QuestionID = dicUserAnswer[@"QuestionID"];
        for (NSDictionary *dicUaerAns in _arrayUserAnswer) {
            NSString *dicQuestionID = dicUaerAns[@"QuestionID"];
            if ([QuestionID isEqualToString:dicQuestionID]) {
                [_arrayUserAnswer removeObject:dicUaerAns];
                //防止数组被枚举出错
                break;
            }
        }
        [_arrayUserAnswer addObject:dicUserAnswer];
    }
    
    if (_intUserDidTopic == _scrollContentWidth) {
        LXAlertView *subAlert = [[LXAlertView alloc]initWithTitle:@"温馨提示" message:@"试卷所有试题已做完并保存，是否交卷？" cancelBtnTitle:@"继续做题" otherBtnTitle:@"交卷" clickIndexBlock:^(NSInteger clickIndex) {
            if (clickIndex == 1) {
              [self submitPaterAlert];
            }
        }];
        
        subAlert.animationStyle = LXASAnimationTopShake;
        [subAlert showLXAlertView];
    }
    
}
//保存进度按钮
- (IBAction)buttonSaveSchClick:(UIButton *)sender {
    if (!_isUserLogin) {
        [SVProgressHUD showInfoWithStatus:@"你还没有登录，不能保存进度哦"];
        return;
    }
    
    //aleat View 提示框
    LXAlertView *alertSaveSch;
    //未做题不能保存
    if (_intUserDidTopic == 0) {
        alertSaveSch = [[LXAlertView alloc]initWithTitle:@"温馨提示" message:@"您还没有做题，暂时没有进度保存哦" cancelBtnTitle:nil otherBtnTitle:@"确定" clickIndexBlock:nil];
        
    }
    //题未做完提示
    else {
        alertSaveSch = [[LXAlertView alloc]initWithTitle:@"温馨提示" message:@"进度保存后可以在我的练习记录查看记录，确定保存进度并退出做题吗" cancelBtnTitle:@"继续做题" otherBtnTitle:@"保存进度" clickIndexBlock:^(NSInteger clickIndex) {
            if (clickIndex == 1) {
                //保存进度
                [self saveUserDoTopicSchedule];
            }
        }];
    }
    alertSaveSch.animationStyle = LXASAnimationTopShake;
    [alertSaveSch showLXAlertView];
}

/**
 保存用户做题进度
 */
- (void)saveUserDoTopicSchedule{
    [SVProgressHUD showWithStatus:@"进度保存中..."];
    NSString *urlString;
    NSDictionary *dicPost = [[NSDictionary alloc]init];
    //模拟试卷单独接口
    if (_paperParameter == 2) {
        urlString = [NSString stringWithFormat:@"%@api/Paper/SaveAnswer?access_token=%@",systemHttps,_accessToken];
        NSString *paterId =[NSString stringWithFormat:@"%ld",[_dicPater[@"Id"] integerValue]];
        //试卷标题
        NSString *paterTitle = _dicPater[@"Names"];
        //讲用户答过的试题信息进行编码转json
        NSData *dataPostStr = [NSJSONSerialization dataWithJSONObject:_arrayUserAnswer options:NSJSONWritingPrettyPrinted error:nil];
        NSString *postStr = [[NSString alloc]initWithData:dataPostStr encoding:NSUTF8StringEncoding];
        //参数字典
        dicPost = @{@"Id":paterId,@"Title":paterTitle,@"PostStr":postStr};
    }
    //其他模块(暂时只有每周精选)
    else if(_paperParameter == 1){
        //api/Answer/SaveAnswer?access_token={access_token}
        urlString = [NSString stringWithFormat:@"%@api/Answer/SaveAnswer?access_token=%@",systemHttps,_accessToken];
        //讲用户答过的试题信息进行编码转json
        NSData *dataPostStr = [NSJSONSerialization dataWithJSONObject:_arrayUserAnswer options:NSJSONWritingPrettyPrinted error:nil];
        NSString *postStr = [[NSString alloc]initWithData:dataPostStr encoding:NSUTF8StringEncoding];
        dicPost = @{@"rid":_rIdString,@"postStr":postStr};
    }
    [HttpTools postHttpRequestURL:urlString RequestPram:dicPost RequestSuccess:^(id respoes) {
        NSDictionary *dicSchedule = (NSDictionary *)respoes;
        NSInteger codeId = [dicSchedule[@"code"] integerValue];
        if (codeId  == 1) {
            NSDictionary *dicDatas = dicSchedule[@"datas"];
            [SVProgressHUD showSuccessWithStatus:dicDatas[@"msg"]];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } RequestFaile:^(NSError *erro) {
        httpsErrorShow;
    }];
}
//////////////////////////////////
//交卷按钮
- (IBAction)subButtonClick:(UIButton *)sender {
    [self submitPaterAlert];
}
/**
 交卷提示
 */
- (void)submitPaterAlert{
    NSInteger topicCount = 0;
    if (_paperParameter == 2) {
        for (NSDictionary *dicTopicType in _arrayPaterData) {
            NSArray *array = dicTopicType[@"Questions"];
            topicCount = topicCount + array.count;
        }
    }
    else if (_paperParameter == 3 | _paperParameter == 1|_paperParameter == 4){
        topicCount = _arrayPaterData.count;
    }
    
    //aleat View 提示框
    LXAlertView *alertSubmit;
    //  未做题不能交卷
    if (_intUserDidTopic == 0) {
        alertSubmit = [[LXAlertView alloc]initWithTitle:@"温馨提示" message:@"您还没有做题，不能交卷哦" cancelBtnTitle:nil otherBtnTitle:@"确定" clickIndexBlock:nil];
        
    }
    //题未做完提示
    else if (topicCount != _intUserDidTopic) {
        NSInteger sTopic = topicCount - _intUserDidTopic;
        NSString *alertMessage = [NSString stringWithFormat:@"您还有【%ld】道题没有做，确认交卷吗?",sTopic];
        
        alertSubmit = [[LXAlertView alloc]initWithTitle:@"温馨提示" message:alertMessage cancelBtnTitle:@"交卷" otherBtnTitle:@"继续做题" clickIndexBlock:^(NSInteger clickIndex) {
            if (clickIndex == 0) {
                //模拟试卷提交
                if (_paperParameter == 1) {
                    [self submitChaperPaper];
                }
                else if (_paperParameter == 2) {
                    [self submitSimulatePater];
                }
                //每周精选试卷提交
                else if (_paperParameter == 3){
                    [self submitWeekPater];
                }
                //智能做题试卷提交
                else if (_paperParameter == 4){
                    [self submitIntelligentPaper];
                }
            }
        }];
    }
    //交卷提示
    else{
        alertSubmit = [[LXAlertView alloc]initWithTitle:@"温馨提示" message:@"确认提交试卷吗?" cancelBtnTitle:@"取消" otherBtnTitle:@"交卷" clickIndexBlock:^(NSInteger clickIndex) {
            if (clickIndex == 1) {
                //模拟试卷提交
                if (_paperParameter == 1) {
                    [self submitChaperPaper];
                }
                else if (_paperParameter == 2) {
                    [self submitSimulatePater];
                }
                //每周精选试卷提交
                else if (_paperParameter == 3){
                    [self submitWeekPater];
                }
                //智能做题试卷提交
                else if (_paperParameter == 4){
                    [self submitIntelligentPaper];
                }
            }
        }];
    }
    
    alertSubmit.animationStyle = LXASAnimationTopShake;
    [alertSubmit showLXAlertView];
}
/////////////////////试卷试题分析（公共）//////////////////////////////
/////////////////////试卷试题分析（公共）//////////////////////////////
///////////2016-05-13进度记录 /////试题分析报告

/////////////////////模拟试卷模块分析报告//////////////////////////////
/**
 获取模拟试卷模块分析报告
 */
- (void)getSimulatePaperAnalysisReportInfoWithRid:(NSString *)rid{
    NSString *urlString = [NSString stringWithFormat:@"%@api/Paper/LookReportInfo?access_token=%@&rid=%@",systemHttps,_accessToken,rid];
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
            
            [self addTopicAnalysisNoLoginForView];
        }
    } RequestFaile:^(NSError *erro) {
        httpsErrorShow;
    }];
}
/////////////////////模拟试卷模块分析报告//////////////////////////////
//05-25 0.5记录
/////////////////////每周精选模块分析报告//////////////////////////////
- (void)getWeekPaperAnalysisReportInfoWithRid:(NSString *)rid{
    NSString *urlString = [NSString stringWithFormat:@"%@api/Weekly/GetWeeklyReport?access_token=%@&rid=%@",systemHttps,_accessToken,rid];
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
            [self addTopicAnalysisNoLoginForView];
        }
    } RequestFaile:^(NSError *error) {
        httpsErrorShow;
    }];
    
}
/////////////////////每周精选模块分析报告//////////////////////////////

/////////////////////章节练习模块分析报告//////////////////////////////
/**
 章节练习分析报告
 */
- (void)getChaperPaperAnalysisReportInfoWithRid:(NSString *)rid{
    NSString *urlString = [NSString stringWithFormat:@"%@api/Chapter/GetReportInfo?access_token=%@&rid=%@",systemHttps,_accessToken,rid];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicAnalysis = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        if ([dicAnalysis[@"code"] integerValue] == 1) {
            NSDictionary *dicDatas = dicAnalysis[@"datas"];
            _intDoTopic = [dicDatas[@"DoneNum"] integerValue];
            _intRightTopic = [dicDatas[@"RightNum"] integerValue];
            _intWrongTopic = [dicDatas[@"ErrorNum"] integerValue];
            _intAccuracy = [dicDatas[@"Accuracy"] integerValue];
            _intScore = [dicDatas[@"Score"] integerValue];
            [self addTopicAnalysisNoLoginForView];
            
        }
    } RequestFaile:^(NSError *error) {
        httpsErrorShow;
    }];
}
/////////////////////章节练习模块分析报告//////////////////////////////

/////////////////////智能做题模块分析报告//////////////////////////////
/**
 获取智能做题分析报告
 */
- (void)getIntelligentPaperAnalysisReportInfoWithRid:(NSString *)rid{
    //    api/Smart/GetSmartReport?access_token={access_token}&rid={rid}
    NSString *urlString = [NSString stringWithFormat:@"%@api/Smart/GetSmartReport?access_token=%@&rid=%@",systemHttps,_accessToken,rid];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicAnalysis = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        if ([dicAnalysis[@"code"] integerValue] == 1) {
            NSDictionary *dicDatas = dicAnalysis[@"datas"];
            _intDoTopic = [dicDatas[@"DoneNum"] integerValue];
            _intRightTopic = [dicDatas[@"RightNum"] integerValue];
            _intWrongTopic = [dicDatas[@"ErrorNum"] integerValue];
            _intAccuracy = [dicDatas[@"Accuracy"] integerValue];
            _intScore = [dicDatas[@"Score"] integerValue];
            [self addTopicAnalysisNoLoginForView];
        }
        
    } RequestFaile:^(NSError *error) {
        httpsErrorShow;
    }];
}
/////////////////////智能做题模块分析报告//////////////////////////////
/**
 添加数据分析报告试图
 */
- (void)addTopicAnalysisNoLoginForView{
    _viewAnalysis = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Height)];
    _viewAnalysis.backgroundColor = ColorWithRGBWithAlpp(0, 0, 0, 0.6);
    UIView *viewAnalyParticulars = [[UIView alloc]initWithFrame:CGRectMake((Scr_Width-253)/2, Scr_Height, 253, 215)];
    viewAnalyParticulars.backgroundColor =[UIColor whiteColor];
    UILabel *labTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, viewAnalyParticulars.frame.size.width, 48)];
    labTitle.text = @"试卷分析";
    labTitle.textColor = [UIColor lightGrayColor];
    labTitle.font = [UIFont systemFontOfSize:18.0];
    labTitle.textAlignment = NSTextAlignmentCenter;
    [viewAnalyParticulars addSubview:labTitle];
    UIView *viewL1 = [[UIView alloc]initWithFrame:CGRectMake(0, labTitle.frame.origin.y+labTitle.frame.size.height, viewAnalyParticulars.frame.size.width, 2)];
    viewL1.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [viewAnalyParticulars addSubview:viewL1];
    ///总做题数
    UILabel *labDoNum = [[UILabel alloc]initWithFrame:CGRectMake(0, viewL1.frame.origin.y + 2 + 10, (viewAnalyParticulars.bounds.size.width)/2, 20)];
    labDoNum.text = @"总做题数：";
    labDoNum.textAlignment = NSTextAlignmentRight;
    labDoNum.font = [UIFont systemFontOfSize:16.0];
    [viewAnalyParticulars addSubview:labDoNum];
    
    UILabel *labDoNumText = [[UILabel alloc]initWithFrame:CGRectMake((viewAnalyParticulars.bounds.size.width)/2, viewL1.frame.origin.y + 2 + 10, (viewAnalyParticulars.bounds.size.width)/2, 20)];
    labDoNumText.adjustsFontSizeToFitWidth = YES;
    labDoNumText.text = [NSString stringWithFormat:@"【 %ld 】题",_intDoTopic];
    labDoNumText.textColor = [UIColor blueColor];
    labDoNum.font = [UIFont systemFontOfSize:16.0];
    [viewAnalyParticulars addSubview:labDoNumText];
    ///答对题数
    UILabel *labRightNum = [[UILabel alloc]initWithFrame:CGRectMake(0, labDoNum.frame.origin.y+20+5, (viewAnalyParticulars.bounds.size.width)/2, 20)];
    labRightNum.text = @"答对题数：";
    labRightNum.textAlignment = NSTextAlignmentRight;
    labRightNum.font = [UIFont systemFontOfSize:16.0];
    [viewAnalyParticulars addSubview:labRightNum];
    
    UILabel *labRightNumText = [[UILabel alloc]initWithFrame:CGRectMake((viewAnalyParticulars.bounds.size.width)/2, labDoNum.frame.origin.y+20+5, (viewAnalyParticulars.bounds.size.width)/2, 20)];
    labRightNumText.adjustsFontSizeToFitWidth = YES;
    labRightNumText.text = [NSString stringWithFormat:@"【 %ld 】题",_intRightTopic];
    labRightNumText.textColor = [UIColor blueColor];
    labRightNumText.font = [UIFont systemFontOfSize:16.0];
    [viewAnalyParticulars addSubview:labRightNumText];
    
    ///答错题数
    UILabel *labErrorNum = [[UILabel alloc]initWithFrame:CGRectMake(0, labRightNum.frame.origin.y+20+5, (viewAnalyParticulars.bounds.size.width)/2, 20)];
    labErrorNum.text = @"答错题数：";
    labErrorNum.textAlignment = NSTextAlignmentRight;
    labErrorNum.font = [UIFont systemFontOfSize:16.0];
    [viewAnalyParticulars addSubview:labErrorNum];
    
    UILabel *labErrorNumText = [[UILabel alloc]initWithFrame:CGRectMake((viewAnalyParticulars.bounds.size.width)/2, labRightNum.frame.origin.y+20+5, (viewAnalyParticulars.bounds.size.width)/2, 20)];
    labErrorNumText.adjustsFontSizeToFitWidth = YES;
    labErrorNumText.text = [NSString stringWithFormat:@"【 %ld 】题",_intWrongTopic];
    labErrorNumText.textColor = [UIColor blueColor];
    labErrorNumText.font = [UIFont systemFontOfSize:16.0];
    [viewAnalyParticulars addSubview:labErrorNumText];
    ///正确率
    UILabel *labAccuracy = [[UILabel alloc]initWithFrame:CGRectMake(0, labErrorNum.frame.origin.y+20+5, (viewAnalyParticulars.bounds.size.width)/2, 20)];
    labAccuracy.text = @"正确率：";
    labAccuracy.textAlignment = NSTextAlignmentRight;
    labAccuracy.font = [UIFont systemFontOfSize:16.0];
    [viewAnalyParticulars addSubview:labAccuracy];
    
    UILabel *labAccuracyText = [[UILabel alloc]initWithFrame:CGRectMake((viewAnalyParticulars.bounds.size.width)/2, labErrorNum.frame.origin.y+20+5, (viewAnalyParticulars.bounds.size.width)/2, 20)];
    labAccuracyText.text = [NSString stringWithFormat:@"  %ld %%",_intAccuracy];
    labAccuracyText.textColor = [UIColor orangeColor];
    labAccuracyText.font = [UIFont systemFontOfSize:20.0];
    [viewAnalyParticulars addSubview:labAccuracyText];
    ///第二条线
    UIView *view2 = [[UIView alloc]initWithFrame:CGRectMake(0, labAccuracy.frame.origin.y + 20 + 10, viewAnalyParticulars.frame.size.width, 2)];
    view2.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [viewAnalyParticulars addSubview:view2];
    ///退出按钮
    UIButton *btnOut = [UIButton buttonWithType:UIButtonTypeCustom];
    btnOut.frame = CGRectMake(15, view2.frame.origin.y+2 + 8, (viewAnalyParticulars.bounds.size.width)/2 - 20, 30);
    [btnOut setTitle:@"直接退出" forState:UIControlStateNormal];
    btnOut.titleLabel.font = [UIFont systemFontOfSize:15.0];
    btnOut.layer.masksToBounds = YES;
    btnOut.layer.cornerRadius = 3;
    btnOut.backgroundColor = [UIColor lightGrayColor];
    btnOut.tag = 1000;
    [btnOut addTarget:self action:@selector(btnAnalysisClick:) forControlEvents:UIControlEventTouchUpInside];
    [viewAnalyParticulars addSubview:btnOut];
    
    ///再做一次按钮
    UIButton *btnAgain = [UIButton buttonWithType:UIButtonTypeCustom];
    btnAgain.frame = CGRectMake((viewAnalyParticulars.bounds.size.width)/2 + 5, view2.frame.origin.y+2 + 8, (viewAnalyParticulars.bounds.size.width)/2 - 20, 30);
    [btnAgain setTitle:@"再做一次" forState:UIControlStateNormal];
    btnAgain.titleLabel.font = [UIFont systemFontOfSize:15.0];
    btnAgain.backgroundColor = [UIColor orangeColor];
    btnAgain.layer.masksToBounds = YES;
    btnAgain.layer.cornerRadius = 3;
    btnAgain.tag = 1001;
    [btnAgain addTarget:self action:@selector(btnAnalysisClick:) forControlEvents:UIControlEventTouchUpInside];
    [viewAnalyParticulars addSubview:btnAgain];
    ////设置弹出试图样式
    viewAnalyParticulars.layer.masksToBounds = YES;
    viewAnalyParticulars.layer.cornerRadius = 5;
    [_viewAnalysis addSubview:viewAnalyParticulars];
    [self.navigationController.tabBarController.view addSubview:_viewAnalysis];
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = viewAnalyParticulars.frame;
        rect.origin.y = (Scr_Height - viewAnalyParticulars.bounds.size.height)/2;
        viewAnalyParticulars.frame = rect;
    }];
}
///未登录做题提交试卷，点击弹出选择按钮
- (void)btnAnalysisClick:(UIButton *)button{
    [_viewAnalysis removeFromSuperview];
    ///直接退出
    if (button.tag == 1000) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    ///再做一次
    else{
        [self againDoTopicRidClear];
    }
}
////向下滑动隐藏试题分析
//- (void)viewAnalysisHiden:(UISwipeGestureRecognizer *)swipe{
//    [self hidenViewAnalysis];
//}
//
////隐藏试卷解析报告试图
//- (void)buttonHidenViewAnalysisClick:(UIButton *)sender{
//    [self hidenViewAnalysis];
//}
///**
// 隐藏数据分析报告试图
// */
//- (void)hidenViewAnalysis{
//    [UIView animateWithDuration:0.2 animations:^{
//        CGRect rectAna =_viewAnalysis.frame;
//        rectAna.origin.y = Scr_Height;
//        _viewAnalysis.frame = rectAna;
//    }];
//}

//************************再次做题（再做一次）/////////////////////////
///再做一次时重置当前的记录(点击重新做题的一次时间)
- (void)againDoTopicRidClear{
    //api/Chapter/ResetRecord?access_token={access_token}&rid={rid}
    NSString *urlString = [NSString stringWithFormat:@"%@api/Chapter/ResetRecord?access_token=%@&rid=%@",systemHttps,_accessToken,_rIdString];
    [HttpTools postHttpRequestURL:urlString RequestPram:nil RequestSuccess:^(id respoes) {
        NSDictionary *diccc = (NSDictionary *)respoes;
        NSInteger codeId = [diccc[@"code"] integerValue];
        if (codeId == 1) {
            NSDictionary *dicDatas = diccc[@"datas"];
            NSString *ridString = dicDatas[@"rid"];
            _rIdString = ridString;
            [self clearChildViewControl];
            if (self.paperParameter == 1) {
                ///章节练习
                [self getChaperPaperData];
            }
            else if (self.paperParameter == 2){
                ///模拟试卷
                [_timeLong invalidate];
                [self setTimeForTopic];
                [self getPaterDatas];
            }
            else if (self.paperParameter == 3){
                ///每周精选
                [self getWeekPaperData];
            }
            else if (self.paperParameter == 4){
                ///智能做题
                [self getIntelligentPaperData];
            }
            
            [self.scrollViewPater setContentOffset:CGPointMake(0, 0) animated:YES];
        }
    } RequestFaile:^(NSError *erro) {
        httpsErrorShow;
    }];
}
///清除self.view的所有的子试图并清除scrollView上的子试图
- (void)clearChildViewControl{
    _intUserDidTopic = 0;
    [_collectionViewTopicCard.arrayisMakeTopic removeAllObjects];
    _collectionViewTopicCard.intHour = 0;
    _collectionViewTopicCard.intMinutes = 0;
    _collectionViewTopicCard.intSecond = 0;
    [_collectionViewTopicCard reloadData];
    for (UIViewController *Vc in self.childViewControllers) {
        [Vc removeFromParentViewController];
    }
    
    for (id subView in _scrollViewPater.subviews) {
        [subView removeFromSuperview];
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    StartAnalysisTopicViewController *analysisVc = segue.destinationViewController;
    analysisVc.PaperId = [_dicPater[@"Id"] integerValue];
    analysisVc.paperAnalysisParameter = _paperParameter;
    analysisVc.isFromTiKu = YES;
    analysisVc.rId = sender;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
