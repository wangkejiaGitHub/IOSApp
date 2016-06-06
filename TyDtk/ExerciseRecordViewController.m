//
//  ExerciseRecordViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/6/2.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "ExerciseRecordViewController.h"

@interface ExerciseRecordViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollViewHeard;
@property (weak, nonatomic) IBOutlet UITableView *tableViewRe;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonRight;
@property (weak, nonatomic) IBOutlet UIButton *buttonSubject;
@property (weak, nonatomic) IBOutlet UIButton *buttonTypeTopic;

@property (nonatomic,strong) NSUserDefaults *tyUser;
@property (nonatomic,strong) NSArray *arraySubject;
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
@property (nonatomic,strong) ViewNullData *viewDataNil;
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
    _pageCurr = 1;
    _topicModel = 4;
    _subjectId = 0;
    [self viewLoad];
}
- (void)viewLoad{
    [_buttonTypeTopic setTitle:@"章节练习" forState:UIControlStateNormal];
    _topicModel = 1;
    [_buttonSubject setTitle:@"全部" forState:UIControlStateNormal];
    _buttonSubject.titleLabel.adjustsFontSizeToFitWidth = YES;
    _subjectId = 0;
    NSDictionary *dicSubject = [_tyUser objectForKey:tyUserClass];
    NSInteger classId = [dicSubject[@"Id"] integerValue];
    [self getAllSubjectWithClass:classId];
    _tableViewRe.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableViewRe.tableFooterView = [UIView new];
}
- (void)viewDidAppear:(BOOL)animated{
    //设置tableView的上拉控件
    _refreshFooter = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshClick:)];
    [_refreshFooter setTitle:@"上拉查看更多记录" forState:MJRefreshStateIdle];
    [_refreshFooter setTitle:@"松开加载更多记录" forState:MJRefreshStatePulling];
    [_refreshFooter setTitle:@"正在为您加载更多记录..." forState:MJRefreshStateRefreshing];
    [_refreshFooter setTitle:@"记录已全部加载完毕" forState:MJRefreshStateNoMoreData];
    _tableViewRe.mj_footer = _refreshFooter;
    _tableViewRe.separatorStyle = UITableViewCellSeparatorStyleNone;
}
- (void)viewDidDisappear:(BOOL)animated{
    _refreshFooter = nil;
}
- (void)footerRefreshClick:(MJRefreshBackNormalFooter *)reFresh{
    [self getExerciseRe];
}
//做题模式按钮
- (IBAction)buttonTypeClick:(UIButton *)sender {
    [ZFPopupMenu setMenuBackgroundColorWithRed:0.6 green:0.4 blue:0.2 aphla:0.9];
    [ZFPopupMenu setTextColorWithRed:1 green:1 blue:1 aphla:1.0];
    [ZFPopupMenu setHighlightedImage:[UIImage imageNamed:@"cancelBg"]];
    ZFPopupMenu *popupMenu = [[ZFPopupMenu alloc] initWithItems:[self typeMenuItemArray]];
    [popupMenu showInView:self.navigationController.view fromRect:CGRectMake(Scr_Width - 60, -30, 50, 120) layoutType:Vertical];
    [self.navigationController.view addSubview:popupMenu];
}
//返回试题类型菜单item数组
//1章节练习 2智能出题 3每周精选 4试卷
- (NSArray *)typeMenuItemArray{
    NSMutableArray *arrayTypeMuen = [NSMutableArray array];
//    ZFPopupMenuItem *itemA = [ZFPopupMenuItem initWithMenuName:@"全部" image:nil action:@selector(menuTypeClick:) target:self];
//    itemA.tag = 100 + 0;
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
//    NSLog(@"%ld",item.tag);
    [_buttonTypeTopic setTitle:item.itemName forState:UIControlStateNormal];
    _topicModel = item.tag - 100;
    _pageCurr = 1;
    [_arrayExRe removeAllObjects];
    [self getExerciseRe];
}
///获取当前专业下的所有科目
- (void)getAllSubjectWithClass:(NSInteger)classId{
    NSString *urlString = [NSString stringWithFormat:@"%@api/CourseInfo/%ld",systemHttps,classId];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicSubject = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dicSubject[@"code"] integerValue];
        if (codeId == 1) {
            _arraySubject = dicSubject[@"datas"];
//            [self addMenuSubject];
            [self getExerciseRe];
        }
//        NSLog(@"%@",dicSubject);
    } RequestFaile:^(NSError *error) {
        
    }];
}
//科目选择按钮
- (IBAction)buttonSubjectClick:(UIButton *)sender {
    [ZFPopupMenu setMenuBackgroundColorWithRed:0.6 green:0.4 blue:0.2 aphla:0.9];
    [ZFPopupMenu setTextColorWithRed:1 green:1 blue:1 aphla:1.0];
    [ZFPopupMenu setHighlightedImage:[UIImage imageNamed:@"cancelBg"]];
    ZFPopupMenu *popupMenu = [[ZFPopupMenu alloc] initWithItems:[self subjectMenuItemArray]];
    [popupMenu showInView:self.navigationController.view fromRect:CGRectMake(48, -30, 0, 120) layoutType:Vertical];
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
///添加科目
//- (void)addMenuForScrollow{
//    ///scrollView的内容宽
//    NSInteger scrollContWith = 0;
//    for (int i =0; i<_arraySubject.count; i++) {
//        NSDictionary *dicSub = _arraySubject[i];
//        NSString *name = dicSub[@"Names"];
//        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(scrollContWith, 5, name.length*19+10, 40)];
//        titleLabel.text = name;
//        titleLabel.tag = i;
//        titleLabel.font = [UIFont systemFontOfSize:16.0];
//        titleLabel.textAlignment = NSTextAlignmentCenter;
//        titleLabel.textColor = [UIColor lightGrayColor];
//        //允许用户交互
//        titleLabel.userInteractionEnabled = YES;
//        [titleLabel addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labClick:)]];
//        [self.scrollViewHeard addSubview:titleLabel];
//        scrollContWith = scrollContWith + name.length * 19+10 ;
//    }
//    [self.scrollViewHeard setContentSize:CGSizeMake(scrollContWith, 45)];
//}
////科目点击事件
//- (void)labClick:(UITapGestureRecognizer *)recognizer{
//    UILabel *labClick = (UILabel *)recognizer.view;
//    for (id subView in _scrollViewHeard.subviews) {
//        if ([subView isKindOfClass:[UILabel class]]) {
//            UILabel *lab = (UILabel *)subView;
//            if (labClick.tag == lab.tag) {
//                lab.textColor = [UIColor redColor];
//            }
//            else{
//                lab.textColor = [UIColor lightGrayColor];
//            }
//        }
//    }
//    CGRect rect = labClick.frame;
//    if (rect.origin.x + rect.size.width/2<Scr_Width/2) {
//        [_scrollViewHeard setContentOffset:CGPointMake(0, 0) animated:YES];
//    }
//    else if (rect.origin.x + rect.size.width/2 > _scrollViewHeard.contentSize.width - Scr_Width/2){
//        [_scrollViewHeard setContentOffset:CGPointMake(_scrollViewHeard.contentSize.width-Scr_Width, 0) animated:YES];
//    }
//    else{
//        [_scrollViewHeard setContentOffset:CGPointMake(rect.origin.x+rect.size.width/2 - Scr_Width/2, 0) animated:YES];
//    }
//    NSDictionary *dicSubject = _arraySubject[labClick.tag];
//    _subjectId = [dicSubject[@"Id"] integerValue];
//    _pageCurr = 1;
//    [_arrayExRe removeAllObjects];
//    
//    [self getExerciseRe];
//}
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
    NSLog(@"%@",urlString);
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
            for (NSDictionary *dicPater in arrayDatas) {
                [_arrayExRe addObject:dicPater];
            }
            _tableViewRe.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            [_tableViewRe reloadData];
            [_refreshFooter endRefreshing];
            NSLog(@"%ld",_arrayExRe.count);
        }
        else{
            
        }
        [SVProgressHUD dismiss];
    } RequestFaile:^(NSError *error) {
        
    }];
    
}
//tableView代理
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrayExRe.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *dicRx = _arrayExRe[indexPath.row];
    NSLog(@"%@",dicRx[@"AddTime"]);
    UILabel *labTitle = (UILabel *)[cell.contentView viewWithTag:10];
    labTitle.text = dicRx[@"Title"];
//   UILabel *labAddTime = (UILabel *)[cell.contentView viewWithTag:11];
//   UILabel *labRE = (UILabel *)[cell.contentView viewWithTag:12];
//   cell.backgroundColor = [UIColor lightGrayColor];
    //获取当前时间，日期（用于计算记录日期）
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd hh:mm"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    NSLog(@"dateString:%@",dateString);
    return cell;
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
