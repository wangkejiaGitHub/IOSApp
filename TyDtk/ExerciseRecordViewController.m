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
@interface ExerciseRecordViewController ()<UITableViewDataSource,UITableViewDelegate,ExerciseDelegate>
@property (nonatomic, strong) UIScrollView *scrollViewHeard;
@property (weak, nonatomic) IBOutlet UITableView *tableViewRe;
@property (weak, nonatomic) IBOutlet UIButton *buttonSubject;
@property (weak, nonatomic) IBOutlet UIButton *buttonTypeTopic;

@property (nonatomic,strong) NSUserDefaults *tyUser;
@property (nonatomic,strong) NSArray *arraySubject;
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
//刷新控件
@property (nonatomic,strong) MJRefreshBackNormalFooter *refreshFooter;
@property (nonatomic,strong) MJRefreshNormalHeader *refreshHeader;
@property (nonatomic,strong) ViewNullData *viewDataNil;
//记录再次做题时获取的每周精选rid
@property (nonatomic,strong) NSString *ridAgainWeekTopic;
@property (nonatomic,assign) BOOL isContinueDoTopic;
@end

@implementation ExerciseRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _arrayExRe = [NSMutableArray array];
    _tyUser = [NSUserDefaults standardUserDefaults];
    _accToken = [_tyUser objectForKey:tyUserAccessToken];
    // Do any additional setup after loading the view.
//    _scrollViewHeard = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, Scr_Width, 50)];
//    _scrollViewHeard.tag =100;
//    [self.view addSubview:_scrollViewHeard];
    [_buttonTypeTopic setTitle:@"章节练习" forState:UIControlStateNormal];
    _topicModel = 1;
    [_buttonSubject setTitle:@"全部" forState:UIControlStateNormal];
    _buttonSubject.titleLabel.adjustsFontSizeToFitWidth = YES;
    _subjectId = 0;
}
- (void)viewLoad{
    NSDictionary *dicSubject = [_tyUser objectForKey:tyUserClass];
    NSInteger classId = [dicSubject[@"Id"] integerValue];
    [_arrayExRe removeAllObjects];
    [self getAllSubjectWithClass:classId];
    _tableViewRe.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableViewRe.tableFooterView = [UIView new];
}
- (void)viewWillAppear:(BOOL)animated{
    _pageCurr = 1;
//    _topicModel = 4;
//    _subjectId = 0;
    [self viewLoad];
}
- (void)viewDidAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = NO;
    //设置tableView的上拉控件
    _refreshFooter = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshClick:)];
    [_refreshFooter setTitle:@"上拉查看更多记录" forState:MJRefreshStateIdle];
    [_refreshFooter setTitle:@"松开加载更多记录" forState:MJRefreshStatePulling];
    [_refreshFooter setTitle:@"正在为您加载更多记录..." forState:MJRefreshStateRefreshing];
    [_refreshFooter setTitle:@"记录已全部加载完毕" forState:MJRefreshStateNoMoreData];
    _tableViewRe.mj_footer = _refreshFooter;
    
    _refreshHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefereshClick:)];
    _tableViewRe.mj_header = _refreshHeader;
    _tableViewRe.separatorStyle = UITableViewCellSeparatorStyleNone;
}
- (void)viewDidDisappear:(BOOL)animated{
    _refreshFooter = nil;
    _refreshHeader = nil;
}
- (void)footerRefreshClick:(MJRefreshBackNormalFooter *)reFresh{
    [self getExerciseRe];
}
- (void)headerRefereshClick:(MJRefreshNormalHeader *)reFresh{
//    _topicModel = 1;
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
            _arraySubject = dicSubject[@"datas"];
            [self getExerciseRe];
        }
    } RequestFaile:^(NSError *error) {
        
    }];
}
////////////////////////////////////////////////////
/////////////////////做题模式////////////////////////
//做题模式按钮
- (IBAction)buttonTypeClick:(UIButton *)sender {
    [ZFPopupMenu setMenuBackgroundColorWithRed:0.6 green:0.4 blue:0.2 aphla:0.9];
    [ZFPopupMenu setTextColorWithRed:1 green:1 blue:1 aphla:1.0];
    [ZFPopupMenu setHighlightedImage:[UIImage imageNamed:@"cancelBg"]];
    ZFPopupMenu *popupMenu = [[ZFPopupMenu alloc] initWithItems:[self typeMenuItemArray]];
    [popupMenu showInView:self.navigationController.view fromRect:CGRectMake(Scr_Width - 50, -30, 50, 120) layoutType:Vertical];
    [self.navigationController.view addSubview:popupMenu];
}
//返回试题类型菜单item数组
//1章节练习 2智能出题 3每周精选 4试卷
- (NSArray *)typeMenuItemArray{
    NSMutableArray *arrayTypeMuen = [NSMutableArray array];
     ZFPopupMenuItem *item1 = [ZFPopupMenuItem initWithMenuName:@"章节练习" image:nil action:@selector(menuTypeClick:) target:self];
    item1.tag = 101;
     ZFPopupMenuItem *item2 = [ZFPopupMenuItem initWithMenuName:@"模拟试卷" image:nil action:@selector(menuTypeClick:) target:self];
    item2.tag = 104;
     ZFPopupMenuItem *item3 = [ZFPopupMenuItem initWithMenuName:@"每周精选" image:nil action:@selector(menuTypeClick:) target:self];
    item3.tag = 103;
     ZFPopupMenuItem *item4 = [ZFPopupMenuItem initWithMenuName:@"智能出题" image:nil action:@selector(menuTypeClick:) target:self];
    item4.tag = 102;
//    [arrayTypeMuen addObject:itemA];
    [arrayTypeMuen addObject:item1];
    [arrayTypeMuen addObject:item2];
    [arrayTypeMuen addObject:item3];
    [arrayTypeMuen addObject:item4];
    return arrayTypeMuen;
}
//做题模式按钮菜单点击事件
- (void)menuTypeClick:(ZFPopupMenuItem *)item{
    [_buttonTypeTopic setTitle:item.itemName forState:UIControlStateNormal];
    _topicModel = item.tag - 100;
    _pageCurr = 1;
    [_arrayExRe removeAllObjects];
    [self getExerciseRe];
}
//*******************做题模式////////////////////////
/////////////////////做题模式////////////////////////

////////////////////////////////////////////////////
/////////////////////科目选项////////////////////////
//科目选择按钮
- (IBAction)buttonSubjectClick:(UIButton *)sender {
    [ZFPopupMenu setMenuBackgroundColorWithRed:0.6 green:0.4 blue:0.2 aphla:0.9];
    [ZFPopupMenu setTextColorWithRed:1 green:1 blue:1 aphla:1.0];
    [ZFPopupMenu setHighlightedImage:[UIImage imageNamed:@"cancelBg"]];
    ZFPopupMenu *popupMenu = [[ZFPopupMenu alloc] initWithItems:[self subjectMenuItemArray]];
    [popupMenu showInView:self.navigationController.view fromRect:CGRectMake(55, -30, 0, 120) layoutType:Vertical];
    [self.navigationController.view addSubview:popupMenu];
}

//返回科目菜单数组
- (NSArray *)subjectMenuItemArray{
    NSMutableArray *arraySubjectMuen = [NSMutableArray array];
        ZFPopupMenuItem *itemA = [ZFPopupMenuItem initWithMenuName:@"全部" image:nil action:@selector(menuSubjectClick:) target:self];
    itemA.tag = 100;
    [arraySubjectMuen addObject:itemA];
    for (int i =0; i<_arraySubject.count; i++) {
        NSDictionary *dicSubject = _arraySubject[i];
        ZFPopupMenuItem *item = [ZFPopupMenuItem initWithMenuName:dicSubject[@"Names"] image:nil action:@selector(menuSubjectClick:) target:self];
        item.tag = 100 + 1 + i;
        [arraySubjectMuen addObject:item];
    }
    return arraySubjectMuen;
}
//科目item点击事件
- (void)menuSubjectClick:(ZFPopupMenuItem *)item{
    if (item.tag == 100) {
        _subjectId = 0;
    }
    else{
        NSDictionary *dicSubject = _arraySubject[item.tag - 100 - 1];
        _subjectId = [dicSubject[@"Id"] integerValue];
    }
    [_buttonSubject setTitle:item.itemName forState:UIControlStateNormal];
    [_arrayExRe removeAllObjects];
    _pageCurr = 1;
    [self getExerciseRe];
}
//*******************科目选项////////////////////////
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
   // api/Practice/GetDoRecords?access_token={access_token}&mode={mode}&courseId={courseId}&page={page}&size={size}
    NSString *urlString = [NSString stringWithFormat:@"%@api/Practice/GetDoRecords?access_token=%@&mode=%ld&courseId=%ld&page=%ld&size=20",systemHttps,_accToken,_topicModel,_subjectId,_pageCurr];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicN = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dicN[@"code"] integerValue];
        if (codeId == 1) {
            //获取最大页数
            NSDictionary *dicPage =dicN[@"page"];
            _pages = [dicPage[@"pages"] integerValue];
            //当前页数增加1
            _pageCurr = _pageCurr+1; 
            //追加数据
            NSArray *arrayDatas =dicN[@"datas"];
//            NSLog(@"%@",arrayDatas);
            ///////////////////////////////////////////////////////
            //首先先判断在当前的数组中是否存在新请求的记录，如果存在，不在显示
//            if (_arrayExRe.count != 0) {
//                for (NSDictionary *dicExreCurr in _arrayExRe) {
//                    for (NSDictionary *dicPater in arrayDatas) {
//                        if ([dicExreCurr[@"Rid"] isEqualToString:dicPater[@"Rid"]]) {
//                            [_arrayExRe removeObject:dicExreCurr];
//                        }
//                    }
//                }
//            }
            for (NSDictionary *dicP in arrayDatas) {
                [_arrayExRe addObject:dicP];
            }
             NSLog(@"%@",_arrayExRe);
            ///判断第一次加载时是否为空数据
            if (_arrayExRe.count == 0) {
                _viewDataNil = [[ViewNullData alloc]initWithFrame:CGRectMake(0, 45, Scr_Width, Scr_Height - 45 - 64- 49) showText:@"没有更多记录了，换个做题试试看~"];
                _tableViewRe.tableFooterView = _viewDataNil;
            }
            else{
                _tableViewRe.tableFooterView = [UIView new];
            }
            _tableViewRe.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            [_tableViewRe reloadData];
            [_refreshFooter endRefreshing];
            [_refreshHeader endRefreshing];
        }
        else{
            
        }
        [SVProgressHUD dismiss];
    } RequestFaile:^(NSError *error) {
        
    }];
}
///删除记录，单个删除
- (void)deleteExercise:(NSIndexPath *)dicIndexPath{
    [SVProgressHUD show];
    //api/Practice/Del?access_token={access_token}&rid={rid}
    NSString *urlString =[NSString stringWithFormat:@"%@api/Practice/Del?access_token=%@&rid=%@",systemHttps,_accToken,_dicSelectSubject[@"Rid"]];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicRe = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dicRe[@"code"] integerValue];
        if (codeId == 1) {
//            [_arrayExRe removeObjectAtIndex:dicIndexPath.row];
//            [_tableViewRe deleteRowsAtIndexPaths:@[dicIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            [_tableViewRe reloadData];
            
            //删除成功后重新获取记录，科目、做题模式不改变，初始页为1，清除记录数组
            _pageCurr = 1;
            [_arrayExRe removeAllObjects];
            [self getExerciseRe];
            NSDictionary *dicDatas = dicRe[@"datas"];
            [SVProgressHUD showSuccessWithStatus:dicDatas[@"msg"]];
        }
        else{
            [SVProgressHUD showInfoWithStatus:@"操作失败！"];
        }
//        NSLog(@"%@",dicRe);
    } RequestFaile:^(NSError *error) {
        
    }];
}
//tableView代理
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrayExRe.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 140;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ExerciseTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"cell1" forIndexPath:indexPath];
//    NSLog(@"indexPath.row = %ld",indexPath.row);
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
//    [_arrayExRe removeObjectAtIndex:indexPath.row];
//    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    NSLog(@"commitEditingStyle");
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _dicSelectSubject = _arrayExRe[indexPath.row];
//    NSInteger stateId = [_dicSelectSubject[@"State"] integerValue];
//    [self showSelectDoTopicOp:stateId];
}
///cell上的查看解析按钮回调
- (void)cellAnalysisWithDictionary:(NSDictionary *)dicModel{
    _dicSelectSubject = dicModel;
    [self getPaperInfoAnalysisUsePaperId];
}
///cell上的做题（继续做题或者再做一次）按钮回调
- (void)cellTopicWithDictionary:(NSDictionary *)dicModel parameterInt:(NSInteger)parameter{
    _dicSelectSubject = dicModel;
    //如果继续做题
    if (parameter == 0 | parameter == 2) {
        _isContinueDoTopic = YES;
        [self getPaperInfo];
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
    //api/Paper/GetPaperInfo/{id}?access_token={access_token}
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
///根据试卷id获取试卷详细信息
- (void)getPaperInfo{
    //api/Paper/GetPaperInfo/{id}?access_token={access_token}
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
            ///每周精选
            if (_topicModel == 3) {
                NSDictionary *dicDatas = diccc[@"datas"];
                NSString *ridString = dicDatas[@"rid"];
                _ridAgainWeekTopic = ridString;
                [self performSegueWithIdentifier:@"startDoTopic" sender:nil];
            }
            //模拟试卷
            else if(_topicModel == 4){
                _isContinueDoTopic = NO;
                [self getPaperInfo];
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
        if (_topicModel == 1 ) {
            starVc.paperParameter = _topicModel;
        }
        if (_topicModel == 2) {
            //智能出题
            starVc.paperParameter = 4;
        }
        else if (_topicModel == 4){
            //模拟试卷
            starVc.paperParameter = 2;
        }
        else if(_topicModel == 3){
            starVc.paperParameter = _topicModel;
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
        if (_topicModel == 2) {
            //智能出题
            analysisVc.paperAnalysisParameter = 4;
        }
        else if (_topicModel == 4){
            //模拟试卷
            analysisVc.paperAnalysisParameter = 2;
        }
        else{
            analysisVc.paperAnalysisParameter = _topicModel;
        }

    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
