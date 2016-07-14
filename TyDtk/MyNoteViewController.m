//
//  MyNoteViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/6/22.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "MyNoteViewController.h"
#import "MyNoteTableViewCell.h"
#import "NotesTopicViewController.h"

@interface MyNoteViewController ()<UITableViewDataSource,UITableViewDelegate,NotesDelegateDelete>
@property (weak, nonatomic) IBOutlet UITableView *tableViewNote;

@property (nonatomic,strong) NSUserDefaults *tyUser;
@property (nonatomic,strong) NSString *accessToken;

@property (nonatomic,assign) NSInteger pageCurr;
@property (nonatomic,assign) NSInteger pageCount;
@property (nonatomic,assign) CGFloat cellHeight;
@property (nonatomic,strong) NSMutableArray *arrayNotes;
//上拉刷新
@property (nonatomic,strong) MJRefreshBackNormalFooter *refreshFooter;
//下拉刷新
@property (nonatomic,strong) MJRefreshNormalHeader *refreshHeader;
@end

@implementation MyNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的笔记";
    // Do any additional setup after loading the view from its nib.
    _tyUser = [NSUserDefaults standardUserDefaults];
    _accessToken = [_tyUser objectForKey:tyUserAccessToken];
    
    _pageCount = 0;
    _pageCurr = 1;
    _cellHeight = 90;
    _arrayNotes = [NSMutableArray array];
    _tableViewNote.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableViewNote.tableFooterView = [UIView new];
    [self getNoteWipthChaperId];
    
}
- (void)viewDidAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = NO;
    
    _refreshHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefereshClick:)];
    _tableViewNote.mj_header = _refreshHeader;
    //设置tableView的上拉控件
    _refreshFooter = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshClick:)];
    [_refreshFooter setTitle:@"上拉查看更多笔记" forState:MJRefreshStateIdle];
    [_refreshFooter setTitle:@"松开加载更多笔记" forState:MJRefreshStatePulling];
    [_refreshFooter setTitle:@"正在为您加载更多笔记..." forState:MJRefreshStateRefreshing];
    [_refreshFooter setTitle:@"笔记已全部加载完毕" forState:MJRefreshStateNoMoreData];
    _tableViewNote.mj_footer = _refreshFooter;
}
//下拉刷新
- (void)headerRefereshClick:(MJRefreshNormalHeader *)reFresh{
    _pageCount= 0;
    _pageCurr = 1;
//    [_arrayNotes removeAllObjects];
    [self getNoteWipthChaperId];
}
//上拉刷新
- (void)footerRefreshClick:(MJRefreshBackNormalFooter *)reFresh{
    [self getNoteWipthChaperId];
}
///根据章节id获取该章节下满所有的试题笔记
- (void)getNoteWipthChaperId{
    if (_pageCount != 0) {
        if (_pageCurr > _pageCount) {
            [_refreshFooter endRefreshingWithNoMoreData];
            return;
        }
    }
    [SVProgressHUD show];
    NSString *urlString = [NSString stringWithFormat:@"%@api/Note/GetUserChapterNotes?access_token=%@&chapterId=%ld&page=%ld&size=20",systemHttps,_accessToken,_chaperId,_pageCurr];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicNote = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        if ([dicNote[@"code"] integerValue] == 1) {
            
            if (_pageCurr == 1) {
                [_arrayNotes removeAllObjects];
            }
            
            _pageCurr = _pageCurr + 1;
            NSArray *arrayNote = dicNote[@"datas"];
            for (NSDictionary *dicN in arrayNote) {
                [_arrayNotes addObject:dicN];
            }
            
            NSDictionary *dicPage = dicNote[@"page"];
            _pageCount = [dicPage[@"pages"]integerValue];
            _tableViewNote.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            [_tableViewNote reloadData];
            [_refreshFooter endRefreshing];
            [_refreshHeader endRefreshing];
        }
        [SVProgressHUD dismiss];
    } RequestFaile:^(NSError *error) {
        [SVProgressHUD showInfoWithStatus:@"网络异常"];
    }];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return _cellHeight;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrayNotes.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MyNoteTableViewCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"MyNoteTableViewCell" owner:self options:nil]lastObject];
    cell.delegateNote = self;
    NSDictionary *dicNote = _arrayNotes[indexPath.row];
    _cellHeight = [cell setModelValueForCellWitnDic:dicNote];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dicNote = _arrayNotes[indexPath.row];
    NSInteger questionId = [dicNote[@"QuestionId"]integerValue];
    [self getQuestionTopicWithQuestionId:questionId];
}
//根据笔记试题id获取试题
- (void)getQuestionTopicWithQuestionId:(NSInteger)questionId{
    //api/ExamQuestion/GetExamQuestionInfo/{id}?access_token={access_token}
    [SVProgressHUD show];
    NSString *urlString = [NSString stringWithFormat:@"%@api/ExamQuestion/GetExamQuestionInfo/%ld?access_token=%@",systemHttps,questionId,_accessToken];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicTopic = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        if ([dicTopic[@"code"] integerValue] == 1) {
            NSDictionary *dicNoteTopic = dicTopic[@"datas"];
            [self goNoteAboutTopic:dicNoteTopic];
        }
        [SVProgressHUD dismiss];
        NSLog(@"%@",dicTopic);
        
        
    } RequestFaile:^(NSError *error) {
        
    }];
}
///跳转到笔记相关试题页面
- (void)goNoteAboutTopic:(NSDictionary *)dicTopic{
    NotesTopicViewController *noteTopic = [[NotesTopicViewController alloc]initWithNibName:@"NotesTopicViewController" bundle:nil];
    noteTopic.dicNoteTopic = dicTopic;
    [self.navigationController pushViewController:noteTopic animated:YES];
}
///删除笔记回调
- (void)deleteNoteWithNoteId:(NSInteger)noteId cell:(UITableViewCell *)cell{
    LXAlertView *alertDelete = [[LXAlertView alloc]initWithTitle:@"删除提示" message:@"确认删除这条笔记吗?" cancelBtnTitle:@"取消" otherBtnTitle:@"删除" clickIndexBlock:^(NSInteger clickIndex) {
        if (clickIndex == 1) {
            [self deleteUserNote:noteId];
            NSLog(@"notes");
        }
    }];
    [alertDelete showLXAlertView];
}
///删除笔记
- (void)deleteUserNote:(NSInteger)noteId{
    NSString *urlString = [NSString stringWithFormat:@"%@api/Note/Del/%ld?access_token=%@",systemHttps,noteId,_accessToken];
    [HttpTools postHttpRequestURL:urlString RequestPram:nil RequestSuccess:^(id respoes) {
        NSDictionary *dicDele = (NSDictionary *)respoes;
        NSInteger codeId = [dicDele[@"code"] integerValue];
        if (codeId == 1) {
            NSDictionary *dicccc = dicDele[@"datas"];
            _pageCount = 0;
            _pageCurr = 1;
            [_arrayNotes removeAllObjects];
            [self getNoteWipthChaperId];
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
