//
//  PaperTopicAnalysisViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/5/6.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "PaperTopicAnalysisViewController.h"
#import "AnalysisQtype1And2TableViewCell.h"
#import "AnalysisQtype3TableViewCell.h"
#import "AnalysisQtype5TableViewCell.h"
#import "AnalysisQtype6TableViewCell.h"
#import "ImageEnlargeViewController.h"
#import "AnalysisQtype4TableViewCell.h"
#import "NotesViewController.h"
@interface PaperTopicAnalysisViewController ()<UITableViewDelegate,UITableViewDataSource,TopicAnalysisCellDelegateTest>
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
@property (nonatomic,assign) BOOL isWebSubFirstLoading;
//一题多问下的小题cell高字典
@property (nonatomic,strong) NSMutableDictionary *dicSubHeight;
//一题多问下的小题cell选项按钮Y坐标字典
@property (nonatomic,strong) NSMutableDictionary *dicSubButtonSubOy;
//是否包含需要第二次刷新的一题多问下的小题cell数组
@property (nonatomic,strong) NSMutableArray *arrayFirstLoading;
@property (nonatomic,assign) CGFloat buttonOy;
@property (nonatomic,assign) CGFloat buttonSubOy;
@property (nonatomic,assign) CGFloat imageOy;
//暂时保存用户收藏的试题
@property (nonatomic,strong) NSMutableDictionary *dicUserCollectTopic;
//纠错
@property (nonatomic,strong) ErrorView *errorView;
@end

@implementation PaperTopicAnalysisViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self viewLoad];
  
}
//页面加载
- (void)viewLoad{
    _isFirstLoad = YES;
    _isWebFirstLoading = YES;
    _cellWebLoadingheight= 0;
    _arrayFirstLoading = [NSMutableArray array];
    _dicSubHeight = [NSMutableDictionary dictionary];
    _dicSubButtonSubOy = [NSMutableDictionary dictionary];
    _tableViewPater = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Height - 64 - 45) style:UITableViewStyleGrouped];
    _tableViewPater.delegate = self;
    _tableViewPater.dataSource = self;
    _tableViewPater.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableViewPater];
    
    _qType = [_dicTopic[@"qtype"] integerValue];
    if (_qType == 6) {
        _arraySubQuestion = _dicTopic[@"subQuestion"];
    }
    _cellHeight = 0;
    _cellSubHeight = 0;
    _dicUserCollectTopic = [NSMutableDictionary dictionary];
    self.view.backgroundColor = [UIColor clearColor];

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //如果是一题多问
    if (_qType == 6) {
        return _arraySubQuestion.count + 1;
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
        if (_qType ==1 | _qType == 2 | _qType == 3 | _qType == 5 | _qType == 4) {
            return _cellWebLoadingheight;
        }
        return _cellHeight = 50;
    }
}
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_qType == 1 | _qType == 2) {
        AnalysisQtype1And2TableViewCell *cell1 = (AnalysisQtype1And2TableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AnalysisQtype1And2Cell"];
        if (cell1 == nil) {
            cell1 = [[[NSBundle mainBundle] loadNibNamed:@"AnalysisQtype1And2Cell" owner:self options:nil]lastObject];
        }
        cell1.selectionStyle = UITableViewCellSelectionStyleNone;
        cell1.dicTopic = _dicTopic;
        cell1.topicType = _qType;
        cell1.indexTopic = _topicIndex;
        cell1.dicCollectDone = _dicUserCollectTopic;
        cell1.isFirstLoad = _isFirstLoad;
        cell1.isWebFirstLoading = _isWebFirstLoading;
        cell1.delegateAnalysisCellClick = self;
        [cell1 setvalueForCellModel:_dicTopic topicIndex:_topicIndex];
         return cell1;
    }
    else if (_qType == 3){
        AnalysisQtype3TableViewCell *cell3 = (AnalysisQtype3TableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AnalysisQtype3Cell"];
        if (cell3 == nil) {
            cell3 = [[[NSBundle mainBundle] loadNibNamed:@"AnalysisQtype3Cell" owner:self options:nil]lastObject];
        }
        cell3.selectionStyle = UITableViewCellSelectionStyleNone;
        cell3.dicTopic = _dicTopic;
        cell3.topicType = _qType;
        cell3.indexTopic = _topicIndex;
        cell3.isFirstLoad = _isFirstLoad;
        cell3.isWebFirstLoading = _isWebFirstLoading;
        cell3.buttonOy = _buttonOy;
        cell3.delegateAnalysisCellClick = self;
        [cell3 setvalueForCellModel:_dicTopic topicIndex:_topicIndex];
        return cell3;

    }
    else if (_qType == 4){
        AnalysisQtype4TableViewCell *cell4 = [[[NSBundle mainBundle] loadNibNamed:@"AnalysisQtype4TableViewCell" owner:self options:nil]lastObject];
        cell4.selectionStyle = UITableViewCellSelectionStyleNone;
        cell4.dicTopic = _dicTopic;
        cell4.topicType = _qType;
        cell4.indexTopic = _topicIndex;
        cell4.isFirstLoad = _isFirstLoad;
        cell4.isWebFirstLoading = _isWebFirstLoading;
        cell4.buttonOy = _buttonOy;
        cell4.delegateAnalysisCellClick = self;
        [cell4 setvalueForCellModel:_dicTopic topicIndex:_topicIndex];
        return cell4;
    }
    else if (_qType == 5){
        AnalysisQtype5TableViewCell *cell5 = (AnalysisQtype5TableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AnalysisQtype5Cell"];
        if (cell5 == nil) {
            cell5 = [[[NSBundle mainBundle] loadNibNamed:@"AnalysisQtype5Cell" owner:self options:nil]lastObject];
        }
        cell5.selectionStyle = UITableViewCellSelectionStyleNone;
        cell5.dicTopic = _dicTopic;
        cell5.topicType = _qType;
        cell5.indexTopic = _topicIndex;
        cell5.isFirstLoad = _isFirstLoad;
        cell5.isWebFirstLoading = _isWebFirstLoading;
        cell5.buttonOy = _buttonOy;
        cell5.delegateAnalysisCellClick = self;
        [cell5 setvalueForCellModel:_dicTopic topicIndex:_topicIndex];
        return cell5;

    }
    else if (_qType == 6){
        if (indexPath.row == 0) {
            AnalysisQtype6TableViewCell *cell6 = [[[NSBundle mainBundle] loadNibNamed:@"AnalysisQtype6Cell" owner:self options:nil]lastObject];
            cell6.delegateAnalysisCellClick = self;
            cell6.indexTopic = _topicIndex;
            cell6.isFirstLoad = _isFirstLoad;
            cell6.buttonOy = _buttonOy;
            cell6.isWebFirstLoading = _isWebFirstLoading;
            cell6.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell6 setvalueForCellModel:_dicTopic topicIndex:_topicIndex];
            return cell6;
        }
        else{
            //一题多问下面的小题
            //先判断小题的类型
            NSDictionary *dicSubQues = _arraySubQuestion[indexPath.row - 1];
            NSInteger qtypeSubQues = [dicSubQues[@"qtype"] integerValue];
            //小题类型为选择题
            if (qtypeSubQues == 1 | qtypeSubQues == 2) {
                AnalysisQtype1And2TableViewCell *cell1 = [[[NSBundle mainBundle] loadNibNamed:@"AnalysisQtype1And2Cell" owner:self options:nil]lastObject];
                cell1.topicType = qtypeSubQues;
                cell1.indexTopic = indexPath.row;
                cell1.delegateAnalysisCellClick = self;
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
                AnalysisQtype3TableViewCell *cell3 = (AnalysisQtype3TableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AnalysisQtype3Cell"];
                if (cell3 == nil) {
                    cell3 = [[[NSBundle mainBundle] loadNibNamed:@"AnalysisQtype3Cell" owner:self options:nil]lastObject];
                }
                cell3.delegateAnalysisCellClick = self;
                cell3.indexTopic = indexPath.row;
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
            else{
                AnalysisQtype5TableViewCell *cell5 = [[[NSBundle mainBundle] loadNibNamed:@"AnalysisQtype5Cell" owner:self options:nil]lastObject];
                cell5.delegateAnalysisCellClick = self;
                cell5.dicCollectDone = _dicUserCollectTopic;
                cell5.indexTopic = indexPath.row;
                cell5.arrayFirstLoading = _arrayFirstLoading;
                cell5.buttonSubOy = _buttonSubOy;
                if ([_dicSubButtonSubOy.allKeys containsObject:[NSString stringWithFormat:@"%ld",indexPath.row]]) {
                    cell5.buttonSubOy = [[_dicSubButtonSubOy valueForKey:[NSString stringWithFormat:@"%ld",indexPath.row]] floatValue];
                }

                cell5.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell5 setvalueForCellModel:dicSubQues topicIndex:indexPath.row];
                return cell5;
            }
        }
        
    }
    return nil;
}

//cell代理
- (void)IsFirstload:(BOOL)isFirstLoad{
    _isFirstLoad = isFirstLoad;
    [_tableViewPater reloadData];
}
//不是一题多问下的小题二次刷新
- (void)isWebLoadingCellHeight:(CGFloat)cellHeight withButtonOy:(CGFloat)buttonOy{
    _cellWebLoadingheight = cellHeight;
    _isWebFirstLoading = NO;
    [_tableViewPater reloadData];
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
///接受所传递过来的图片数组
- (void)imageTopicArray:(NSArray *)imageArray withImageIndex:(NSInteger)imageIndex{
    ImageEnlargeViewController *imageEnlargeVC = [[ImageEnlargeViewController alloc]init];
    imageEnlargeVC.imageUrlArrays = imageArray;
    imageEnlargeVC.imageIndex = imageIndex;
    [self presentViewController:imageEnlargeVC animated:YES completion:nil];
}
- (void)saveUserCollectTiopic:(NSDictionary *)dic{
    [_dicUserCollectTopic setValue:dic.allValues.firstObject forKey:dic.allKeys.firstObject];
}

//提交笔记或纠错
- (void)saveNotesOrErrorClick:(NSInteger)questionId executeParameter:(NSInteger)parameterId{
    [_errorView removeFromSuperview];
    //纠错
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
        [UIView animateWithDuration:0.2 animations:^{
            CGRect rect = _errorView.frame;
            rect.origin.y = (Scr_Height-200)/2 - 30;
            _errorView.frame = rect;
        }];

    }
    //试卷分析笔记
    else{
        //跳转到笔记界面
//        [self.delegatePersent persentNotesViewController:[NSString stringWithFormat:@"%ld",questionId]];
        NotesViewController *noteVc = [[NotesViewController alloc]initWithNibName:@"NotesViewController" bundle:nil];
        noteVc.questionId = [NSString stringWithFormat:@"%ld",questionId];
        [self.navigationController pushViewController:noteVc animated:YES];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
// 
//}

@end
