//
//  WeekSelectViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/5/18.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "WeekSelectViewController.h"

@interface WeekSelectViewController ()<CustomToolDelegate,ActiveDelegate,UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableViewWeek;

//授权工具
@property (nonatomic,strong) CustomTools *customTools;
//本地信息存储
@property (nonatomic,strong) NSUserDefaults *tyUser;
//朦层
@property (nonatomic,strong) MZView *mzView;
//头试图
@property (nonatomic,strong) ActiveVIew *hearhVIew;
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

//回到顶部的按钮
@property (nonatomic,strong) UIButton *buttonTopTable;
@end
@implementation WeekSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _arrayPapers = [NSMutableArray array];
    _tableViewWeek.tableFooterView = [UIView new];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated{
    //设置tableView的上拉控件
    _refreshFooter = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshClick:)];
    [_refreshFooter setTitle:@"上拉查看更多试卷" forState:MJRefreshStateIdle];
    [_refreshFooter setTitle:@"松开加载更多试卷" forState:MJRefreshStatePulling];
    [_refreshFooter setTitle:@"正在为您加载更多试卷..." forState:MJRefreshStateRefreshing];
    [_refreshFooter setTitle:@"试卷已全部加载完毕" forState:MJRefreshStateNoMoreData];
    _tableViewWeek.mj_footer = _refreshFooter;
    //试卷授权一次
    if (_allowToken) {
        //        _paterLevel = @"0";
        //        _paterYear =@"0";
        _paterPages = 0;
        _paterIndexPage = 1;
        [_arrayPapers removeAllObjects];
        [self getAccessToken];
    }
    _allowToken = NO;
}
- (void)viewDidAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = YES;
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
        _tableViewWeek.tableHeaderView = view;
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
 授权，收取令牌
 */
- (void)getAccessToken{
    _customTools = [[CustomTools alloc]init];
    _customTools.delegateTool = self;
    _tyUser = [NSUserDefaults standardUserDefaults];
    //获取储存的专业信息
    NSDictionary *dicUserInfo = [_tyUser objectForKey:tyUserUser];
    _dicUserClass = [_tyUser objectForKey:tyUserClass];
    if (!_mzView) {
        _mzView = [[MZView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Height)];
    }
    //授权并收取令牌
    NSString *classId = [NSString stringWithFormat:@"%@",_dicUserClass[@"Id"]];
    [_customTools empowerAndSignatureWithUserId:dicUserInfo[@"userId"] userName:dicUserInfo[@"name"] classId:classId subjectId:_subjectId];
}
/**
 授权成功
 */
- (void)httpSussessReturnClick{
     _accessToken = [_tyUser objectForKey:tyUserAccessToken];
    [self getWeekSelectPaper];
}
/**
授权失败
*/
-(void)httpErrorReturnClick{
    
}
//上拉刷新
- (void)footerRefreshClick:(MJRefreshBackNormalFooter *)footer{
    [self getWeekSelectPaper];
}
/**
 获取每周精选所有试题
 */
- (void)getWeekSelectPaper{
    //api/Weekly/GetWeeklyList?access_token={access_token}&page={page}&size={size}
    //在这之前比较当前页和最大页数的值
    if (_paterPages != 0) {
        if (_paterIndexPage > _paterPages) {
            [_refreshFooter endRefreshingWithNoMoreData];
            return;
        }
    }
    [self.view addSubview:_mzView];
    [SVProgressHUD show];
    [self addHeardViewForPaterList];
    NSString *urlString = [NSString stringWithFormat:@"%@api/Weekly/GetWeeklyList?access_token=%@&page=%ld",systemHttps,_accessToken,_paterIndexPage];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicWeek = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dicWeek[@"code"] integerValue];
        if (codeId == 1) {
            NSDictionary *dicPage =dicWeek[@"page"];
            _paterPages = [dicPage[@"pages"] integerValue];
            //当前页数增加1
            _paterIndexPage = _paterIndexPage+1;
            NSArray *arrayDatas = dicWeek[@"datas"];
            if (arrayDatas.count == 0) {
                
                _viewNilData = [[ViewNullData alloc]initWithFrame:CGRectMake(0, 40, Scr_Width, Scr_Height - 64 - 40 - 50 - Scr_Width/2 + 10) showText:@"没有更多试卷"];
                _tableViewWeek.tableFooterView = _viewNilData;
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
            [_tableViewWeek reloadData];
        }
    } RequestFaile:^(NSError *error) {
        [_mzView removeFromSuperview];
        [SVProgressHUD showInfoWithStatus:@"请求异常"];
    }];
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
