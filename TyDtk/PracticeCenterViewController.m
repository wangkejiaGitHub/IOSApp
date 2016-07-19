//
//  PracticeCenterViewController.m
//  TyDtk
//  练习中心
//  Created by 天一文化 on 16/5/26.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

///
#import "PracticeCenterViewController.h"
///章节练习
#import "ChaptersViewController.h"
///模拟试卷
#import "ModelPapersViewController.h"
///每周精选
#import "WeekSelectViewController.h"
///智能做题
#import "IntelligentTopicViewController.h"
///练习记录
#import "ExerciseRecordViewController.h"
///我的收藏
#import "MyCollectViewController.h"
///我的笔记
#import "MyNoteViewController.h"
///科目选择
#import "SelectSubjectViewController.h"
///登录
#import "LoginViewController.h"
@interface PracticeCenterViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableViewCenter;
@property (nonatomic,strong) NSUserDefaults *tyUser;
@property (nonatomic,strong) NSDictionary *dicSelectSubject;
@property (nonatomic,strong) NSArray *arrayList;
@property (nonatomic,strong) NSArray *arrayListSelf;
@property (nonatomic,strong) NSArray *arrayImg;
@property (nonatomic,strong) NSArray *arrayImgSelf;
//////
//所有专业分类
@property (nonatomic,strong) NSMutableArray *arraySubject;
//所有专业
@property (nonatomic,strong) NSMutableArray *arraySecoundSubject;
@end

@implementation PracticeCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /////专业分类科目信息
    _arraySubject = [NSMutableArray array];
    _arraySecoundSubject = [NSMutableArray array];
    _tyUser =[NSUserDefaults standardUserDefaults];
    _arrayList = @[@"章节练习",@"模拟试卷",@"每周精选",@"智能出题"];
    _arrayListSelf = @[@"做题记录",@"我的收藏",@"我的错题",@"我的笔记"];
    _arrayImg = @[@"chapter",@"paper",@"weeksift",@"quest"];
    _arrayImgSelf = @[@"learnrecord",@"collect",@"errquests",@"ebook"];
    _tableViewCenter.backgroundColor = [UIColor clearColor];
    //    _tableViewCenter.separatorStyle = UITableViewCellSeparatorStyleNone;
}
- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.tabBarController.tabBar.hidden = NO;
    [self addTableHeardView];
}
- (void)viewDidAppear:(BOOL)animated{
}
///添加头试图，用于显示用户最近一次所选的科目
- (void)addTableHeardView{
    UIView *heardView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 60)];
    heardView.backgroundColor = [UIColor whiteColor];
    //    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(20, 10, Scr_Width - 40, 50)];
    //    view.layer.masksToBounds = YES;
    //    view.layer.cornerRadius = 5;
    //    view.backgroundColor = [UIColor clearColor];
    
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(10, 15, 70, 30)];
    lab.font = [UIFont systemFontOfSize:15.0];
    lab.textColor = [UIColor orangeColor];
    lab.text = @"当前科目:";
    //显示科目名字
    UILabel *labSubject =[[UILabel alloc]initWithFrame:CGRectMake(80, 15,Scr_Width - 80-10 , 30)];
    labSubject.adjustsFontSizeToFitWidth = YES;
    labSubject.font = [UIFont systemFontOfSize:17.0];
    labSubject.textColor = ColorWithRGB(55, 155, 255);
    labSubject.userInteractionEnabled = YES;
    if ([_tyUser objectForKey:tyUserSelectSubject]) {
        _dicSelectSubject = [_tyUser objectForKey:tyUserSelectSubject];
        labSubject.text = _dicSelectSubject[@"Names"];
    }
    else{
        labSubject.text = @"未选择科目";
        labSubject.textColor = [UIColor redColor];
    }
    [heardView addSubview:lab];
    [heardView addSubview:labSubject];
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestAClick)];
    [labSubject addGestureRecognizer:tapGest];
    _tableViewCenter.tableHeaderView = heardView;
}
///科目选择，跳到科目选择页面
- (void)tapGestAClick{
    if (_arraySubject.count >0 && _arraySecoundSubject.count > 0) {
        [self goSelectSubjectView];
    }
    else{
        [self getSubjectClass];
    }
}
- (void)goSelectSubjectView{
    UIStoryboard *sUser = CustomStoryboard(@"TyUserIn");
    SelectSubjectViewController *subjectVc = [sUser instantiateViewControllerWithIdentifier:@"SelectSubjectViewController"];
    subjectVc.arraySubject = _arraySubject;
    subjectVc.arraySecoundSubject = _arraySecoundSubject;
    subjectVc.selectSubject = 0;
    [self.navigationController pushViewController:subjectVc animated:YES];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return _arrayList.count;
    }
    return _arrayListSelf.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 40)];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel *labTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, Scr_Width - 30, 30)];
    labTitle.font = [UIFont systemFontOfSize:18.0];
    //    labTitle.textAlignment = NSTextAlignmentCenter;
    labTitle.textColor = ColorWithRGB(55, 155, 255);
    labTitle.backgroundColor = [UIColor clearColor];
    if (section == 0) {
        UIView *viewL = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 1)];
        viewL.backgroundColor = ColorWithRGB(200, 200, 200);
        [view addSubview:viewL];
        labTitle.text = @"题库模块";
    }
    else{
        labTitle.text = @"个人中心";
    }
    [view addSubview:labTitle];
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *viewFooter = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 1)];
    viewFooter.backgroundColor = [UIColor groupTableViewBackgroundColor];
    return viewFooter;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    UIImageView *img = (UIImageView *)[cell.contentView viewWithTag:10];
    UILabel *labTitle = (UILabel *)[cell.contentView viewWithTag:11];
    if (indexPath.section == 0) {
        img.image = [UIImage imageNamed:_arrayImg[indexPath.row]];
        labTitle.text = _arrayList[indexPath.row];
    }
    else{
        img.image = [UIImage imageNamed:_arrayImgSelf[indexPath.row]];
        labTitle.text = _arrayListSelf[indexPath.row];
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([_tyUser objectForKey:tyUserSelectSubject]) {
        UIStoryboard *sCommon = CustomStoryboard(@"TyCommon");
        if (indexPath.section == 0) {
            //章节练习
            if (indexPath.row == 0) {
                ChaptersViewController *chaperVc = [sCommon instantiateViewControllerWithIdentifier:@"ChaptersViewController"];
                chaperVc.intPushWhere = 1;
                chaperVc.subjectId = [NSString stringWithFormat:@"%ld",[_dicSelectSubject[@"Id"] integerValue]];
                chaperVc.dicSubject = [_tyUser objectForKey:tyUserSelectSubject];
                chaperVc.title = @"章节练习";
                [self.navigationController pushViewController:chaperVc animated:YES];
            }
            //模拟试卷
            else if (indexPath.row == 1){
                ModelPapersViewController *modelVc = [sCommon instantiateViewControllerWithIdentifier:@"ModelPapersViewController"];
                modelVc.subjectId = [NSString stringWithFormat:@"%ld",[_dicSelectSubject[@"Id"] integerValue]];
                modelVc.intPushWhere = 1;
                modelVc.dicSubject = [_tyUser objectForKey:tyUserSelectSubject];
                modelVc.title = @"模拟试卷";
                [self.navigationController pushViewController:modelVc animated:YES];
            }
            //每周精选
            else if (indexPath.row == 2){
                WeekSelectViewController *weekVc = [sCommon instantiateViewControllerWithIdentifier:@"WeekSelectViewController"];
                weekVc.subjectId = [NSString stringWithFormat:@"%ld",[_dicSelectSubject[@"Id"] integerValue]];
                weekVc.intPushWhere = 1;
                weekVc.title = @"每周精选";
                [self.navigationController pushViewController:weekVc animated:YES];
            }
            //智能做题
            else if (indexPath.row == 3){
                IntelligentTopicViewController *intellVc = [sCommon instantiateViewControllerWithIdentifier:@"IntelligentTopicViewController"];
                intellVc.intPushWhere = 1;
                intellVc.dicSubject = _dicSelectSubject;
                [self.navigationController pushViewController:intellVc animated:YES];
            }
        }
        else{
            ///判断是否登录
            if ([_tyUser objectForKey:tyUserUserInfo]) {
                //做题记录
                if (indexPath.row == 0) {
                    ExerciseRecordViewController *execVc = [sCommon instantiateViewControllerWithIdentifier:@"ExerciseRecordViewController"];
                    [self.navigationController pushViewController:execVc animated:YES];
                }
                //我的收藏
                else if (indexPath.row == 1){
                    MyCollectViewController *collectVc = [sCommon instantiateViewControllerWithIdentifier:@"MyCollectViewController"];
                    collectVc.parameterView = 1;
                    [self.navigationController pushViewController:collectVc animated:YES];
                }
                //我的错题
                else if (indexPath.row == 2){
                    MyCollectViewController *collectVc = [sCommon instantiateViewControllerWithIdentifier:@"MyCollectViewController"];
                    collectVc.parameterView = 2;
                    [self.navigationController pushViewController:collectVc animated:YES];
                }
                //我的笔记
                else if (indexPath.row == 3){
                    MyCollectViewController *collectVc = [sCommon instantiateViewControllerWithIdentifier:@"MyCollectViewController"];
                    collectVc.parameterView = 3;
                    [self.navigationController pushViewController:collectVc animated:YES];
                }
            }
            ///跳转到登录页面
            else{
                UIStoryboard *sCommon = CustomStoryboard(@"TyCommon");
                LoginViewController *loginVc = [sCommon instantiateViewControllerWithIdentifier:@"LoginViewController"];
                [self.navigationController pushViewController:loginVc animated:YES];
            }
        }
    }
    else{
        [SVProgressHUD showInfoWithStatus:@"您还未选过科目~"];
        self.tabBarController.selectedIndex = 0;
    }
}
//////////////////专业科目信息//////////////////
//数据请求，获取专业信息
- (void)getSubjectClass{
    [SVProgressHUD show];
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
        
        [self goSelectSubjectView];
        
        [SVProgressHUD dismiss];
        
    } RequestFaile:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"网络异常"];
        [_arraySubject removeAllObjects];
        [_arraySecoundSubject removeAllObjects];
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
