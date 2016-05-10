//
//  NotesUserViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/5/10.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "NotesUserViewController.h"

@interface NotesUserViewController ()<UITableViewDelegate,UITableViewDataSource>
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

@implementation NotesUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *tyUser = [NSUserDefaults standardUserDefaults];
    _accessToken = [tyUser objectForKey:tyUserAccessToken];
    // Do any additional setup after loading the view.
    _tableViewNotes = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width,self.view.bounds.size.height) style:UITableViewStylePlain];
    _tableViewNotes.backgroundColor = [UIColor clearColor];
    _tableViewNotes.delegate = self;
    _tableViewNotes.dataSource = self;
    [self.view addSubview:_tableViewNotes];
}
- (void)viewWillAppear:(BOOL)animated{
    [_arrayNotes removeAllObjects];
    _pageCurrIndex = 1;
    _pages = 0;
    [self getUserNotes];
}
- (void)getUserNotes{
    if (_pages != 0) {
        if (_pageCurrIndex > _pages) {
            [_refreshFooter endRefreshingWithNoMoreData];
            return;
        }
    }
    //api/Note/GetMyExamNotes/{id}?access_token={access_token}&page={page}&size={size}
    NSString *urlString = [NSString stringWithFormat:@"%@api/Note/GetMyExamNotes/%ld?access_token=%@&page=%ld&size=20",systemHttps,_questionId,_accessToken,_pageCurrIndex];
    
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicNotes = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"%@",dicNotes);
    } RequestFaile:^(NSError *error) {
        
    }];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 8;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell1"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell1"];
    }
    cell.textLabel.text = @"fsfa";
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
