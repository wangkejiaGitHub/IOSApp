//
//  UserIndexViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/4/5.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "UserIndexViewController.h"
#import "TableHeardView.h"
#import "MyCollectViewController.h"
#import "SelectSubjectViewController.h"
#import "LoginViewController.h"
#import "ExerciseRecordViewController.h"
@interface UserIndexViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableViewList;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewBg;

@property (nonatomic,strong) TableHeardView *tableHeardView;
@property (nonatomic,strong) NSUserDefaults *tyUser;
@property (nonatomic,strong) NSDictionary *dicUser;
@property (nonatomic,strong) NSArray *arrayCellTitle;
@property (nonatomic,strong) NSArray *arrayCellImage;
@property (nonatomic,strong) ViewNullData *viewDataNil;
/////////专业分类科目信息////////////////
//所有专业分类
@property (nonatomic,strong) NSMutableArray *arraySubject;
//所有专业
@property (nonatomic,strong) NSMutableArray *arraySecoundSubject;
@end

@implementation UserIndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self viewLoad];
}
- (void)viewLoad{
    _imageViewBg.image = systemBackGrdImg;
    self.navigationController.tabBarItem.selectedImage = [[UIImage imageNamed:@"btm_icon4_hover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _arrayCellTitle = @[@"个人资料",@"当前科目",@"我的考试",@"我的订单",@"做题记录",@"我的收藏",@"我的错题",@"我的笔记"];
    _arrayCellImage = @[@"",@"course",@"quest",@"order",@"learnrecord",@"collect",@"errquests",@"ebook"];
    _tyUser = [NSUserDefaults standardUserDefaults];
    [self addTableViewHeardView];
    /////专业分类科目信息
    _arraySubject = [NSMutableArray array];
    _arraySecoundSubject = [NSMutableArray array];
}
- (void)viewWillAppear:(BOOL)animated{
    [SVProgressHUD dismiss];
    [_tableViewList reloadData];
    //登录是否超时（没有其他定义）
    [self getUserInfo];
    //    [self getUserImage];
}
///添加tableView头试图
- (void)addTableViewHeardView{
    _tableHeardView = [[[NSBundle mainBundle] loadNibNamed:@"TableHeardViewForUser" owner:self options:nil]lastObject];
    _tableHeardView.frame = CGRectMake(0, 0, Scr_Width, 200);
    _tableViewList.tableHeaderView = _tableHeardView;
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
    return 60;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section != 0) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 30)];
        view.backgroundColor = [UIColor clearColor];
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
    if (section == 1) {
        return 30;
    }
    return 1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 1) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 30)];
        view.backgroundColor = [UIColor clearColor];
    }
    return nil;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellUser" forIndexPath:indexPath];
    UILabel *labTitle =(UILabel *)[cell.contentView viewWithTag:11];
    UIImageView *img = (UIImageView *)[cell.contentView viewWithTag:10];
    
    if (indexPath.section == 0) {
        img.image = [UIImage imageNamed:_arrayCellImage[indexPath.row]];
        labTitle.text = _arrayCellTitle[indexPath.row];
        if (indexPath.row == 1) {
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
        img.image = [UIImage imageNamed:@"about"];
        labTitle.text = @"关于我们";
    }
    return  cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // _arrayCellTitle = @[@"个人资料",@"当前科目",@"我的考试",@"我的订单",@"做题记录",@"我的收藏",@"我的错题",@"我的笔记"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if ([self loginTest]) {
            UIStoryboard *Scommon = CustomStoryboard(@"TyCommon");
            if (indexPath.row == 0) {
                //个人资料
                [self performSegueWithIdentifier:@"userinfo" sender:nil];
            }
            else if (indexPath.row == 1){
//                //当前科目
                [self getSubjectClass];

            }
            else if (indexPath.row == 2){
                //我的考试
                if ([_tyUser objectForKey:tyUserSubject]) {
                    [self performSegueWithIdentifier:@"myexam" sender:nil];
                }
                else{
                    [SVProgressHUD showInfoWithStatus:@"还没有选择过相关科目"];
                }
                NSLog(@"1");
            }
            else if (indexPath.row == 3){
                //我的订单
                if ([_tyUser objectForKey:tyUserSubject]) {
                    [self performSegueWithIdentifier:@"myorder" sender:nil];
                }
                else{
                    [SVProgressHUD showInfoWithStatus:@"还没有选择过相关科目"];
                }

                NSLog(@"2");
            }
            //做题记录
            else if (indexPath.row == 4){
                if ([_tyUser objectForKey:tyUserSubject]) {
                    ExerciseRecordViewController *execVc = [Scommon instantiateViewControllerWithIdentifier:@"ExerciseRecordViewController"];
                    [self.navigationController pushViewController:execVc animated:YES];
                }
                else{
                    [SVProgressHUD showInfoWithStatus:@"还没有选择过相关科目"];
                }
             
            }
            //我的收藏
            else if (indexPath.row == 5){
                if ([_tyUser objectForKey:tyUserSubject]) {
                    MyCollectViewController *collectVc = [Scommon instantiateViewControllerWithIdentifier:@"MyCollectViewController"];
                    collectVc.parameterView = 1;
                    [self.navigationController pushViewController:collectVc animated:YES];
                }
                else{
                    [SVProgressHUD showInfoWithStatus:@"还没有选择过相关科目"];
                }
            }
            //我的错题
            else if (indexPath.row == 6){
                if ([_tyUser objectForKey:tyUserSubject]) {
                    MyCollectViewController *collectVc = [Scommon instantiateViewControllerWithIdentifier:@"MyCollectViewController"];
                    collectVc.parameterView = 2;
                    [self.navigationController pushViewController:collectVc animated:YES];
                }
                else{
                    [SVProgressHUD showInfoWithStatus:@"还没有选择过相关科目"];
                }

            }
            //我的笔记
            else if (indexPath.row == 7){
                if ([_tyUser objectForKey:tyUserSubject]) {
                    MyCollectViewController *collectVc = [Scommon instantiateViewControllerWithIdentifier:@"MyCollectViewController"];
                    collectVc.parameterView = 3;
                    [self.navigationController pushViewController:collectVc animated:YES];
                }
                else{
                    [SVProgressHUD showInfoWithStatus:@"还没有选择过相关科目"];
                }

            }
        }
        else{
            [SVProgressHUD showInfoWithStatus:@"登录超时或未登录"];
            UIStoryboard *sCommon = CustomStoryboard(@"TyCommon");
            LoginViewController *loginVc =  [sCommon instantiateViewControllerWithIdentifier:@"LoginViewController"];
            loginVc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:loginVc animated:YES];
        }
    }
}

///用户退出登录
//- (void)logOutUser{
//    [SVProgressHUD show];
//    NSUserDefaults *tyUser = [NSUserDefaults standardUserDefaults];
//    NSDictionary *dicUser = [tyUser objectForKey:tyUserUser];
//    ///logout/json
//    NSString *urlString = [NSString stringWithFormat:@"%@logout/json?SHAREJSESSIONID=%@",systemHttpsTyUser,dicUser[@"jeeId"]];
//    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
//        NSDictionary *dicOut = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
//        NSInteger codeId = [dicOut[@"code"] integerValue];
//        if (codeId == 1) {
//            [SVProgressHUD showSuccessWithStatus:@"退出成功！"];
//            //            [_tyUser removeObjectForKey:tyUserUser];
//        }
//        else{
//            [SVProgressHUD showInfoWithStatus:@"操作失败！"];
//        }
//        NSLog(@"%@",dicOut);
//    } RequestFaile:^(NSError *error) {
//        [SVProgressHUD showInfoWithStatus:@"操作失败！"];
//    }];
//}

/////获取用户信息
- (void)getUserInfo{
//    [SVProgressHUD show];
    NSUserDefaults *tyUser = [NSUserDefaults standardUserDefaults];
    NSDictionary *dicUser = [tyUser objectForKey:tyUserUser];
    NSString *urlString = [NSString stringWithFormat:@"%@front/user/finduserinfo;JSESSIONID=%@",systemHttpsTyUser,dicUser[@"jeeId"]];
    NSLog(@"%@",urlString);
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicUserInfo = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        if (dicUserInfo != nil) {
            _tableHeardView.labUserName.text = dicUserInfo[@"userName"];
//            [self getUserImage];
        }
        else{
            [SVProgressHUD showInfoWithStatus:@"登录超时或未登录"];
            _tableHeardView.labUserName.text = @"未登录";
//？？        [_tyUser removeObjectForKey:tyUserAccessToken];
//            [_tyUser removeObjectForKey:tyUserClass];
//            [_tyUser removeObjectForKey:tyUserSelectSubject];
//            [_tyUser removeObjectForKey:tyUserSubject];
            [_tyUser removeObjectForKey:tyUserUser];
        }
//        [SVProgressHUD dismiss];
    } RequestFaile:^(NSError *error) {
        [SVProgressHUD showInfoWithStatus:@"异常！"];
    }];
    NSLog(@"%@",dicUser);
}
///获取用户头像
- (void)getUserImage{
    NSUserDefaults *tyUser = [NSUserDefaults standardUserDefaults];
    NSDictionary *dicUser = [tyUser objectForKey:tyUserUser];
    NSLog(@"%@",dicUser);
    NSString *urlString = [NSString stringWithFormat:@"%@front/user/findheadimg;JSESSIONID=%@&userId=%@&formSystem=902",systemHttpsTyUser,dicUser[@"jeeId"],dicUser[@"userId"]];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSString *string = [[NSString alloc]initWithData:repoes encoding:NSUTF8StringEncoding];
        NSLog(@"%@",string);
        if (string.length > 50) {
            [self performSegueWithIdentifier:@"login" sender:nil];
        }
    } RequestFaile:^(NSError *error) {

    }];
}
//////////////////专业科目信息//////////////////
//数据请求，获取专业信息
- (void)getSubjectClass{
    [SVProgressHUD show];
    [_arraySubject removeAllObjects];
    [_arraySecoundSubject removeAllObjects];
    [HttpTools getHttpRequestURL:[NSString stringWithFormat:@"%@api/Classify/GetAll",systemHttps] RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        
        NSDictionary *dicSubject =[NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        
        NSArray *arrayDatas = dicSubject[@"datas"];
        
        for (NSDictionary *dicArr in arrayDatas) {
            NSInteger ParentId = [dicArr[@"ParentId"] integerValue];
            if (ParentId==0) {
                [_arraySubject addObject:dicArr];
            }
            else{
                [_arraySecoundSubject addObject:dicArr];
            }
        }
        [self performSegueWithIdentifier:@"selectSubject" sender:nil];
        [SVProgressHUD dismiss];
        
    } RequestFaile:^(NSError *error) {
        [SVProgressHUD showInfoWithStatus:@"网络异常"];
        [_arraySubject removeAllObjects];
        [_arraySecoundSubject removeAllObjects];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    //选择科目
    if ([segue.identifier isEqualToString:@"selectSubject"]){
        SelectSubjectViewController *selectSubVc = segue.destinationViewController;
        selectSubVc.arraySubject = _arraySubject;
        selectSubVc.arraySecoundSubject = _arraySecoundSubject;
        selectSubVc.selectSubject = 0;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
