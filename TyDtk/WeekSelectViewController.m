//
//  WeekSelectViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/5/18.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "WeekSelectViewController.h"
#import "ActiveSubjectViewController.h"
@interface WeekSelectViewController ()<ActiveSubjectDelegate,UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableViewWeek;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottom;
//授权工具
@property (nonatomic,strong) CustomTools *customTools;
//本地信息存储
@property (nonatomic,strong) NSUserDefaults *tyUser;
//朦层
@property (nonatomic,strong) MZView *mzView;
//头试图
@property (nonatomic,strong) ActiveSubjectView *hearhVIew;
//空数据显示层
@property (nonatomic,strong) ViewNullData *viewNilData;
//令牌
@property (nonatomic,strong)NSString *accessToken;
//储存的专业信息
@property (nonatomic,strong) NSDictionary *dicUserClass;
//请求的当前页
@property (nonatomic,assign) NSInteger paterIndexPage;
//请求数据的最大页
@property (nonatomic,assign) NSInteger paterPages;
//所有试卷数据数组
@property (nonatomic,strong) NSMutableArray *arrayPapers;
//刷新控件
@property (nonatomic,strong) MJRefreshBackNormalFooter *refreshFooter;

@property (nonatomic,strong) MJRefreshNormalHeader *refreshHeader;
//回到顶部的按钮
@property (nonatomic,strong) UIButton *buttonTopTable;

///判断是否登录
@property (nonatomic,assign) BOOL isLoginUser;
@end
@implementation WeekSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _arrayPapers = [NSMutableArray array];
    _tableViewWeek.tableFooterView = [UIView new];
    // Do any additional setup after loading the view.
    _tyUser = [NSUserDefaults standardUserDefaults];
    _accessToken = [_tyUser objectForKey:tyUserAccessToken];
    
    if ([_tyUser objectForKey:tyUserUserInfo]) {
        _isLoginUser = YES;
    }
    else{
        _isLoginUser = NO;
    }
    
    if (_intPushWhere == 1) {
//        _tableViewBottom.constant = 49;
    }
    else{
        _tableViewBottom.constant = 49;
    }

    _paterPages = 0;
    _paterIndexPage = 1;
    [self getWeekSelectPaper];
    [self addRefreshForTableViewHeader];
    [self addRefreshForTableViewFooter];
}
- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.tabBarController.tabBar.hidden = NO;
}
- (void)addRefreshForTableViewFooter{
    //设置tableView的上拉控件
    _refreshFooter = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshClick:)];
    [_refreshFooter setTitle:@"上拉查看更多试卷" forState:MJRefreshStateIdle];
    [_refreshFooter setTitle:@"松开加载更多试卷" forState:MJRefreshStatePulling];
    [_refreshFooter setTitle:@"正在为您加载更多试卷..." forState:MJRefreshStateRefreshing];
    [_refreshFooter setTitle:@"试卷已全部加载完毕" forState:MJRefreshStateNoMoreData];
    _tableViewWeek.mj_footer = _refreshFooter;
}
//上拉刷新
- (void)footerRefreshClick:(MJRefreshBackNormalFooter *)footer{
    [self getWeekSelectPaper];
}
///添加下拉刷新
- (void)addRefreshForTableViewHeader{
    _refreshHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefereshWClick:)];
    _tableViewWeek.mj_header = _refreshHeader;
}
//下拉刷新
- (void)headerRefereshWClick:(MJRefreshNormalHeader *)header{
    _tableViewWeek.userInteractionEnabled = NO;
    ///重新判断科目是否激活
    if (_isLoginUser) {
        [self determineSubjectActive];
    }
    else{
        _paterPages = 0;
        _paterIndexPage = 1;
        [self getWeekSelectPaper];
    }
}
///判断科目是否激活（登录情况下）
- (void)determineSubjectActive{
    NSDictionary *dicUserInfo = [_tyUser objectForKey:tyUserUserInfo];
    NSString *urlString = [NSString stringWithFormat:@"%@/ty/mobile/order/productValidate?productId=%@&jeeId=%@",systemHttpsKaoLaTopicImg,_subjectId,dicUserInfo[@"jeeId"]];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicActive = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];

        if ([dicActive[@"code"] integerValue] == 1) {
            NSDictionary *dicDatas = dicActive[@"datas"];
            ///激活
            if ([dicDatas[@"status"] integerValue] == 1) {
                _isActiveSubject = YES;
            }
            ///未激活
            else{
                _isActiveSubject = NO;
            }
            
            _paterPages = 0;
            _paterIndexPage = 1;
            [self getWeekSelectPaper];
        }
    } RequestFaile:^(NSError *error) {
        
    }];
}

/**
 试卷信息列表的头试图
 */
- (void)addHeardViewForPaterList{
    _dicUserClass = [_tyUser objectForKey:tyUserClass];
    NSDictionary *dicCurrSubject = [_tyUser objectForKey:tyUserSelectSubject];
    
    _hearhVIew= [[[NSBundle mainBundle] loadNibNamed:@"ActiveSubjetView" owner:self options:nil]lastObject];
    _hearhVIew.delegateAtive = self;
    _hearhVIew.subjectId = _subjectId;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Width/2 -10)];
    [view addSubview:_hearhVIew];
    view.backgroundColor = [UIColor whiteColor];
    _tableViewWeek.tableHeaderView = view;
    [_hearhVIew setActiveValue:dicCurrSubject];
    
    if (_isActiveSubject) {
        [_hearhVIew.buttonActive setTitle:@"科目已激活" forState:UIControlStateNormal];
        _hearhVIew.buttonActive.userInteractionEnabled = NO;
        _hearhVIew.buttonPay.userInteractionEnabled = NO;
        _hearhVIew.buttonPay.backgroundColor = [UIColor clearColor];
        [_hearhVIew.buttonPay setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    }
}
/**
 头试图回调代理
 */
//激活码做题或购买商品回调代理
- (void)paySubjectProductWithPayParameter:(NSInteger)PayParameter{
    if (_isLoginUser) {
        UIStoryboard *sCommon = CustomStoryboard(@"TyCommon");
        ActiveSubjectViewController *acVc = [sCommon instantiateViewControllerWithIdentifier:@"ActiveSubjectViewController"];
        acVc.subjectId = [_subjectId integerValue];
        acVc.payParameter = PayParameter;
        [self.navigationController pushViewController:acVc animated:YES];
    }
    else{
        [SVProgressHUD showInfoWithStatus:@"您还没有登录"];
    }
}
/**
 获取每周精选所有试题
 */
- (void)getWeekSelectPaper{
    //在这之前比较当前页和最大页数的值
    if (_paterPages != 0) {
        if (_paterIndexPage > _paterPages) {
            [_refreshFooter endRefreshingWithNoMoreData];
            return;
        }
    }
    ///从联系中心进入
    if (self.intPushWhere == 1) {
        [SVProgressHUD show];
        if (!_mzView) {
            _mzView = [[MZView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Height)];
        }
        [self.navigationController.tabBarController.view addSubview:_mzView];
    }
    [self addHeardViewForPaterList];
    NSString *urlString = [NSString stringWithFormat:@"%@api/Weekly/GetWeeklyList?access_token=%@&page=%ld",systemHttps,_accessToken,_paterIndexPage];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicWeek = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dicWeek[@"code"] integerValue];
        if (codeId == 1) {
            if (_paterIndexPage == 1) {
                [_arrayPapers removeAllObjects];
            }
            NSDictionary *dicPage =dicWeek[@"page"];
            _paterPages = [dicPage[@"pages"] integerValue];
            //当前页数增加1
            _paterIndexPage = _paterIndexPage+1;
            NSArray *arrayDatas = dicWeek[@"datas"];
            if (arrayDatas.count == 0) {
//                UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 100)];
//                view.backgroundColor = [UIColor whiteColor];
//                UILabel *labText = [[UILabel alloc]initWithFrame:CGRectMake(30, 30, Scr_Width - 60, 30)];
//                labText.font = [UIFont systemFontOfSize:18.0];
//                labText.textColor= [UIColor lightGrayColor];
//                labText.textAlignment = NSTextAlignmentCenter;
//                labText.text = @"没有更多试卷了";
//                [view addSubview:labText];
//                _tableViewWeek.tableFooterView = view;
                [self addTableFooterView];
            }
            else{
                //追加数据
                for (NSDictionary *dicPater in arrayDatas) {
                    [_arrayPapers addObject:dicPater];
                }
                _tableViewWeek.tableFooterView = [UIView new];
            }
            [_mzView removeFromSuperview];
            [SVProgressHUD dismiss];
            [_refreshFooter endRefreshing];
            [_refreshHeader endRefreshing];
            [_tableViewWeek reloadData];
            _tableViewWeek.userInteractionEnabled = YES;
        }
    } RequestFaile:^(NSError *error) {
        [_mzView removeFromSuperview];
        [_refreshFooter endRefreshing];
        [_refreshHeader endRefreshing];
        _tableViewWeek.userInteractionEnabled = YES;
        httpsErrorShow;
    }];
}

///当没有科目试卷信息时，显示空数据视图信息
- (void)addTableFooterView{
    NSString *alertString = @"暂时没有更多相关试卷";
    UIView *viewFooter = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 50)];
    viewFooter.backgroundColor = [UIColor whiteColor];
    UILabel *labAlert = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, Scr_Width - 40, 30)];
    labAlert.text = alertString;
    labAlert.textColor = [UIColor lightGrayColor];
    labAlert.backgroundColor = [UIColor clearColor];
    labAlert.font = [UIFont systemFontOfSize:15.0];
    labAlert.textAlignment = NSTextAlignmentCenter;
    [viewFooter addSubview:labAlert];
    _tableViewWeek.tableFooterView = viewFooter;
}
/////////////////////////////////////////
/////////////////////////////////////////
//tableView代理
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrayPapers.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"weekcell" forIndexPath:indexPath];
    NSDictionary *dicWeek = _arrayPapers[indexPath.row];
    UILabel *labTitle = (UILabel *)[cell.contentView viewWithTag:10];
    //标题
    NSString *titleString = [NSString stringWithFormat:@"%@(每周精选)",dicWeek[@"Title"]];
    //标题属性字符串
    NSMutableAttributedString *attriTitle = [[NSMutableAttributedString alloc] initWithString:titleString];
    [attriTitle addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor]
                          range:NSMakeRange([NSString stringWithFormat:@"%@",dicWeek[@"Title"]].length,6)];
    UIFont *titleFont = [UIFont systemFontOfSize:12.0];
    
    [attriTitle addAttribute:NSFontAttributeName value:titleFont
                       range:NSMakeRange([NSString stringWithFormat:@"%@",dicWeek[@"Title"]].length,6)];
    
    [labTitle setAttributedText:attriTitle];
//    labTitle.text = dicWeek[@"Title"];
    
    UILabel *labCount = (UILabel *)[cell.contentView viewWithTag:11];
    //题量
    NSString *quantityString = [NSString stringWithFormat:@"%ld 题",[dicWeek[@"Quantity"] integerValue]];
    //题量属性字符串
    NSMutableAttributedString *attriQuantity = [[NSMutableAttributedString alloc] initWithString:quantityString];
    [attriQuantity addAttribute:NSForegroundColorAttributeName value:[UIColor brownColor]
                          range:NSMakeRange(0,[NSString stringWithFormat:@"%ld",[dicWeek[@"Quantity"] integerValue]].length )];
    [labCount setAttributedText:attriQuantity];
    
    UILabel *labLecel = (UILabel *)[cell.contentView viewWithTag:12];
    //难度系数
    NSString *DifficultyLabelString = [NSString stringWithFormat:@"难度系数：%@",dicWeek[@"DifficultyLabel"]];
    //题量属性字符串
    NSMutableAttributedString *attriDifficulty = [[NSMutableAttributedString alloc] initWithString:DifficultyLabelString];
    [attriDifficulty addAttribute:NSForegroundColorAttributeName value:[UIColor brownColor]
                          range:NSMakeRange(5,[NSString stringWithFormat:@"%@",dicWeek[@"DifficultyLabel"]].length )];
    [labLecel setAttributedText:attriDifficulty];
    
    UILabel *labPerson = (UILabel *)[cell.contentView viewWithTag:13];
    //参与人数
    NSString *personString = [NSString stringWithFormat:@"已有【%ld】人参与此周练",[dicWeek[@"DoNum"] integerValue]];
    NSMutableAttributedString *attriPerson = [[NSMutableAttributedString alloc] initWithString:personString];
    [attriPerson addAttribute:NSForegroundColorAttributeName value:[UIColor brownColor]
                          range:NSMakeRange(3,[NSString stringWithFormat:@"%ld",[dicWeek[@"DoNum"] integerValue]].length )];
    [labPerson setAttributedText:attriPerson];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dicWeekPaper = _arrayPapers[indexPath.row];
    [self getWeekPaperRid:dicWeekPaper];
}
/**
 获取记录id
 */
- (void)getWeekPaperRid:(NSDictionary *)dic{
    [SVProgressHUD show];
    NSString *titleString = dic[@"Title"];
    //标题编码
    titleString = [titleString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //api/Weekly/MakeWeeklyRecord/{id}?access_token={access_token}&title={title}
    NSString *urlString = [NSString stringWithFormat:@"%@api/Weekly/MakeWeeklyRecord/%@?access_token=%@&title=%@",systemHttps,dic[@"Id"],_accessToken,titleString];
    
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicRid = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dicRid[@"code"] integerValue];
        if (codeId == 1) {
            NSDictionary *dicDatas = dicRid[@"datas"];
            NSString *ridString = dicDatas[@"rid"];
            [self topicResetRidClear:ridString];
        }
    } RequestFaile:^(NSError *error) {
        
    }];
}
/**
 重置rid
 */
///再做一次时重置当前的记录(点击重新做题的一次时间)
- (void)topicResetRidClear:(NSString *)rid{
    //api/Chapter/ResetRecord?access_token={access_token}&rid={rid}
    NSString *urlString = [NSString stringWithFormat:@"%@api/Chapter/ResetRecord?access_token=%@&rid=%@",systemHttps,_accessToken,rid];
    [HttpTools postHttpRequestURL:urlString RequestPram:nil RequestSuccess:^(id respoes) {
        NSDictionary *diccc = (NSDictionary *)respoes;
        NSInteger codeId = [diccc[@"code"] integerValue];
        if (codeId == 1) {
            ///每周精选
            NSDictionary *dicDatas = diccc[@"datas"];
            NSString *ridString = dicDatas[@"rid"];
            [self performSegueWithIdentifier:@"topicStar" sender:ridString];
            
        }
    } RequestFaile:^(NSError *erro) {
        
    }];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"topicStar"]) {
        StartDoTopicViewController *topicVc = segue.destinationViewController;
        topicVc.paperParameter = 3;
        topicVc.rIdString = sender;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
