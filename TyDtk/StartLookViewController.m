//
//  StartLookViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/6/17.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "StartLookViewController.h"
#import "PaperLookViewController.h"
@interface StartLookViewController ()<UIScrollViewDelegate>
@property (nonatomic,strong) UIScrollView *scrollViewPater;
@property (weak, nonatomic) IBOutlet UIButton *lastButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (nonatomic,strong) NSUserDefaults *tyUser;
//scrollview 的宽度，单位是以屏宽的个数去计算(所有试题的个数)
@property (nonatomic,assign) NSInteger scrollContentWidth;
//令牌
@property (nonatomic,strong) NSString *accessToken;
@property (nonatomic,strong) NSMutableArray *arrayTopicLook;
@end

@implementation StartLookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self viewLoad];
}
- (void)viewLoad{
    _arrayTopicLook = [NSMutableArray array];
    self.navigationController.tabBarController.tabBar.hidden = YES;
    _scrollViewPater = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, Scr_Width, Scr_Height - 44 - 64)];
    _scrollViewPater.delegate = self;
    _scrollViewPater.pagingEnabled = YES;
    [self.view addSubview:_scrollViewPater];
    _tyUser = [NSUserDefaults standardUserDefaults];
    _accessToken = [_tyUser objectForKey:tyUserAccessToken];
    [_scrollViewPater setContentSize:CGSizeMake(Scr_Width * _arrayTopicLook.count, Scr_Height - 64 - 44)];
//    
//    for (int i = 0; i<5; i++) {
//        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(Scr_Width*i, 0, Scr_Width, Scr_Height - 64 - 44)];
//        view.backgroundColor = colorSuiJi;
//        [_scrollViewPater addSubview:view];
//    }
    //收藏的试题
    if (_parameterView == 1) {
        self.title = @"我的收藏";
        [self getCollectTopicWithChaperId:_chaperId];
    }
    //错题
    else if (self.parameterView == 2){
        self.title = @"我的错题";
        [self getErrorTopicWithChaperId:_chaperId];
    }
    //添加过笔记试题
    else if (self.parameterView == 3){
        self.title = @"笔记试题";
        [self getNoteTopicWithChaperId:_chaperId];
    }
//    [self addChildViewLookTopic];
}

///按照章节考点id获取收藏试题列表
- (void)getCollectTopicWithChaperId:(NSInteger)chaperId{
    [SVProgressHUD showWithStatus:@"试题加载中..."];
    NSString *urlString = [NSString stringWithFormat:@"%@api/Collection/GetCollectionQuestions?access_token=%@&chapterId=%ld&page=1&size=20",systemHttps,_accessToken,chaperId];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicCollect = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        if ([dicCollect[@"code"]integerValue] == 1) {
            NSArray *arrayCollectTopic = dicCollect[@"datas"];
            _arrayTopicLook = [NSMutableArray arrayWithArray:arrayCollectTopic];
            [self addChildViewLookTopic];
        }
        [SVProgressHUD dismiss];
        NSLog(@"%@",dicCollect);
    } RequestFaile:^(NSError *error) {
        [SVProgressHUD showInfoWithStatus:@"网络异常！"];
    }];
}
///按照章节考点id获取错题列表
- (void)getErrorTopicWithChaperId:(NSInteger)chaperId{
    [SVProgressHUD showWithStatus:@"试题加载中..."];
    NSString *urlString = [NSString stringWithFormat:@"%@api/Error/GetErrorQuestions?access_token=%@&chapterId=%ld&page=1&size=20",systemHttps,_accessToken,chaperId];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicError = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        if ([dicError[@"code"] integerValue] == 1) {
            NSArray *arrayError = dicError[@"datas"];
            _arrayTopicLook = [NSMutableArray arrayWithArray:arrayError];
            [self addChildViewLookTopic];
        }
        [SVProgressHUD dismiss];
        NSLog(@"%@",dicError);
    } RequestFaile:^(NSError *error) {
        [SVProgressHUD showInfoWithStatus:@"网络异常！"];
    }];
}
///按照章节考点id获取笔记试题列表
- (void)getNoteTopicWithChaperId:(NSInteger)chaperId{
    [SVProgressHUD showWithStatus:@"试题加载中..."];
    NSString *urlString = [NSString stringWithFormat:@"%@api/Note/GetNoteQuestions?access_token=%@&chapterid=%ld&page=1&size=20",systemHttps,_accessToken,chaperId];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicNote = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        if ([dicNote[@"code"]integerValue] == 1) {
            NSArray *arrayNoteTopic= dicNote[@"datas"];
            _arrayTopicLook = [NSMutableArray arrayWithArray:arrayNoteTopic];
             [self addChildViewLookTopic];
        }
        [SVProgressHUD dismiss];
        NSLog(@"%@",dicNote);
    } RequestFaile:^(NSError *error) {
        [SVProgressHUD showInfoWithStatus:@"网络异常！"];
    }];
}
- (void)addChildViewLookTopic{
     [_scrollViewPater setContentSize:CGSizeMake(Scr_Width * _arrayTopicLook.count, Scr_Height - 64-44)];
    _scrollContentWidth = _arrayTopicLook.count;
    for (int i = 0; i<_arrayTopicLook.count; i++) {
        PaperLookViewController *paterVc = [[PaperLookViewController alloc]init];
        [self addChildViewController:paterVc];
    }
    
    for (int i = 0; i<_arrayTopicLook.count; i++) {
        PaperLookViewController *paVC = self.childViewControllers[i];
        paVC.dicTopic = _arrayTopicLook[i];
        paVC.topicIndex = i + 1;
        paVC.view.backgroundColor = [UIColor whiteColor];
        paVC.view.frame = CGRectMake(Scr_Width * i, 0, Scr_Width, Scr_Height - 64 - 44);
        [_scrollViewPater addSubview:paVC.view];
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
