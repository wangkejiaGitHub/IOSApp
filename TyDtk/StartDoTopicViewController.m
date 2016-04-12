//
//  StartDoTopicViewController.m
//  TyDtk
//  用户展示所有试题界面，把所有试题都加载在scrollView上进行展示
//  Created by 天一文化 on 16/4/11.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "StartDoTopicViewController.h"
#import "PatersTopicViewController.h"
@interface StartDoTopicViewController ()<UIScrollViewDelegate>
//所有展示试题的容器
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewPater;
@property (weak, nonatomic) IBOutlet UIButton *lastButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *labTime;

//本地信息存储
@property (nonatomic,strong) NSUserDefaults *tyUser;
//令牌
@property (nonatomic,strong) NSString *accessToken;
//试卷信息数组
@property (nonatomic,strong) NSArray *arrayPaterData;
//scrollview 的宽度，单位是以屏宽的个数去计算
@property (nonatomic,assign) NSInteger scrollContentWidth;

@property (nonatomic,strong) NSTimer *timeLong;
@property (nonatomic,assign) NSInteger timeHo;
@property (nonatomic,assign) NSInteger timeMin;
@property (nonatomic,assign) NSInteger timeSe;
@end

@implementation StartDoTopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tyUser = [NSUserDefaults standardUserDefaults];
    _accessToken = [_tyUser objectForKey:tyUserAccessToken];
    // Do any additional setup after loading the view.
    [self setTimeForTopic];
    [self getPaterDatas];
}
- (void)setTimeForTopic{
    NSInteger timeLong = [_dicPater[@"TimeLong"] integerValue];
    if (timeLong % 60 == 0) {
        _timeHo = timeLong/60;
        _timeMin = 0;
        _timeMin = 0;
    }
    else{
        NSLog(@"%ld",timeLong/60);
        NSLog(@"%ld",timeLong%60);
        _timeHo = timeLong/60;
        _timeMin = timeLong%60;
    }
    _timeSe = 0;
    NSLog(@"%ld",timeLong);
//    _timeHo = 5;
//    _timeMin = 5;
//    _timeSe = 0;
}
- (void)viewDidAppear:(BOOL)animated{
    if (!_timeLong) {
        _timeLong = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeClick:) userInfo:nil repeats:YES];
    }
    _timeLong.fireDate = [NSDate distantPast];
}
- (void)viewDidDisappear:(BOOL)animated{
    _timeLong = nil;
    NSLog(@"fadsffasfsadfaf");
}
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
//答题卡
- (IBAction)topicCardClick:(UIBarButtonItem *)sender {
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
}
//下一题
- (IBAction)nextBtnClick:(UIButton *)sender {
    if (_scrollViewPater.contentOffset.x < _scrollContentWidth*Scr_Width - Scr_Width) {
        _lastButton.userInteractionEnabled = NO;
        _nextButton.userInteractionEnabled =NO;
         [_scrollViewPater setContentOffset:CGPointMake(_scrollViewPater.contentOffset.x + Scr_Width, 0) animated:YES];
    }
}
/**
 获取模拟试卷试题
 */
- (void)getPaterDatas{
    [SVProgressHUD showWithStatus:@"试卷加载中..."];
    NSInteger paterId = [_dicPater[@"Id"] integerValue];
     NSString *urlString = [NSString stringWithFormat:@"%@api/Paper/GetPaperQuestions/%ld?access_token=%@",systemHttps,paterId,_accessToken];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicPater = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        _arrayPaterData = dicPater[@"datas"];
        NSLog(@"%ld == %@",paterId,_accessToken);
        _scrollContentWidth = 0;
        for (NSDictionary *dicNum in _arrayPaterData) {
            NSArray *arrayDic = dicNum[@"Questions"];
            _scrollContentWidth = _scrollContentWidth + arrayDic.count;
        }
        _scrollViewPater.contentSize = CGSizeMake(_scrollContentWidth*Scr_Width, _scrollViewPater.bounds.size.height);
        [self testScrollView];
        
        [self addChildViewWithTopicForSelf];
        [SVProgressHUD dismiss];
    } RequestFaile:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}
- (void)testScrollView{
    for (int i = 0; i<_scrollContentWidth; i++) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(Scr_Width*i, 0, Scr_Width, Scr_Height - 50)];
        view.backgroundColor = colorSuiJi;
        [_scrollViewPater addSubview:view];
    }
}
//添加子试图，（每一个子试图相当于一道题）并依次在scrollView中显示出来
- (void)addChildViewWithTopicForSelf{
    for (int i =0; i<_scrollContentWidth; i++) {
        UIViewController *chVc = [self.storyboard instantiateViewControllerWithIdentifier:@"PatersTopicViewController"];
        [self addChildViewController:chVc];
    }
    for (int i = 0; i<_scrollContentWidth; i++) {
        PatersTopicViewController *paterVc = self.childViewControllers[i];
        paterVc.dicTopic = [self getTopicDictionary:i];
        paterVc.topicIndex = i+1;
        paterVc.view.frame = CGRectMake(i*Scr_Width, 0, Scr_Width, Scr_Height);
        [_scrollViewPater addSubview:paterVc.view];
    }
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
