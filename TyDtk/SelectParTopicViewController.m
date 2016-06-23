//
//  SelectParTopicViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/6/18.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "SelectParTopicViewController.h"
#import "StartDoTopicViewController.h"
@interface SelectParTopicViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *labName;
@property (nonatomic,strong) NSUserDefaults *tyUser;
@property (nonatomic,strong) NSString *accessToken;
@property (nonatomic,strong) UITableView *tableViewSelect;
///折叠数组
@property (nonatomic,strong) NSMutableArray *arraySectionSelect;
//每段显示的段头字符数组
@property (nonatomic,strong) NSArray *arraySecitonHeader;
//显示的数组数组
@property (nonatomic,strong) NSDictionary *dicData;
//练习模式
@property (nonatomic,strong) NSString *topicModel;
//练习类型
@property (nonatomic,strong) NSString *topicType;
//试题年份
@property (nonatomic,strong) NSString *topicYear;
//试题数量
@property (nonatomic,strong) NSString *topicCount;
////////////////////
////////////////////
////////////////////
////试题模式参数
//@property (nonatomic,strong) NSArray *arrayTopicModePa;
//开始做题时需要传递的章节信息参数字典
@property (nonatomic,strong) NSMutableDictionary *dicTopicParameter;
//////////???????????????????????????????????????????????
//////////???????????????????????????????????????????????
///年份数组
@property (nonatomic,strong) NSMutableArray *arrayYear;
///题干类型数组
@property (nonatomic,strong) NSMutableArray *arrayType;
///试题数量数组
@property (nonatomic,strong) NSMutableArray *arrayCount;
///试题模式数组
@property (nonatomic,strong) NSArray *arrayModel;
//////////???????????????????????????????????????????????
//////////???????????????????????????????????????????????
@end

@implementation SelectParTopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tyUser = [NSUserDefaults standardUserDefaults];
    _accessToken = [_tyUser objectForKey:tyUserAccessToken];
    self.title = @"章节练习";
    [self viewLoad];
}
- (void)viewDidAppear:(BOOL)animated{
    self.navigationController.tabBarController.tabBar.hidden = NO;
}
- (void)viewLoad{
     _arraySectionSelect = [NSMutableArray array];
    _dicTopicParameter = [NSMutableDictionary dictionary];
    _tableViewSelect = [[UITableView alloc]initWithFrame:CGRectMake(0, 64+50, Scr_Width, Scr_Height - 64 - 50 - 49) style:UITableViewStylePlain];
    _tableViewSelect.backgroundColor = [UIColor whiteColor];
    _tableViewSelect.showsVerticalScrollIndicator = NO;
    _tableViewSelect.delegate = self;
    _tableViewSelect.dataSource = self;
    [self.view addSubview:_tableViewSelect];
    _arraySecitonHeader = @[@"练习模式>>",@"试题类型>>",@"试题年份>>",@"试题数量>>"];
//    _dicData = @{@"0":@"未做试题,已做试题,错误试题",@"1":@"全部,单项选择题,多项选择题",@"2":@"全部,2016年,2015年,2014年",@"3":@"5,10,15,20,30"};
    _topicModel = @"未做试题";
    _topicType = @"全部";
    _topicYear = @"全部";
    _topicCount = @"5";
    [_dicTopicParameter setObject:[NSString stringWithFormat:@"%ld",_chaperId] forKey:@"id"];
    [_dicTopicParameter setObject:@"0" forKey:@"model"];
    [_dicTopicParameter setObject:@"0" forKey:@"type"];
    [_dicTopicParameter setObject:@"0" forKey:@"year"];
    [_dicTopicParameter setObject:@"5" forKey:@"count"];
    _labName.textColor = ColorWithRGB(70, 130, 255);
    _labName.textColor = [UIColor blackColor];
    _labName.adjustsFontSizeToFitWidth = YES;
    NSString *titleString = [NSString stringWithFormat:@"%@ (练习)",_chaperName];
    NSMutableAttributedString *attriTitle = [[NSMutableAttributedString alloc]initWithString:titleString];
    [attriTitle addAttribute:NSForegroundColorAttributeName value:ColorWithRGB(70, 130, 255)
                       range:NSMakeRange(titleString.length - 4,4)];
    [_labName setAttributedText:attriTitle];
    [self addFooterViewForTableView];
    ////////////////////////////////
    _arrayModel = @[@{@"Value":@"0",@"Text":@"未做试题"},@{@"Value":@"1",@"Text":@"已做试题"},@{@"Value":@"2",@"Text":@"做错试题"}];
    [self getChaperTopicYear];
//    [self getChaperTopicType];
//    [self getChaperTopicCount];
}

/**
 获取试卷年份枚举
 */
- (void)getChaperTopicYear{
    _arrayYear = [NSMutableArray array];
    [_arrayYear removeAllObjects];
    NSString *urlString = [NSString stringWithFormat:@"%@api/Paper/GetPaperYear",systemHttps];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicYear = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        if ([dicYear[@"code"] integerValue] == 1) {
            NSDictionary *dicYearAll = @{@"Value":@"0",@"Text":@"全部"};
            [_arrayYear addObject:dicYearAll];
            NSArray *arrayYear = dicYear[@"datas"];
            for (NSDictionary *dicY in arrayYear) {
                [_arrayYear addObject:dicY];
            }
            [self getChaperTopicType];
        }
    } RequestFaile:^(NSError *error) {
        
    }];
}
/**
 获取试题题干类型枚举
 */
- (void)getChaperTopicType{
    [_arrayType removeAllObjects];
    _arrayType = [NSMutableArray array];
    NSString *urlString = [NSString stringWithFormat:@"%@api/CaptionType/GetCaptionTypes?access_token=%@",systemHttps,_accessToken];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicType = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        if ([dicType[@"code"] integerValue] == 1) {
            NSDictionary *dicAllType = @{@"Id":@"0",@"Names":@"全部"};
            NSArray *arrayType = dicType[@"datas"];
            [_arrayType addObject:dicAllType];
            for (NSDictionary *dicT in arrayType) {
                [_arrayType addObject:dicT];
            }
        }
        NSLog(@"%@",_arrayType);
        NSLog(@"%@",dicType);
        [self getChaperTopicCount];
    } RequestFaile:^(NSError *error) {
        
    }];
}
/**
获取试题题数枚举
*/
- (void)getChaperTopicCount{
    [SVProgressHUD show];
    [_arrayCount removeAllObjects];
    _arrayCount = [NSMutableArray array];
    NSString *urlString = [NSString stringWithFormat:@"%@api/Chapter/GetQuestionQuantityListItem?access_token=%@",systemHttps,_accessToken];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicTopicCount = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        if ([dicTopicCount[@"code"] integerValue] == 1) {
            NSArray *arrayCount = dicTopicCount[@"datas"];
            _arrayCount = [NSMutableArray arrayWithArray:arrayCount];
            /////在此加载tableView（首次）//进度。。。06_18
            
        }
        [SVProgressHUD dismiss];
        [_tableViewSelect reloadData];
    } RequestFaile:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}
///添加未试图
- (void)addFooterViewForTableView{
    UIView *viewFooter = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 235 + 66)];
    viewFooter.backgroundColor = [UIColor whiteColor];
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(20, 20, Scr_Width - 40, 160)];
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 3;
    view.layer.borderColor = [[UIColor orangeColor] CGColor];
    view.layer.borderWidth = 1;
    [viewFooter addSubview:view];
    UILabel *labAlert = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 100, 20)];
    labAlert.text = @"温馨提示：";
    labAlert.font =[UIFont systemFontOfSize:15.0];
    labAlert.textColor = [UIColor orangeColor];
    [view addSubview:labAlert];
    
    UILabel *labAlert1 = [[UILabel alloc]initWithFrame:CGRectMake(15, 35, view.bounds.size.width - 25, 30)];
    labAlert1.font = [UIFont systemFontOfSize:12.5];
    labAlert1.textColor = [UIColor lightGrayColor];
    labAlert1.numberOfLines = 0;
    labAlert1.text = @"1、未作试题：筛选本章节下未作的试题并且纠错次数小于5次的试题";
    [view addSubview:labAlert1];
    
    UILabel *labAlert2 =[[UILabel alloc]initWithFrame:CGRectMake(15, 75, view.bounds.size.width - 25, 30)];
    labAlert2.font = [UIFont systemFontOfSize:12.5];
    labAlert2.textColor = [UIColor lightGrayColor];
    labAlert2.numberOfLines = 0;
    labAlert2.text = @"2、已做试题：复习本章节下已经做过了的试题，复习时会清除掉上一次练习的答案记录";
    [view addSubview:labAlert2];
    
    UILabel *labAlert3 =[[UILabel alloc]initWithFrame:CGRectMake(15, 115, view.bounds.size.width - 25, 30)];
    labAlert3.font = [UIFont systemFontOfSize:12.5];
    labAlert3.textColor = [UIColor lightGrayColor];
    labAlert3.numberOfLines = 0;
    labAlert3.text = @"3、错误试题：复习本章将下做错了的试题，复习时会清除掉上一次练习的答案记录";
    [view addSubview:labAlert3];
    
    UIButton *btnTopic = [UIButton buttonWithType:UIButtonTypeCustom];
    btnTopic.frame = CGRectMake(20, view.frame.origin.y+view.frame.size.height + 30, Scr_Width - 40, 35);
    btnTopic.backgroundColor = ColorWithRGB(70, 130, 255);
    btnTopic.layer.masksToBounds = YES;
    btnTopic.layer.cornerRadius = 3;
    [btnTopic setTitle:@"开始做题" forState:UIControlStateNormal];
    [btnTopic addTarget:self action:@selector(buttonTopicClick:) forControlEvents:UIControlEventTouchUpInside];
    [viewFooter addSubview:btnTopic];
    _tableViewSelect.tableFooterView = viewFooter;
}
///开始做题
- (void)buttonTopicClick:(UIButton *)button{
    [self getChaperPaperTopicRid];
}
/**
 获取章节练习rid
 */
- (void)getChaperPaperTopicRid{
    NSString *urlString = [NSString stringWithFormat:@"%@api/Chapter/MakePractice?access_token=%@&chapterId=%@&captionType=%@&filter=%@&top=%@&year=%@",systemHttps,_accessToken,_dicTopicParameter[@"id"],_dicTopicParameter[@"type"],_dicTopicParameter[@"model"],_dicTopicParameter[@"count"],_dicTopicParameter[@"year"]];
    [HttpTools postHttpRequestURL:urlString RequestPram:nil RequestSuccess:^(id respoes) {
        NSDictionary *dicChaper = (NSDictionary *)respoes;
        if ([dicChaper[@"code"] integerValue] == 1) {
            NSDictionary *dicDatas = dicChaper[@"datas"];
            if (dicDatas!=nil) {
                [SVProgressHUD showSuccessWithStatus:dicDatas[@"msg"]];
                ///获取 Storyboard 上做题页面
                UIStoryboard *sCommon = CustomStoryboard(@"Common");
                StartDoTopicViewController *topicVc = [sCommon instantiateViewControllerWithIdentifier:@"StartDoTopicViewController"];
                topicVc.rIdString = dicDatas[@"rid"];
                topicVc.paperParameter = 1;
                [self.navigationController pushViewController:topicVc animated:YES];
            }
            else{
                [SVProgressHUD showInfoWithStatus:@"没有更多试题了，换个参数试试看~"];
            }
        }
        NSLog(@"%@",dicChaper);
    } RequestFaile:^(NSError *erro) {
        
    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSString *str = [NSString stringWithFormat:@"%ld",section];
    if ([_arraySectionSelect containsObject:str]) {
        if (section == 0) {
            return _arrayModel.count;
        }
        else if (section == 1){
            return _arrayType.count;
        }
        else if (section == 2){
            return _arrayYear.count;
        }
        else{
            return _arrayCount.count;
        }
    }
    else{
        return 0;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 35;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 1)];
    if (section != 3) {
        view.backgroundColor = [UIColor lightGrayColor];
    }
    else{
        view.backgroundColor = [UIColor whiteColor];
    }
    
    return view;
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 40)];
    view.backgroundColor = ColorWithRGB(211, 186, 155);
    if (section == 0) {
        UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 1)];
        viewLine.backgroundColor = [UIColor lightGrayColor];
        [view addSubview:viewLine];
    }
    UILabel *labTitle = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, 100, 20)];
    labTitle.font = [UIFont systemFontOfSize:16.0];
    labTitle.text = _arraySecitonHeader[section];
    [view addSubview:labTitle];
    
    UILabel *labValue = [[UILabel alloc]initWithFrame:CGRectMake(Scr_Width - 123 - 10, 5, 123, 30)];
    if (section == 0) {
        labValue.text =[NSString stringWithFormat:@"(%@)", _topicModel];
    }
    else if (section == 1){
        labValue.text = [NSString stringWithFormat:@"(%@)", _topicType];;
    }
    else if (section == 2){
        labValue.text = [NSString stringWithFormat:@"(%@)", _topicYear];;
    }
    else if (section == 3){
        labValue.text = [NSString stringWithFormat:@"(%@)", _topicCount];;
    }
    labValue.font = [UIFont systemFontOfSize:18.0];
    labValue.textColor = ColorWithRGB(70, 130, 255);
    labValue.textAlignment = NSTextAlignmentRight;
    [view addSubview:labValue];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, Scr_Width, 40);
    btn.backgroundColor = [UIColor clearColor];
    btn.tag = 100 + section;
    [btn addTarget:self action:@selector(sectionbtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
    return view;
}
- (void)sectionbtnClick:(UIButton *)button{
    NSInteger sectoinId = button.tag - 100;
    NSString *str = [NSString stringWithFormat:@"%ld",sectoinId];
    if ([_arraySectionSelect containsObject:str]) {
        [_arraySectionSelect removeObject:str];
    }
    else{
        [_arraySectionSelect addObject:str];
    }
    
//    [_tableViewSelect reloadSections:[NSIndexSet indexSetWithIndex:sectoinId] withRowAnimation:UITableViewRowAnimationFade];
    [_tableViewSelect reloadData];

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    for (id subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    cell.backgroundColor = [UIColor whiteColor];
//    NSString *secString = [NSString stringWithFormat:@"%ld",indexPath.section];
//    NSString *arrayString = [_dicData objectForKey:secString];
//    NSArray *array = [arrayString componentsSeparatedByString:@","];
    NSDictionary *dicCurr = [[NSDictionary alloc]init];
    if (indexPath.section == 0) {
        dicCurr = _arrayModel[indexPath.row];
    }
    else if (indexPath.section == 1){
        dicCurr = _arrayType[indexPath.row];
    }
    else if (indexPath.section == 2){
        dicCurr = _arrayYear[indexPath.row];
    }
    else if (indexPath.section == 3){
        dicCurr = _arrayCount[indexPath.row];
    }
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(30, (35-20)/2, 100, 20)];
    lab.text = dicCurr[@"Text"];
    if (indexPath.section == 1) {
        lab.text = dicCurr[@"Names"];
    }
    lab.textColor = [UIColor brownColor];
    lab.tag = 10;
    lab.font = [UIFont systemFontOfSize:15.0];
    [cell.contentView addSubview:lab];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UILabel *labText = (UILabel *)[cell.contentView viewWithTag:10];
    NSDictionary *dicCurr = [[NSDictionary alloc]init];
    if (indexPath.section == 0) {
        dicCurr = _arrayModel[indexPath.row];
        [_dicTopicParameter setObject:dicCurr[@"Value"] forKey:@"model"];
         _topicModel = labText.text;
    }
    else if (indexPath.section == 1){
        dicCurr = _arrayType[indexPath.row];
        [_dicTopicParameter setObject:[NSString stringWithFormat:@"%ld",[dicCurr[@"Id"] integerValue]] forKey:@"type"];
        _topicType = labText.text;
    }
    else if (indexPath.section == 2){
        dicCurr = _arrayYear[indexPath.row];
        [_dicTopicParameter setObject:dicCurr[@"Value"] forKey:@"year"];
        _topicYear = labText.text;
    }
    else if (indexPath.section == 3){
        dicCurr = _arrayCount[indexPath.row];
        [_dicTopicParameter setObject:dicCurr[@"Value"] forKey:@"count"];
        _topicCount = labText.text;
    }
    NSString *str = [NSString stringWithFormat:@"%ld",indexPath.section];
    [_arraySectionSelect removeObject:str];
    NSLog(@"%@",_dicTopicParameter);
    
    [_tableViewSelect reloadData];
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
