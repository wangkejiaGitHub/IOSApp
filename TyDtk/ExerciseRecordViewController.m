//
//  ExerciseRecordViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/6/2.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "ExerciseRecordViewController.h"
#import "StartDoTopicViewController.h"
#import "StartAnalysisTopicViewController.h"
#import "ExerciseTableViewCell.h"
#import "SelectParTopicViewController.h"

#import "DOPDropDownMenu.h"
@interface ExerciseRecordViewController ()<UITableViewDataSource,UITableViewDelegate,ExerciseDelegate,DOPDropDownMenuDataSource,DOPDropDownMenuDelegate>
@property (nonatomic, strong) UIScrollView *scrollViewHeard;
@property (weak, nonatomic) IBOutlet UITableView *tableViewRe;

@property (nonatomic,strong) NSUserDefaults *tyUser;
@property (nonatomic,strong) NSDictionary *dicSelectSubject;
///练习记录
@property (nonatomic,strong) NSMutableArray *arrayExRe;
@property (nonatomic,strong) NSString *accToken;
///最大页数
@property (nonatomic,assign) NSInteger pages;
//当前页
@property (nonatomic,assign) NSInteger pageCurr;
//做题模式
@property (nonatomic,assign) NSInteger topicModel;
//科目编号
@property (nonatomic,assign) NSInteger subjectId;
@property (nonatomic,assign) NSInteger topicModelCell;
//刷新控件
@property (nonatomic,strong) MJRefreshBackNormalFooter *refreshFooter;
@property (nonatomic,strong) MJRefreshNormalHeader *refreshHeader;
@property (nonatomic,strong) ViewNullData *viewDataNil;
//记录再次做题时获取的每周精选rid
@property (nonatomic,strong) NSString *ridAgainWeekTopic;
@property (nonatomic,assign) BOOL isContinueDoTopic;
@property (nonatomic,strong) NSMutableArray *arraySubject;
@property (nonatomic,strong) NSArray *arrayModelTopic;
@property (nonatomic,strong) DOPDropDownMenu *dropDownMenu;

@end

@implementation ExerciseRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _arrayExRe = [NSMutableArray array];
    _arraySubject = [NSMutableArray array];
    _tyUser = [NSUserDefaults standardUserDefaults];
    _accToken = [_tyUser objectForKey:tyUserAccessToken];
    _topicModel = 0;
    _subjectId = 0;
    
    _pageCurr = 1;
    _pages = 0;
    _arrayModelTopic = @[@"全部模块",@"章节练习",@"智能出题",@"每周精选",@"模拟试卷"];
    
    [self viewLoad];
}
- (void)viewLoad{
    NSDictionary *dicSubject = [_tyUser objectForKey:tyUserClass];
    NSInteger classId = [dicSubject[@"Id"] integerValue];
    [self getAllSubjectWithClass:classId];
//    _tableViewRe.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableViewRe.tableFooterView = [UIView new];
}
- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.tabBarController.tabBar.hidden = NO;
}
- (void)viewDidAppear:(BOOL)animated{
    //设置tableView的上拉控件
    _refreshFooter = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshClick:)];
    [_refreshFooter setTitle:@"上拉查看更多记录" forState:MJRefreshStateIdle];
    [_refreshFooter setTitle:@"松开加载更多记录" forState:MJRefreshStatePulling];
    [_refreshFooter setTitle:@"正在为您加载更多记录..." forState:MJRefreshStateRefreshing];
    [_refreshFooter setTitle:@"记录已全部加载完毕" forState:MJRefreshStateNoMoreData];
    _tableViewRe.mj_footer = _refreshFooter;
}
///添加table头试图
- (void)addRefreshHeaderForTableView{
    _refreshHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefereshClick:)];
    _tableViewRe.mj_header = _refreshHeader;
}
- (void)viewDidDisappear:(BOOL)animated{
    _refreshFooter = nil;
    _refreshHeader = nil;
}
- (void)footerRefreshClick:(MJRefreshBackNormalFooter *)reFresh{
    [self getExerciseRe];
}
- (void)headerRefereshClick:(MJRefreshNormalHeader *)reFresh{
    _pageCurr = 1;
    _pages = 0;
    [_arrayExRe removeAllObjects];
    [self getExerciseRe];
}
///获取当前专业下的所有科目
- (void)getAllSubjectWithClass:(NSInteger)classId{
    [SVProgressHUD show];
    NSString *urlString = [NSString stringWithFormat:@"%@api/CourseInfo/%ld",systemHttps,classId];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicSubject = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dicSubject[@"code"] integerValue];
        if (codeId == 1) {
            NSDictionary *dicAllSubject = @{@"Id":@"0",@"Names":@"当前科目"};
            [_arraySubject addObject:dicAllSubject];
            NSArray *arraySub= dicSubject[@"datas"];
            for (NSDictionary *dicSub in arraySub) {
                [_arraySubject addObject:dicSub];
            }
            [self getExerciseRe];
            [self addDropDownMenuForTableView];
        }
    } RequestFaile:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"网络异常"];
    }];
}
////////////////////////////////////////////////////
- (void)addDropDownMenuForTableView{
    if (!_dropDownMenu) {
        _dropDownMenu = [[DOPDropDownMenu alloc]initWithOrigin:CGPointMake(0, 64) andHeight:40];
        _dropDownMenu.indicatorColor = [UIColor orangeColor];
        _dropDownMenu.textColor = ColorWithRGB(53, 122, 255);
        _dropDownMenu.delegate = self;
        _dropDownMenu.dataSource = self;
        [self.view addSubview:_dropDownMenu];
    }
    
    [self addRefreshHeaderForTableView];
}
////////////////////////////////////////////////////

////////////////////////////////////////////////////
/////////////////////做题模式////////////////////////

/////////////////////科目选项////////////////////////

///获取练习记录数据
- (void)getExerciseRe{
    if (_pages != 0) {
        if (_pageCurr> _pages) {
            [_refreshFooter endRefreshingWithNoMoreData];
            return;
        }
    }
    [SVProgressHUD showWithStatus:@"正在加载做题记录..."];
    NSString *urlString = [NSString stringWithFormat:@"%@api/Practice/GetDoRecords?access_token=%@&mode=%ld&courseId=%ld&page=%ld&size=20",systemHttps,_accToken,_topicModel,_subjectId,_pageCurr];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicN = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dicN[@"code"] integerValue];
        if (codeId == 1) {
            //获取最大页数
            if (_pageCurr == 1) {
                [_arrayExRe removeAllObjects];
            }
            NSDictionary *dicPage =dicN[@"page"];
            _pages = [dicPage[@"pages"] integerValue];
            //当前页数增加1
            _pageCurr = _pageCurr+1; 
            //追加数据
            NSArray *arrayDatas =dicN[@"datas"];
            for (NSDictionary *dicP in arrayDatas) {
                [_arrayExRe addObject:dicP];
            }
            ///判断第一次加载时是否为空数据
            if (_arrayExRe.count == 0) {
                _viewDataNil = [[ViewNullData alloc]initWithFrame:CGRectMake(0, 40, Scr_Width, Scr_Height - 40 - 64- 49) showText:@"没有更多记录了，换个做题试试看~"];
                _tableViewRe.tableFooterView = _viewDataNil;
            }
            else{
                _tableViewRe.tableFooterView = [UIView new];
            }
            _tableViewRe.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            [_tableViewRe reloadData];
        }
        else{
            
        }
        [_refreshFooter endRefreshing];
        [_refreshHeader endRefreshing];
        [SVProgressHUD dismiss];
    } RequestFaile:^(NSError *error) {
        [_refreshFooter endRefreshing];
        [_refreshHeader endRefreshing];
        [SVProgressHUD showInfoWithStatus:@"网络异常"];
    }];
}
///删除记录，单个删除
- (void)deleteExercise:(NSIndexPath *)dicIndexPath{
    [SVProgressHUD show];
    NSString *urlString =[NSString stringWithFormat:@"%@api/Practice/Del?access_token=%@&rid=%@",systemHttps,_accToken,_dicSelectSubject[@"Rid"]];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicRe = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dicRe[@"code"] integerValue];
        if (codeId == 1) {

            //删除成功后重新获取记录，科目、做题模式不改变，初始页为1，清除记录数组
            _pageCurr = 1;
            [_arrayExRe removeAllObjects];
            [self getExerciseRe];
            NSDictionary *dicDatas = dicRe[@"datas"];
            [SVProgressHUD showSuccessWithStatus:dicDatas[@"msg"]];
        }
        else{
            [SVProgressHUD showInfoWithStatus:dicRe[@"errmsg"]];
        }
    } RequestFaile:^(NSError *error) {
        httpsErrorShow;
    }];
}
////////////////////////tableView代理
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrayExRe.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 140;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ExerciseTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"cell1" forIndexPath:indexPath];
    if (_arrayExRe.count > 0) {
        NSDictionary *dicRx = _arrayExRe[indexPath.row];
        cell.dicExercise = dicRx;
        cell.delegateExercise = self;
        [cell setCellModelValueWithDictionary:dicRx];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除记录";
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    LXAlertView *alert = [[LXAlertView alloc]initWithTitle:@"记录删除" message:@"确认删除该做题记录吗？" cancelBtnTitle:@"保留" otherBtnTitle:@"删除" clickIndexBlock:^(NSInteger clickIndex) {
        if (clickIndex == 1) {
            _dicSelectSubject = _arrayExRe[indexPath.row];
            [self deleteExercise:indexPath];
        }
        else{
            [_tableViewRe setEditing:NO animated:YES];
        }
    }];
    alert.animationStyle = LXASAnimationTopShake;
    [alert showLXAlertView];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _dicSelectSubject = _arrayExRe[indexPath.row];
}
/////////////////////////////////////////////////////////////
//////////////dropDownMenu 代理 /////////////////////////////
///返回下拉菜单个数
- (NSInteger)numberOfColumnsInMenu:(DOPDropDownMenu *)menu {
    return 2;
}
///返回每个下拉菜单的item
- (NSInteger)menu:(DOPDropDownMenu *)menu numberOfRowsInColumn:(NSInteger)column {
    if (column == 0) {
        return _arraySubject.count;
    }
    else{
        return _arrayModelTopic.count;
    }
}
///返回每个下拉菜单的值
- (NSString *)menu:(DOPDropDownMenu *)menu titleForRowAtIndexPath:(DOPIndexPath *)indexPath {
    NSDictionary *dic;
    switch (indexPath.column) {
        case 0:
            dic = _arraySubject[indexPath.row];
            return dic[@"Names"];
            break;
        case 1:
            return _arrayModelTopic[indexPath.row];
            break;
        default:
            return nil;
            break;
    }
}
///下拉菜单点击事件
- (void)menu:(DOPDropDownMenu *)menu didSelectRowAtIndexPath:(DOPIndexPath *)indexPath {
    NSDictionary *dicSelect;
    ///试卷类型
    if (indexPath.column == 0) {
        
        dicSelect = _arraySubject[indexPath.row];
        _subjectId = [dicSelect[@"Id"] integerValue];
        _pageCurr = 1;
        _pages = 0;
        [self getExerciseRe];
    }
    ///试卷年份
    else{
        _topicModel = indexPath.row;
        _pages = 0;
        _pageCurr = 1;
        [self getExerciseRe];
    }
}


//////////////dropDownMenu 代理 /////////////////////////////

///cell上的查看解析按钮回调
- (void)cellAnalysisWithDictionary:(NSDictionary *)dicModel{
    _topicModelCell = [dicModel[@"Mode"] integerValue];
    _dicSelectSubject = dicModel;
    if (_topicModelCell == 4) {
        [self getPaperInfoAnalysisUsePaperId];
    }
    else{
        [self performSegueWithIdentifier:@"topicAnalysis" sender:nil];
    }
}
///cell上的做题（继续做题或者再做一次）按钮回调
- (void)cellTopicWithDictionary:(NSDictionary *)dicModel parameterInt:(NSInteger)parameter{
    _topicModelCell = [dicModel[@"Mode"] integerValue];
    _dicSelectSubject = dicModel;
    //如果继续做题
    if (parameter == 0 | parameter == 2) {
        _isContinueDoTopic = YES;
         ///1章节练习 2智能出题 3每周精选 4试卷
        if (_topicModelCell == 1) {
            //章节练习继续做题，直接传rid
            [self performSegueWithIdentifier:@"startDoTopic" sender:_dicSelectSubject[@"Rid"]];
            
        }
        else if (_topicModelCell == 2){
            [self performSegueWithIdentifier:@"startDoTopic" sender:_dicSelectSubject[@"Rid"]];
        }
        else if (_topicModelCell == 3){
            //每周精选继续做题，直接传rid
            [self performSegueWithIdentifier:@"startDoTopic" sender:_dicSelectSubject[@"Rid"]];
        }
        else if (_topicModelCell == 4){
            //模拟试卷继续做题，先获取试卷的详细信息
            [self getPaperInfoModelPaper];
        }
    }
    //如果再做一次
    else if (parameter == 1){
        [self againDoTopicRidClear];
    }
}

//////////////////////////////////////////////////////
/////////////////////////解析/////////////////////////

///根据试卷id获取试卷详细信息(解析)
- (void)getPaperInfoAnalysisUsePaperId{
    NSString *urlString = [NSString stringWithFormat:@"%@api/Paper/GetPaperInfo/%ld?access_token=%@",systemHttps,[_dicSelectSubject[@"ExamId"] integerValue],_accToken];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicPaper = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dicPaper[@"code"] integerValue];
        if (codeId == 1) {
            NSDictionary *dicDatas = dicPaper[@"datas"];
            [self performSegueWithIdentifier:@"topicAnalysis" sender:[NSString stringWithFormat:@"%ld",[dicDatas[@"Id"] integerValue]]];
        }
    } RequestFaile:^(NSError *error) {
        
    }];
}
//*******************解析/////////////////////////

//*******************做题/////////////////////////
///根据试卷id获取试卷详细信息(模拟试卷)
- (void)getPaperInfoModelPaper{
    NSString *urlString = [NSString stringWithFormat:@"%@api/Paper/GetPaperInfo/%ld?access_token=%@",systemHttps,[_dicSelectSubject[@"ExamId"] integerValue],_accToken];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicPaper = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dicPaper[@"code"] integerValue];
        if (codeId == 1) {
            NSString *rid = _dicSelectSubject[@"Rid"];
            _dicSelectSubject = dicPaper[@"datas"];
            if (_isContinueDoTopic) {
                [self performSegueWithIdentifier:@"startDoTopic" sender:rid];
            }
            else{
                [self performSegueWithIdentifier:@"startDoTopic" sender:nil];
            }
        }
        else{
            [SVProgressHUD showInfoWithStatus:dicPaper[@"errmsg"]];
        }
    } RequestFaile:^(NSError *error) {
        
    }];
}
//************************再次做题（再做一次）/////////////////////////
///再做一次时重置当前的记录(点击重新做题的一次时间)
- (void)againDoTopicRidClear{
    //api/Chapter/ResetRecord?access_token={access_token}&rid={rid}
    NSString *urlString = [NSString stringWithFormat:@"%@api/Chapter/ResetRecord?access_token=%@&rid=%@",systemHttps,_accToken,_dicSelectSubject[@"Rid"]];
    [HttpTools postHttpRequestURL:urlString RequestPram:nil RequestSuccess:^(id respoes) {
        NSDictionary *diccc = (NSDictionary *)respoes;
        NSInteger codeId = [diccc[@"code"] integerValue];
        if (codeId == 1) {
            ///每周精选 //章节练习
            if (_topicModelCell == 3 | _topicModelCell == 1 |_topicModelCell == 2) {
                NSDictionary *dicDatas = diccc[@"datas"];
                NSString *ridString = dicDatas[@"rid"];
                _ridAgainWeekTopic = ridString;
                [self performSegueWithIdentifier:@"startDoTopic" sender:nil];
            }
            //模拟试卷
            else if(_topicModelCell == 4){
                _isContinueDoTopic = NO;
                [self getPaperInfoModelPaper];
            }
        }
    } RequestFaile:^(NSError *erro) {
        
    }];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    ///1章节练习 2智能出题 3每周精选 4试卷
    if ([segue.identifier isEqualToString:@"startDoTopic"]) {
        StartDoTopicViewController *starVc = segue.destinationViewController;
        starVc.dicPater = _dicSelectSubject;
        if (_topicModelCell == 1 ) {
            starVc.paperParameter = _topicModelCell;
            starVc.rIdString = _ridAgainWeekTopic;
        }
        if (_topicModelCell == 2) {
            //智能出题
            starVc.paperParameter = 4;
        }
        else if (_topicModelCell == 4){
            //模拟试卷
            starVc.paperParameter = 2;
        }
        else if(_topicModelCell== 3){
            //每周精选
            starVc.paperParameter = _topicModelCell;
            starVc.rIdString = _ridAgainWeekTopic;
        }
        
        if (sender != nil) {
            starVc.ridContinue = sender;
        }
        else{
            starVc.ridContinue = nil;
        }
    }
    else if ([segue.identifier isEqualToString:@"topicAnalysis"]){
        StartAnalysisTopicViewController *analysisVc = segue.destinationViewController;
        analysisVc.PaperId = [sender integerValue];
        analysisVc.rId = _dicSelectSubject[@"Rid"];
        if (_topicModelCell == 2) {
            //智能出题
            analysisVc.paperAnalysisParameter = 4;
        }
        else if (_topicModelCell == 4){
            //模拟试卷
            analysisVc.paperAnalysisParameter = 2;
        }
        else{
            analysisVc.paperAnalysisParameter = _topicModelCell;
        }

    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
