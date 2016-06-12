//
//  PracticeCenterViewController.m
//  TyDtk
//  练习中心
//  Created by 天一文化 on 16/5/26.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "PracticeCenterViewController.h"
#import "ChaptersViewController.h"
#import "ModelPapersViewController.h"
#import "WeekSelectViewController.h"
#import "IntelligentTopicViewController.h"
#import "ExerciseRecordViewController.h"
#import "MyCollectViewController.h"
@interface PracticeCenterViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableViewCenter;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewBg;

@property (nonatomic,strong) NSUserDefaults *tyUser;
@property (nonatomic,strong) NSDictionary *dicSelectSubject;
@property (nonatomic,strong) NSArray *arrayList;
@property (nonatomic,strong) NSArray *arrayListSelf;
@end

@implementation PracticeCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tyUser =[NSUserDefaults standardUserDefaults];
    _arrayList = @[@"章节练习",@"模拟试卷",@"每周精选",@"智能出题"];
    _arrayListSelf = @[@"做题记录",@"我的收藏",@"我的错题"];
    _tableViewCenter.backgroundColor = [UIColor clearColor];
    _tableViewCenter.separatorStyle = UITableViewCellSeparatorStyleNone;
    _imageViewBg.image = systemBackGrdImg;
}
- (void)viewWillAppear:(BOOL)animated{
    [self addTableHeardView];
}
///添加头试图，用于显示用户最近一次所选的科目
- (void)addTableHeardView{
    UIView *heardView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 60)];
    heardView.backgroundColor = [UIColor clearColor];
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(20, 10, Scr_Width - 40, 50)];
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 5;
    view.backgroundColor = [UIColor clearColor];
    
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 70, 30)];
    lab.font = [UIFont systemFontOfSize:15.0];
    lab.textColor = [UIColor orangeColor];
    lab.text = @"当前科目:";
    //显示科目名字
    UILabel *labSubject =[[UILabel alloc]initWithFrame:CGRectMake(70, 10,Scr_Width - 40 - 70 , 30)];
    labSubject.adjustsFontSizeToFitWidth = YES;
    labSubject.font = [UIFont systemFontOfSize:17.0];
    labSubject.textColor = [UIColor purpleColor];
    if ([_tyUser objectForKey:tyUserSelectSubject]) {
        _dicSelectSubject = [_tyUser objectForKey:tyUserSelectSubject];
        labSubject.text = _dicSelectSubject[@"Names"];
    }
    else{
        labSubject.text = @"您还没有选过任何科目";
        labSubject.textColor = [UIColor redColor];
    }
    [view addSubview:labSubject];
    [view addSubview:lab];
    [heardView addSubview:view];
    _tableViewCenter.tableHeaderView = heardView;
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
    if (section == 0) {
        return 40;
    }
    return 30;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 30)];
    view.backgroundColor = [UIColor clearColor];
    UILabel *labTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 30)];
    labTitle.font = [UIFont systemFontOfSize:18.0];
    labTitle.textAlignment = NSTextAlignmentCenter;
    labTitle.textColor = [UIColor orangeColor];
    labTitle.backgroundColor = [UIColor clearColor];
    if (section == 0) {
        labTitle.text = @"<模块练习>";
        view.frame = CGRectMake(0, 0, Scr_Width, 40);
        labTitle.frame = CGRectMake(0, 10, Scr_Width , 30);
    }
    else{
        labTitle.text = @"<我的练习>";
    }
    [view addSubview:labTitle];
    return view;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = 5;
    UILabel *labText = (UILabel *)[cell.contentView viewWithTag:10];
    labText.layer.masksToBounds = YES;
    labText.layer.cornerRadius = 5;
//    labText.backgroundColor = ColorWithRGB(190, 200, 252);
//    labText.textColor = ColorWithRGB(90, 144, 266);
    if (indexPath.section == 0) {
        labText.text = _arrayList[indexPath.row];
    }
    else{
        labText.text = _arrayListSelf[indexPath.row];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ([_tyUser objectForKey:tyUserSelectSubject]&&[_tyUser objectForKey:tyUserUser]) {
        if (indexPath.section == 0) {
            //章节练习
            if (indexPath.row == 0) {
                [self performSegueWithIdentifier:@"chapters" sender:nil];
                NSLog(@"章节练习");
            }
            //模拟试卷
            else if (indexPath.row == 1){
                [self performSegueWithIdentifier:@"modelPaper" sender:nil];
                 NSLog(@"模拟试卷");
            }
            //每周精选
            else if (indexPath.row == 2){
                [self performSegueWithIdentifier:@"weekSelect" sender:nil];
                 NSLog(@"每周精选");
            }
            //智能做题
            else if (indexPath.row == 3){
            [self performSegueWithIdentifier:@"intelligent" sender:nil];
                 NSLog(@"智能做题");
            }
        }
        else{
            //做题记录
            if (indexPath.row == 0) {
//                if ([_tyUser objectForKey:tyUserClass]) {
//                    [self performSegueWithIdentifier:@"topicR" sender:nil];
//                }
//                else{
//                    [SVProgressHUD showInfoWithStatus:@"还没有选择相关专业"];
//                }
                [self performSegueWithIdentifier:@"Exercise" sender:nil];
                 NSLog(@"做题记录");
            }
            //我的收藏
            else if (indexPath.row == 1){
                 NSLog(@"我的收藏");
                [self performSegueWithIdentifier:@"collect" sender:@"1"];
            }
            //我的错题
            else if (indexPath.row == 2){
                 NSLog(@"我的错题");
                [self performSegueWithIdentifier:@"collect" sender:@"2"];
            }
        }
    }
    else{
        [SVProgressHUD showInfoWithStatus:@"您还没有登录或未选过科目~"];
        self.tabBarController.selectedIndex = 0;
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"intelligent"]) {
        IntelligentTopicViewController *intellVc = segue.destinationViewController;
        intellVc.dicSubject = _dicSelectSubject;
    }
    else if ([segue.identifier isEqualToString:@"weekSelect"]){
        WeekSelectViewController *weekVc = segue.destinationViewController;
        weekVc.subjectId = [NSString stringWithFormat:@"%ld",[_dicSelectSubject[@"Id"] integerValue]];
        weekVc.allowToken = YES;
        weekVc.title = @"每周精选";
    }
    else if ([segue.identifier isEqualToString:@"modelPaper"]){
        ModelPapersViewController *modelPaVc = segue.destinationViewController;
        modelPaVc.subjectId = [NSString stringWithFormat:@"%ld",[_dicSelectSubject[@"Id"] integerValue]];
        modelPaVc.allowToken = YES;
        modelPaVc.intPushWhere = 1;
        modelPaVc.title = @"模拟试卷";
    }
    else if ([segue.identifier isEqualToString:@"chapters"]){
        ChaptersViewController *chapVc = segue.destinationViewController;
        chapVc.subjectId = [NSString stringWithFormat:@"%ld",[_dicSelectSubject[@"Id"] integerValue]];
        chapVc.title = @"章节练习";
    }
    else if ([segue.identifier isEqualToString:@"Exercise"]){
//        ExerciseRecordViewController *exerVc = segue.destinationViewController;
        
    }
    else if ([segue.identifier isEqualToString:@"collect"]){
        MyCollectViewController *Vc = segue.destinationViewController;
        Vc.parameterView = [sender integerValue];
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
