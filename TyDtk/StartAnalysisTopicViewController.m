//
//  StartAnalysisTopicViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/5/6.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "StartAnalysisTopicViewController.h"
#import "PaperTopicAnalysisViewController.h"
#import "NotesDataViewController.h"
@interface StartAnalysisTopicViewController ()<TopicAnalysisCardDelegate,persentNotesDelegate>
//所有展示试题的容器
//@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewPater;
@property (weak, nonatomic) IBOutlet UIButton *buttonRight;

@property (nonatomic,strong) UIScrollView *scrollViewPater;
@property (weak, nonatomic) IBOutlet UIButton *lastButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (nonatomic,strong) NSUserDefaults *tyUser;
@property (nonatomic,strong) TopicAnalysisCardView *cardView;
@property (nonatomic,assign) BOOL isShowTopicCard;
//令牌
@property (nonatomic,strong) NSString *accessToken;
//试卷所有试题数组
@property (nonatomic,strong) NSArray *arrayPaterAnalysisData;
//scrollview 的宽度，单位是以屏宽的个数去计算(所有试题的个数)
@property (nonatomic,assign) NSInteger scrollContentWidth;
@end

@implementation StartAnalysisTopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"试卷解析";
    _scrollViewPater = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, Scr_Width, Scr_Height - 45 - 64)];
    _scrollViewPater.pagingEnabled = YES;
    [self.view addSubview:_scrollViewPater];
     _tyUser = [NSUserDefaults standardUserDefaults];
    _buttonRight.userInteractionEnabled = NO;
    [_buttonRight setTitle:@"试卷答题卡" forState:UIControlStateNormal];
    [self getTopicAnalysisPaper];
}
- (void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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
/**
 获取试卷分析
 */
- (void)getTopicAnalysisPaper{
    [SVProgressHUD showWithStatus:@"正在获取试题分析..."];
    _accessToken = [_tyUser objectForKey:tyUserAccessToken];
    NSString *urlString = [NSString stringWithFormat:@"%@api/Resolve/IOSGetPaperResolveQuestions/%ld?access_token=%@&rid=%@",systemHttps,_PaperId,_accessToken,_rId];
    [HttpTools postHttpRequestURL:urlString RequestPram:nil RequestSuccess:^(id respoes) {
        NSDictionary *dicAnalysis = (NSDictionary *)respoes;
        _arrayPaterAnalysisData = dicAnalysis[@"datas"];
        _scrollContentWidth = 0;
        for (NSDictionary *dicNum in _arrayPaterAnalysisData) {
            NSArray *arrayDic = dicNum[@"Questions"];
            _scrollContentWidth = _scrollContentWidth + arrayDic.count;
        }
        //设置scrollView的容量
        _scrollViewPater.contentSize = CGSizeMake(_scrollContentWidth*Scr_Width, _scrollViewPater.bounds.size.height);
        
        [self addChildViewWithTopicForSelf];
        _buttonRight.userInteractionEnabled = YES;
        [self addAnalysisTpoicCard];
        [SVProgressHUD dismiss];
        
        NSLog(@"%@",dicAnalysis);
    } RequestFaile:^(NSError *erro) {
        
    }];
}
//隐藏或显示答题卡
- (IBAction)buttonRightClick:(UIButton *)sender {
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
        _cardView = [[TopicAnalysisCardView alloc]initWithFrame:CGRectMake(Scr_Width, 64, Scr_Width,Scr_Height/2) arrayTopic:_arrayPaterAnalysisData];
        _cardView.delegateCellClick = self;
        [self.view addSubview:_cardView];
    }
}
/**
 显示答题卡
 */
- (void)topicCardShow{
    [_buttonRight setTitle:@"隐藏答题卡" forState:UIControlStateNormal];
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
    [_buttonRight setTitle:@"试卷答题卡" forState:UIControlStateNormal];
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
        paterVc.dicTopic = [self getTopicDictionary:i];
        paterVc.topicIndex = i+1;
        paterVc.delegatePersent = self;
        NSString *topString = [self topicTitle:i];
        paterVc.topicTitle = nil;
        if (topString != nil) {
            paterVc.topicTitle = topString;
        }
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
    [self performSegueWithIdentifier:@"notesdata" sender:questionId];
}
//跳转到笔记界面
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NotesDataViewController *notesVc = segue.destinationViewController;
    notesVc.questionId = sender;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
