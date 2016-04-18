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
@interface PatersTopicViewController ()<UITableViewDelegate,UITableViewDataSource,TopicCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableViewPater;
//需要返回的cell的高
@property (nonatomic,assign) CGFloat cellHeight;
//需要返回的tableView头的高
@property (nonatomic,assign) CGFloat cellHeardHeight;
//判断是否是第一次加载
@property (nonatomic,assign) BOOL isFirstLoad;
@property (nonatomic,assign) BOOL isNotes;
@property (nonatomic,assign) CGFloat viewNotesOY;
@property (nonatomic,assign) BOOL isError;
@property (nonatomic,assign) CGFloat viewErrorOY;
//笔记试图
@property (nonatomic,strong) UIView *viewNotes;
//纠错试图
@property (nonatomic,strong) UIView *viewError;
@end

@implementation PatersTopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isFirstLoad = YES;
    // Do any additional setup after loading the view.
    _tableViewPater.tableFooterView = [UIView new];
    _tableViewPater.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableViewPater.backgroundColor = [UIColor whiteColor];
    _cellHeight = 130;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
//section头的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    //topicTitle 通过参数传递
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
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
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
    //先判断题的类型
    NSInteger topicType = [_dicTopic[@"qtype"] integerValue];
    PaterTopicTableViewCell *cellSelect;
    if (topicType == 1 | topicType == 2) {
        cellSelect= [tableView dequeueReusableCellWithIdentifier:@"celltopic" forIndexPath:indexPath];
        cellSelect.selectionStyle = UITableViewCellSelectionStyleNone;
        if (_dicTopic.allKeys > 0) {
            [cellSelect setvalueForCellModel:_dicTopic topicIndex:_topicIndex];
            if (_isFirstLoad) {
                _cellHeight = cellSelect.selfHeight;
            }
            cellSelect.topicType = topicType;
            cellSelect.indexTopic = _topicIndex;
            cellSelect.delegateCellClick = self;
            
            if (_isNotes) {
                [cellSelect addNotesView:_viewNotesOY];
            }
            else{
                [cellSelect.viewNotes removeFromSuperview];
            }
            if (_isError) {
                [cellSelect addErrorView:_viewErrorOY];
            }
            else{
                [cellSelect.viewError removeFromSuperview];
            }
        }
        return cellSelect;
    }
    else if (topicType == 6){
        UITableViewCell *cellSubQu = [tableView dequeueReusableCellWithIdentifier:@"cell2" forIndexPath:indexPath];
        return cellSubQu;
    }
    return nil;
}
//cell上的点击选项按钮代理回调
- (void)topicCellSelectClick:(NSInteger)indexTpoic selectDone:(NSString *)selectString{
    for (NSString *keys in _dicTopic.allKeys) {
        NSLog(@"%@ == %@",keys,_dicTopic[keys]);
    }
    [self.delegateRefreshTiopicCard refreshTopicCard:indexTpoic selectString:selectString];


//    NSLog(@"%ld == %@",indexTpoic,selectString);
}
- (void)cellHetghtChangeWithNE:(NSInteger)indexStep{
    _isFirstLoad = NO;
    if (indexStep == 0) {
        _isNotes = !_isNotes;
        if (_isNotes) {
            _viewNotesOY = _cellHeight + 120;
            _cellHeight = _cellHeight + 120;
            
        }
        else{
            _cellHeight = _cellHeight - 120;
            _viewNotesOY = _cellHeight - 120;
            
        }
        NSLog(@"_viewNotesOY == %f",_viewNotesOY);
    }
    else if (indexStep == 1){
        _isError = !_isError;
        if (_isError) {
            
            _viewErrorOY = _cellHeight + 120;
            _cellHeight = _cellHeight + 120;
        }
        else{
            _cellHeight = _cellHeight - 120;
            _viewErrorOY = _cellHeight - 120;
        }
        NSLog(@"_viewErrorOY == %f",_viewNotesOY);
    }
    
    [_tableViewPater reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
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
