//
//  TestCenterViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/7/19.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "TestCenterViewController.h"

#import "ChaptersViewController.h"
#import "WeekSelectViewController.h"
#import "ModelPapersViewController.h"
#import "IntelligentTopicViewController.h"
@interface TestCenterViewController ()<UIScrollViewDelegate,CustomToolDelegate,SYNavigationDropdownMenuDataSource, SYNavigationDropdownMenuDelegate>
/////////////////暂时注释
//@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentShowText;
@property (weak, nonatomic) IBOutlet UIView *heardView;
@property (nonatomic, strong) UIView *viewHeardLine;
@property (nonatomic,strong) UIScrollView *scrollViewCenter;
@property (nonatomic,strong) NSUserDefaults *tyUser;
//从tyUser中获取到的用户信息
@property (nonatomic,strong) NSDictionary *dicUser;
//科目授权
@property (nonatomic,strong) CustomTools *customTool;
//专业下所有科目科目
@property (nonatomic,strong) NSArray *arraySubject;
//储存的专业信息
@property (nonatomic,strong) NSDictionary *dicUserClass;
///当前选择的科目
@property (nonatomic,strong) NSDictionary *dicCurrSubject;
//下拉菜单
@property (nonatomic,strong) SYNavigationDropdownMenu *menuView;
@property (nonatomic ,strong) UIColor *colorLine;
@end

@implementation TestCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _colorLine = ColorWithRGB(53, 122, 255);
    _tyUser = [NSUserDefaults standardUserDefaults];
     _dicUserClass = [_tyUser objectForKey:tyUserClass];
    _dicUser = [_tyUser objectForKey:tyUserUserInfo];
    _customTool = [[CustomTools alloc]init];
    _customTool.delegateTool = self;
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _scrollViewCenter = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64 + 40, Scr_Width, self.view.bounds.size.height - 40 - 64)];
    _scrollViewCenter.delegate = self;
    _scrollViewCenter.pagingEnabled = YES;
    _scrollViewCenter.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _scrollViewCenter.contentSize = CGSizeMake(Scr_Width*4, _scrollViewCenter.bounds.size.height);
    [self.view addSubview:_scrollViewCenter];
    ///添加下划线
    _viewHeardLine = [[UIView alloc]initWithFrame:CGRectMake(0, _heardView.bounds.size.height - 1, Scr_Width/4, 1)];
    _viewHeardLine.backgroundColor = _colorLine;
    [_heardView addSubview:_viewHeardLine];
    ///默认选中第一个button颜色
    for (id subView in _heardView.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)subView;
            if (btn.tag == 10) {
                [btn setTitleColor:_colorLine forState:UIControlStateNormal];
            }
        }
    }
    /////////////////暂时注释
//    _segmentShowText.selectedSegmentIndex = 0;
//    _segmentShowText.tintColor = [UIColor brownColor];
    /////////////////
}
- (void)viewDidAppear:(BOOL)animated{
    ///不是第一次加载（直接加载下拉菜单）
    if (_arraySubject.count > 0) {
        [self addDropDownListMenu];
    }
    ///第一次加载页面
    else{
        [self getAllSubject];
    }
}

- (void)viewWillAppear:(BOOL)animated{
     self.navigationController.tabBarController.tabBar.hidden = NO;
}
- (void)viewWillDisappear:(BOOL)animated{
    [_menuView hide];
}
- (IBAction)btnLiftItemClick:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

///添加子试图，并添加对应模块view
- (void)addSubViewForScrollView{
    UIStoryboard *sCommon = CustomStoryboard(@"TyCommon");
    ChaptersViewController *chapter = [sCommon instantiateViewControllerWithIdentifier:@"ChaptersViewController"];
    [self addChildViewController:chapter];
    
    ModelPapersViewController *model = [sCommon instantiateViewControllerWithIdentifier:@"ModelPapersViewController"];
    [self addChildViewController:model];
    
    WeekSelectViewController *week = [sCommon instantiateViewControllerWithIdentifier:@"WeekSelectViewController"];
    [self addChildViewController:week];
    
    IntelligentTopicViewController *intell = [sCommon instantiateViewControllerWithIdentifier:@"IntelligentTopicViewController"];
    [self addChildViewController:intell];
    ////////////////////////////////////
    ////////////////////////////////////
    
    ChaptersViewController *chapVc = self.childViewControllers[0];
    chapVc.dicSubject = _dicCurrSubject;
    chapVc.intPushWhere = 0;
    chapVc.subjectId =[NSString stringWithFormat:@"%ld", [_dicCurrSubject[@"Id"] integerValue]];
    chapVc.isActiveSubject = _isActiveSubject;
    chapVc.view.frame = CGRectMake(0, 0, Scr_Width, _scrollViewCenter.bounds.size.height);
    chapVc.view.tag = 1000;
    [_scrollViewCenter addSubview:chapVc.view];
    
    
    ModelPapersViewController *modelVc = self.childViewControllers[1];
    modelVc.dicSubject = _dicCurrSubject;
    modelVc.subjectId =[NSString stringWithFormat:@"%ld", [_dicCurrSubject[@"Id"] integerValue]];
    modelVc.intPushWhere = 0;
    modelVc.isActiveSubject = _isActiveSubject;
    modelVc.view.frame = CGRectMake(Scr_Width, 0, Scr_Width, _scrollViewCenter.bounds.size.height);
    modelVc.view.tag = 1000;
    [_scrollViewCenter addSubview:modelVc.view];
    
    WeekSelectViewController *weekVc = self.childViewControllers[2];
    weekVc.subjectId =[NSString stringWithFormat:@"%ld", [_dicCurrSubject[@"Id"] integerValue]];
    weekVc.intPushWhere = 0;
    weekVc.isActiveSubject = _isActiveSubject;
    weekVc.view.frame = CGRectMake(Scr_Width*2, 0, Scr_Width,_scrollViewCenter.bounds.size.height);
    weekVc.view.tag = 1000;
    [_scrollViewCenter addSubview:weekVc.view];
    
    IntelligentTopicViewController *intellVc =self.childViewControllers[3];
    intellVc.dicSubject = _dicCurrSubject;
    intellVc.intPushWhere = 0;
    intellVc.isActiveSubject = _isActiveSubject;
    intellVc.view.frame = CGRectMake(Scr_Width*3, 0, Scr_Width, _scrollViewCenter.bounds.size.height);
    intellVc.view.tag = 1000;
    [_scrollViewCenter addSubview:intellVc.view];
}
/**
 获取专业下所有科目
 */
- (void)getAllSubject{
//    [SVProgressHUD show];
    NSInteger subId = [_dicSubject[@"Id"] intValue];
    NSString *urlString = [NSString stringWithFormat:@"%@api/CourseInfo/%ld",systemHttps,subId];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicSubject = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dicSubject[@"code"] integerValue];
        if (codeId == 1) {
//            [SVProgressHUD dismiss];
            _arraySubject = dicSubject[@"datas"];
            [self addDropDownListMenu];
            _dicCurrSubject = _arraySubject[0];
            NSDictionary *dicDidSelectSubject = [_tyUser objectForKey:tyUserSelectSubject];
            if ([_arraySubject containsObject:dicDidSelectSubject]) {
                _dicCurrSubject = dicDidSelectSubject;
            }
            [self empowerWithSubjectDic];
        }
        else{
            [SVProgressHUD showInfoWithStatus:dicSubject[@"errmsg"]];
        }
    } RequestFaile:^(NSError *error) {
        httpsErrorShow;
    }];
}

///添加下拉菜单
- (void)addDropDownListMenu{
    if (!_menuView) {
        _menuView = [[SYNavigationDropdownMenu alloc]initWithNavigationController:self.navigationController menuItemCount:_arraySubject.count];
        _menuView.frame = CGRectMake(50, 10, Scr_Width - 100, self.navigationItem.titleView.frame.size.height - 20);
        _menuView.delegate = self;
        _menuView.dataSource = self;
    }
    self.navigationItem.titleView = _menuView;
    if (_dicCurrSubject != nil) {
        [_menuView setTitle:_dicCurrSubject[@"Names"] forState:UIControlStateNormal];
    }
    else{
        NSDictionary *dicDidSelectSubject = [_tyUser objectForKey:tyUserSelectSubject];
        if ([_arraySubject containsObject:dicDidSelectSubject]) {
            [_menuView setTitle:dicDidSelectSubject[@"Names"] forState:UIControlStateNormal];
        }
    }
}
///下拉下单代理事件
- (NSArray<NSString *> *)titleArrayForNavigationDropdownMenu:(SYNavigationDropdownMenu *)navigationDropdownMenu {
    NSMutableArray *arraySubjectName = [NSMutableArray array];
    for (NSDictionary *dicSubject in _arraySubject) {
        [arraySubjectName addObject:dicSubject[@"Names"]];
    }
    return arraySubjectName;
}

- (CGFloat)arrowPaddingForNavigationDropdownMenu:(SYNavigationDropdownMenu *)navigationDropdownMenu {
    return 8.0;
}

- (UIImage *)arrowImageForNavigationDropdownMenu:(SYNavigationDropdownMenu *)navigationDropdownMenu {
    return [UIImage imageNamed:@"arrow_down"];
}
////////////////修改者：王可佳
- (void)menuTableFooterClick{
    [_menuView hide];
}
////////////////修改者：王可佳
- (void)navigationDropdownMenu:(SYNavigationDropdownMenu *)navigationDropdownMenu didSelectTitleAtIndex:(NSUInteger)index {
    _dicCurrSubject = _arraySubject[index];
    [self empowerWithSubjectDic];
}

///下拉菜单中的item点击事件
//- (void)itemMenuClick:(NSInteger)indexItem{
//    _dicCurrSubject = _arraySubject[indexItem];
//    [self empowerWithSubjectDic];
//    //获取储存的专业、科目信息
//}
///科目授权，默认是第一个科目
- (void)empowerWithSubjectDic{
    NSString *subjectId = [NSString stringWithFormat:@"%ld",[_dicCurrSubject[@"Id"] integerValue]];
    NSString *classId = [NSString stringWithFormat:@"%@",_dicUserClass[@"Id"]];
    [_tyUser setObject:_dicCurrSubject forKey:tyUserSelectSubject];
    ///先授权
    ///登录状态
    if (_isUserLogin) {
        ///使用用户账户
        //获取储存的用户信息
        NSDictionary *dicUserInfo = [_tyUser objectForKey:tyUserUserInfo];
        //授权并收取令牌
        [_customTool empowerAndSignatureWithUserId:dicUserInfo[@"userId"] userCode:dicUserInfo[@"userCode"] classId:classId subjectId:subjectId];
    }
    ///未登录状态
    else{
        ///使用默认账户
        [_customTool empowerAndSignatureWithUserId:defaultUserId userCode:defaultUserCode classId:classId subjectId:subjectId];
    }

}
////授权成功
- (void)httpSussessReturnClick{
    ////////先判断科目是否激活或可做题
    if (_isUserLogin) {
        [self determineSubjectActive];
    }
    else{
        [self determineSubjectCanDo];
    }
}
-(void)httpErrorReturnClick{
    
}
- (void)clearChildViewAndAgainAddSubview{
    ///先清除所有子试图
    for (UIViewController *subViewCon in self.childViewControllers) {
        [subViewCon removeFromParentViewController];
    }
    ///清除容器中所有模块试图
    for (id subView in _scrollViewCenter.subviews) {
        if ([subView isKindOfClass:[UIView class]]) {
            UIView *view = (UIView *)subView;
            if (view.tag == 1000) {
                [view removeFromSuperview];
            }
        }
    }
    //加载模块
    [self addSubViewForScrollView];
}
///判断科目是否激活（登录情况下）
- (void)determineSubjectActive{
    [SVProgressHUD show];
    NSString *urlString = [NSString stringWithFormat:@"%@/ty/mobile/order/productValidate?productId=%@&jeeId=%@",systemHttpsKaoLaTopicImg,[NSString stringWithFormat:@"%ld",[_dicCurrSubject[@"Id"] integerValue]],_dicUser[@"jeeId"]];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicActive = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];

        if ([dicActive[@"code"] integerValue] == 1) {
            NSDictionary *dicDatas = dicActive[@"datas"];
            ///激活
            if ([dicDatas[@"status"] integerValue] == 1) {
                _isActiveSubject = YES;
            }
            ///未激活
            else{
                _isActiveSubject = NO;
            }
            [self clearChildViewAndAgainAddSubview];
            [SVProgressHUD dismiss];
        }
    } RequestFaile:^(NSError *error) {
        
    }];
}
///未登录情况下
- (void)determineSubjectCanDo{
    _isActiveSubject = NO;
    [self clearChildViewAndAgainAddSubview];
}
///模式切换按钮
- (IBAction)btnSelectTopicModelClick:(UIButton *)sender {
    NSInteger tagButton = sender.tag;
    ///下划线跟踪
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = _viewHeardLine.frame;
        rect.origin.x = (tagButton - 10)*(Scr_Width/4);
        _viewHeardLine.frame = rect;
    }];
    ///button按钮跟踪
    for (id subView in _heardView.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)subView;
            if (btn.tag == tagButton) {
                [btn setTitleColor:_colorLine forState:UIControlStateNormal];
            }
            else{
                [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            }
        }
    }
    
    ///设置scrollView偏移量
    [_scrollViewCenter setContentOffset:CGPointMake((tagButton - 10)*Scr_Width, 0) animated:YES];
    
}

///选择练习模式
//- (IBAction)selectTopicModelClick:(UISegmentedControl *)sender {
//    [_scrollViewCenter setContentOffset:CGPointMake(sender.selectedSegmentIndex * Scr_Width, 0) animated:YES];
//}
///acrollView 代理
//完成拖拽
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
 
    if (scrollView.contentOffset.x < -33) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
///跟踪
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger selectIndex = scrollView.contentOffset.x/Scr_Width;
//    _segmentShowText.selectedSegmentIndex = selectIndex;
    ///下划线跟踪
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = _viewHeardLine.frame;
        rect.origin.x = selectIndex*(Scr_Width/4);
        _viewHeardLine.frame = rect;
    }];
    
    ///button按钮跟踪
    for (id subView in _heardView.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)subView;
            if (btn.tag == selectIndex + 10) {
                [btn setTitleColor:_colorLine forState:UIControlStateNormal];
            }
            else{
                [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            }
        }
    }

    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
