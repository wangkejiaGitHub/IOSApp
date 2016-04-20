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
#import "NotesOrErrorTableViewCell.h"
#import "PaterTopicQtype6TableViewCell.h"
@interface PatersTopicViewController ()<UITableViewDelegate,UITableViewDataSource,TopicCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableViewPater;
//需要返回的cell的高
@property (nonatomic,assign) CGFloat cellHeight;
//需要返回的tableView头的高
@property (nonatomic,assign) CGFloat cellHeardHeight;
//判断是否是第一次加载
@property (nonatomic,assign) BOOL isFirstLoad;
@property (nonatomic,assign) BOOL isNotes;
@property (nonatomic,assign) BOOL isError;
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
    if (section == 0) {
        return 1;
    }
    else if (section == 1){
        if (_isNotes) {
            return 1;
            
        }
        return 0;
    }
    else{
        if (_isError) {
            return 1;
        }
        return 0;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
//section头的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
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
    else{
        return 30;
    }
   
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
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
    else{
        //  arrow_right   arrow_down arrow_up
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 30)];
        view.backgroundColor = [UIColor groupTableViewBackgroundColor];
        view.layer.masksToBounds = YES;
        view.layer.cornerRadius = 5;
        UIImageView *imageV = [[UIImageView alloc]initWithFrame:CGRectMake(Scr_Width-30, 10, 16, 8)];
        if (section == 1) {
            if (_isNotes) {
                 imageV.image = [UIImage imageNamed:@"arrow_up"];
            }
            else{
                 imageV.image = [UIImage imageNamed:@"arrow_down"];
            }
        }
        else
        {
            if (_isError) {
                 imageV.image = [UIImage imageNamed:@"arrow_up"];
            }
            else{
                 imageV.image = [UIImage imageNamed:@"arrow_down"];
            }
        }
        
        [view addSubview:imageV];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, Scr_Width, 30);
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        button.backgroundColor = [UIColor clearColor];
        button.titleLabel.font = [UIFont systemFontOfSize:13.0];
        if (section == 1) {
            [button setTitle:@"笔记 >>" forState:UIControlStateNormal];
        }
        else{
            [button setTitle:@"纠错 >>" forState:UIControlStateNormal];
        }
        button.tag = 100+section;
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(sectionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        return view;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return _cellHeight;
    }
    else{
        return 120;
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        //先判断题的类型
        NSInteger topicType = [_dicTopic[@"qtype"] integerValue];
        PaterTopicTableViewCell *cellSelect;
        if (topicType == 1 | topicType == 2) {
            cellSelect= [tableView dequeueReusableCellWithIdentifier:@"celltopicqtype1" forIndexPath:indexPath];
            cellSelect.selectionStyle = UITableViewCellSelectionStyleNone;
            if (_dicTopic.allKeys > 0) {
                _cellHeight = [cellSelect setvalueForCellModel:_dicTopic topicIndex:_topicIndex];
                cellSelect.topicType = topicType;
                cellSelect.indexTopic = _topicIndex;
                cellSelect.delegateCellClick = self;
            }
            cellSelect.selectionStyle = UITableViewCellSelectionStyleNone;
            return cellSelect;
        }
        else if (topicType == 6){
            PaterTopicQtype6TableViewCell *cellSubQu = [tableView dequeueReusableCellWithIdentifier:@"celltopicqtype6" forIndexPath:indexPath];
            cellSubQu.selectionStyle = UITableViewCellSelectionStyleNone;
            _cellHeight = [cellSubQu setvalueForCellModel:_dicTopic topicIndex:_topicIndex];
            return cellSubQu;
        }
        return nil;

    }
    else{
        NotesOrErrorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellNotes" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.backgroundColor = ColorWithRGB(218, 218, 218);
        return cell;
    }
}
//点击笔记或者纠错触发
- (void)sectionBtnClick:(UIButton*)sender{
    NSInteger sectionIndex = sender.tag - 100;
    if (sectionIndex == 1) {
        _isNotes = !_isNotes;
    }
    else{
        _isError = !_isError;
    }
    [_tableViewPater reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
    CGFloat ccc = _tableViewPater.contentSize.height;
    CGFloat ddd = Scr_Height - 69 - 45;
    NSLog(@"%f == %f",ddd,ccc);
}
//cell上的点击选项按钮代理回调
//- (void)topicCellSelectClick:(NSInteger)indexTpoic selectDone:(NSString *)selectString{
////    for (NSString *keys in _dicTopic.allKeys) {
////        NSLog(@"%@ == %@",keys,_dicTopic[keys]);
////    }
//    
//    [self.delegateRefreshTiopicCard refreshTopicCard:indexTpoic selectString:selectString];
//}
- (void)topicCellSelectClick:(NSInteger)indexTpoic selectDone:(NSDictionary *)dicUserAnswer{
    [self.delegateRefreshTiopicCard refreshTopicCard:indexTpoic selectDone:dicUserAnswer];
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
