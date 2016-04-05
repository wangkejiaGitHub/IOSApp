//
//  SubjectInfoViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/3/30.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "SubjectInfoViewController.h"
@interface SubjectInfoViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *ScrolHeardView;
@property (weak, nonatomic) IBOutlet UIView *viewNaviTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonLayoutWidth;
@property (weak, nonatomic) IBOutlet UIButton *buttonHeard;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewHeard;
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
//朦层
//@property (nonatomic,strong) MZView *mzView;
@end

@implementation SubjectInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self viewLoad];
    
    [self test];
}
- (void)viewLoad{
    _buttonString = @"请选择科目";
    _allowMenu = NO;
    CGSize btnSize = sizeWithStrinfLength(_buttonString, 15.0, 30);
    _buttonLayoutWidth.constant = btnSize.width;
    [_buttonHeard setTitle:_buttonString forState:UIControlStateNormal];
    [self getAllSubject];
}
/**
 屏幕点击事件
 */
- (void)viewTapTextRfr{
    [self hideViewDroupDownListMenu];
}
-(void)test{
        _tyUser = tyNSUserDefaults;
    //    _dicUser = [_tyUser objectForKey:tyUserUser];
    //    _customTool = [[CustomTools alloc]init];
    //    _customTool.delegateTool = self;
    //    [_customTool empowerAndSignatureWithUserId:_dicUser[@"userId"] userName:_dicUser[@"name"] classId:@"105" subjectId:@"661"];
    
        [_tyUser removeObjectForKey:tyUserUser];
        [_tyUser removeObjectForKey:tyUserAccessToken];
}

- (IBAction)heardButtonClick:(UIButton *)sender {
    _allowMenu = !_allowMenu;
    if (_allowMenu) {
       
        [self addViewDroupDownListMenuForSelf];
    }
    else{
        
        
        [self hideViewDroupDownListMenu];
    }
    NSLog(@"fasfsfff");
}
/**
 菜单出现
 */
- (void)addViewDroupDownListMenuForSelf{
    UITableView *tableView;
    if (!_viewDroupDownList) {
        _viewDroupDownList = [[UIView alloc]initWithFrame:CGRectMake(0, -_tableHeight, Scr_Width, _tableHeight)];
        _viewDroupDownList.backgroundColor = ColorWithRGBWithAlpp(0, 0, 0, 0.3);
        
        tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, _tableHeight) style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource =self;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.tableFooterView = [UIView new];
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
        rect.origin.y = -Scr_Height/2;
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
        NSLog(@"%@",dicSubject);
        _arraySubject = dicSubject[@"datas"];
        NSLog(@"%@",_arraySubject);
        _tableHeight = _arraySubject.count*30+20;
        [SVProgressHUD dismiss];
        _buttonHeard.enabled = YES;
    } RequestFaile:^(NSError *error) {
        [SVProgressHUD showInfoWithStatus:@"网络异常"];
    }];
}
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
    labText.textColor = [UIColor blueColor];
    labText.font = [UIFont systemFontOfSize:16.0];
    labText.text = dic[@"Names"];
    labText.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:labText];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = _arraySubject[indexPath.row];
    _buttonString = dic[@"Names"];
    CGSize size = sizeWithStrinfLength(_buttonString, 15.0, 30);
    _buttonHeard.titleLabel.font = [UIFont systemFontOfSize:15.0];
    if (_buttonString.length > 15) {
        _buttonHeard.titleLabel.font = [UIFont systemFontOfSize:13.0];
    }
    [_buttonHeard setTitle:_buttonString forState:UIControlStateNormal];
    _buttonLayoutWidth.constant = size.width;
    [self hideViewDroupDownListMenu];
    NSLog(@"ddddddddd");
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
