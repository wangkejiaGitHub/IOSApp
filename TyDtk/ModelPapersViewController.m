//
//  ModelPapersViewController.m
//  TyDtk
//  模拟试卷
//  Created by 天一文化 on 16/4/6.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "ModelPapersViewController.h"
@interface ModelPapersViewController ()<CustomToolDelegate,UITableViewDataSource,UITableViewDelegate,ActiveDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
//授权工具
@property (nonatomic,strong) CustomTools *customTools;
//本地信息存储
@property (nonatomic,strong) NSUserDefaults *tyUser;
//朦层
@property (nonatomic,strong) MZView *mzView;
//头试图
@property (nonatomic,strong) ActiveVIew *hearhVIew;
//令牌
@property (nonatomic,strong)NSString *accessToken;
//储存的专业信息
@property (nonatomic,strong) NSDictionary *dicUserClass;
//是否允许授权
@property (nonatomic,assign) BOOL allowToken;
//请求的试卷的年份
@property (nonatomic,assign) NSString *paterYear;
//请求的试卷类型
@property (nonatomic,assign) NSString *paterLevel;
//请求的当前页
@property (nonatomic,assign) NSInteger paterIndexPage;
//请求数据的最大页
@property (nonatomic,assign) NSInteger paterPages;
//所有试卷数据数组
@property (nonatomic,strong) NSMutableArray *arrayPapers;
//刷新控件
@property (nonatomic,strong) MJRefreshBackNormalFooter *refreshFooter;

//回到顶部的按钮
@property (nonatomic,strong) UIButton *buttonTopTable;
@end

@implementation ModelPapersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self viewLoad];
}
- (void)viewLoad{
    _allowToken = YES;
    _paterPages = 0;
    _paterIndexPage = 1;
    _arrayPapers = [NSMutableArray array];
}
- (void)viewDidAppear:(BOOL)animated{
    //设置tableView的上拉控件
    _refreshFooter = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshClick:)];
    [_refreshFooter setTitle:@"上拉查看更多试卷" forState:MJRefreshStateIdle];
    [_refreshFooter setTitle:@"松开加载更多试卷" forState:MJRefreshStatePulling];
    [_refreshFooter setTitle:@"正在为您加载更多试卷..." forState:MJRefreshStateRefreshing];
    [_refreshFooter setTitle:@"试卷已全部加载完毕" forState:MJRefreshStateNoMoreData];
    _myTableView.mj_footer = _refreshFooter;
    _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //试卷授权一次
    if (_allowToken) {
        _paterLevel = @"0";
        _paterYear =@"0";
        [self getAccessToken];
    }
    else{
        //新数据从传递的科目Id中请求获取
        _paterPages = 0;
        _paterIndexPage = 1;
        [_arrayPapers removeAllObjects];
        [self getModelPapersData];
    }
    _allowToken = NO;

}

- (void)viewWillDisappear:(BOOL)animated{
     _refreshFooter = nil;
}
/**
 授权，收取令牌
 */
- (void)getAccessToken{
    _customTools = [[CustomTools alloc]init];
    _customTools.delegateTool = self;
    _tyUser = [NSUserDefaults standardUserDefaults];
    //获取储存的专业信息
    NSDictionary *dicUserInfo = [_tyUser objectForKey:tyUserUser];
    _dicUserClass = [_tyUser objectForKey:tyUserClass];
    
//    [self addHeardViewForPaterList];
//    if (!_hearhVIew) {
//        _hearhVIew= [[[NSBundle mainBundle] loadNibNamed:@"ActiveView" owner:self options:nil]lastObject];
//        _hearhVIew.delegateAtive = self;
//        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Width/2 + 20)];
//        [view addSubview:_hearhVIew];
//        view.backgroundColor = [UIColor clearColor];
//        _myTableView.tableHeaderView = view;
//    }
//    
//    
//    
//    [_hearhVIew.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",systemHttpImgs,_dicUserClass[@"ImageUrl"]]]];
//    _hearhVIew.labTitle.text = _dicUserClass[@"Names"];
//    _hearhVIew.labRemark.text = _dicUserClass[@"Names"];
//    NSInteger personNum = [_dicUserClass[@"CourseNum"] integerValue];
//    _hearhVIew.labSubjectNumber.text = [NSString stringWithFormat:@"%ld",personNum];
//    _hearhVIew.labPersonNumber.text = @"0";
//    _hearhVIew.labPrice.text = @"0.0";
    
    if (!_mzView) {
        _mzView = [[MZView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Height)];
    }
    //授权并收取令牌
    NSString *classId = [NSString stringWithFormat:@"%@",_dicUserClass[@"Id"]];
    [_customTools empowerAndSignatureWithUserId:dicUserInfo[@"userId"] userName:dicUserInfo[@"name"] classId:classId subjectId:_subjectId];
}
/**
 试卷信息列表的头试图
 */
- (void)addHeardViewForPaterList{
    if (!_hearhVIew) {
        _hearhVIew= [[[NSBundle mainBundle] loadNibNamed:@"ActiveView" owner:self options:nil]lastObject];
        _hearhVIew.delegateAtive = self;
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Width/2 - 10)];
        [view addSubview:_hearhVIew];
        view.backgroundColor = [UIColor clearColor];
        _myTableView.tableHeaderView = view;
    }
    
    NSDictionary *dicCurrSubject = [_tyUser objectForKey:tyUserSubject];
    NSString *imgsUrlSub = dicCurrSubject[@"productImageListStore"];
    [_hearhVIew.imageView sd_setImageWithURL:[NSURL URLWithString:imgsUrlSub]];
    _hearhVIew.labTitle.text = dicCurrSubject[@"Names"];
    NSString *remarkPriceSub =[NSString stringWithFormat:@"￥ %ld",[dicCurrSubject[@"marketPrice"] integerValue]];
    //市场价格用属性字符串添加删除线
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:remarkPriceSub];
    [attri addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle | NSUnderlineStyleSingle) range:NSMakeRange(2,remarkPriceSub.length -2)];
    [attri addAttribute:NSStrikethroughColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(2,remarkPriceSub.length-2)];
//    _hearhVIew.labRemark.text = remarkPriceSub;
    [_hearhVIew.labRemark setAttributedText:attri];
    NSString *priceSub = [NSString stringWithFormat:@"￥ %ld",[dicCurrSubject[@"price"] integerValue]];
    _hearhVIew.labPrice.text = priceSub;

}
/**
 头试图回调代理
 */
//激活码做题回调代理
- (void)activeForPapersClick{
    NSLog(@"激活码做题");
}
//获取激活码回调代理
- (void)getActiveMaClick{
    NSLog(@"如何获取激活码");
}
/**
 授权成功回调，用与第一次授权加载数据
 */
- (void)httpSussessReturnClick{
    _accessToken = [_tyUser objectForKey:tyUserAccessToken];
    //获取试卷信息
    [self getModelPapersData];
    
}
/**
 授权失败
 */
- (void)httpErrorReturnClick{
    
}
/**
 获取试卷数据
 */
- (void)getModelPapersData{
    if (_paterPages != 0) {
        if (_paterIndexPage > _paterPages) {
            [_refreshFooter endRefreshingWithNoMoreData];
            return;
        }
    }
    
    //添加试卷列表的头试图 科目信息
    [self addHeardViewForPaterList];
    [SVProgressHUD show];
    //获取试卷级别
    [self.view addSubview:_mzView];
    //获取试卷级别
    //    [self getModelPaterLevel];
    NSString *urlString = [NSString stringWithFormat:@"%@api/Paper/GetPapers?access_token=%@&courseId=%@&page=%ld&level=%@&year=%@",systemHttps,_accessToken,_subjectId,_paterIndexPage,_paterLevel,_paterYear];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicModelPapers = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        //获取最大页数
        NSDictionary *dicPage =dicModelPapers[@"page"];
        _paterPages = [dicPage[@"pages"] integerValue];
        //当前页数增加1
        _paterIndexPage = _paterIndexPage+1;
        //追加数据
        NSArray *arrayPaters = dicModelPapers[@"datas"];
        for (NSDictionary *dicPater in arrayPaters) {
            [_arrayPapers addObject:dicPater];
        }
        [_mzView removeFromSuperview];
        [SVProgressHUD dismiss];
        [_refreshFooter endRefreshing];
        [_myTableView reloadData];
        _myTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    } RequestFaile:^(NSError *error) {
        [_mzView removeFromSuperview];
        [SVProgressHUD showInfoWithStatus:@"网络异常"];
    }];
}
/**
 获取当前专业下的试卷级别,
 */
//- (void)getModelPaterLevel{
//    NSString *urlString = [NSString stringWithFormat:@"%@api/Paper/GetLevels?access_token=%@",systemHttps,_accessToken];
//    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
//        NSDictionary *dicPaterLevel = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
//    } RequestFaile:^(NSError *error) {
//        
//    }];
//}
- (void)footerRefreshClick:(MJRefreshBackNormalFooter *)footer{
    [self getModelPapersData];
}
//tableView上的scroll代理，用户判断是否显示'回到顶部'按钮
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_myTableView.contentOffset.y > Scr_Height - 64 - 50) {
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
            [_buttonTopTable addTarget:self action:@selector(topButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        [self.view addSubview:_buttonTopTable];
    }
    else{
        [_buttonTopTable removeFromSuperview];
    }
}
//回到顶部按钮
- (void)topButtonClick:(UIButton *)topButton{
    [_myTableView setContentOffset:CGPointMake(0, 0) animated:YES];
}
///////////////////////////////////////
//tableview 代理
///////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_arrayPapers.count > 0) {
        return _arrayPapers.count;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellmodel" forIndexPath:indexPath];
    NSDictionary *dicCurrPater = _arrayPapers[indexPath.row];
    UILabel *labName = (UILabel *)[cell.contentView viewWithTag:10];
    UILabel *labQuantity = (UILabel *)[cell.contentView viewWithTag:11];
    UILabel *labTime= (UILabel *)[cell.contentView viewWithTag:12];
    UILabel *labScore = (UILabel *)[cell.contentView viewWithTag:13];
    UILabel *labPerson = (UILabel *)[cell.contentView viewWithTag:14];
    
    labName.text = dicCurrPater[@"Names"];
    labQuantity.text =[NSString stringWithFormat:@"%ld 题",[dicCurrPater[@"Quantity"] integerValue]];
    labTime.text = [NSString stringWithFormat:@"%ld 分钟",[dicCurrPater[@"TimeLong"] integerValue]];
    labScore.text =[NSString stringWithFormat:@"%ld 分",[dicCurrPater[@"Score"] integerValue]];
    labPerson.text = @"0人参与";
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *diccc = _arrayPapers[indexPath.row];
    [self performSegueWithIdentifier:@"topicStar" sender:diccc];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"topicStar"]) {
        StartDoTopicViewController *topicVc = segue.destinationViewController;
        topicVc.dicPater = sender;
    }
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
