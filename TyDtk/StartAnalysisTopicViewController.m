//
//  StartAnalysisTopicViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/5/6.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "StartAnalysisTopicViewController.h"
#import "PaperTopicAnalysisViewController.h"
@interface StartAnalysisTopicViewController ()
//所有展示试题的容器
//@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewPater;
@property (nonatomic,strong) UIScrollView *scrollViewPater;
@property (weak, nonatomic) IBOutlet UIButton *lastButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (nonatomic,strong) NSUserDefaults *tyUser;
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
    _scrollViewPater = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, Scr_Width, Scr_Height - 45 - 64)];
    _scrollViewPater.backgroundColor = [UIColor redColor];
    _scrollViewPater.pagingEnabled = YES;
    [self.view addSubview:_scrollViewPater];
     _tyUser = [NSUserDefaults standardUserDefaults];
    [self getTopicAnalysisPaper];
}
- (void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)viewDidDisappear:(BOOL)animated{
    NSLog(@"fsf");
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
    _accessToken = [_tyUser objectForKey:tyUserAccessToken];
    NSString *urlString = [NSString stringWithFormat:@"%@api/Resolve/GetPaperResolveQuestions/%ld?access_token=%@&rid=%@",systemHttps,_PaperId,_accessToken,_rId];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicAnalysis = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        _arrayPaterAnalysisData = dicAnalysis[@"datas"];
        _scrollContentWidth = 0;
        for (NSDictionary *dicNum in _arrayPaterAnalysisData) {
            NSArray *arrayDic = dicNum[@"Questions"];
            _scrollContentWidth = _scrollContentWidth + arrayDic.count;
        }
        //设置scrollView的容量
        _scrollViewPater.contentSize = CGSizeMake(_scrollContentWidth*Scr_Width, _scrollViewPater.bounds.size.height);
        
        [self addChildViewWithTopicForSelf];
        
        NSLog(@"%@",dicAnalysis);
    } RequestFaile:^(NSError *error) {
        
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
        NSString *topString = [self topicTitle:i];
        paterVc.topicTitle = nil;
        if (topString != nil) {
            paterVc.topicTitle = topString;
        }
        paterVc.view.frame = CGRectMake(i*Scr_Width, 0, Scr_Width, Scr_Height - 45 - 64);
        paterVc.view.backgroundColor = colorSuiJi;
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
