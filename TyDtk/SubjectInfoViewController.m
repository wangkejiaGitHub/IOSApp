//
//  SubjectInfoViewController.m
//  TyDtk
//  选择科目，并展示对应章节考点、模拟试卷、每周精选、智能出题模块
//  Created by 天一文化 on 16/3/30.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//
//////////////⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️//////////////
////此模块暂时被 TestCenterViewController 控制类替换
//////////////⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️//////////////

#import "SubjectInfoViewController.h"
//章节练习
#import "ChaptersViewController.h"
//模拟试卷
#import "ModelPapersViewController.h"
//每周精选
#import "WeekSelectViewController.h"
//智能出题
#import "IntelligentTopicViewController.h"

@interface SubjectInfoViewController ()<CustomToolDelegate>
//@property (weak, nonatomic) IBOutlet UIView *viewNaviTitle;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonLayoutWidth;
//@property (weak, nonatomic) IBOutlet UIButton *buttonHeard;
//@property (weak, nonatomic) IBOutlet UIImageView *imageViewHeard;
//view底部试图
@property (weak, nonatomic) IBOutlet UIView *viewFooter;
//追踪的下划线
@property (nonatomic ,strong) UIView *viewFooterLine;
////titleButton要显示的字段
//@property (nonatomic,strong) NSString *buttonString;
//用户信息，以及所需全局信息
@property (nonatomic,strong) NSUserDefaults *tyUser;
//从tyUser中获取到的用户信息
@property (nonatomic,strong) NSDictionary *dicUser;
//科目授权
@property (nonatomic,strong) CustomTools *customTool;
//专业下所有科目科目
@property (nonatomic,strong) NSArray *arraySubject;
//储存的专业信息
@property (nonatomic,strong) NSDictionary *dicUserClass;
//@property (nonatomic,strong) UIView *viewDroupDownList;
@property (nonatomic,assign) BOOL allowMenu;
//@property (nonatomic,assign) CGFloat tableHeight;
//手势层
//@property (nonatomic,strong) UIView *viewDown;
@property (nonatomic,nonnull) ViewNullData *viewNilData;

///当前选择的科目
@property (nonatomic,strong) NSDictionary *dicCurrSubject;
//当前需要显示的子试图的索引
@property (nonatomic,assign) NSInteger indexCurrChildView;
//下拉菜单
//@property (nonatomic,strong) DTKDropdownMenuView *menuView;
@property (nonatomic,assign) NSInteger dropDownCurrIndex;
//章节练习
@property (nonatomic,strong) ChaptersViewController *chapterVc;
//模拟试卷
@property (nonatomic,strong) ModelPapersViewController *modelPapersVc;
//每周精选
@property (nonatomic,strong) WeekSelectViewController *weekSelectVc;
//智能出题
@property (nonatomic,strong) IntelligentTopicViewController *intelligentVc;
@property (nonatomic,strong) NSString *currSubject;

@end

@implementation SubjectInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tyUser = [NSUserDefaults standardUserDefaults];
    // Do any additional setup after loading the view.
    _dropDownCurrIndex = 0;
    [self viewLoad];
    [self ifDataIsNil];
    [self addChildViewControllerForSelfWithUser];
    [SVProgressHUD dismiss];
}
- (void)viewWillAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = YES;
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
- (void)viewLoad{
    _allowMenu = NO;
    
    //添加追踪下划线
    _viewFooterLine = [[UIView alloc]initWithFrame:CGRectMake(0, 45, Scr_Width/4, 2)];
    _viewFooterLine.backgroundColor = [UIColor purpleColor];
    _viewFooterLine.layer.masksToBounds = YES;
    _viewFooterLine.layer.cornerRadius = 1;
    [_viewFooter addSubview:_viewFooterLine];
    //设置button颜色
    for (id subView in _viewFooter.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)subView;
            [btn setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
            if (btn.tag == 0) {
                [btn setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
                btn.titleLabel.font = [UIFont systemFontOfSize:15.0];
            }
        }
    }
}
//根据点击的button不同，显示不同的子试图页面
- (IBAction)downButtonClick:(UIButton *)sender {
    
    
    if (sender.tag == 3) {
        if ([self ifDataIsNil]) {
            UIStoryboard *sCommon = CustomStoryboard(@"TyCommon");
            IntelligentTopicViewController *intellVc = [sCommon instantiateViewControllerWithIdentifier:@"IntelligentTopicViewController"];
            intellVc.dicSubject = _dicCurrSubject;
            [self.navigationController pushViewController:intellVc animated:YES];
            return;
        }
    }
    _indexCurrChildView = sender.tag;
    //下划线跟踪
    [UIView animateWithDuration:0.15 animations:^{
        CGRect rectV = _viewFooterLine.frame;
        rectV.origin.x = _indexCurrChildView*(Scr_Width/4);
        _viewFooterLine.frame = rectV;
    }];
    
    for (id subView in _viewFooter.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)subView;
            [btn setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:13.0];
            if (btn.tag == _indexCurrChildView) {
                [btn setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
                btn.titleLabel.font = [UIFont systemFontOfSize:15.0];
            }
        }
    }
    if ([self ifDataIsNil]) {
        _indexCurrChildView = sender.tag;
        [self showSelfChildViewWithViewIndex];
    }
}
/**
 判断是否选择了科目
 */
- (BOOL)ifDataIsNil{
    if (_dicCurrSubject.allKeys == 0) {
        [_viewNilData removeFromSuperview];
        if (!_viewNilData) {
            _viewNilData = [[ViewNullData alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Height - 49) showText:@"您还没有选择考试科目"];
        }
        [self.view addSubview:_viewNilData];
        return NO;
    }
    return YES;
}
/**
 ******************************
 根据添加的子试图索引，显示子试图页面
 ******************************
 */
- (void)showSelfChildViewWithViewIndex{
    //去除空数据层
    if (_viewNilData) {
        [_viewNilData removeFromSuperview];
    }
    //移除可能显示过的子试图
    [_chapterVc.view removeFromSuperview];
    [_modelPapersVc.view removeFromSuperview];
    [_weekSelectVc.view removeFromSuperview];
    //章节考点
    if (_indexCurrChildView == 0) {
        if (!_chapterVc) {
            _chapterVc = self.childViewControllers[_indexCurrChildView];
            _chapterVc.view.frame = CGRectMake(0, 64, Scr_Width, Scr_Height - 49-64);
        }
        _chapterVc.subjectId = [NSString stringWithFormat:@"%@",_dicCurrSubject[@"Id"]];
        _chapterVc.dicSubject = _dicCurrSubject;
        _chapterVc.title = @"章节考点";
        [self.view addSubview:_chapterVc.view];
    }
    
    //模拟试卷
    else if (_indexCurrChildView == 1){
        if (!_modelPapersVc) {
            _modelPapersVc = self.childViewControllers[_indexCurrChildView];
            _modelPapersVc.view.frame = CGRectMake(0, 64, Scr_Width, Scr_Height - 49 - 64);
        }
        _modelPapersVc.intPushWhere = 0;
        _modelPapersVc.subjectId = [NSString stringWithFormat:@"%@",_dicCurrSubject[@"Id"]];
        _modelPapersVc.dicSubject = _dicCurrSubject;
        [self.view addSubview:_modelPapersVc.view];
    }
    //每周精选
    else if (_indexCurrChildView == 2){
        if (!_weekSelectVc) {
            _weekSelectVc = self.childViewControllers[_indexCurrChildView];
            _weekSelectVc.view.frame = CGRectMake(0, 64, Scr_Width, Scr_Height - 49 - 64);
        }
        _weekSelectVc.subjectId = [NSString stringWithFormat:@"%@",_dicCurrSubject[@"Id"]];
        [self.view addSubview:_weekSelectVc.view];
    }
}

/////////////////////////////
/**
 ****************************
 添加章节考点、模拟试卷等相关view
 ****************************
 */
- (void)addChildViewControllerForSelfWithUser{
    //添加章节考点子试图
    UIStoryboard *sCommon = CustomStoryboard(@"TyCommon");
    UIViewController *cZjVc = [sCommon instantiateViewControllerWithIdentifier:@"ChaptersViewController"];
    [self addChildViewController:cZjVc];
    //添加模拟试卷子试图
    UIViewController *mPapersVc = [sCommon instantiateViewControllerWithIdentifier:@"ModelPapersViewController"];
    [self addChildViewController:mPapersVc];
    //添加每周精选子试图
    UIViewController *weekVc = [sCommon instantiateViewControllerWithIdentifier:@"WeekSelectViewController"];
    [self addChildViewController:weekVc];
}

- (IBAction)leftButtonClick:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
            _arraySubject = dicSubject[@"datas"];
            [self addDropDownListMenu];
            [SVProgressHUD dismiss];
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
//    ///菜单item数组
//    NSMutableArray *arrayMenuItem = [NSMutableArray array];
//    ///每个所有item中的字符串最大个数（计算最大宽度）
//    NSInteger menuStringLength = 0;
//    for (NSDictionary *dicSub in _arraySubject) {
//        NSString *name = dicSub[@"Names"];
//        NSInteger nameLength = name.length;
//        if (nameLength > menuStringLength) {
//            menuStringLength = nameLength;
//        }
//    }
//    for (int i =0; i<_arraySubject.count + 1; i++) {
//        if (i == 0) {
//            DTKDropdownItem *item = [DTKDropdownItem itemWithTitle:@"--请选择你的科目--" callBack:^(NSUInteger index, id info) {
//                [self itemMenuClick:index];
//            }];
//            [arrayMenuItem addObject:item];
//        }
//        else{
//            NSDictionary *dicSubject = _arraySubject[i - 1];
//            DTKDropdownItem *item = [DTKDropdownItem itemWithTitle:dicSubject[@"Names"] callBack:^(NSUInteger index, id info) {
//                [self itemMenuClick:index];
//            }];
//            [arrayMenuItem addObject:item];
//        }
//    }
//    _menuView = [DTKDropdownMenuView dropdownMenuViewForNavbarTitleViewWithFrame:CGRectMake(46, 0, Scr_Width - 92, 44) dropdownItems:arrayMenuItem];
//    _menuView.currentNav = self.navigationController;
//    _menuView.dropWidth = menuStringLength*19 - 15;
//    if (menuStringLength <= 10) {
//        _menuView.dropWidth = 200;
//    }
//    _menuView.titleFont = [UIFont systemFontOfSize:13.0];
//    _menuView.textColor = [UIColor brownColor];
//    _menuView.titleColor = [UIColor purpleColor];
//    _menuView.textFont = [UIFont systemFontOfSize:13.f];
//    _menuView.cellSeparatorColor = [UIColor lightGrayColor];
//    _menuView.textFont = [UIFont systemFontOfSize:14.f];
//    _menuView.animationDuration = 0.2f;
//    if (_dicCurrSubject != nil) {
//        _menuView.selectedIndex = [_arraySubject indexOfObject:_dicCurrSubject] + 1;
//    }
//    self.navigationItem.titleView = _menuView;
}
///下拉菜单中的item点击事件
- (void)itemMenuClick:(NSInteger)indexItem{
    _dropDownCurrIndex = indexItem;
    [_viewNilData removeFromSuperview];
    if (indexItem!=0) {
        _dicCurrSubject = _arraySubject[indexItem - 1];
        _customTool = [[CustomTools alloc]init];
        _customTool.delegateTool = self;
        //获取储存的专业、科目信息
        _dicUserClass = [_tyUser objectForKey:tyUserClass];
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
    else{
        _dicCurrSubject = nil;
        [self ifDataIsNil];
    }
}
////授权成功
- (void)httpSussessReturnClick{
    if (_indexCurrChildView == 3) {
        UIStoryboard *sCommon = CustomStoryboard(@"TyCommon");
        IntelligentTopicViewController *intellVc = [sCommon instantiateViewControllerWithIdentifier:@"IntelligentTopicViewController"];
        intellVc.dicSubject = _dicCurrSubject;
        [self.navigationController pushViewController:intellVc animated:YES];
    }
    else{
        [self showSelfChildViewWithViewIndex];
    }
}
-(void)httpErrorReturnClick{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
