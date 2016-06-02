//
//  UserInfoViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/5/31.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "UserInfoViewController.h"
#import "UpdateUserInfoViewController.h"
#import "UptadePwdViewController.h"
@interface UserInfoViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableViewUser;
@property (nonatomic,strong) NSArray *arrayListName1;
@property (nonatomic,strong) NSArray *arrayListName2;
//用户信息
@property (nonatomic,strong) NSDictionary *dicUserInfo;
//当前需要修改的参数值
@property (nonatomic,strong) NSString *updateStringCurr;
@property (nonatomic,strong) NSUserDefaults *tyUser;
@end

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tyUser = [NSUserDefaults standardUserDefaults];
    self.title = @"我的信息";
    _arrayListName1 = @[@"用户名",@"手机号",@"邮箱"];
    _arrayListName2 = @[@"修改密码",@"退出登录"];
//    [self updateTest];
}
- (void)viewWillAppear:(BOOL)animated{
    [self getUserInfo];
}
///获取用户信息
- (void)getUserInfo{
    NSDictionary *dicUser = [_tyUser objectForKey:tyUserUser];
    NSString *urlString = [NSString stringWithFormat:@"%@front/user/finduserinfo;JSESSIONID=%@",systemHttpsTyUser,dicUser[@"jeeId"]];
    NSLog(@"%@",urlString);
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicUserInfo = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        _dicUserInfo = dicUserInfo;
        [_tableViewUser reloadData];
    } RequestFaile:^(NSError *error) {
        
    }];
    NSLog(@"%@",dicUser);
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return _arrayListName1.count + 1;
    }
    return _arrayListName2.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 60;
        }
    }
    return 50;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 35;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 35)];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"imgcell" forIndexPath:indexPath];
            if (_dicUserInfo.allKeys.count > 0) {
                
            }
        }
        else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"usercell" forIndexPath:indexPath];
            UILabel *labText = (UILabel *)[cell.contentView viewWithTag:10];
            if (_dicUserInfo.allKeys.count > 0) {
                labText.text = _arrayListName1[indexPath.row - 1];
                UILabel *labValue = (UILabel *)[cell.contentView viewWithTag:11];
                if (indexPath.row == 1) {
                    labValue.text = _dicUserInfo[@"userName"];
                }
                else if (indexPath.row == 2){
                    labValue.text =_dicUserInfo[@"mobile"];
                }
                else if (indexPath.row == 3){
                    labValue.text = _dicUserInfo[@"email"];
                }
            }
        }
    }
    else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"usercell" forIndexPath:indexPath];
        UILabel *labText = (UILabel *)[cell.contentView viewWithTag:10];
        labText.text = _arrayListName2[indexPath.row];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //修改头像
    if (indexPath.section == 0&&indexPath.row == 0) {
        NSLog(@"修改头像");
    }
    //修改基本信息（用户名，手机号，邮箱）
    else if (indexPath.section == 0&&indexPath.row != 0) {
        UILabel *labValue = (UILabel*)[cell.contentView viewWithTag:11];
        _updateStringCurr = labValue.text;
        [self performSegueWithIdentifier:@"updateinfo" sender:[NSString stringWithFormat:@"%ld",indexPath.row]];
    }
    //修改密码
    else if (indexPath.section == 1&&indexPath.row == 0){
        UptadePwdViewController *upVe= [[UptadePwdViewController alloc]initWithNibName:@"UptadePwdViewController" bundle:nil];
        [self.navigationController pushViewController:upVe animated:YES];
//        [self performSegueWithIdentifier:@"fffff" sender:nil];
        
    }
    //退出登录
    else if (indexPath.section == 1&&indexPath.row != 0){
        LXAlertView *alertLx = [[LXAlertView alloc]initWithTitle:@"退出登录" message:@"确认退出登录" cancelBtnTitle:@"取消" otherBtnTitle:@"退出" clickIndexBlock:^(NSInteger clickIndex) {
            if (clickIndex == 1) {
                [self logOutUser];
            }
        }];
        [alertLx showLXAlertView];
        NSLog(@"退出登录");
    }
}
//传递修改参数
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"updateinfo"]) {
        UpdateUserInfoViewController *updateVc = segue.destinationViewController;
        updateVc.updateInfoPar =[sender integerValue];
        updateVc.stringCurr = _updateStringCurr;
    }
    else if ([segue.identifier isEqualToString:@"updatepwd"]){
        
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
            [_tyUser removeObjectForKey:tyUserAccessToken];
            [_tyUser removeObjectForKey:tyUserClass];
            [_tyUser removeObjectForKey:tyUserSelectSubject];
            [_tyUser removeObjectForKey:tyUserSubject];
            [_tyUser removeObjectForKey:tyUserUser];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            [SVProgressHUD showInfoWithStatus:@"操作失败！"];
        }
        NSLog(@"%@",dicOut);
    } RequestFaile:^(NSError *error) {
        [SVProgressHUD showInfoWithStatus:@"操作失败！"];
    }];
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
