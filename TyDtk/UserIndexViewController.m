//
//  UserIndexViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/4/5.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "UserIndexViewController.h"
#import "TableHeardView.h"
@interface UserIndexViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableViewList;
@property (nonatomic,strong) TableHeardView *tableHeardView;
@property (nonatomic,strong) NSUserDefaults *tyUser;
@property (nonatomic,strong) NSDictionary *dicUser;
@property (nonatomic,strong) NSArray *arrayCellTitle;
@property (nonatomic,strong) NSArray *arrayCellImage;
@end

@implementation UserIndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self viewLoad];
}
- (void)viewLoad{
        self.navigationController.tabBarItem.selectedImage = [[UIImage imageNamed:@"btm_icon4_hover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _arrayCellTitle = @[@"个人资料",@"我的订单",@"当前科目",@"做题记录",@"我的收藏",@"我的错题",@"我的笔记"];
    _tyUser = [NSUserDefaults standardUserDefaults];
    [self addTableViewHeardView];
        [_tyUser removeObjectForKey:tyUserUser];
}
- (void)viewWillAppear:(BOOL)animated{
    [_tableViewList reloadData];
//    [self getUserInfo];
    [self getUserImage];
}
///添加tableView头试图
- (void)addTableViewHeardView{
    _tableHeardView = [[[NSBundle mainBundle] loadNibNamed:@"TableHeardViewForUser" owner:self options:nil]lastObject];
    _tableHeardView.frame = CGRectMake(0, 0, Scr_Width, 200);
    _tableViewList.tableHeaderView = _tableHeardView;
    //http://www.tydlk.cn/tyuser/front/user/findheadimg;JSESSIONID=af39a65f-4053-4e59-a59d-678fbe3266e4?userId=dd187a90a1894c08801d384f1c663af8
    ///front/user/look/json?formSystem=902&id=dd187a90a1894c08801d384f1c663af8
    if ([self loginTest]) {
        NSLog(@"%@",_dicUser);
    }
}
///判断是否登录
- (BOOL)loginTest{
    if ([_tyUser objectForKey:tyUserUser]) {
        _dicUser = [_tyUser objectForKey:tyUserUser];
        return YES;
    }
    return NO;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return _arrayCellTitle.count;
    }
    return 1;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section != 0) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 30)];
        view.backgroundColor = [UIColor groupTableViewBackgroundColor];
        return view;
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section != 0) {
        return 30;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellUser" forIndexPath:indexPath];
    UILabel *labTitle =(UILabel *)[cell.contentView viewWithTag:11];
    
    if (indexPath.section == 0) {
        labTitle.text = _arrayCellTitle[indexPath.row];
        if (indexPath.row == 2) {
            UILabel *labSiubject = (UILabel *)[cell.contentView viewWithTag:12];
            labSiubject.adjustsFontSizeToFitWidth = YES;
            if ([_tyUser objectForKey:tyUserSelectSubject]) {
                NSDictionary *dicCurrSubject = [_tyUser objectForKey:tyUserSelectSubject];
                labSiubject.text= dicCurrSubject[@"Names"];
            }
            else{
                labSiubject.text = @"未选择科目";
            }
        }
    }
    else{
        labTitle.text = @"关于我们";
    }
    return  cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section!=1) {
        if ([self loginTest]) {
            if (indexPath.section == 0) {
                NSLog(@"个人中心");
                if (indexPath.row == 0) {
                    [self performSegueWithIdentifier:@"userinfo" sender:nil];
                }
            }
            else{
                NSLog(@"修改密码");
                //修改密码
//                [self logOut];
//                [self logOutUser];
            }
        }
        else{
            [self performSegueWithIdentifier:@"login" sender:nil];
        }
    }
}
///用户退出登录
- (void)logOutUser{
    [SVProgressHUD show];
    NSUserDefaults *tyUser = [NSUserDefaults standardUserDefaults];
    NSDictionary *dicUser = [tyUser objectForKey:tyUserUser];
    ///logout/json
    NSString *urlString = [NSString stringWithFormat:@"%@logout/json?SHAREJSESSIONID=%@",systemHttpsTyUser,dicUser[@"jeeId"]];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicOut = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dicOut[@"code"] integerValue];
        if (codeId == 1) {
            [SVProgressHUD showSuccessWithStatus:@"退出成功！"];
//            [_tyUser removeObjectForKey:tyUserUser];
        }
        else{
            [SVProgressHUD showInfoWithStatus:@"操作失败！"];
        }
        NSLog(@"%@",dicOut);
    } RequestFaile:^(NSError *error) {
        [SVProgressHUD showInfoWithStatus:@"操作失败！"];
    }];
}
///获取用户头像
- (void)getUserImage{
    NSUserDefaults *tyUser = [NSUserDefaults standardUserDefaults];
    NSDictionary *dicUser = [tyUser objectForKey:tyUserUser];
    NSString *urlString = [NSString stringWithFormat:@"%@front/user/findheadimg;JSESSIONID=%@&userId=%@",systemHttpsTyUser,dicUser[@"jeeId"],dicUser[@"userId"]];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSLog(@"%@",repoes);
    } RequestFaile:^(NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
