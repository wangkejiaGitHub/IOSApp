//
//  AnalysisErrorTopicViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/7/27.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "AnalysisErrorTopicViewController.h"
#import "TopicNumberCard.h"
#import "PaperLookViewController.h"
@interface AnalysisErrorTopicViewController ()<UIScrollViewDelegate,NumberCardDelegate>
@property (nonatomic,strong) UIScrollView *scrollViewPater;
@property (weak, nonatomic) IBOutlet UIButton *lastButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
//@property (weak, nonatomic) IBOutlet UIButton *buttonTopNum;

@property (nonatomic,strong) NSUserDefaults *tyUser;
//scrollview 的宽度，单位是以屏宽的个数去计算(所有试题的个数)
@property (nonatomic,assign) NSInteger scrollContentWidth;
//令牌
@property (nonatomic,strong) NSString *accessToken;
//需要查看的错误试题
@property (nonatomic,strong) NSMutableArray *arrayTopicLook;
///显示题号索引题卡
@property (nonatomic,strong) TopicNumberCard *topicNumberCard;
@property (nonatomic,strong) UIBarButtonItem *buttonItemR;
@property (nonatomic,assign) BOOL isShowCard;
@end

@implementation AnalysisErrorTopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我的错题";
//    self.view.backgroundColor = colorSuiJi;
    _tyUser = [NSUserDefaults standardUserDefaults];
    _accessToken = [_tyUser objectForKey:tyUserAccessToken];
    _buttonItemR = [[UIBarButtonItem alloc]initWithTitle:@"答题卡" style:UIBarButtonItemStylePlain target:self action:@selector(buttonItemClick:)];
    self.navigationItem.rightBarButtonItem = _buttonItemR;
    [self viewLoad];
}
- (void)viewLoad{
//    _buttonTopNum.userInteractionEnabled = NO;
//    _buttonTopNum.layer.masksToBounds = YES;
//    _buttonTopNum.layer.cornerRadius = 3;
//    _buttonTopNum.layer.borderWidth = 1;
//    _buttonTopNum.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _arrayTopicLook = [NSMutableArray array];
    self.navigationController.tabBarController.tabBar.hidden = YES;

    ////???????????????????
    
    _scrollViewPater = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, Scr_Width, Scr_Height - 44 - 64)];
    _scrollViewPater.delegate = self;
    _scrollViewPater.pagingEnabled = YES;
    _scrollViewPater.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_scrollViewPater];
    _tyUser = [NSUserDefaults standardUserDefaults];
    _accessToken = [_tyUser objectForKey:tyUserAccessToken];
    [_scrollViewPater setContentSize:CGSizeMake(Scr_Width * _arrayTopicLook.count, Scr_Height - 64 - 44)];
    
    [self getErrorTopicAnalysis];
}
///答题卡
- (void)buttonItemClick:(UIBarButtonItem *)item{
    _isShowCard = !_isShowCard;
    if (_isShowCard) {
        item.title = @"隐藏答题卡";
        [self showTopicNumberCard];

    }
    else{
        item.title = @"答题卡";
        [self hidenTopicNumberCard];
    }
}
///获取所有错误试题
- (void)getErrorTopicAnalysis{
    /// api/Error/GetUserErrorQuestionsByRidArray?access_token={access_token}&rid={rid}
    [SVProgressHUD showWithStatus:@"正在加载试题..."];
    NSString *urlString = [NSString stringWithFormat:@"%@api/Error/GetUserErrorQuestionsByRidArray?access_token=%@&rid=%@",systemHttps,_accessToken,_ridError];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicError = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        if ([dicError[@"code"] integerValue] == 1) {
            _arrayTopicLook = dicError[@"datas"];
            _scrollContentWidth = _arrayTopicLook.count;
            [_scrollViewPater setContentSize:CGSizeMake(_arrayTopicLook.count * Scr_Width, Scr_Height - 64 - 44)];
            [self addChildTopicView];
            [self addTopicNumberCardForTopic];
            [SVProgressHUD dismiss];
        }
        else{
            [SVProgressHUD showInfoWithStatus:dicError[@"errmsg"]];
        }
    } RequestFaile:^(NSError *error) {
        httpsErrorShow;
    }];
}

///添加试题模板
- (void)addChildTopicView{
    for (int i = 0; i< _scrollContentWidth; i++) {
        PaperLookViewController *paterVc = [[PaperLookViewController alloc]init];
        [self addChildViewController:paterVc];
    }
    
    for (int i = 0; i < _scrollContentWidth; i ++) {
        PaperLookViewController *paVc = self.childViewControllers[i];
        paVc.dicTopic = _arrayTopicLook[i];
        paVc.topicIndex = i + 1;
        paVc.view.backgroundColor =[UIColor whiteColor];
        paVc.view.frame = CGRectMake(Scr_Width * i, 0, Scr_Width, Scr_Height - 64 - 44);
        [_scrollViewPater addSubview:paVc.view];
    }
}
//////////////////////////////////////////////////////////////////
- (IBAction)buttonTopicCardClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [sender setTitle:@"隐藏" forState:UIControlStateNormal];
        [self showTopicNumberCard];
    }
    else{
        [sender setTitle:@"试题编号" forState:UIControlStateNormal];
        [self hidenTopicNumberCard];
    }
}
- (IBAction)buttonLastClick:(UIButton *)sender {
    if (_scrollViewPater.contentOffset.x>=Scr_Width) {
        _lastButton.userInteractionEnabled = NO;
        _nextButton.userInteractionEnabled =NO;
        [_scrollViewPater setContentOffset:CGPointMake(_scrollViewPater.contentOffset.x - Scr_Width, 0) animated:YES];
    }
    else{
        [SVProgressHUD showInfoWithStatus:@"前面没有试题了~"];
    }
    
}

- (IBAction)buttonNextClick:(UIButton *)sender {
    if (_scrollViewPater.contentOffset.x < _scrollContentWidth*Scr_Width - Scr_Width) {
        _lastButton.userInteractionEnabled = NO;
        _nextButton.userInteractionEnabled =NO;
        [_scrollViewPater setContentOffset:CGPointMake(_scrollViewPater.contentOffset.x + Scr_Width, 0) animated:YES];
    }
    else{
        [SVProgressHUD showInfoWithStatus:@"已经到最后一题了~"];
    }
}
///添加试题编号
- (void)addTopicNumberCardForTopic{
    if (!_topicNumberCard) {
        _topicNumberCard = [[TopicNumberCard alloc]initWithFrame:CGRectMake(Scr_Width, 64, Scr_Width, [self getTopicNumberCardHeight:_arrayTopicLook.count]) withTopicNumber:_arrayTopicLook.count];
        _topicNumberCard.delegateNumberTop = self;
//        _buttonTopNum.userInteractionEnabled = YES;
        [self.view addSubview:_topicNumberCard];
    }
    _topicNumberCard.topicNumber = _arrayTopicLook.count;
    [_topicNumberCard.collectionViewCard reloadData];
}
///获取答题卡试图高度 topicNumber：试题数量
- (CGFloat)getTopicNumberCardHeight:(NSInteger)topicNumber{
    ///先计算题号的行数
    ///每个item的高 (Scr_Width-20-5*10)/6
    NSInteger itemRows;
    CGFloat cardHeight;
    if (topicNumber%6 == 0) {
        itemRows = topicNumber/6;
    }
    else{
        itemRows = topicNumber/6 + 1;
    }
    if (itemRows <= 5) {
        cardHeight = 20 + itemRows*((Scr_Width-20-5*10)/6) + (itemRows - 1)*10;
    }
    else{
        cardHeight = 20 + 5*((Scr_Width-20-5*10)/6) + (5-1)*10;
    }
    return cardHeight;
}

///显示题卡
- (void)showTopicNumberCard{
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = _topicNumberCard.frame;
        rect.origin.x = 0;
        _topicNumberCard.frame = rect;
    }];
}

///隐藏题卡
- (void)hidenTopicNumberCard{
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = _topicNumberCard.frame;
        rect.origin.x = Scr_Width;
        _topicNumberCard.frame = rect;
    }];
}
///点击编号回调
- (void)getTopicNumber:(NSInteger)topicNumber{
    [_scrollViewPater setContentOffset:CGPointMake(_scrollViewPater.frame.size.width * topicNumber, 0) animated:YES];
//    _buttonTopNum.selected = NO;
//    [_buttonTopNum setTitle:@"试题编号" forState:UIControlStateNormal];
    _buttonItemR.title = @"";
    _isShowCard = NO;
    _buttonItemR.title = @"答题卡";
    [self hidenTopicNumberCard];
}
//scrollView代理
//动画结束，控制不让‘上一题’，‘下一题’连续点击
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    _lastButton.userInteractionEnabled = YES;
    _nextButton.userInteractionEnabled =YES;
}

//完成拖拽（放手）
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    ///向左拖拽pop返回上一页
    if (scrollView.contentOffset.x < -20) {
        [self.navigationController popViewControllerAnimated:YES];
    }
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
