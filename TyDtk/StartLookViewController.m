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
//需要查看的所有试题（收藏试题、错误试题、笔记试题模块通用）
@property (nonatomic,strong) NSMutableArray *arrayTopicLook;
////////////数据分页参数//////////////
///当前页
@property (nonatomic,assign) NSInteger pageCurr;
///总页数
@property (nonatomic,assign) NSInteger pageCount;
///每页个数
@property (nonatomic,assign) NSInteger pageSize;
////////scrollview使用的参数/////////////
@property (nonatomic,strong) UIView *viewScrollRightView;
@property (nonatomic,strong) UILabel *labTest;
@property (nonatomic,strong) UIView *viewLine;
/**
最新请求的试题数（同一个大题下面的小题归属一道大题:qtype=6）
用户设置scrollView的容量和偏移量
*/
@property (nonatomic,assign) NSInteger newTopicCount;
//@property (nonatomic,assign) BOOL isFirstRequest;
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
    ////添加scrollView分页提示显示view
    _viewScrollRightView = [[UIView alloc]initWithFrame:CGRectMake(Scr_Width - 60 - 15, 64+50, 60, (Scr_Height - 64 - 45 - 100))];
    _viewScrollRightView.backgroundColor = [UIColor clearColor];
    _viewLine =[[UIView alloc]initWithFrame:CGRectMake(30+(30-1)/2, 0, 1, _viewScrollRightView.bounds.size.height)];
    _viewLine.backgroundColor = [UIColor clearColor];
    [_viewScrollRightView addSubview:_viewLine];
    _labTest = [[UILabel alloc]initWithFrame:CGRectMake(30, (_viewScrollRightView.bounds.size.height - 233)/2, 30, 233)];
    _labTest.font = [UIFont systemFontOfSize:18.0];
    _labTest.textColor = [UIColor clearColor];
    _labTest.backgroundColor = [UIColor whiteColor];
    _labTest.textAlignment = NSTextAlignmentCenter;
    _labTest.numberOfLines = 0;
    _labTest.text = @"向左滑动加载更多试题";
    [_viewScrollRightView addSubview:_labTest];
    [self.view addSubview:_viewScrollRightView];
    
    ////???????????????????
    
    _scrollViewPater = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, Scr_Width, Scr_Height - 44 - 64)];
    _scrollViewPater.delegate = self;
    _scrollViewPater.pagingEnabled = YES;
    _scrollViewPater.backgroundColor = [UIColor clearColor];
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
    _pageSize = 20;
    _pageCurr = 1;
    _pageCount = 0;
    
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
//    //添加过笔记试题
//    else if (self.parameterView == 3){
//        self.title = @"笔记试题";
////        [self getNoteTopicWithChaperId:_chaperId];
//    }
//    [self addChildViewLookTopic];
}
///按照章节考点id获取收藏试题列表
- (void)getCollectTopicWithChaperId:(NSInteger)chaperId{
//    [selfpageRequest];
    [SVProgressHUD showWithStatus:@"试题加载中..."];
    NSString *urlString = [NSString stringWithFormat:@"%@api/Collection/GetCollectionQuestions?access_token=%@&chapterId=%ld&page=%ld&size=%ld",systemHttps,_accessToken,chaperId,_pageCurr,_pageSize];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicCollect = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        if ([dicCollect[@"code"]integerValue] == 1) {
            NSArray *arrayCollectTopic = dicCollect[@"datas"];
            //重置最新请求到的试题数量
            _newTopicCount = arrayCollectTopic.count;
            //追加方式添加试题
            for (NSDictionary *dicc in arrayCollectTopic) {
                [_arrayTopicLook addObject:dicc];
            }
            //获取最大页数
            NSDictionary *pageDatas = dicCollect[@"page"];
            _pageCount = [pageDatas[@"pages"] integerValue];
            [self addChildViewLookTopic];
        }
        [SVProgressHUD dismiss];
    } RequestFaile:^(NSError *error) {
        [SVProgressHUD showInfoWithStatus:@"网络异常！"];
    }];
}
///按照章节考点id获取错题列表
- (void)getErrorTopicWithChaperId:(NSInteger)chaperId{
    [SVProgressHUD showWithStatus:@"试题加载中..."];
    NSString *urlString = [NSString stringWithFormat:@"%@api/Error/GetErrorQuestions?access_token=%@&chapterId=%ld&page=%ld&size=%ld",systemHttps,_accessToken,chaperId,_pageCurr,_pageSize];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicError = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        if ([dicError[@"code"] integerValue] == 1) {
            NSArray *arrayError = dicError[@"datas"];
            //重置最新请求到的试题数量
            _newTopicCount = arrayError.count;
            //追加方式添加试题
            for (NSDictionary *diccc in arrayError) {
                [_arrayTopicLook addObject:diccc];
            }
            //获取最大页数
            NSDictionary *pageDatas = dicError[@"page"];
            _pageCount = [pageDatas[@"pages"] integerValue];
            [self addChildViewLookTopic];
        }
        [SVProgressHUD dismiss];
    } RequestFaile:^(NSError *error) {
        [SVProgressHUD showInfoWithStatus:@"网络异常！"];
    }];
}
/////按照章节考点id获取笔记试题列表
//- (void)getNoteTopicWithChaperId:(NSInteger)chaperId{
//    [SVProgressHUD showWithStatus:@"试题加载中..."];
//    NSString *urlString = [NSString stringWithFormat:@"%@api/Note/GetNoteQuestions?access_token=%@&chapterid=%ld&page=%ld&size=5",systemHttps,_accessToken,chaperId,_pageCurr];
//    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
//        NSDictionary *dicNote = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
//        if ([dicNote[@"code"]integerValue] == 1) {
//            NSArray *arrayNoteTopic= dicNote[@"datas"];
//            //重置最新请求到的试题数量
//            _newTopicCount = arrayNoteTopic.count;
//            //追加方式添加试题
//            for (NSDictionary *diccc in arrayNoteTopic) {
//                [_arrayTopicLook addObject:diccc];
//            }
//            //获取最大页数
//            NSDictionary *pageDatas = dicNote[@"page"];
//            _pageCount = [pageDatas[@"pages"] integerValue];
//            [self addChildViewLookTopic];
//        }
//        [SVProgressHUD dismiss];
//    } RequestFaile:^(NSError *error) {
//        [SVProgressHUD showInfoWithStatus:@"网络异常！"];
//    }];
//}
- (void)addChildViewLookTopic{
    ///添加试图前删除scrollView上面的所有试图
    for (id subView in _scrollViewPater.subviews) {
        [subView removeFromSuperview];
    }
    ///添加试图前删除所有孩子Viewcontrol
    _labTest.textColor = [UIColor clearColor];
    ///????????????????????????
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
    ///根据当前页，设置scrollView的偏移量
    [_scrollViewPater setContentOffset:CGPointMake((_arrayTopicLook.count-_newTopicCount)*Scr_Width, 0) animated:YES];

    
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
//    NSLog(@"scrollViewDidEndScrollingAnimation");
}
//降速结束
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
}
//只要滚定了就会触发
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat scrollConSize = scrollView.contentOffset.x + Scr_Width;
    if (_pageCount != 0) {
        if (_pageCurr > _pageCount) {
            _labTest.text = @"没有更多相关试题了";
            _labTest.textColor = [UIColor lightGrayColor];
            return;
        }
    }
    
    if (scrollConSize >= _arrayTopicLook.count * Scr_Width && scrollConSize < _arrayTopicLook.count * Scr_Width+60) {
        _labTest.textColor = [UIColor lightGrayColor];
        _labTest.text = @"向左滑动加载更多试题";
        _viewLine.backgroundColor = [UIColor lightGrayColor];
    }
    else if (scrollConSize >= _arrayTopicLook.count*Scr_Width + 60){
        _labTest.textColor = [UIColor lightGrayColor];
        _labTest.text = @"松手可加载更多试题";
        _viewLine.backgroundColor = [UIColor lightGrayColor];
    }
    else{
        _labTest.textColor = [UIColor clearColor];
        _viewLine.backgroundColor = [UIColor clearColor];
        
    }
}
//完成拖拽（放手）
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    CGFloat scrollConSize = scrollView.contentOffset.x + Scr_Width;
    if (scrollConSize >= _arrayTopicLook.count*Scr_Width + 60) {
        _pageCurr = _pageCurr + 1;
        if (_pageCount != 0) {
            if (_pageCurr > _pageCount) {
                return;
            }
        }
        
        //收藏的试题
        if (_parameterView == 1) {
            [self getCollectTopicWithChaperId:_chaperId];
        }
        //错题
        else if (self.parameterView == 2){
            [self getErrorTopicWithChaperId:_chaperId];
        }
//        //添加过笔记试题
//        else if (self.parameterView == 3){
//            [self getNoteTopicWithChaperId:_chaperId];
//        }
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
