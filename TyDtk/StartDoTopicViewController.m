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
//scrollview 的宽度，单位是以屏宽的个数去计算
@property (nonatomic,assign) NSInteger scrollContentWidth;
//答题卡
@property (nonatomic,strong) TopicCardCollectionView *collectionViewTopicCard;
@property (nonatomic,assign) BOOL isShowTopicCard;
@property (nonatomic,strong) NSTimer *timeLong;
@property (nonatomic,assign) NSInteger timeHo;
@property (nonatomic,assign) NSInteger timeMin;
@property (nonatomic,assign) NSInteger timeSe;
@end

@implementation StartDoTopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _arrayUserAnswer = [NSMutableArray array];
    _tyUser = [NSUserDefaults standardUserDefaults];
    _accessToken = [_tyUser objectForKey:tyUserAccessToken];
    _buttonRight.userInteractionEnabled = NO;
    [_buttonRight setTitle:@"答题卡" forState:UIControlStateNormal];
    [_buttonSubPater setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    _buttonSubPater.layer.masksToBounds = YES;
    _buttonSubPater.layer.cornerRadius = 3;
    [_buttonSaveSch setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    _buttonSaveSch.layer.masksToBounds = YES;
    _buttonSaveSch.layer.cornerRadius = 3;
    [self setTimeForTopic];
    //章节练习
    if (self.paperParameter == 1) {
        
    }
    //模拟试卷
    else if (self.paperParameter == 2){
         [self getPaterDatas];
    }
    //每周精选
    else if (self.paperParameter == 3){
         self.navigationItem.titleView = nil;
        self.title = @"每周精选";
        [_buttonSubPater setTitle:@"结束答题" forState:UIControlStateNormal];
        [self getWeekPaperData];
    }
    //智能出题
    else if (self.paperParameter == 4){
        
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
    _timeLong = nil;
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
//////////////////////////////模拟试卷模块//////////////////////////////
/**
 获取试卷试题
 */
- (void)getPaterDatas{
    [SVProgressHUD showWithStatus:@"试卷加载中..."];
    NSInteger paterId = [_dicPater[@"Id"] integerValue];
   NSString *urlString = [NSString stringWithFormat:@"%@api/Paper/GetPaperQuestions/%ld?access_token=%@",systemHttps,paterId,_accessToken];
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
        [SVProgressHUD dismiss];
    }];
}
//倒计时时间事件
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
    if (!_timeLong) {
        _timeLong = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeClick:) userInfo:nil repeats:YES];
    }
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
    NSDictionary *dicPost = @{@"Id":paterId,@"Title":paterTitle,@"PostStr":postStr};
    NSString *urlString = [NSString stringWithFormat:@"%@api/Paper/SubmitPaper?access_token=%@",systemHttps,_accessToken];
    [HttpTools postHttpRequestURL:urlString RequestPram:dicPost RequestSuccess:^(id respoes) {
        NSDictionary *dic =(NSDictionary *)respoes;
        NSInteger codeId = [dic[@"code"] integerValue];
        if (codeId == 1) {
            NSDictionary *dicDatas = dic[@"datas"];
            NSString *rId = dicDatas[@"rid"];
            [self performSegueWithIdentifier:@"topicAnalysis" sender:rId];
        }
        else{
            [SVProgressHUD showInfoWithStatus:@"提交失败"];
        }
    } RequestFaile:^(NSError *erro) {
        
    }];
}

//////////////////////////////模拟试卷模块//////////////////////////////
//////////////////////////////模拟试卷模块//////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////每周精选模块//////////////////////////////
//////////////////////////////每周精选模块//////////////////////////////
/**
 获取每周精选试卷试题
 */
- (void)getWeekPaperData{
    [SVProgressHUD showWithStatus:@"试卷加载中..."];
    //api/Weekly/GetWeeklyQuestions?access_token={access_token}&rid={rid}
    NSString *urlString = [NSString stringWithFormat:@"%@api/Weekly/GetWeeklyQuestions?access_token=%@&rid=%@",systemHttps,_accessToken,self.rIdString];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicWeekPaper = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dicWeekPaper[@"code"] integerValue];
        if (codeId == 1) {
            _arrayPaterData = dicWeekPaper[@"datas"];
            _scrollContentWidth = _arrayPaterData.count;
            _scrollViewPater.contentSize = CGSizeMake(_scrollContentWidth*Scr_Width, _scrollViewPater.bounds.size.height);
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
        [SVProgressHUD showInfoWithStatus:@"请求异常"];
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
            NSString *rId = dicDatas[@"rid"];
            [self performSegueWithIdentifier:@"topicAnalysis" sender:rId];
        }
    } RequestFaile:^(NSError *erro) {
        [SVProgressHUD showInfoWithStatus:@"操作异常!"];
    }];
}
//////////////////////////////每周精选模块//////////////////////////////
//////////////////////////////每周精选模块//////////////////////////////
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
        else if (_paperParameter == 3){
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
//pop
- (IBAction)popButtonClick:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
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

}
//保存进度按钮
- (IBAction)buttonSaveSchClick:(UIButton *)sender {
//    NSInteger topicCount = 0;
//    if (_paperParameter == 2) {
//        for (NSDictionary *dicTopicType in _arrayPaterData) {
//            NSArray *array = dicTopicType[@"Questions"];
//            topicCount = topicCount + array.count;
//        }
//    }
//    else if (_paperParameter == 3){
//        topicCount = _arrayPaterData.count;
//    }
    
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
    else if(_paperParameter == 3){
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
        [SVProgressHUD showInfoWithStatus:@"操作异常！"];
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
    else if (_paperParameter == 3){
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
                if (_paperParameter == 2) {
                    [self submitSimulatePater];
                }
                //每周精选试卷提交
                else if (_paperParameter == 3){
                    [self submitWeekPater];
                }
                
            }
        }];
    }
    //交卷提示
    else{
        alertSubmit = [[LXAlertView alloc]initWithTitle:@"温馨提示" message:@"确认提交试卷吗?" cancelBtnTitle:@"取消" otherBtnTitle:@"交卷" clickIndexBlock:^(NSInteger clickIndex) {
            if (clickIndex == 1) {
                //模拟试卷提交
                if (_paperParameter == 2) {
                    [self submitSimulatePater];
                }
                //每周精选试卷提交
                else if (_paperParameter == 3){
                    [self submitWeekPater];
                }

            }
        }];
    }
    
    alertSubmit.animationStyle = LXASAnimationTopShake;
    [alertSubmit showLXAlertView];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    StartAnalysisTopicViewController *analysisVc = segue.destinationViewController;
    analysisVc.PaperId = [_dicPater[@"Id"] integerValue];
    analysisVc.paperAnalysisParameter = _paperParameter;
    analysisVc.rId = sender;
}
//- (void)paterAnalysis:(NSString *)rId{
//    //api/Resolve/GetPaperResolveQuestions/{id}?access_token={access_token}&rid={rid}
//    NSInteger paterId = [_dicPater[@"Id"] integerValue];
//    NSString *urlString = [NSString stringWithFormat:@"%@api/Resolve/GetPaperResolveQuestions/%ld?access_token=%@&rid=%@",systemHttps,paterId,_accessToken,rId];
//    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
//        NSDictionary *dicAnalysis = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
//        NSLog(@"%@",dicAnalysis);
//    } RequestFaile:^(NSError *error) {
//        
//    }];
//}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
