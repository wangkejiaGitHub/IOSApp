//
//  NotesElseUserViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/5/10.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "NotesElseUserViewController.h"
#import "NotesUserTableViewCell.h"
@interface NotesElseUserViewController ()<UITableViewDelegate,UITableViewDataSource>
//tableView 笔记
@property (nonatomic,strong) UITableView *tableViewNotes;
//返回cell的高
@property (nonatomic,assign) CGFloat cellHeight;
//笔记当前页
@property (nonatomic,assign) NSInteger pageCurrIndex;
//笔记总页数
@property (nonatomic,assign) NSInteger pages;
//令牌
@property (nonatomic,strong) NSString *accessToken;
//笔记数组
@property (nonatomic,strong) NSMutableArray *arrayNotes;
//刷新控件
@property (nonatomic,strong) MJRefreshBackNormalFooter *refreshFooter;
@end

@implementation NotesElseUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _cellHeight = 50;
    NSUserDefaults *tyUser = [NSUserDefaults standardUserDefaults];
    _accessToken = [tyUser objectForKey:tyUserAccessToken];
    _arrayNotes = [NSMutableArray array];
    _tableViewNotes = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width,self.view.bounds.size.height-64 - 45) style:UITableViewStylePlain];
    _tableViewNotes.backgroundColor = [UIColor clearColor];
    _tableViewNotes.delegate = self;
    _tableViewNotes.dataSource = self;
    _tableViewNotes.userInteractionEnabled = YES;
    _tableViewNotes.tableFooterView = [UIView new];
    [self.view addSubview:_tableViewNotes];
    
}
- (void)viewWillAppear:(BOOL)animated{
    _refreshFooter = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshClick:)];
    [_refreshFooter setTitle:@"上拉查看更多笔记" forState:MJRefreshStateIdle];
    [_refreshFooter setTitle:@"松开加载更多笔记" forState:MJRefreshStatePulling];
    [_refreshFooter setTitle:@"正在为您加载更多笔记..." forState:MJRefreshStateRefreshing];
    [_refreshFooter setTitle:@"笔记已全部加载完毕" forState:MJRefreshStateNoMoreData];
    _tableViewNotes.mj_footer = _refreshFooter;
    _pageCurrIndex = 1;
    _pages = 0;
    [_arrayNotes removeAllObjects];
    [self getElseNotes];
}
- (void)getElseNotes{
  
    if (_pages != 0) {
        if (_pageCurrIndex > _pages) {
            [_refreshFooter endRefreshingWithNoMoreData];
            return;
        }
    }
    NSString *urlString = [NSString stringWithFormat:@"%@api/Note/GetExamNotes/%ld?access_token=%@&page=%ld&size=20",systemHttps,_questionId,_accessToken,_pageCurrIndex];
    
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicNotes = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dicNotes[@"code"] integerValue];
        if (codeId == 1) {
            NSDictionary *dicPages = dicNotes[@"page"];
            _pages = [dicPages[@"pages"] integerValue];
            _pageCurrIndex = _pageCurrIndex + 1;
            NSArray *arrayNotes = dicNotes[@"datas"];
            for (NSDictionary *dicN in arrayNotes) {
                [_arrayNotes addObject:dicN];
            }
            [_tableViewNotes reloadData];
            [_refreshFooter endRefreshing];
        }
        NSLog(@"%@",dicNotes);
    } RequestFaile:^(NSError *error) {
        
    }];

}
- (void)footerRefreshClick:(MJRefreshBackNormalFooter *)footer{
    [self getElseNotes];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrayNotes.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return _cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NotesUserTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"NotesUserCell" owner:self options:nil] lastObject];
    cell.userParameter = 0;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *dic = _arrayNotes[indexPath.row];
    _cellHeight = [cell setvalueForCellModel:dic];
    cell.userInteractionEnabled = YES;
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
