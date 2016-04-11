//
//  StartDoTopicViewController.m
//  TyDtk
//
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
//本地信息存储
@property (nonatomic,strong) NSUserDefaults *tyUser;
//令牌
@property (nonatomic,strong) NSString *accessToken;
//试卷信息数组
@property (nonatomic,strong) NSArray *arrayPaterData;
//scrollview 的宽度，单位是以屏宽的个数去计算
@property (nonatomic,assign) NSInteger scrollContentWidth;
@end

@implementation StartDoTopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tyUser = [NSUserDefaults standardUserDefaults];
    _accessToken = [_tyUser objectForKey:tyUserAccessToken];
    // Do any additional setup after loading the view.
    [self getPaterDatas];
}
- (IBAction)tewtwew:(UIBarButtonItem *)sender {
    NSLog(@"datas");
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
 获取试卷试题
 */
- (void)getPaterDatas{
     NSString *urlString = [NSString stringWithFormat:@"%@api/Paper/GetPaperQuestions/%ld?access_token=%@",systemHttps,_paterId,_accessToken];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicPater = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        _arrayPaterData = dicPater[@"datas"];
        NSLog(@"%ld == %@",_paterId,_accessToken);
        _scrollContentWidth = 0;
        for (NSDictionary *dicNum in _arrayPaterData) {
            NSArray *arrayDic = dicNum[@"Questions"];
            _scrollContentWidth = _scrollContentWidth + arrayDic.count;
        }
        _scrollViewPater.contentSize = CGSizeMake(_scrollContentWidth*Scr_Width, _scrollViewPater.bounds.size.height);
        [self testScrollView];
        
        [self addChildViewWithTopicForSelf];
        
        
    } RequestFaile:^(NSError *error) {
        
    }];
}
- (void)testScrollView{
    for (int i = 0; i<_scrollContentWidth; i++) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(Scr_Width*i, 0, Scr_Width, Scr_Height - 50)];
        view.backgroundColor = colorSuiJi;
        [_scrollViewPater addSubview:view];
    }
}
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
