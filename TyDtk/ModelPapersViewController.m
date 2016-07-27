//
//  ModelPapersViewController.m
//  TyDtk
//  模拟试卷
//  Created by 天一文化 on 16/4/6.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "ModelPapersViewController.h"
#import "ActiveSubjectViewController.h"
///下拉菜单
#import "DOPDropDownMenu.h"
@interface ModelPapersViewController ()<UITableViewDataSource,UITableViewDelegate,ActiveSubjectDelegate,UIScrollViewDelegate,DOPDropDownMenuDataSource,DOPDropDownMenuDelegate>

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewLayoutTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewLauoutBottom;

@property (nonatomic, strong) UIButton *buttonLeveles;
@property (nonatomic, strong) UIButton *buttonYear;

//授权工具
@property (nonatomic,strong) CustomTools *customTools;
//本地信息存储
@property (nonatomic,strong) NSUserDefaults *tyUser;
//朦层
@property (nonatomic,strong) MZView *mzView;
//头试图
@property (nonatomic,strong) ActiveSubjectView *hearhVIew;
//空数据显示层
//@property (nonatomic,strong) ViewNullData *viewNilData;
//令牌
@property (nonatomic,strong)NSString *accessToken;
//储存的专业信息
@property (nonatomic,strong) NSDictionary *dicUserClass;

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
//上拉刷新控件
@property (nonatomic,strong) MJRefreshBackNormalFooter *refreshFooter;
//下拉刷新控件
@property (nonatomic,strong) MJRefreshNormalHeader *refreshHeader;
//回到顶部的按钮
@property (nonatomic,strong) UIButton *buttonTopTable;
///用户判断tableView的滑动方向
@property (nonatomic,assign) CGFloat lastContentOffset;
//@property (nonatomic,strong) UIView *dropDownMenu;
///下拉菜单
@property (nonatomic ,strong) DOPDropDownMenu *dropDownMenuHearder;
//试卷年份
@property (nonatomic ,strong) NSMutableArray *arrayYearN;
//试卷级别（试卷类型）
@property (nonatomic ,strong) NSMutableArray *arrayTypeN;
///判断是否登录
@property (nonatomic,assign) BOOL isLoginUser;
@end
@implementation ModelPapersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self viewLoad];
}
- (void)viewLoad{
    _arrayYearN = [NSMutableArray array];
    _arrayTypeN = [NSMutableArray array];
    
    _tyUser = [NSUserDefaults standardUserDefaults];
    _accessToken = [_tyUser objectForKey:tyUserAccessToken];
    if ([_tyUser objectForKey:tyUserUserInfo]) {
        _isLoginUser = YES;
    }
    else{
        _isLoginUser = NO;
    }
    //从题库进入
    if (_intPushWhere == 0) {
        _tableViewLayoutTop.constant = 40;
    }
    //从练习中心进入
    else{
        _tableViewLayoutTop.constant = 0;
        _tableViewLauoutBottom.constant = -49;
    }
    _arrayPapers = [NSMutableArray array];
    _myTableView.tableFooterView = [UIView new];
    [_buttonYear setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    [_buttonLeveles setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
     _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    //设置tableView的上拉控件
    _paterPages = 0;
    _paterIndexPage = 1;
    _paterYear = @"0";
    _paterLevel = @"0";
    [_arrayPapers removeAllObjects];
    [self getModelPapersData];
    [self getPaperLevels];
    [self addrefreshForTableViewFooter];
    
}
////////////////////////////////////////////////////
///添加下拉菜单
- (void)addDropDownMenuForTableView{
    if (!_dropDownMenuHearder) {
        _dropDownMenuHearder = [[DOPDropDownMenu alloc] initWithOrigin:CGPointMake(0, 64) andHeight:40];
        if (self.intPushWhere == 0) {
            CGRect rect = _dropDownMenuHearder.frame;
            rect.origin.y = 0;
            _dropDownMenuHearder.frame = rect;
        }
        _dropDownMenuHearder.indicatorColor = [UIColor orangeColor];
        _dropDownMenuHearder.textColor = ColorWithRGB(53, 122, 255);
        _dropDownMenuHearder.dataSource = self;
        _dropDownMenuHearder.delegate = self;
        [self.view addSubview:_dropDownMenuHearder];
        [self addRefreshForTableViewHeader];
    }
}
////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.tabBarController.tabBar.hidden = NO;
}
///添加下拉刷新
- (void)addRefreshForTableViewHeader{
    _refreshHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefereshMClick:)];
    _myTableView.mj_header = _refreshHeader;
}
//下拉刷新
- (void)headerRefereshMClick:(MJRefreshNormalHeader *)header{
    [self getPaperLevels];
    _myTableView.userInteractionEnabled = NO;
    ///重新判断科目是否激活
    if (_isLoginUser) {
        [self determineSubjectActive];
    }
    else{
        _paterPages = 0;
        _paterIndexPage = 1;
        [_arrayPapers removeAllObjects];
        [self getModelPapersData];
    }
}
- (void)addrefreshForTableViewFooter{
    _refreshFooter = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshMClick:)];
    [_refreshFooter setTitle:@"上拉查看更多试卷" forState:MJRefreshStateIdle];
    [_refreshFooter setTitle:@"松开加载更多试卷" forState:MJRefreshStatePulling];
    [_refreshFooter setTitle:@"正在为您加载更多试卷..." forState:MJRefreshStateRefreshing];
    [_refreshFooter setTitle:@"试卷已全部加载完毕" forState:MJRefreshStateNoMoreData];
    _myTableView.mj_footer = _refreshFooter;
}
///上拉刷新
- (void)footerRefreshMClick:(MJRefreshBackNormalFooter *)footer{
    [self getModelPapersData];
}
///判断科目是否激活（登录情况下）
- (void)determineSubjectActive{
    NSDictionary *dicUserInfo = [_tyUser objectForKey:tyUserUserInfo];
    NSString *urlString = [NSString stringWithFormat:@"%@/ty/mobile/order/productValidate?productId=%@&jeeId=%@",systemHttpsKaoLaTopicImg,_subjectId,dicUserInfo[@"jeeId"]];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicActive = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"%@",dicActive);
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
            [self getModelPapersData];

        }
    } RequestFaile:^(NSError *error) {
        
    }];
}

/**
 试卷信息列表的头试图
 */
- (void)addHeardViewForPaterList{
    _hearhVIew= [[[NSBundle mainBundle] loadNibNamed:@"ActiveSubjetView" owner:self options:nil]lastObject];
    _hearhVIew.delegateAtive = self;
    NSDictionary *dicsubjectCu = [_tyUser objectForKey:tyUserSelectSubject];
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Width/2 - 10)];
    [view addSubview:_hearhVIew];
    view.backgroundColor = [UIColor clearColor];
    _hearhVIew.subjectId = _subjectId;
    [_hearhVIew setActiveValue:dicsubjectCu];
    
    if (_isActiveSubject) {
        [_hearhVIew.buttonActive setTitle:@"科目已激活" forState:UIControlStateNormal];
        _hearhVIew.buttonActive.userInteractionEnabled = NO;
        _hearhVIew.buttonPay.userInteractionEnabled = NO;
        _hearhVIew.buttonPay.backgroundColor = [UIColor clearColor];
        [_hearhVIew.buttonPay setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    }
    _myTableView.tableHeaderView = view;
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
        ///
        [SVProgressHUD showInfoWithStatus:@"您还没有登录"];
    }
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
    if (self.intPushWhere == 1) {
        [SVProgressHUD show];
        //获取试卷级别
        ///添加朦层
        if (!_mzView) {
            _mzView = [[MZView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Height)];
        }
        [self.navigationController.tabBarController.view addSubview:_mzView];
    }
    NSString *urlString = [NSString stringWithFormat:@"%@api/Paper/GetPapers?access_token=%@&courseId=%@&page=%ld&level=%@&year=%@",systemHttps,_accessToken,_subjectId,_paterIndexPage,_paterLevel,_paterYear];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicModelPapers = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dicModelPapers[@"code"] integerValue];
        if (codeId == 1) {
            if (_paterIndexPage == 1) {
                [_arrayPapers removeAllObjects];
            }
            //获取最大页数
            NSDictionary *dicPage =dicModelPapers[@"page"];
            _paterPages = [dicPage[@"pages"] integerValue];
            //当前页数增加1
            _paterIndexPage = _paterIndexPage+1;
            //追加数据
            NSArray *arrayPaters = dicModelPapers[@"datas"];
            if (arrayPaters.count == 0) {
                [self addTableFooterView];
            }
            else{
                for (NSDictionary *dicPater in arrayPaters) {
                    [_arrayPapers addObject:dicPater];
                }
                _myTableView.tableFooterView = [UIView new];
            }
            [_mzView removeFromSuperview];
            [SVProgressHUD dismiss];
            [_refreshFooter endRefreshing];
            [_refreshHeader endRefreshing];
            [_myTableView reloadData];
            _buttonLeveles.userInteractionEnabled = YES;
            _buttonYear.userInteractionEnabled = YES;
            _myTableView.userInteractionEnabled = YES;
        }
        _myTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    } RequestFaile:^(NSError *error) {
        [_mzView removeFromSuperview];
        httpsErrorShow;
        [_refreshFooter endRefreshing];
        [_refreshHeader endRefreshing];
        _buttonYear.userInteractionEnabled = NO;
        _buttonLeveles.userInteractionEnabled = NO;
        _myTableView.userInteractionEnabled = YES;
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
    _myTableView.tableFooterView = viewFooter;
}
/**
 获取试卷类型
 */
- (void)getPaperLevels{
    NSString *urlString = [NSString stringWithFormat:@"%@api/Paper/GetPaperTypes?access_token=%@",systemHttps,_accessToken];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicLevels = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dicLevels[@"code"] integerValue];
        if (codeId == 1) {
            [_arrayTypeN removeAllObjects];
            NSArray *arrayType = dicLevels[@"datas"];
            
            NSDictionary *dicAllType = @{@"Names":@"全部试卷",@"Id":@"0"};
            [_arrayTypeN addObject:dicAllType];
            for (NSDictionary *dicType in arrayType) {
                [_arrayTypeN addObject:dicType];
            }
            
            [self getPaperYears];
        }
    } RequestFaile:^(NSError *error) {
        [_refreshHeader endRefreshing];
        _myTableView.userInteractionEnabled = YES;
        httpsErrorShow;
    }];
}
/**
 获取试卷年份
 */
- (void)getPaperYears{
    NSString *urlString = [NSString stringWithFormat:@"%@api/Paper/GetPaperYear",systemHttps];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicYesrs = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dicYesrs[@"code"] integerValue];
        if (codeId == 1) {
            [_arrayYearN removeAllObjects];
            NSArray *arrayYear = dicYesrs[@"datas"];
            
            NSDictionary *dicAllYear = @{@"Text":@"全部年份",@"Value":@"0"};
            [_arrayYearN addObject:dicAllYear];
            for (NSDictionary *dicYear in arrayYear) {
                [_arrayYearN addObject:dicYear];
            }
            
            [self addDropDownMenuForTableView];
        }
    } RequestFaile:^(NSError *error) {
        [_refreshHeader endRefreshing];
        _myTableView.userInteractionEnabled = YES;
        httpsErrorShow;
    }];
}

//tableView上的scroll代理，用户判断是否显示'回到顶部'按钮
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    if (_myTableView.contentOffset.y > Scr_Height - 64 - 50) {
//        [_buttonTopTable removeFromSuperview];
//        if (!_buttonTopTable) {
//            _buttonTopTable = [UIButton buttonWithType:UIButtonTypeCustom];
//            _buttonTopTable.frame = CGRectMake(Scr_Width - 55, Scr_Height - 300, 100, 30);
//            [_buttonTopTable setTitle:@"回到顶部" forState:UIControlStateNormal];
//            _buttonTopTable.titleLabel.font = [UIFont systemFontOfSize:12.0];
//            _buttonTopTable.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
//            _buttonTopTable.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//            _buttonTopTable.backgroundColor = ColorWithRGBWithAlpp(0, 0, 0, 0.3);
//            [_buttonTopTable setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
//            _buttonTopTable.layer.masksToBounds = YES;
//            _buttonTopTable.layer.cornerRadius = 5;
//            [_buttonTopTable addTarget:self action:@selector(topButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//        }
//        [self.view addSubview:_buttonTopTable];
//    }
//    else{
//        [_buttonTopTable removeFromSuperview];
//    }
    
    if (_lastContentOffset < scrollView.contentOffset.y) {
        //从题库进入
        if (_intPushWhere == 0) {
            [UIView animateWithDuration:0.3 animations:^{
                CGRect rect = _dropDownMenuHearder.frame;
                rect.origin.y = -40;
                _dropDownMenuHearder.frame = rect;
            }];
            _tableViewLayoutTop.constant = 0;
        }
        //从练习中心进入
        else{
            [UIView animateWithDuration:0.3 animations:^{
                CGRect rect = _dropDownMenuHearder.frame;
                rect.origin.y = 24;
                _dropDownMenuHearder.frame = rect;
            }];
            _tableViewLayoutTop.constant = 0;
        }
        
    }else{
        //从题库进入
        if (_intPushWhere == 0) {
            [UIView animateWithDuration:0.3 animations:^{
                //             _heardViewLayoutTop.constant = -40;
                CGRect rect = _dropDownMenuHearder.frame;
                rect.origin.y = 0;
                _dropDownMenuHearder.frame = rect;
            }];
            _tableViewLayoutTop.constant = 40;
        }
        //从练习中心进入
        else{
            [UIView animateWithDuration:0.3 animations:^{
                CGRect rect = _dropDownMenuHearder.frame;
                rect.origin.y = 64;
                _dropDownMenuHearder.frame = rect;
            }];
            _tableViewLayoutTop.constant = 40;
        }
    }
    
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    _lastContentOffset = scrollView.contentOffset.y;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{

}
//回到顶部按钮
- (void)topButtonClick:(UIButton *)topButton{
    [_myTableView setContentOffset:CGPointMake(0, 0) animated:YES];
}
///////////////////////////////////////
// tableview 代理
///////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _arrayPapers.count;
    
    
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
    //题量
    NSString *quantityString = [NSString stringWithFormat:@"%ld 题",[dicCurrPater[@"Quantity"] integerValue]];
    //题量属性字符串
    NSMutableAttributedString *attriQuantity = [[NSMutableAttributedString alloc] initWithString:quantityString];
    [attriQuantity addAttribute:NSForegroundColorAttributeName value:[UIColor brownColor]
                       range:NSMakeRange(0,[NSString stringWithFormat:@"%ld",[dicCurrPater[@"Quantity"] integerValue]].length )];
    [labQuantity setAttributedText:attriQuantity];
    
    //时间
     NSString *timeString = [NSString stringWithFormat:@"%ld 分钟",[dicCurrPater[@"TimeLong"] integerValue]];
    //时间属性字符串
    NSMutableAttributedString *attriTime = [[NSMutableAttributedString alloc] initWithString:timeString];
    [attriTime addAttribute:NSForegroundColorAttributeName value:[UIColor brownColor]
                          range:NSMakeRange(0,[NSString stringWithFormat:@"%ld",[dicCurrPater[@"TimeLong"] integerValue]].length )];
    [labTime setAttributedText:attriTime];
    //总分
    NSString *scoreString =[NSString stringWithFormat:@"%ld 分",[dicCurrPater[@"Score"] integerValue]];
    //总分属性字符串
    NSMutableAttributedString *attriScore = [[NSMutableAttributedString alloc] initWithString:scoreString];
    [attriScore addAttribute:NSForegroundColorAttributeName value:[UIColor brownColor]
                      range:NSMakeRange(0,[NSString stringWithFormat:@"%ld",[dicCurrPater[@"Score"] integerValue]].length )];
    [labScore setAttributedText:attriScore];
    //参数人数
    NSString *personString = [NSString stringWithFormat:@"%ld 人参与",[dicCurrPater[@"DoNum"] integerValue]];
    //参与人数属性字符串
    NSMutableAttributedString *attriperson = [[NSMutableAttributedString alloc] initWithString:personString];
    [attriperson addAttribute:NSForegroundColorAttributeName value:[UIColor brownColor]
                       range:NSMakeRange(0,[NSString stringWithFormat:@"%ld",[dicCurrPater[@"DoNum"] integerValue]].length )];
    [labPerson setAttributedText:attriperson];
    
    cell.backgroundColor = [UIColor whiteColor];
    ////////////////////////////////////////////
    ///登录状态
    if (_isLoginUser) {
        ///先判断是否激活
        if (_isActiveSubject) {
             cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        ///如果未激活，判断isopen
        else{
            ///章节开放，可做题
            if ([dicCurrPater[@"IsPublic"] integerValue] == 1) {
                 cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            else{
                 cell.accessoryType = UITableViewCellAccessoryDetailButton;
            }
        }
    }
    else{
        ///直接判断是否isOpen
        if ([dicCurrPater[@"IsPublic"] integerValue] == 1) {
             cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else{
             cell.accessoryType = UITableViewCellAccessoryDetailButton;
        }
    }
    return cell;
    
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *diccc = _arrayPapers[indexPath.row];
    ///登录状态
    if (_isLoginUser) {
        ///先判断是否激活
        if (_isActiveSubject) {
            [self performSegueWithIdentifier:@"topicStar" sender:diccc];
        }
        ///如果未激活，判断isopen
        else{
            ///章节开放，可做题
            if ([diccc[@"IsPublic"] integerValue] == 1) {
               [self performSegueWithIdentifier:@"topicStar" sender:diccc];
            }
            else{
                [SVProgressHUD showInfoWithStatus:@"该试卷需要激活科目才能做题哦"];
            }
        }
    }
    else{
        ///直接判断是否isOpen
        if ([diccc[@"IsPublic"] integerValue] == 1) {
            [self performSegueWithIdentifier:@"topicStar" sender:diccc];
        }
        else{
            [SVProgressHUD showInfoWithStatus:@"该试卷还未开放，您可以登录激活科目哦"];
        }
    }
}
//////////////////////////////////////////////////////////////////////////////
/**********DropDownMenu 代理*********/
///返回下拉菜单个数
- (NSInteger)numberOfColumnsInMenu:(DOPDropDownMenu *)menu {
    return 2;
}
///返回每个下拉菜单的item
- (NSInteger)menu:(DOPDropDownMenu *)menu numberOfRowsInColumn:(NSInteger)column {
    if (column == 0) {
        return _arrayTypeN.count;
    }
    else{
        return _arrayYearN.count;
    }
}
///返回每个下拉菜单的值
- (NSString *)menu:(DOPDropDownMenu *)menu titleForRowAtIndexPath:(DOPIndexPath *)indexPath {
    NSDictionary *dic;
    switch (indexPath.column) {
        case 0:
            dic = _arrayTypeN[indexPath.row];
            return dic[@"Names"];
            break;
        case 1:
            dic = _arrayYearN[indexPath.row];
            return dic[@"Text"];
            break;
        default:
            return nil;
            break;
    }
}
///下拉菜单点击事件
- (void)menu:(DOPDropDownMenu *)menu didSelectRowAtIndexPath:(DOPIndexPath *)indexPath {
    NSDictionary *dicSelect;
    ///试卷类型
    if (indexPath.column == 0) {
        dicSelect = _arrayTypeN[indexPath.row];
        _paterLevel = [NSString stringWithFormat:@"%ld",[dicSelect[@"Id"] integerValue]];
    }
    ///试卷年份
    else{
         dicSelect = _arrayYearN[indexPath.row];
        _paterYear = dicSelect[@"Value"];
    }
    if (self.intPushWhere == 0) {
        [SVProgressHUD show];
    }
    _myTableView.userInteractionEnabled = NO;
    _paterIndexPage = 1;
    _paterPages = 0;
    [self getModelPapersData];
}
/**********DropDownMenu 代理*********/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"topicStar"]) {
        StartDoTopicViewController *topicVc = segue.destinationViewController;
        topicVc.paperParameter = 2;
        topicVc.dicPater = sender;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
