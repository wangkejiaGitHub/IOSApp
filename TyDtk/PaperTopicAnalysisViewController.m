//
//  PaperTopicAnalysisViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/5/6.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "PaperTopicAnalysisViewController.h"
#import "AnalysisQtype1And2TableViewCell.h"
@interface PaperTopicAnalysisViewController ()<UITableViewDelegate,UITableViewDataSource,TopicAnalysisCellDelegateTest>
@property (nonatomic,strong) UITableView *tableViewPater;
//需要返回的cell的高
@property (nonatomic,assign) CGFloat cellHeight;
//需要返回的cell的高
@property (nonatomic,assign) CGFloat cellSubHeight;
//需要返回的tableView头的高
@property (nonatomic,assign) CGFloat cellHeardHeight;
//一题多问下面的小题数组
@property (nonatomic,strong) NSArray *arraySubQuestion;
//当前题的题型
@property (nonatomic,assign) NSInteger qType;
//判断是否是第一次加载
@property (nonatomic,assign) BOOL isFirstLoad;
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
    _tableViewPater = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Height - 64 - 45) style:UITableViewStyleGrouped];
    _tableViewPater.delegate = self;
    _tableViewPater.dataSource = self;
    _tableViewPater.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableViewPater];
    
    _qType = [_dicTopic[@"qtype"] integerValue];
    if (_qType == 6) {
        _arraySubQuestion = _dicTopic[@"subQuestion"];
    }
    NSLog(@"fsfsfaf");
    _cellHeight = 130;
    _cellSubHeight = 50;
    _dicUserCollectTopic = [NSMutableDictionary dictionary];
    self.view.backgroundColor = [UIColor clearColor];

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    if (_qType == 6) {
//        return _arraySubQuestion.count + 1;
//    }
    if (_qType == 1 | _qType == 2) {
        return 1;
    }
    return 0;

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
//    if (_qType == 6) {
//        if (indexPath.row == 0) {
//            return _cellHeight;
//        }
//        else{
//            return _cellSubHeight;
//        }
//    }
//    else{
    if (_qType == 1 | _qType == 2) {
        return _cellHeight;
    }
    return 0;
    
//    }
    
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
            cell1.selectionStyle = UITableViewCellSelectionStyleNone;
            cell1.dicTopic = _dicTopic;
            cell1.topicType = _qType;
            cell1.indexTopic = _topicIndex;
            cell1.isFirstLoad = _isFirstLoad;
            cell1.delegateCellClick = self;
            _cellHeight = [cell1 setvalueForCellModel:_dicTopic topicIndex:_topicIndex];
            return cell1;
        }
        return nil;
        
    }
    return nil;
}
- (void)IsFirstload:(BOOL)isFirstLoad{
    _isFirstLoad = isFirstLoad;
    [_tableViewPater reloadData];
}
- (void)imageSaveQtype1Test:(UIImage *)image{
    
}
- (void)saveUserCollectTiopic:(NSDictionary *)dic{
    
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
