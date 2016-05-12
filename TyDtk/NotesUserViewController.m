//
//  NotesUserViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/5/10.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "NotesUserViewController.h"
#import "NotesUserTableViewCell.h"
@interface NotesUserViewController ()<UITableViewDelegate,UITableViewDataSource,NotesDelegateDelete,ViewNullDataDelegate>
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
@property (nonatomic,strong) MJRefreshNormalHeader *refreshHeader;
//没有笔记时显示的view
@property (nonatomic,strong) ViewNullData *viewNilData;
@end

@implementation NotesUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _cellHeight = 50;
    NSUserDefaults *tyUser = [NSUserDefaults standardUserDefaults];
    _accessToken = [tyUser objectForKey:tyUserAccessToken];
    _arrayNotes = [NSMutableArray array];
    _tableViewNotes = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width,Scr_Height - 64 - 44) style:UITableViewStylePlain];
    _tableViewNotes.backgroundColor = [UIColor clearColor];
    _tableViewNotes.delegate = self;
    _tableViewNotes.dataSource = self;
    _tableViewNotes.userInteractionEnabled = YES;
    _tableViewNotes.tableFooterView = [UIView new];
    [self.view addSubview:_tableViewNotes];
}

- (void)viewWillAppear:(BOOL)animated{
    //设置tableView的上拉控件
    _refreshFooter = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshClick:)];
    [_refreshFooter setTitle:@"上拉查看更多笔记" forState:MJRefreshStateIdle];
    [_refreshFooter setTitle:@"松开加载更多笔记" forState:MJRefreshStatePulling];
    [_refreshFooter setTitle:@"正在为您加载更多笔记..." forState:MJRefreshStateRefreshing];
    [_refreshFooter setTitle:@"笔记已全部加载完毕" forState:MJRefreshStateNoMoreData];
    _tableViewNotes.mj_footer = _refreshFooter;
    
    _refreshHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshClick:)];
    _tableViewNotes.mj_header = _refreshHeader;

    _pageCurrIndex = 1;
    _pages = 0;
    [self getUserNotes];
}
- (void)viewDidDisappear:(BOOL)animated{
    _refreshFooter = nil;
}
- (void)getUserNotes{
    if (_pages != 0) {
        if (_pageCurrIndex > _pages) {
            [_refreshFooter endRefreshingWithNoMoreData];
            return;
        }
    }
    NSString *urlString = [NSString stringWithFormat:@"%@api/Note/GetMyExamNotes/%ld?access_token=%@&page=%ld&size=20",systemHttps,_questionId,_accessToken,_pageCurrIndex];
    
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicNotes = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dicNotes[@"code"] integerValue];
        if (codeId == 1) {
            NSDictionary *dicPages = dicNotes[@"page"];
            _pages = [dicPages[@"pages"] integerValue];
            _pageCurrIndex = _pageCurrIndex + 1;
            NSArray *arrayNotes = dicNotes[@"datas"];
            [_viewNilData removeFromSuperview];
            if (arrayNotes.count == 0) {
                if (!_viewNilData) {
                    _viewNilData = [[ViewNullData alloc]initWithFrame:self.view.bounds showText:@"暂时没有笔记，点击刷新试试"];
                    _viewNilData.delegateNullData = self;
                }
                [self.view addSubview:_viewNilData];
            }
            else{
                for (NSDictionary *dicN in arrayNotes) {
                    [_arrayNotes addObject:dicN];
                }

            }
            [_tableViewNotes reloadData];
            [_refreshFooter endRefreshing];
            [_refreshHeader endRefreshing];
        }
        NSLog(@"%@",dicNotes);
    } RequestFaile:^(NSError *error) {
        
    }];
    
}
//上拉刷新
- (void)footerRefreshClick:(MJRefreshBackNormalFooter *)footer{
    [self getUserNotes];
}
//下拉刷新
- (void)headerRefreshClick:(MJRefreshNormalHeader *)header{
    _pageCurrIndex = 1;
    _pages = 0;
    [_arrayNotes removeAllObjects];
    [self getUserNotes];
}
//空数据时点击屏幕触发
- (void)nullDataTapGestClick{
    _pageCurrIndex = 1;
    _pages = 0;
    [_arrayNotes removeAllObjects];
    [_viewNilData removeFromSuperview];
    [self getUserNotes];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrayNotes.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return _cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NotesUserTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"NotesUserCell" owner:self options:nil] lastObject];
    cell.userParameter = 1;
    cell.delegateNotes = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *dic = _arrayNotes[indexPath.row];
   _cellHeight = [cell setvalueForCellModel:dic];
    cell.userInteractionEnabled = YES;
    return cell;
}

- (void)deleteNoteWithNoteId:(NSInteger)noteId cell:(UITableViewCell *)cell{
        LXAlertView *alertDelete = [[LXAlertView alloc]initWithTitle:@"删除提示" message:@"确认删除这条笔记吗?" cancelBtnTitle:@"取消" otherBtnTitle:@"删除" clickIndexBlock:^(NSInteger clickIndex) {
            if (clickIndex == 1) {
                [self deleteUserNote:noteId];
            }
        }];
        [alertDelete showLXAlertView];
}
- (void)deleteUserNote:(NSInteger)noteId{
    NSString *urlString = [NSString stringWithFormat:@"%@api/Note/Del/%ld?access_token=%@",systemHttps,noteId,_accessToken];
    [HttpTools postHttpRequestURL:urlString RequestPram:nil RequestSuccess:^(id respoes) {
        NSDictionary *dicDele = (NSDictionary *)respoes;
        NSInteger codeId = [dicDele[@"code"] integerValue];
        if (codeId == 1) {
            NSDictionary *dicccc = dicDele[@"datas"];
            _pageCurrIndex = 1;
            _pages = 0;
            [_arrayNotes removeAllObjects];
            [self getUserNotes];
            [SVProgressHUD showSuccessWithStatus:dicccc[@"msg"]];
        }
        NSLog(@"%@",dicDele);
    } RequestFaile:^(NSError *erro) {
        
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
