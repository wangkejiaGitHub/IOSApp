//
//  PatersTopicViewController.m
//  TyDtk
//  试题展示页面，用于每道试试题的展示
//  (可用于从章节考点、模拟试卷、每周精选、智能出题页面所选试题或试卷展示)
//  Created by 天一文化 on 16/4/11.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "PatersTopicViewController.h"
#import "PaterTopicTableViewCell.h"
@interface PatersTopicViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableViewPater;
//需要返回的cell的高
@property (nonatomic,assign) CGFloat cellHeight;
//需要返回的tableView头的高
@property (nonatomic,assign) CGFloat cellHeardHeight;
@end

@implementation PatersTopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tableViewPater.tableFooterView = [UIView new];
    _tableViewPater.separatorStyle = UITableViewCellSeparatorStyleNone;
    _cellHeight = 120;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (_topicTitle!=nil) {
        UILabel *lab = [[UILabel alloc]init];
        lab.numberOfLines = 0;
        lab.font = [UIFont systemFontOfSize:15.0];
        lab.text = _topicTitle;
        CGSize labSize = [lab sizeThatFits:CGSizeMake(Scr_Width-10, MAXFLOAT)];
        _cellHeardHeight = labSize.height;
        lab = nil;
        return _cellHeardHeight+20;
    }
    return 0;
}
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (_topicTitle!=nil) {
        UIView *viewTitle = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, _cellHeardHeight+20)];
        viewTitle.backgroundColor = ColorWithRGB(210, 210, 205);
        
        UILabel *labTitle = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, Scr_Width-20, _cellHeardHeight)];
        labTitle.numberOfLines = 0;
        labTitle.font = [UIFont systemFontOfSize:15.0];
        labTitle.text = _topicTitle;
        [viewTitle addSubview:labTitle];
        return viewTitle;
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return _cellHeight;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PaterTopicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"celltopic" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (_dicTopic.allKeys > 0) {
        _cellHeight = [cell setvalueForCellModel:_dicTopic topicIndex:_topicIndex];
    }
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
