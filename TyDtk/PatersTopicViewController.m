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
@property (nonatomic,assign) CGFloat cellHeight;
@end

@implementation PatersTopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tableViewPater.tableFooterView = [UIView new];
    _cellHeight = 100;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
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
