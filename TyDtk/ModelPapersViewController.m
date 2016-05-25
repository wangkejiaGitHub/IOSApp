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
@property (weak, nonatomic) IBOutlet UIButton *buttonLeveles;
@property (weak, nonatomic) IBOutlet UIButton *buttonYear;

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
//试卷级别（试卷类型）
@property (nonatomic,strong) NSArray *arrayLevels;
//试卷年份
@property (nonatomic,strong) NSArray *arrayYears;
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
    _paterYear = @"0";
    _paterLevel = @"0";
    _arrayPapers = [NSMutableArray array];
    _myTableView.tableFooterView = [UIView new];
    [_buttonYear setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    [_buttonLeveles setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
}
- (void)viewDidAppear:(BOOL)animated{
    [self getPaperYears];
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
        //        _paterLevel = @"0";
        //        _paterYear =@"0";
        _paterPages = 0;
        _paterIndexPage = 1;
        [_arrayPapers removeAllObjects];
        [self getAccessToken];
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
    [self getPaperLevels];
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
        NSInteger codeId = [dicModelPapers[@"code"] integerValue];
        if (codeId == 1) {
            //获取最大页数
            NSDictionary *dicPage =dicModelPapers[@"page"];
            _paterPages = [dicPage[@"pages"] integerValue];
            //当前页数增加1
            _paterIndexPage = _paterIndexPage+1;
            //追加数据
            NSArray *arrayPaters = dicModelPapers[@"datas"];
            if (arrayPaters.count == 0) {
                
            _viewNilData = [[ViewNullData alloc]initWithFrame:CGRectMake(0, 40, Scr_Width, Scr_Height - 64 - 40 - 50 - Scr_Width/2+10) showText:@"没有更多试卷"];
                _myTableView.tableFooterView = _viewNilData;
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
            [_myTableView reloadData];
            
        }
        _myTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    } RequestFaile:^(NSError *error) {
        [_mzView removeFromSuperview];
        [SVProgressHUD showInfoWithStatus:@"请求异常"];
    }];
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
            _arrayLevels = dicLevels[@"datas"];
        }
    } RequestFaile:^(NSError *error) {
        
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
            _arrayYears = dicYesrs[@"datas"];
        }
    } RequestFaile:^(NSError *error) {
        [SVProgressHUD showInfoWithStatus:@"系统异常"];
    }];
}
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
    NSString *personString = [NSString stringWithFormat:@"%ld人参与",[dicCurrPater[@"DoNum"] integerValue]];
    //参与人数属性字符串
    NSMutableAttributedString *attriperson = [[NSMutableAttributedString alloc] initWithString:personString];
    [attriperson addAttribute:NSForegroundColorAttributeName value:[UIColor brownColor]
                       range:NSMakeRange(0,[NSString stringWithFormat:@"%ld",[dicCurrPater[@"DoNum"] integerValue]].length )];
    [labPerson setAttributedText:attriperson];
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
        topicVc.paperParameter = 2;
        topicVc.dicPater = sender;
    }
}
//试题类型按钮
- (IBAction)buttonTypeClick:(UIButton *)sender {
    [ZFPopupMenu setMenuBackgroundColorWithRed:0.6 green:0.4 blue:0.2 aphla:0.9];
    [ZFPopupMenu setTextColorWithRed:1 green:1 blue:1 aphla:1.0];
    [ZFPopupMenu setHighlightedImage:[UIImage imageNamed:@"cancelBg"]];
    ZFPopupMenu *popupMenu = [[ZFPopupMenu alloc] initWithItems:[self LevelsMenuItemArray]];
    CGRect rectBtn = sender.frame;
    rectBtn.origin.y = rectBtn.origin.y + 60;
    rectBtn.origin.x = rectBtn.origin.x - 10;
    [popupMenu showInView:self.navigationController.view fromRect:rectBtn layoutType:Vertical];
    [self.navigationController.view addSubview:popupMenu];
}
//试题年份按钮
- (IBAction)buttonYearClick:(UIButton *)sender {
    [ZFPopupMenu setMenuBackgroundColorWithRed:0.6 green:0.4 blue:0.2 aphla:0.9];
    [ZFPopupMenu setTextColorWithRed:1 green:1 blue:1 aphla:1.0];
    [ZFPopupMenu setHighlightedImage:[UIImage imageNamed:@"cancelBg"]];
    ZFPopupMenu *popupMenu = [[ZFPopupMenu alloc] initWithItems:[self yearMenuItemArray]];
    CGRect rectBtn = sender.frame;
    rectBtn.origin.y = rectBtn.origin.y + 60;
    rectBtn.origin.x = rectBtn.origin.x - 10;
    [popupMenu showInView:self.navigationController.view fromRect:rectBtn layoutType:Vertical];
    [self.navigationController.view addSubview:popupMenu];
}
//返回试题类型菜单item数组
- (NSArray *)LevelsMenuItemArray{
    NSMutableArray *arrayLevelMuen = [NSMutableArray array];
    ZFPopupMenuItem *itemA = [ZFPopupMenuItem initWithMenuName:@"全部" image:nil action:@selector(menuLevelsClick:) target:self];
    itemA.tag = 100 + 0;
    [arrayLevelMuen addObject:itemA];
    for (int i = 0; i<_arrayLevels.count; i++) {
        NSDictionary *dicLevels = _arrayLevels[i];
        ZFPopupMenuItem *item = [ZFPopupMenuItem initWithMenuName:dicLevels[@"Names"] image:nil action:@selector(menuLevelsClick:) target:self];
        item.tag = 100 + i + 1;
        [arrayLevelMuen addObject:item];
    }
    return arrayLevelMuen;
}
//返回年份菜单item数组
- (NSArray *)yearMenuItemArray{
    NSMutableArray *arrayYearMuen = [NSMutableArray array];
    ZFPopupMenuItem *itemA = [ZFPopupMenuItem initWithMenuName:@"全部" image:nil action:@selector(menuYearClick:) target:self];
    itemA.tag = 1000 + 0;
    [arrayYearMuen addObject:itemA];
    for (int i =0; i<_arrayYears.count; i++) {
        NSDictionary *dicYear = _arrayYears[i];
        ZFPopupMenuItem *item = [ZFPopupMenuItem initWithMenuName:dicYear[@"Value"] image:nil action:@selector(menuYearClick:) target:self];
        item.tag = 1000 + i + 1;
        [arrayYearMuen addObject:item];
    }
    return arrayYearMuen;
}
//点击年份菜单事件
- (void)menuYearClick:(ZFPopupMenuItem *)item{
    NSInteger itemIndex = item.tag - 1000;
    if (itemIndex == 0) {
        _paterYear = @"0";
        [_buttonYear setTitle:@"全部" forState:UIControlStateNormal];
    }
    else{
        NSDictionary *dicYear = _arrayYears[itemIndex - 1];
        _paterYear = dicYear[@"Value"];
        [_buttonYear setTitle:dicYear[@"Value"] forState:UIControlStateNormal];
    }
    
    _paterIndexPage = 1;
    _paterPages = 0;
    [_arrayPapers removeAllObjects];
    
    [self getModelPapersData];
    
}
//点击试卷类型菜单事件
- (void)menuLevelsClick:(ZFPopupMenuItem *)item{
    NSInteger itemIndex = item.tag - 100;
    if (itemIndex == 0) {
        _paterLevel = @"0";
        [_buttonLeveles setTitle:@"全部" forState:UIControlStateNormal];
    }
    else{
        NSDictionary *dicLevels = _arrayLevels[itemIndex - 1];
        _paterLevel = [NSString stringWithFormat:@"%ld",[dicLevels[@"Id"] integerValue]];
        [_buttonLeveles setTitle:dicLevels[@"Names"] forState:UIControlStateNormal];
    }
    _paterIndexPage = 1;
    _paterPages = 0;
    [_arrayPapers removeAllObjects];
    
    [self getModelPapersData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
