//
//  PatersTopicViewController.m
//  TyDtk
//  试题展示页面，用于每道试试题的展示
//  (可用于从章节考点、模拟试卷、每周精选、智能出题页面所选试题或试卷展示)
//  Created by 天一文化 on 16/4/11.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "PatersTopicViewController.h"
#import "PaterTopicQtype6TableViewCell.h"
#import "paterTopicQtype5TableViewCell.h"
#import "paterTopicQtype1and2TableViewCell.h"
#import "PaterTopicQtype3TableViewCell.h"
#import "PaterTopicQtype4TableViewCell.h"
#import "UIImageView+SJClickEnlarge.h"
#import "ImageEnlargeViewController.h"
@interface PatersTopicViewController ()<UITableViewDelegate,UITableViewDataSource,TopicCellDelegateTest,UIScrollViewDelegate>
@property (nonatomic,strong) UITableView *tableViewPater;
//需要返回的cell的高
@property (nonatomic,assign) CGFloat cellHeight;
//需要返回的cell的高
@property (nonatomic,assign) CGFloat cellSubHeight;
//需要返回的tableView头的高
@property (nonatomic,assign) CGFloat cellHeardHeight;
//通过webview加载后计算出的高度
@property (nonatomic,assign) CGFloat cellWebLoadingheight;
//一题多问下面的小题数组
@property (nonatomic,strong) NSArray *arraySubQuestion;
//当前题的题型
@property (nonatomic,assign) NSInteger qType;
//判断是否是第一次加载
@property (nonatomic,assign) BOOL isFirstLoad;
@property (nonatomic,assign) BOOL isWebFirstLoading;
//@property (nonatomic,assign) CGFloat imageOy;
@property (nonatomic,assign) BOOL isWebSubFirstLoading;
//一题多问下的小题cell高字典
@property (nonatomic,strong) NSMutableDictionary *dicSubHeight;
//一题多问下的小题cell选项按钮Y坐标字典
@property (nonatomic,strong) NSMutableDictionary *dicSubButtonSubOy;
//是否包含需要第二次刷新的一题多问下的小题cell数组
@property (nonatomic,strong) NSMutableArray *arrayFirstLoading;
@property (nonatomic,assign) CGFloat buttonOy;
@property (nonatomic,assign) CGFloat buttonSubOy;

//添加朦层
@property (nonatomic,strong) MZView *viewMz;
//暂时保存用户答案，cell复用
@property (nonatomic,strong) NSMutableDictionary *dicUserAnswer;
@property (nonatomic,strong) NSMutableDictionary *dicUserCollectTopic;
//笔记
@property (nonatomic,strong) NotesView *notesView;
//纠错
@property (nonatomic,strong) ErrorView *errorView;
//朦层
@property (nonatomic,strong) MZView *mzView;
//回到顶部的按钮
@property (nonatomic,strong) UIButton *buttonTopTable;
@end

@implementation PatersTopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isWebFirstLoading = YES;
    _cellWebLoadingheight= 0;
    _arrayFirstLoading = [NSMutableArray array];
    _dicSubHeight = [NSMutableDictionary dictionary];
    _dicSubButtonSubOy = [NSMutableDictionary dictionary];
    
    _tableViewPater = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Height - 64 - 45) style:UITableViewStyleGrouped];
    _tableViewPater.delegate = self;
    _tableViewPater.dataSource = self;
    [self.view addSubview:_tableViewPater];
    
    _isFirstLoad = YES;
    // Do any additional setup after loading the view.
    _tableViewPater.tableFooterView = [UIView new];
    //    _tableViewPater.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableViewPater.backgroundColor = [UIColor whiteColor];
    _qType = [_dicTopic[@"qtype"] integerValue];
    if (_qType == 6) {
        _arraySubQuestion = _dicTopic[@"subQuestion"];
    }
    _cellHeight = 130;
    _cellSubHeight = 50;
    _dicUserAnswer = [NSMutableDictionary dictionary];
    _dicUserCollectTopic = [NSMutableDictionary dictionary];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //如果是一题多问
    if (_qType == 6) {
        return _arraySubQuestion.count + 1;
    }
    return 1;
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
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
        return _cellHeardHeight+30;
    }
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (_topicTitle!=nil) {
        UIView *viewTitle = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, _cellHeardHeight+30)];
        viewTitle.backgroundColor = ColorWithRGB(210, 210, 205);
        
        UILabel *labTitle = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, Scr_Width-20, _cellHeardHeight+10)];
        labTitle.numberOfLines = 0;
        labTitle.font = [UIFont systemFontOfSize:15.0];
        labTitle.text = _topicTitle;
        labTitle.adjustsFontSizeToFitWidth = YES;
        [viewTitle addSubview:labTitle];
        return viewTitle;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_qType == 6) {
        if (indexPath.row == 0) {
            return _cellWebLoadingheight;
            
        }
        else{
            if ([_dicSubHeight.allKeys containsObject:[NSString stringWithFormat:@"%ld",indexPath.row]]) {
                return [[_dicSubHeight valueForKey:[NSString stringWithFormat:@"%ld",indexPath.row]] floatValue];
            }
            return _cellSubHeight;
        }
    }
    else{
        if (_qType ==1 | _qType == 2 |_qType == 3 | _qType == 5 |_qType == 4) {
            return _cellWebLoadingheight;
        }
        return _cellHeight;
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //先判断题的类型
    //选择题（单选和多选）
    if (_qType == 1 | _qType == 2) {
        paterTopicQtype1and2TableViewCell *cell1 = (paterTopicQtype1and2TableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"TopicQtype1and2Cell"];
        if (cell1 == nil) {
            cell1 = [[[NSBundle mainBundle] loadNibNamed:@"TopicQtype1and2Cell" owner:self options:nil]lastObject];
        }
        cell1.topicType = _qType;
        //            cell1.isFirstLoad = _isFirstLoad;
        cell1.isWebFirstLoading = _isWebFirstLoading;
        cell1.isLastTopic = _isLastTopic;
        cell1.buttonOy = _buttonOy;
        cell1.indexTopic = _topicIndex;
        cell1.dicCollectDone = _dicUserCollectTopic;
        cell1.delegateCellClick = self;
        [cell1 setvalueForCellModel:_dicTopic topicIndex:_topicIndex];
        
        cell1.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell1;
    }
    //判断题
    else if (_qType == 3){
        PaterTopicQtype3TableViewCell *cell3 = (PaterTopicQtype3TableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"paterTopicQtype3Cell"];
        if (cell3 == nil) {
            cell3 = [[[NSBundle mainBundle] loadNibNamed:@"paterTopicQtype3Cell" owner:self options:nil]lastObject];
        }
        cell3.isLastTopic = _isLastTopic;
        cell3.delegateCellClick = self;
//        cell3.isFirstLoad = _isFirstLoad;
        cell3.indexTopic = _topicIndex;
        cell3.dicCollectDone = _dicUserCollectTopic;
        cell3.isWebFirstLoading = _isWebFirstLoading;
        cell3.buttonOy = _buttonOy;
        cell3.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell3 setvalueForCellModel:_dicTopic topicIndex:_topicIndex];
        return cell3;
    }
    //填空题
    else if (_qType == 4){
        PaterTopicQtype4TableViewCell *cell4 = (PaterTopicQtype4TableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"paterTopicQtype4Cell"];
        if (cell4 == nil) {
            cell4 = [[[NSBundle mainBundle] loadNibNamed:@"paterTopicQtype4Cell" owner:self options:nil] lastObject];
        }
        cell4.isLastTopic = _isLastTopic;
        cell4.delegateCellClick = self;
        cell4.isWebFirstLoading = _isWebFirstLoading;
        cell4.buttonOy = _buttonOy;
        cell4.indexTopic = _topicIndex;
        cell4.dicCollectDone = _dicUserCollectTopic;
        cell4.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell4 setvalueForCellModel:_dicTopic topicIndex:_topicIndex];
        return cell4;
    }
    //简答题
    else if (_qType == 5){
        paterTopicQtype5TableViewCell *cell5 = (paterTopicQtype5TableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"paterTopicQtype5Cell"];
        if (cell5 == nil) {
            cell5 = [[[NSBundle mainBundle] loadNibNamed:@"paterTopicQtype5Cell" owner:self options:nil]lastObject];
        }
        cell5.isLastTopic = _isLastTopic;
        cell5.isFirstLoad = _isFirstLoad;
        cell5.delegateCellClick = self;
        cell5.indexTopic = _topicIndex;
        cell5.dicCollectDone = _dicUserCollectTopic;
        cell5.isWebFirstLoading = _isWebFirstLoading;
        cell5.buttonOy = _buttonOy;
        cell5.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell5 setvalueForCellModel:_dicTopic topicIndex:_topicIndex];
        return cell5;
        
    }
    //一题多问题
    else if (_qType == 6){
        //第一个cell用于显示试题题目和相关图片
        if (indexPath.row == 0) {
            PaterTopicQtype6TableViewCell *cellSubQu = [[[NSBundle mainBundle] loadNibNamed:@"paterTopicQtype6Cell" owner:self options:nil]lastObject];
            cellSubQu.isLastTopic = _isLastTopic;
            cellSubQu.delegateCellClick = self;
            cellSubQu.indexTopic = _topicIndex;
            cellSubQu.isFirstLoad = _isFirstLoad;
            cellSubQu.buttonOy = _buttonOy;
            cellSubQu.isWebFirstLoading = _isWebFirstLoading;
            cellSubQu.selectionStyle = UITableViewCellSelectionStyleNone;
            [cellSubQu setvalueForCellModel:_dicTopic topicIndex:_topicIndex];
            return cellSubQu;
        }
        else{
            //一题多问下面的小题
            //先判断小题的类型
            NSDictionary *dicSubQues = _arraySubQuestion[indexPath.row - 1];
            NSInteger qtypeSubQues = [dicSubQues[@"qtype"] integerValue];
            //小题类型为选择题
            if (qtypeSubQues == 1 | qtypeSubQues == 2) {
                paterTopicQtype1and2TableViewCell *cell1 = [[[NSBundle mainBundle] loadNibNamed:@"TopicQtype1and2Cell" owner:self options:nil]lastObject];
                cell1.topicType = qtypeSubQues;
                cell1.indexTopic = indexPath.row;
                cell1.delegateCellClick = self;
                cell1.dicSelectDone = _dicUserAnswer;
                cell1.dicCollectDone = _dicUserCollectTopic;
                cell1.arrayFirstLoading = _arrayFirstLoading;
                cell1.buttonSubOy = _buttonSubOy;
                if ([_dicSubButtonSubOy.allKeys containsObject:[NSString stringWithFormat:@"%ld",indexPath.row]]) {
                    cell1.buttonSubOy = [[_dicSubButtonSubOy valueForKey:[NSString stringWithFormat:@"%ld",indexPath.row]] floatValue];
                }
                cell1.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell1 setvalueForCellModel:dicSubQues topicIndex:indexPath.row];
                return cell1;
            }
            else if (_qType == 3){
                PaterTopicQtype3TableViewCell *cell3 = [[[NSBundle mainBundle] loadNibNamed:@"paterTopicQtype3Cell" owner:self options:nil]lastObject];
                cell3.delegateCellClick = self;
                cell3.indexTopic = indexPath.row;
                cell3.dicSelectDone = _dicUserAnswer;
                cell3.dicCollectDone = _dicUserCollectTopic;
                cell3.arrayFirstLoading = _arrayFirstLoading;
                cell3.buttonSubOy = _buttonSubOy;
                if ([_dicSubButtonSubOy.allKeys containsObject:[NSString stringWithFormat:@"%ld",indexPath.row]]) {
                    cell3.buttonSubOy = [[_dicSubButtonSubOy valueForKey:[NSString stringWithFormat:@"%ld",indexPath.row]] floatValue];
                }
                cell3.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell3 setvalueForCellModel:_dicTopic topicIndex:_topicIndex];
                return cell3;
            }
            else if (_qType == 4){
                PaterTopicQtype4TableViewCell *cell4 = [[[NSBundle mainBundle] loadNibNamed:@"paterTopicQtype4Cell" owner:self options:nil] lastObject];
                
                cell4.delegateCellClick = self;
                cell4.dicSelectDone = _dicUserAnswer;
                cell4.dicCollectDone = _dicUserCollectTopic;
                cell4.indexTopic = indexPath.row;
                cell4.arrayFirstLoading = _arrayFirstLoading;
                cell4.buttonSubOy = _buttonSubOy;
                if ([_dicSubButtonSubOy.allKeys containsObject:[NSString stringWithFormat:@"%ld",indexPath.row]]) {
                    cell4.buttonSubOy = [[_dicSubButtonSubOy valueForKey:[NSString stringWithFormat:@"%ld",indexPath.row]] floatValue];
                }
                
                cell4.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell4 setvalueForCellModel:dicSubQues topicIndex:indexPath.row];
                return cell4;

            }
            else{
                paterTopicQtype5TableViewCell *cellQtype5 = [[[NSBundle mainBundle] loadNibNamed:@"paterTopicQtype5Cell" owner:self options:nil]lastObject];
                cellQtype5.delegateCellClick = self;
                cellQtype5.dicSelectDone = _dicUserAnswer;
                cellQtype5.dicCollectDone = _dicUserCollectTopic;
                cellQtype5.indexTopic = indexPath.row;
                cellQtype5.arrayFirstLoading = _arrayFirstLoading;
                cellQtype5.buttonSubOy = _buttonSubOy;
                if ([_dicSubButtonSubOy.allKeys containsObject:[NSString stringWithFormat:@"%ld",indexPath.row]]) {
                    cellQtype5.buttonSubOy = [[_dicSubButtonSubOy valueForKey:[NSString stringWithFormat:@"%ld",indexPath.row]] floatValue];
                }

                cellQtype5.selectionStyle = UITableViewCellSelectionStyleNone;
                [cellQtype5 setvalueForCellModel:dicSubQues topicIndex:indexPath.row];
                return cellQtype5;
            }
        }
    }
    return nil;
}
/**
 点击笔记或纠错回调
 */
- (void)saveNotesOrErrorClick:(NSInteger)questionId executeParameter:(NSInteger)parameterId{
    [_errorView removeFromSuperview];
    [_notesView removeFromSuperview];
    //纠错参数为0
    if (parameterId == 0) {
        _errorView = nil;
        if (!_errorView) {
            _errorView = [[[NSBundle mainBundle] loadNibNamed:@"ErrorView" owner:self options:nil] lastObject];
        }
        _errorView.layer.masksToBounds = YES;
        _errorView.layer.cornerRadius = 5;
        _errorView.questionId = questionId;
        _errorView.frame = CGRectMake(30, -200, Scr_Width - 60, 200);
        [self.view addSubview:_errorView];
        [UIView animateWithDuration:0.15 animations:^{
            CGRect rect = _errorView.frame;
            rect.origin.y = (Scr_Height-200)/2 - 30;
            _errorView.frame = rect;
        }];
    }
    else{
        NSUserDefaults *tyUser = [NSUserDefaults standardUserDefaults];
        if (![tyUser objectForKey:tyUserUserInfo]) {
            [SVProgressHUD showInfoWithStatus:@"您还没有登录哦"];
            return;
        }
        _notesView = nil;
        if (!_notesView) {
            _notesView = [[[NSBundle mainBundle] loadNibNamed:@"NotesView" owner:self options:nil]lastObject];
        }
        _notesView.layer.masksToBounds = YES;
        _notesView.layer.cornerRadius = 5;
        _notesView.questionId = questionId;
        _notesView.frame = CGRectMake(30, -200, Scr_Width - 60, 200);
        [self.view addSubview:_notesView];
        [UIView animateWithDuration:0.15 animations:^{
            CGRect rect = _notesView.frame;
            rect.origin.y = (Scr_Height-200)/2 - 30;
            _notesView.frame = rect;
        }];
    }
}
///获取图片回调
- (void)imageTopicArray:(NSArray *)imageArray withImageIndex:(NSInteger)imageIndex{
    ImageEnlargeViewController *imageEnlargeVC = [[ImageEnlargeViewController alloc]init];
    imageEnlargeVC.imageUrlArrays = imageArray;
    imageEnlargeVC.imageIndex = imageIndex;
    [self presentViewController:imageEnlargeVC animated:YES completion:nil];
}

//暂时保存用户答案，用于cell复用使用
- (void)saveUserAnswerUseDictonary:(NSDictionary *)dic{
    [_dicUserAnswer setValue:dic.allValues.firstObject forKey:dic.allKeys.firstObject];
    NSLog(@"用户暂时答案 == %@",_dicUserAnswer);
}
//暂时保存用户收藏的试题
- (void)saveUserCollectTiopic:(NSDictionary *)dic{
    [_dicUserCollectTopic setValue:dic.allValues.firstObject forKey:dic.allKeys.firstObject];
    NSLog(@"用户已收藏试题 == %@",_dicUserCollectTopic);
}
- (void)IsFirstload:(BOOL)isFirstLoad{
    _isFirstLoad = isFirstLoad;
    [_tableViewPater reloadData];
    [_tableViewPater reloadData];
}
//不是一题多问下的小题二次刷新
- (void)isWebLoadingCellHeight:(CGFloat)cellHeight withButtonOy:(CGFloat)buttonOy{
    _cellWebLoadingheight = cellHeight;
    _isWebFirstLoading = NO;
    [_tableViewPater reloadData];
    [_tableViewPater reloadData];
    _buttonOy = buttonOy;
    
}
//一题多问下的小题二次刷新
- (void)isWebLoadingCellHeight:(CGFloat)cellHeight withButtonOy:(CGFloat)buttonOy withIndex:(NSInteger)index{
    if (![_arrayFirstLoading containsObject:[NSString stringWithFormat:@"%ld",index]]) {
        [_arrayFirstLoading addObject:[NSString stringWithFormat:@"%ld",index]];
    }
    [_dicSubHeight setValue:[NSString stringWithFormat:@"%f",cellHeight] forKey:[NSString stringWithFormat:@"%ld",index]];
    [_dicSubButtonSubOy setValue:[NSString stringWithFormat:@"%f",buttonOy] forKey:[NSString stringWithFormat:@"%ld",index]];
    [_tableViewPater reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:YES];
}
//self.cell上的点击选项按钮（A、B、C、D..）代理回调 点击保存并跳转下一题回调 // 用于刷新答题卡
- (void)topicCellSelectClickTest:(NSInteger)indexTpoic selectDone:(NSDictionary *)dicUserAnswer isRefresh:(BOOL)isResfresh{
    [self.delegateRefreshTiopicCard refreshTopicCard:indexTpoic selectDone:dicUserAnswer isRefresh:isResfresh];
}
//////////////////////////////
//添加回到顶部
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_qType == 6) {
        if (scrollView.contentOffset.y > Scr_Height - 64 - 50) {
            [_buttonTopTable removeFromSuperview];
            if (!_buttonTopTable) {
                _buttonTopTable = [UIButton buttonWithType:UIButtonTypeCustom];
                _buttonTopTable.frame = CGRectMake(Scr_Width - 55, Scr_Height - 300, 100, 30);
                [_buttonTopTable setTitle:@"回到顶部" forState:UIControlStateNormal];
                _buttonTopTable.titleLabel.font = [UIFont systemFontOfSize:12.0];
                _buttonTopTable.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
                _buttonTopTable.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                _buttonTopTable.backgroundColor = ColorWithRGBWithAlpp(0, 0, 0, 0.3);
                [_buttonTopTable setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
                _buttonTopTable.layer.masksToBounds = YES;
                _buttonTopTable.layer.cornerRadius = 5;
//                [_buttonTopTable addTarget:self action:@selector(topButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            }
            [self.view addSubview:_buttonTopTable];
        }
        else{
            [_buttonTopTable removeFromSuperview];
        }
    }
}
//回到顶部按钮点击事件
//- (void)topButtonClick:(UIButton *)topButton{
//    [_tableViewPater setContentOffset:CGPointMake(0, 0) animated:YES];
//}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
