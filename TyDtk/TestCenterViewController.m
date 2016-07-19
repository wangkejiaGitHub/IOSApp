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
@interface TestCenterViewController ()<UIScrollViewDelegate,CustomToolDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentShowText;
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
@property (nonatomic,strong) DTKDropdownMenuView *menuView;
@property (nonatomic,assign) NSInteger dropDownCurrIndex;
@end

@implementation TestCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tyUser = [NSUserDefaults standardUserDefaults];
     _dicUserClass = [_tyUser objectForKey:tyUserClass];
    _customTool = [[CustomTools alloc]init];
    _customTool.delegateTool = self;
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _scrollViewCenter = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64 + 45, Scr_Width, self.view.bounds.size.height - 45 - 64)];
    _scrollViewCenter.delegate = self;
    _scrollViewCenter.pagingEnabled = YES;
    _scrollViewCenter.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _scrollViewCenter.contentSize = CGSizeMake(Scr_Width*4, _scrollViewCenter.bounds.size.height);
    [self.view addSubview:_scrollViewCenter];
    _segmentShowText.selectedSegmentIndex = 0;
    _segmentShowText.tintColor = [UIColor brownColor];
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
    chapVc.view.frame = CGRectMake(0, 0, Scr_Width, _scrollViewCenter.bounds.size.height);
    chapVc.view.tag = 1000;
    [_scrollViewCenter addSubview:chapVc.view];
    
    
    ModelPapersViewController *modelVc = self.childViewControllers[1];
    modelVc.dicSubject = _dicCurrSubject;
    modelVc.subjectId =[NSString stringWithFormat:@"%ld", [_dicCurrSubject[@"Id"] integerValue]];
    modelVc.intPushWhere = 0;
    modelVc.view.frame = CGRectMake(Scr_Width, 0, Scr_Width, _scrollViewCenter.bounds.size.height);
    modelVc.view.tag = 1000;
    [_scrollViewCenter addSubview:modelVc.view];
    
    WeekSelectViewController *weekVc = self.childViewControllers[2];
    weekVc.subjectId =[NSString stringWithFormat:@"%ld", [_dicCurrSubject[@"Id"] integerValue]];
    weekVc.intPushWhere = 0;
    weekVc.view.frame = CGRectMake(Scr_Width*2, 0, Scr_Width,_scrollViewCenter.bounds.size.height);
    weekVc.view.tag = 1000;
    [_scrollViewCenter addSubview:weekVc.view];
    
    IntelligentTopicViewController *intellVc =self.childViewControllers[3];
    intellVc.dicSubject = _dicCurrSubject;
    intellVc.intPushWhere = 0;
    intellVc.view.frame = CGRectMake(Scr_Width*3, 0, Scr_Width, _scrollViewCenter.bounds.size.height);
    intellVc.view.tag = 1000;
    [_scrollViewCenter addSubview:intellVc.view];
}
/**
 获取专业下所有科目
 */
- (void)getAllSubject{
    [SVProgressHUD show];
    //    _buttonHeard.enabled = NO;
    NSInteger subId = [_dicSubject[@"Id"] intValue];
    NSString *urlString = [NSString stringWithFormat:@"%@api/CourseInfo/%ld",systemHttps,subId];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicSubject = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dicSubject[@"code"] integerValue];
        if (codeId == 1) {
            [SVProgressHUD dismiss];
            _arraySubject = dicSubject[@"datas"];
            [self addDropDownListMenu];
            _dicCurrSubject = _arraySubject[0];
            [self empowerWithSubjectDic];
            

        }
        else{
            [SVProgressHUD showInfoWithStatus:dicSubject[@"errmsg"]];
        }
    } RequestFaile:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"网络异常"];
    }];
}

///添加下拉菜单
- (void)addDropDownListMenu{
    ///菜单item数组
    NSMutableArray *arrayMenuItem = [NSMutableArray array];
    ///每个所有item中的字符串最大个数（计算最大宽度）
    NSInteger menuStringLength = 0;
    for (NSDictionary *dicSub in _arraySubject) {
        NSString *name = dicSub[@"Names"];
        NSInteger nameLength = name.length;
        if (nameLength > menuStringLength) {
            menuStringLength = nameLength;
        }
    }
    
    for (int i =0; i<_arraySubject.count; i++) {
        NSDictionary *dicSubject = _arraySubject[i];
        DTKDropdownItem *item = [DTKDropdownItem itemWithTitle:dicSubject[@"Names"] callBack:^(NSUInteger index, id info) {
            [self itemMenuClick:index];
        }];
        [arrayMenuItem addObject:item];
    }
    _menuView = [DTKDropdownMenuView dropdownMenuViewForNavbarTitleViewWithFrame:CGRectMake(46, 0, Scr_Width - 92, 44) dropdownItems:arrayMenuItem];
    _menuView.currentNav = self.navigationController;
    _menuView.dropWidth = menuStringLength*19 - 15;
    if (menuStringLength <= 10) {
        _menuView.dropWidth = 200;
    }
    _menuView.titleFont = [UIFont systemFontOfSize:13.0];
    _menuView.textColor = [UIColor brownColor];
    _menuView.titleColor = [UIColor purpleColor];
    _menuView.textFont = [UIFont systemFontOfSize:13.f];
    _menuView.cellSeparatorColor = [UIColor lightGrayColor];
    _menuView.textFont = [UIFont systemFontOfSize:14.f];
    _menuView.animationDuration = 0.2f;
    if (_dicCurrSubject != nil) {
        _menuView.selectedIndex = [_arraySubject indexOfObject:_dicCurrSubject];
    }
    self.navigationItem.titleView = _menuView;
}
///下拉菜单中的item点击事件
- (void)itemMenuClick:(NSInteger)indexItem{
    _dicCurrSubject = _arraySubject[indexItem];
    [self empowerWithSubjectDic];
    //获取储存的专业、科目信息
}
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
-(void)httpErrorReturnClick{
    
}
///选择练习模式
- (IBAction)selectTopicModelClick:(UISegmentedControl *)sender {
    [_scrollViewCenter setContentOffset:CGPointMake(sender.selectedSegmentIndex * Scr_Width, 0) animated:YES];
}
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
    _segmentShowText.selectedSegmentIndex = selectIndex;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
