//
//  SubjectInfoViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/3/30.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "SubjectInfoViewController.h"
//章节练习
#import "ChaptersViewController.h"
//模拟试卷
#import "ModelPapersViewController.h"
@interface SubjectInfoViewController ()<UITableViewDataSource,UITableViewDelegate,DataDoneDelegatePater,DataDoneDelegateChapter>
@property (weak, nonatomic) IBOutlet UIView *viewNaviTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonLayoutWidth;
@property (weak, nonatomic) IBOutlet UIButton *buttonHeard;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewHeard;
//view底部试图
@property (weak, nonatomic) IBOutlet UIView *viewFooter;
//追踪的下划线
@property (nonatomic ,strong) UIView *viewFooterLine;
//titleButton要显示的字段
@property (nonatomic,strong) NSString *buttonString;
//用户信息，以及所需全局信息
@property (nonatomic,strong) NSUserDefaults *tyUser;
//从tyUser中获取到的用户信息
@property (nonatomic,strong) NSDictionary *dicUser;
//科目授权
@property (nonatomic,strong) CustomTools *
customTool;
//专业下所有科目科目
@property (nonatomic,strong) NSArray *arraySubject;
@property (nonatomic,strong) UIView *viewDroupDownList;
@property (nonatomic,assign) BOOL allowMenu;
@property (nonatomic,assign) CGFloat tableHeight;
//手势层
@property (nonatomic,strong) UIView *viewDown;
@property (nonatomic,nonnull) ViewNullData *viewNilData;
//朦层
//@property (nonatomic,strong) MZView *mzView;

//当前选择的科目
@property (nonatomic,strong) NSDictionary *dicCurrSubject;
//当前需要显示的子试图的索引
@property (nonatomic,assign) NSInteger indexCurrChildView;

//章节练习
@property (nonatomic,strong) ChaptersViewController *chapterVc;
//模拟试卷
@property (nonatomic,strong) ModelPapersViewController *modelPapersVc;
@end

@implementation SubjectInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self viewLoad];
    [self ifDataIsNil];
    [self addChildViewControllerForSelfWithUser];
}

- (void)viewLoad{
    _buttonString = @"请选择考试科目";
    _allowMenu = NO;
    CGSize btnSize = sizeWithStrinfLength(_buttonString, 15.0, 30);
    _buttonLayoutWidth.constant = btnSize.width;
    [_buttonHeard setTitle:_buttonString forState:UIControlStateNormal];
    [self getAllSubject];
    
    //添加追踪下划线
    _viewFooterLine = [[UIView alloc]initWithFrame:CGRectMake(0, 47, Scr_Width/4, 3)];
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
        [self allowTouchButton:NO];
        _indexCurrChildView = sender.tag;
        [self showSelfChildViewWithViewIndex];
    }
}
- (void)allowTouchButton:(BOOL)allow{
    for (id subView in _viewFooter.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)subView;
            btn.userInteractionEnabled = allow;
            }
        }
}

/**
 判断是否选择了科目
 */
- (BOOL)ifDataIsNil{
    if (_dicCurrSubject.allKeys == 0) {
        if (!_viewNilData) {
            _viewNilData = [[ViewNullData alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Height - 49) showText:@"您还没有选择考试科目"];
            [self.view addSubview:_viewNilData];
        }
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
    
    if (_indexCurrChildView == 0) {
        //章节考点
        if (!_chapterVc) {
            _chapterVc = self.childViewControllers[_indexCurrChildView];
            _chapterVc.view.frame = CGRectMake(0, 64, Scr_Width, Scr_Height - 49-64);
        }
        _chapterVc.subjectId = [NSString stringWithFormat:@"%@",_dicCurrSubject[@"Id"]];
        _chapterVc.deledateData = self;
        [self.view addSubview:_chapterVc.view];
    }
    else if (_indexCurrChildView == 1){
        //模拟试卷
        if (!_modelPapersVc) {
            _modelPapersVc = self.childViewControllers[_indexCurrChildView];
            _modelPapersVc.view.frame = CGRectMake(0, 64, Scr_Width, Scr_Height - 49 - 64);
        }
        _modelPapersVc.deledateData = self;
        _modelPapersVc.subjectId = [NSString stringWithFormat:@"%@",_dicCurrSubject[@"Id"]];
        [self.view addSubview:_modelPapersVc.view];
    }
    else if (_indexCurrChildView == 2){
        //?????????????????????????
        [self allowTouchButton:YES];
        //每周精选
    }
    else if (_indexCurrChildView == 3){
        //????????????????????????
        [self allowTouchButton:YES];
        //练习记录
    }
}
/////////////////////////////
// 各个页面请求回调

- (void)doneBlockChapter{
    [self allowTouchButton:YES];
}
- (void)doneBlockPater{
    [self allowTouchButton:YES];
}

/////////////////////////////
/**
 ****************************
 添加章节考点、模拟试卷等相关view
 ****************************
 */
- (void)addChildViewControllerForSelfWithUser{
    //添加章节考点子试图
    UIViewController *cZjVc = [self.storyboard instantiateViewControllerWithIdentifier:@"ChaptersViewController"];
    [self addChildViewController:cZjVc];
    //添加模拟试卷子试图
    UIViewController *mPapersVc = [self.storyboard instantiateViewControllerWithIdentifier:@"ModelPapersViewController"];
    [self addChildViewController:mPapersVc];
    //添加每周精选子试图
    
    
    
    //添加练习记录子试图
    
}
/**
 屏幕点击事件
 */
- (void)viewTapTextRfr{
    [self hideViewDroupDownListMenu];
}

- (IBAction)heardButtonClick:(UIButton *)sender {
    _allowMenu = !_allowMenu;
    if (_allowMenu) {
        
        [self addViewDroupDownListMenuForSelf];
    }
    else{
        [self hideViewDroupDownListMenu];
    }
}
/**
 菜单出现
 */
- (void)addViewDroupDownListMenuForSelf{
    UITableView *tableView;
    if (!_viewDroupDownList) {
        _viewDroupDownList = [[UIView alloc]initWithFrame:CGRectMake(0, -_tableHeight, Scr_Width, _tableHeight)];
        _viewDroupDownList.backgroundColor = ColorWithRGBWithAlpp(0, 0, 0, 0.5);
        
        tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, _tableHeight) style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource =self;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        UIView *viewF = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 10)];
        tableView.tableFooterView = viewF;
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 10)];
        tableView.tableHeaderView = view;
        [_viewDroupDownList addSubview:tableView];
    }
    _imageViewHeard.image = [UIImage imageNamed:@"arrow_up"];
    [self.view addSubview:_viewDroupDownList];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = _viewDroupDownList.frame;
        rect.origin.y = 64;
        _viewDroupDownList.frame = rect;
    }];
    if (!_viewDown) {
        _viewDown = [[UIView alloc]initWithFrame:CGRectMake(0, _tableHeight+60, Scr_Width, Scr_Height-_tableHeight-40)];
        _viewDown.backgroundColor =[UIColor clearColor];
        [self.view addSubview:_viewDown];
        UITapGestureRecognizer *tapViewDown = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapViewDown)];
        [_viewDown addGestureRecognizer:tapViewDown];
    }
    [self.view addSubview:_viewDown];
    
}
-(void)tapViewDown{
    [self hideViewDroupDownListMenu];
}
/**
 隐藏菜单
 */
- (void)hideViewDroupDownListMenu{
    if (_viewDown) {
        [_viewDown removeFromSuperview];
    }
    _imageViewHeard.image = [UIImage imageNamed:@"arrow_down"];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = _viewDroupDownList.frame;
        rect.origin.y = - _tableHeight;
        _viewDroupDownList.frame = rect;
    }];
    _allowMenu = NO;
}
- (IBAction)leftButtonClick:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
/**
 获取专业下所有科目
 */
- (void)getAllSubject{
    [SVProgressHUD show];
    _buttonHeard.enabled = NO;
    NSInteger subId = [_dicSubject[@"Id"] intValue];
    NSString *urlString = [NSString stringWithFormat:@"%@api/CourseInfo/%ld",systemHttps,subId];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicSubject = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        _arraySubject = dicSubject[@"datas"];
        _tableHeight = _arraySubject.count*30+20;
        if (_tableHeight > Scr_Height) {
            _tableHeight = Scr_Height - 153;
        }
        [SVProgressHUD dismiss];
        _buttonHeard.enabled = YES;
    } RequestFaile:^(NSError *error) {
        [SVProgressHUD showInfoWithStatus:@"网络异常"];
    }];
}
//菜单上的tableView代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arraySubject.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell1"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell1"];
    }
    for (id subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    cell.backgroundColor = [UIColor clearColor];
    NSDictionary *dic = _arraySubject[indexPath.row];
    UILabel *labText = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, Scr_Width-20, 20)];
    labText.textColor = [UIColor whiteColor];
    labText.font = [UIFont systemFontOfSize:16.0];
    labText.text = dic[@"Names"];
    labText.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:labText];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _dicCurrSubject = _arraySubject[indexPath.row];
    _buttonString = _dicCurrSubject[@"Names"];
    CGSize size = sizeWithStrinfLength(_buttonString, 15.0, 30);
    _buttonHeard.titleLabel.font = [UIFont systemFontOfSize:15.0];
    if (_buttonString.length > 15) {
        _buttonHeard.titleLabel.font = [UIFont systemFontOfSize:13.0];
    }
    [_buttonHeard setTitle:_buttonString forState:UIControlStateNormal];
    _buttonLayoutWidth.constant = size.width;
    [self hideViewDroupDownListMenu];
    [self showSelfChildViewWithViewIndex];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
