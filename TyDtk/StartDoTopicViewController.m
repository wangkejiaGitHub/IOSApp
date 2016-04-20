//
//  StartDoTopicViewController.m
//  TyDtk
//  用户展示所有试题界面，把所有试题都加载在scrollView上进行展示
//  Created by 天一文化 on 16/4/11.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//
#import "StartDoTopicViewController.h"
#import "PatersTopicViewController.h"
@interface StartDoTopicViewController ()<UIScrollViewDelegate,TopicCardDelegate,TopicCardRefreshDelegate>
//所有展示试题的容器
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewPater;
@property (weak, nonatomic) IBOutlet UIButton *buttonRight;

@property (weak, nonatomic) IBOutlet UIButton *lastButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *labTime;
@property (weak, nonatomic) IBOutlet UILabel *labSurplus;
/**
 用户储存用户每道试题的答案
 */
@property (nonatomic,strong) NSMutableArray *arrayUserAnswer;
//本地信息存储
@property (nonatomic,strong) NSUserDefaults *tyUser;
//令牌
@property (nonatomic,strong) NSString *accessToken;
//试卷信息数组
@property (nonatomic,strong) NSArray *arrayPaterData;
//scrollview 的宽度，单位是以屏宽的个数去计算
@property (nonatomic,assign) NSInteger scrollContentWidth;
@property (weak, nonatomic) IBOutlet UIButton *buttonSubPater;

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
    [_buttonRight setTitle:@"试卷答题卡" forState:UIControlStateNormal];
    // Do any additional setup after loading the view.
    _buttonSubPater.layer.masksToBounds = YES;
    _buttonSubPater.layer.cornerRadius = 3;
    [self setTimeForTopic];
    [self getPaterDatas];
}

- (void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardShow:(NSNotification *)note{
    NSDictionary *userInfo = [note userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    //键盘高度
    CGFloat keyBoardHeight = keyboardRect.size.height;
    CGRect rect = self.view.frame;
    if (keyBoardHeight!=0) {
        rect.origin.y = rect.origin.y - keyBoardHeight+45;
    }
    
    self.navigationController.view.frame = rect;
    
}
/////////////
////键盘监听//
////键盘消失//
- (void)keyboardHide:(NSNotification *)note{
    CGRect rect = self.view.frame;
    self.navigationController.view.frame = rect;
}

/**
 获取模拟试卷试题
 */
- (void)getPaterDatas{
    [SVProgressHUD showWithStatus:@"试卷加载中..."];
    NSInteger paterId = [_dicPater[@"Id"] integerValue];
    NSString *urlString = [NSString stringWithFormat:@"%@api/Paper/IOSGetPaperQuestions/%ld?access_token=%@",systemHttps,paterId,_accessToken];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicPater = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        _arrayPaterData = dicPater[@"datas"];
        //        /////////////////////////////////////////////////////////////////////////////
        //        //在每一道题中，加一个是否已经做过该题的key（isMake:0(未做),1(做过)），用于刷新答题卡信息
        //        NSMutableArray *arrayNewPaterData = [NSMutableArray array];
        //        for (NSDictionary *dic in _arrayPaterData) {
        //            //去除每一个字典中的第一个key,待存贮
        //            NSDictionary *dicCaption = dic[@"Caption"];
        //            NSArray *arrayQuestions = dic[@"Questions"];
        //            //新的Questions数组
        //            NSMutableArray *arrayNewDic = [NSMutableArray array];
        //            for (NSDictionary *dicTopic in arrayQuestions) {
        //                NSMutableDictionary *dicNewTopic = [NSMutableDictionary dictionaryWithDictionary:dicTopic];
        //                [dicNewTopic setValue:@"0" forKey:@"isMake"];
        //                [arrayNewDic addObject:dicNewTopic];
        //            }
        //            NSDictionary *diccc = @{@"Caption":dicCaption,@"Questions":arrayNewDic};
        //            [arrayNewPaterData addObject:diccc];
        //        }
        //        _arrayPaterData = arrayNewPaterData;
        //        //修改原数据添加新key：isMake完成
        //        ///////////////////////////////////////
        NSLog(@"%ld == %@",paterId,_accessToken);
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
        //        实例化答题卡
        if (!_collectionViewTopicCard) {
            UICollectionViewFlowLayout *la =[[UICollectionViewFlowLayout alloc]init];
            _collectionViewTopicCard = [[TopicCardCollectionView alloc]initWithFrame:CGRectMake(Scr_Width, 64, Scr_Width,Scr_Height/2) collectionViewLayout:la withTopicArray:_arrayPaterData];
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
- (void)viewDidDisappear:(BOOL)animated{
    _timeLong = nil;
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
                NSLog(@"倒计时结束");
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
    [self topicCardHiden];
}
//下一题
- (IBAction)nextBtnClick:(UIButton *)sender {
    if (_scrollViewPater.contentOffset.x < _scrollContentWidth*Scr_Width - Scr_Width) {
        _lastButton.userInteractionEnabled = NO;
        _nextButton.userInteractionEnabled =NO;
        [_scrollViewPater setContentOffset:CGPointMake(_scrollViewPater.contentOffset.x + Scr_Width, 0) animated:YES];
    }
    [self topicCardHiden];
}
//添加子试图，（每一个子试图相当于一道题）并依次在scrollView中显示出来
- (void)addChildViewWithTopicForSelf{
    for (int i =0; i<_scrollContentWidth; i++) {
        UIViewController *chVc = [self.storyboard instantiateViewControllerWithIdentifier:@"PatersTopicViewController"];
        [self addChildViewController:chVc];
    }
    for (int i = 0; i<_scrollContentWidth; i++) {
        PatersTopicViewController *paterVc = self.childViewControllers[i];
        paterVc.delegateRefreshTiopicCard =self;
        paterVc.dicTopic = [self getTopicDictionary:i];
        paterVc.topicIndex = i+1;
        paterVc.view.frame = CGRectMake(i*Scr_Width, 0, Scr_Width, self.view.frame.size.height - 64 - 45);
        NSString *topString = [self topicTitle:i];
        paterVc.topicTitle = nil;
        if (topString != nil) {
            paterVc.topicTitle = topString;
        }
        [_scrollViewPater addSubview:paterVc.view];
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
    [_collectionViewTopicCard setContentOffset:CGPointMake(0, 0) animated:YES];
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
    [_buttonRight setTitle:@"试卷答题卡" forState:UIControlStateNormal];
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
////刷新设置答题信息，用于显示做过的题和未做题的信息 并保存用户试题答案信息
- (void)refreshTopicCard:(NSInteger)topicIndex selectDone:(NSDictionary *)dicUserAnswer{
    NSString *indexString = [NSString stringWithFormat:@"%ld",topicIndex];
    if (![_collectionViewTopicCard.arrayisMakeTopic containsObject:indexString]) {
        [_collectionViewTopicCard.arrayisMakeTopic addObject:indexString];
    }
    
    if (_scrollViewPater.contentOffset.x < _scrollContentWidth*Scr_Width - Scr_Width) {
        _lastButton.userInteractionEnabled = NO;
        _nextButton.userInteractionEnabled =NO;
        [_scrollViewPater setContentOffset:CGPointMake(_scrollViewPater.contentOffset.x + Scr_Width, 0) animated:YES];
    }
    
    [_collectionViewTopicCard reloadData];
    
    NSLog(@"%@",dicUserAnswer);
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
    
    NSLog(@"%@",_arrayUserAnswer);
}
//////////////////////////////////
//////////////////////////////////
///？？？？？？？交卷测试？？？？？？
//交卷按钮
- (IBAction)subButtonClick:(UIButton *)sender {
    [self submitPaterAlert];
}
/**
 交卷提示
 */
- (void)submitPaterAlert{
    NSInteger topicCount = 0;
    for (NSDictionary *dicTopicType in _arrayPaterData) {
        NSArray *array = dicTopicType[@"Questions"];
        topicCount = topicCount + array.count;
    }
    //aleat View 提示框
    UIAlertController *alertSubmit;
    //题未做完提示
    if (topicCount != _arrayUserAnswer.count) {
        NSInteger sTopic = topicCount - _arrayUserAnswer.count;
        NSString *alertMessage = [NSString stringWithFormat:@"您还有%ld道题没有做，确认交卷吗?",sTopic];
        NSLog(@"%ld",sTopic);
        
        alertSubmit = [UIAlertController alertControllerWithTitle:@"温馨提示" message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
        //交卷
        UIAlertAction *acSubmit = [UIAlertAction actionWithTitle:@"交卷" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"%@",_dicPater);
            [self submitPater];
        }];
        [alertSubmit addAction:acSubmit];
        //继续做题(不错任何操作)
        UIAlertAction *acContinue = [UIAlertAction actionWithTitle:@"继续做题" style:UIAlertActionStyleDestructive handler:nil];
        [alertSubmit addAction:acContinue];
        
        [self presentViewController:alertSubmit animated:YES completion:nil];
    }
    //交卷提示
    else{
        alertSubmit = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"确认交卷吗?" preferredStyle:UIAlertControllerStyleAlert];
        //交卷
        UIAlertAction *acSubmit = [UIAlertAction actionWithTitle:@"交卷" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertSubmit addAction:acSubmit];
        //取消(不做任何操作)
        UIAlertAction *acCen = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertSubmit addAction:acCen];
        
        [self presentViewController:alertSubmit animated:YES completion:nil];
    }
}
/**
 交卷
 */
- (void)submitPater{
    [SVProgressHUD showWithStatus:@"正在提交..."];
    // api/Paper/SubmitPaper?access_token={access_token}?Id=?Title=?PostStr=
    //试卷id
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
            [SVProgressHUD showSuccessWithStatus:dicDatas[@"msg"]];
            NSString *rId = dicDatas[@"rid"];
        }
        else{
            [SVProgressHUD showInfoWithStatus:@"提交失败"];
        }
        NSLog(@"%@",dic);
    } RequestFaile:^(NSError *erro) {
        NSLog(@"%@",erro);
    }];
    
    NSLog(@"%@ == %@",postStr,_accessToken);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     
 }

@end
