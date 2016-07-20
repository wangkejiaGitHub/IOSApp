//
//  ChaptersViewController.m
//  TyDtk
//  章节考点
//  Created by 天一文化 on 16/4/6.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "ChaptersViewController.h"
#import "MGSwipeTableCell.h"
#import "selectChaperSubjectView.h"
#import "SelectParTopicViewController.h"
#import "ActiveSubjectViewController.h"
@interface ChaptersViewController ()<UITableViewDataSource,UITableViewDelegate,ActiveSubjectDelegate,SelectSubjectDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomLayout;

//授权工具
@property (nonatomic,strong) CustomTools *customTools;
//本地信息存储
@property (nonatomic,strong) NSUserDefaults *tyUser;
//朦层
@property (nonatomic,strong) MZView *mzView;
@property (nonatomic,strong) NSDictionary *dicUserClass;
@property (nonatomic,strong) NSString *accessToken;
@property (nonatomic,strong) ActiveSubjectView *hearhVIew;
//section折叠数组
@property (nonatomic ,strong) NSMutableArray *arraySection;
/****************************************************/
/****************************************************/
//////////////????? 06-27记录修改 ???????//////////////
//////////////????? 06-27记录修改 ???????//////////////
@property (nonatomic,strong) NSArray *arrayAllChap;
//???????级数
@property (nonatomic,assign) NSInteger levelTT;
//??????????
@property (nonatomic,strong) NSMutableArray *arrayLinS;
//??????????
@property (nonatomic,strong) NSArray *arrayZong;
@property (nonatomic,strong) NSArray *arrayTableData;
//section折叠数组
//@property (nonatomic ,strong) NSMutableArray *arraySection;
//所有科目
@property (nonatomic,strong) NSArray *arraySubject;
//当前科目id
@property (nonatomic,assign) NSInteger intSubJectId;
//空数据显示
@property (nonatomic,strong) ViewNullData *viewNilData;
//刷新
@property (nonatomic,strong) MJRefreshNormalHeader *refreshHeader;
/****************************************************/
/****************************************************/
@property (nonatomic,strong) selectChaperSubjectView *viewSelectChaper;
@property (nonatomic,strong) NSDictionary *dicSelectChaper;
///判断是否登录
@property (nonatomic,assign) BOOL isLoginUser;
@end

@implementation ChaptersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _arraySection = [NSMutableArray array];
    _tyUser = [NSUserDefaults standardUserDefaults];
    _accessToken = [_tyUser objectForKey:tyUserAccessToken];
    _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if ([_tyUser objectForKey:tyUserUserInfo]) {
        _isLoginUser = YES;
    }
    else{
        _isLoginUser = NO;
    }
    [self addTableHeaderView];
    
    if (self.intPushWhere == 0) {
        _tableViewBottomLayout.constant = 49;
    }
    
    [self getChaptersInfo:_accessToken];
}
- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.tabBarController.tabBar.hidden = NO;
}
/**
 获取tableView的头试图，并设置其参数值
 */
- (void)addTableHeaderView{
    _dicUserClass = [_tyUser objectForKey:tyUserClass];
    NSDictionary *dicCurrSubject = [_tyUser objectForKey:tyUserSelectSubject];
    if (!_hearhVIew) {
        _hearhVIew= [[[NSBundle mainBundle] loadNibNamed:@"ActiveSubjetView" owner:self options:nil]lastObject];
        _hearhVIew.delegateAtive = self;
        _hearhVIew.subjectId = _subjectId;
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Width/2 -10)];
        [view addSubview:_hearhVIew];
        view.backgroundColor = [UIColor whiteColor];
        _myTableView.tableHeaderView = view;
    }
    [_hearhVIew setActiveValue:dicCurrSubject];
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
 获取章节考点信息,并根据节点进行章节分类
 */
- (void)getChaptersInfo:(NSString *)accessToken{
    if (self.intPushWhere == 1) {
        [SVProgressHUD show];
        ///添加朦层
        if (!_mzView) {
            _mzView = [[MZView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Height)];
        }
        [self.navigationController.tabBarController.view addSubview:_mzView];
    }
    NSString *urlString = [NSString stringWithFormat:@"%@api/Chapter/GetAll?access_token=%@",systemHttps,accessToken];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicChaper = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        if ([dicChaper[@"code"] integerValue] == 1) {
            _arrayAllChap = dicChaper[@"datas"];
            if (_arrayAllChap.count > 0) {
                for (NSDictionary *dicArr in _arrayAllChap) {
                    NSInteger le = [dicArr[@"Level"] integerValue];
                    if (le > _levelTT) {
                        _levelTT = le;
                    }
                }
                _myTableView.tableFooterView = [UIView new];
                [self getFirstLevelAndDate];
            }
            ///没有收藏关于该科目的试题
            else{
                [self addNilDataViewForTableFooterView];
            }

        }

        [_mzView removeFromSuperview];
        //重新刷新数据，让tableView返回到顶部
        [_myTableView reloadData];
        [SVProgressHUD dismiss];
    } RequestFaile:^(NSError *error) {
        [_mzView removeFromSuperview];
        [SVProgressHUD showErrorWithStatus:@"网络异常"];
        [_refreshHeader endRefreshing];
    }];
}
///获取第一层和第二层显示的数据
- (void)getFirstLevelAndDate{
    NSMutableArray *arrayFirstLevel = [NSMutableArray array];
    
    for (NSDictionary *dicFirst in _arrayAllChap) {
        if ([dicFirst[@"ParentId"] integerValue] == 0) {
            [arrayFirstLevel addObject:dicFirst];
        }
    }
    NSMutableArray *arrayZZZ = [NSMutableArray array];
    
    for (NSDictionary *dicFir in arrayFirstLevel) {
        NSMutableArray *arrayFir = [NSMutableArray array];
        NSMutableDictionary *dicFirrr = [NSMutableDictionary dictionary];
        for (NSDictionary *dicA in _arrayAllChap) {
            if ([dicFir[@"Id"] integerValue] == [dicA[@"ParentId"] integerValue]) {
                [arrayFir addObject:dicA];
            }
        }
        [dicFirrr setObject:arrayFir forKey:@"node"];
        [dicFirrr setObject:dicFir forKey:@"id"];
        [arrayZZZ addObject:dicFirrr];
    }
    _arrayTableData = arrayZZZ;
    [_myTableView reloadData];
}
///当没有收藏选中科目下的试题时，显示空数据视图信息
- (void)addNilDataViewForTableFooterView{
    _arrayTableData = nil;
    [_myTableView reloadData];
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 100)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *labText = [[UILabel alloc]initWithFrame:CGRectMake(30, 30, Scr_Width - 60, 30)];
    labText.font = [UIFont systemFontOfSize:18.0];
    labText.textColor= [UIColor lightGrayColor];
    labText.textAlignment = NSTextAlignmentCenter;
    labText.text = @"没有更多试卷了";
    [view addSubview:labText];
    _myTableView.tableFooterView = view;
}

////////////////////////////
//tableView 代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSString *str = [NSString stringWithFormat:@"%ld",section];
    if ([_arraySection containsObject:str]) {
        NSDictionary *dicData = _arrayTableData[section];
        NSArray *arrayData = dicData[@"node"];
        return arrayData.count;
    }
    else{
        return 0;
    }
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
     return _arrayTableData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 45;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 45)];
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 5;
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    NSDictionary *dicDate = _arrayTableData[section];
    NSDictionary *dicHeader = dicDate[@"id"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, Scr_Width, view.frame.size.height);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    //    [button setTitle:dicHeader[@"Names"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonSectionClick:) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font = [UIFont systemFontOfSize:13.0];
    button.tag = 100 + section;
    [view addSubview:button];
    
    //title字符
    NSString *titleString = [NSString stringWithFormat:@"%@（总共%ld题）",dicHeader[@"Names"],[dicHeader[@"Quantity"] integerValue]];
    //标题属性字符串
    NSMutableAttributedString *attriTitle = [[NSMutableAttributedString alloc] initWithString:titleString];
    
    [attriTitle addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor]
                       range:NSMakeRange([NSString stringWithFormat:@"%@",dicHeader[@"Names"]].length,5+[NSString stringWithFormat:@"%ld",[dicHeader[@"Quantity"] integerValue]].length)];
    UIFont *titleFont = [UIFont systemFontOfSize:12.0];
    [attriTitle addAttribute:NSFontAttributeName value:titleFont
                       range:NSMakeRange([NSString stringWithFormat:@"%@",dicHeader[@"Names"]].length ,5+[NSString stringWithFormat:@"%ld",[dicHeader[@"Quantity"] integerValue]].length)];
    
    UILabel *labText = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, Scr_Width - 10 - 60, view.frame.size.height)];
    //    labText.text = dicHeader[@"Names"];
    labText.textColor = ColorWithRGB(53, 122, 255);
    labText.numberOfLines = 0;
    labText.font = [UIFont systemFontOfSize:14.0];
    
    [labText setAttributedText:attriTitle];
    [view addSubview:labText];
    
    UIButton *btnDoTopic = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDoTopic.frame = CGRectMake(Scr_Width - 55, 11, 50, 23);
    btnDoTopic.layer.masksToBounds = YES;
    btnDoTopic.layer.cornerRadius = 3;
    btnDoTopic.backgroundColor = ColorWithRGB(200, 200, 200);
    [btnDoTopic setTitle:@"做题" forState:UIControlStateNormal];
    btnDoTopic.layer.borderWidth = 1;
    btnDoTopic.layer.borderColor = [ColorWithRGBWithAlpp(0, 0, 0, 0.3) CGColor];
    btnDoTopic.tag = 1000 +section;
    btnDoTopic.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [btnDoTopic setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btnDoTopic addTarget:self action:@selector(btnDoTopicClick:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnDoTopic];
    return view;
}
- (void)btnDoTopicClick:(UIButton *)button{
    NSDictionary *dicDate = _arrayTableData[button.tag - 1000];
    NSDictionary *dicHeader = dicDate[@"id"];
    [self isActiveSubjectAndDoTopicWithDictionary:dicHeader];
}
//section折叠
- (void)buttonSectionClick:(UIButton *)sender{
    NSInteger sectoinId = sender.tag - 100;
    NSString *str = [NSString stringWithFormat:@"%ld",sectoinId];
    if ([_arraySection containsObject:str]) {
        [_arraySection removeObject:str];
    }
    else{
        [_arraySection addObject:str];
    }
    
    [_myTableView reloadSections:[NSIndexSet indexSetWithIndex:sectoinId] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)sectionBtnClick:(UIButton *)sender{
        NSString *secString = [NSString stringWithFormat:@"%ld",sender.tag - 1000];
    if ([_arraySection containsObject:secString]) {
        [_arraySection removeObject:secString];
    }
    else{
        [_arraySection addObject:secString];
    }
    [_myTableView reloadSections:[NSIndexSet indexSetWithIndex:sender.tag - 1000] withRowAnimation:UITableViewRowAnimationAutomatic];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dicData = _arrayTableData[indexPath.section];
    NSArray *arrayData = dicData[@"node"];
    NSDictionary *dic = arrayData[indexPath.row];
    NSString *cellIdentifer = @"programmaticCell";
    MGSwipeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (!cell) {
        cell = [[MGSwipeTableCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifer];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    for (id subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(25, (50-9)/2, 9, 9)];
    view.backgroundColor = ColorWithRGB(90, 144, 266);
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 4.5;
    [cell.contentView addSubview:view];
    if (arrayData.count > 1) {
        UIView *viewLY = [[UIView alloc]initWithFrame:CGRectMake(29, 0, 1, 50)];
        if (indexPath.row == 0) {
            viewLY.frame = CGRectMake(29, 25, 1, 25);
        }
        else if (indexPath.row == arrayData.count - 1){
            viewLY.frame = CGRectMake(29, 0, 1, 25);
        }
        viewLY.backgroundColor = ColorWithRGB(90, 144, 266);
        [cell.contentView addSubview:viewLY];
    }
     NSString *titleString = [NSString stringWithFormat:@"%@（总共%ld题）",dic[@"Names"],[dic[@"Quantity"] integerValue]];
    //标题属性字符串
    NSMutableAttributedString *attriTitle = [[NSMutableAttributedString alloc] initWithString:titleString];
    
    [attriTitle addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor]
                       range:NSMakeRange([NSString stringWithFormat:@"%@",dic[@"Names"]].length,5+[NSString stringWithFormat:@"%ld",[dic[@"Quantity"] integerValue]].length)];
    UIFont *titleFont = [UIFont systemFontOfSize:12.0];
    [attriTitle addAttribute:NSFontAttributeName value:titleFont
                       range:NSMakeRange([NSString stringWithFormat:@"%@",dic[@"Names"]].length ,5+[NSString stringWithFormat:@"%ld",[dic[@"Quantity"] integerValue]].length)];
    
    UILabel *labT = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, Scr_Width - 60, 50)];
    labT.numberOfLines = 0;
    labT.font = [UIFont systemFontOfSize:13.0];
    [labT setAttributedText:attriTitle];
    
    MGSwipeButton *btnTopic = [MGSwipeButton buttonWithTitle:@"做 题" icon:nil backgroundColor:ColorWithRGB(109, 188, 254) callback:^BOOL(MGSwipeTableCell *sender) {
        [self isActiveSubjectAndDoTopicWithDictionary:dic];
        return YES;
    }];
    cell.rightButtons = @[btnTopic];
    
    [cell.contentView addSubview:labT];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dicData = _arrayTableData[indexPath.section];
    NSArray *arrayData = dicData[@"node"];
    NSDictionary *dic = arrayData[indexPath.row];
    [self getChildSubjectChaper:dic];
}
/**根据点击tableViewcell上的chaperid获取ParentId等于该id的所有章节数组
 并获取其对应的字章节数组
 */
- (void)getChildSubjectChaper:(NSDictionary *)dicChaper{
    NSInteger chaperId = [dicChaper[@"Id"] integerValue];
    
    NSMutableArray *arrayChaperIdCh = [NSMutableArray array];
    for (NSDictionary *dicChild in _arrayAllChap) {
        if ([dicChild[@"ParentId"] integerValue] == chaperId) {
            [arrayChaperIdCh addObject:dicChild];
        }
    }
    NSMutableArray *arrayZZZ = [NSMutableArray array];
    for (NSDictionary *dicC in arrayChaperIdCh) {
        NSMutableArray *arrayFir = [NSMutableArray array];
        NSMutableDictionary *dicFirrr = [NSMutableDictionary dictionary];
        for (NSDictionary *dicA in _arrayAllChap) {
            if ([dicC[@"Id"] integerValue] == [dicA[@"ParentId"] integerValue]) {
                [arrayFir addObject:dicA];
            }
        }
        [dicFirrr setObject:arrayFir forKey:@"node"];
        [dicFirrr setObject:dicC forKey:@"id"];
        [arrayZZZ addObject:dicFirrr];
    }
    
    [self viewSmallAnimation];
    _viewSelectChaper = [[selectChaperSubjectView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Height) arrayChaperSubject:arrayZZZ chaperName:dicChaper[@"Names"]];
    _viewSelectChaper.delegateChaper = self;
    UIWindow *dd = [[UIApplication sharedApplication] keyWindow];
    [dd addSubview:_viewSelectChaper];
}

//试图还原动画
- (void)viewBigAnimation{
    CABasicAnimation *cba1=[CABasicAnimation animationWithKeyPath:@"position"];
    cba1.fromValue=[NSValue valueWithCGPoint:CGPointMake(self.navigationController.tabBarController.view.center.x, self.navigationController.tabBarController.view.center.y - 30)];
    cba1.toValue=[NSValue valueWithCGPoint:self.navigationController.tabBarController.view.center];

    CABasicAnimation *cba2=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
    cba2.fromValue=[NSNumber numberWithFloat:0.85];
    cba2.toValue=[NSNumber numberWithFloat:1];
    
    CAAnimationGroup *grop = [CAAnimationGroup animation];
    grop.animations = @[cba1,cba2];
    grop.duration = 0.3;
    grop.removedOnCompletion=NO;
    grop.fillMode=kCAFillModeForwards;
    grop.delegate = self;
    [self.navigationController.tabBarController.view.layer addAnimation:grop forKey:@"big"];
}
//试图缩小动画
- (void)viewSmallAnimation{
    CABasicAnimation *cba1=[CABasicAnimation animationWithKeyPath:@"position"];
    cba1.fromValue=[NSValue valueWithCGPoint:self.navigationController.tabBarController.view.center];
    cba1.toValue=[NSValue valueWithCGPoint:CGPointMake(self.navigationController.tabBarController.view.center.x, self.navigationController.tabBarController.view.center.y - 30)];
    
    CABasicAnimation *cba2=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
    cba2.fromValue=[NSNumber numberWithFloat:1];
    cba2.toValue=[NSNumber numberWithFloat:0.85];
    
    CAAnimationGroup *grop = [CAAnimationGroup animation];
    grop.animations = @[cba1,cba2];
    grop.duration = 0.3;
    grop.removedOnCompletion=NO;
    grop.fillMode=kCAFillModeForwards;
    grop.delegate = self;
    [self.navigationController.tabBarController.view.layer addAnimation:grop forKey:@"small"];
}
///动画结束代理（主要判断选过科目之后的动画，执行授权操作）
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (anim == [self.navigationController.tabBarController.view.layer animationForKey:@"big"]) {
        if (_dicSelectChaper != nil) {
            [self isActiveSubjectAndDoTopicWithDictionary:_dicSelectChaper];
        }
    }
}
///判断章节id是否可开放做题
- (void)isActiveSubjectAndDoTopicWithDictionary:(NSDictionary *)dicChaper{
    ///登录状态
    if (_isLoginUser) {
        ///先判断是否激活
        if (_isActiveSubject) {
            [self startDoToic:dicChaper];
        }
        ///如果未激活，判断isopen
        else{
            ///章节开放，可做题
            if ([dicChaper[@"IsOpen"] integerValue] == 1) {
               [self startDoToic:dicChaper];
            }
            else{
                [SVProgressHUD showInfoWithStatus:@"此章节需要激活科目才能做题哦"];
            }
        }
    }
    else{
        ///直接判断是否isOpen
        if ([dicChaper[@"IsOpen"] integerValue] == 1) {
            [self startDoToic:dicChaper];
        }
        else{
            [SVProgressHUD showInfoWithStatus:@"此章节还未开放，您可以登录激活科目哦"];
        }
    }
}
///跳转到章节做题筛选页面
- (void)startDoToic:(NSDictionary *)dicSelectTopic{
    SelectParTopicViewController *selectChap = [[SelectParTopicViewController alloc]initWithNibName:@"SelectParTopicViewController" bundle:nil];
    selectChap.chaperId = [dicSelectTopic[@"Id"] integerValue];
    selectChap.chaperName = dicSelectTopic[@"Names"];
    [self.navigationController pushViewController:selectChap animated:YES];
}
///选择三级（四级）后的章节回调
- (void)selectSubjectViewDismiss:(NSDictionary *)dicSubject{
    _dicSelectChaper = dicSubject;
    [_viewSelectChaper removeFromSuperview];
    [self viewBigAnimation];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
