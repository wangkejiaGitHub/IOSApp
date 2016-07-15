//
//  MyCollectViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/6/8.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "MyCollectViewController.h"
#import "MGSwipeButton.h"
#import "MGSwipeTableCell.h"
#import "StartLookViewController.h"
#import "SelectParTopicViewController.h"
#import "MyNoteViewController.h"
@interface MyCollectViewController ()<UITableViewDataSource,UITableViewDelegate,CustomToolDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableViewCollect;
@property (weak, nonatomic) IBOutlet UILabel *labSubject;

@property (nonatomic,strong) NSUserDefaults *tyUser;
@property (nonatomic,strong) NSString *accessToken;
@property (nonatomic,strong) NSArray *arrayAllChap;
//???????级数
@property (nonatomic,assign) NSInteger levelTT;
//??????????
@property (nonatomic,strong) NSMutableArray *arrayLinS;
//??????????
@property (nonatomic,strong) NSArray *arrayZong;
@property (nonatomic,strong) NSArray *arrayTableData;
//section折叠数组
@property (nonatomic ,strong) NSMutableArray *arraySection;
//所有科目
@property (nonatomic,strong) NSArray *arraySubject;
//当前科目id
@property (nonatomic,assign) NSInteger intSubJectId;
//空数据显示
@property (nonatomic,strong) ViewNullData *viewNilData;
//授权工具
@property (nonatomic,strong) CustomTools *customTools;
//刷新
@property (nonatomic,strong) MJRefreshNormalHeader *refreshHeader;
@end

@implementation MyCollectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tyUser = [NSUserDefaults standardUserDefaults];
    _accessToken = [_tyUser objectForKey:tyUserAccessToken];
    _tableViewCollect.separatorStyle = UITableViewCellSeparatorStyleNone;
    NSDictionary *dicSubject = [_tyUser objectForKey:tyUserSelectSubject];
    if (self.parameterView == 1) {
        self.title = @"我的收藏";
    }
    else if (self.parameterView == 2){
        self.title = @"我的错题";
        //        [self getAllErrorTopicOfChapter];
    }
    else if (self.parameterView == 3){
        self.title = @"我的笔记";
    }
    _customTools = [[CustomTools alloc]init];
    _customTools.delegateTool = self;
    _arraySection = [NSMutableArray array];
    _levelTT = 0;
    _arrayLinS = [NSMutableArray array];
    
    _labSubject.userInteractionEnabled = NO;
    [self addTapGestForLabelSubject];
    
    _labSubject.text = dicSubject[@"Names"];
    _labSubject.textColor = ColorWithRGB(90, 144, 266);
    NSDictionary *dicClass = [_tyUser objectForKey:tyUserClass];
    NSInteger classId = [dicClass[@"Id"] integerValue];
    [self getAllSubjectWithClass:classId];
    _tableViewCollect.tableFooterView = [UIView new];
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.tabBarController.tabBar.hidden = NO;
    //??????
    //    [self chapterInfoTest];
    //    [self getCollectTopicWithChaperId];
    //??????
}
- (void)viewDidAppear:(BOOL)animated{
    _refreshHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefereshClick:)];
    _tableViewCollect.mj_header = _refreshHeader;
    
}
- (void)headerRefereshClick:(MJRefreshNormalHeader *)reFresh{
    if (self.parameterView == 1) {
        [self getAboutChaperCollect];
    }
    else if (self.parameterView == 2){
        [self getAboutChaperErrorTopic];
    }
    else if (self.parameterView == 3){
        [self getAboutChaperNotes];
    }
}
- (void)viewDidDisappear:(BOOL)animated{
    _refreshHeader = nil;
}
///给科目label添加点击手势
- (void)addTapGestForLabelSubject{
    UITapGestureRecognizer *tapSubject = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelSelectSubjectClick:)];
    [_labSubject addGestureRecognizer:tapSubject];
}
//选择科目
- (void)labelSelectSubjectClick:(UITapGestureRecognizer *)tapGest{
    [ZFPopupMenu setMenuBackgroundColorWithRed:0.6 green:0.4 blue:0.2 aphla:0.9];
    [ZFPopupMenu setTextColorWithRed:1 green:1 blue:1 aphla:1.0];
    [ZFPopupMenu setHighlightedImage:[UIImage imageNamed:@"cancelBg"]];
    ZFPopupMenu *popupMenu = [[ZFPopupMenu alloc] initWithItems:[self subjectMenuItemArray]];
    [popupMenu showInView:self.navigationController.view fromRect:CGRectMake(65, -30, 0, 120) layoutType:Vertical];
    [self.navigationController.view addSubview:popupMenu];
}
///返回科目菜单数组
- (NSArray *)subjectMenuItemArray{
    NSMutableArray *arraySubjectMuen = [NSMutableArray array];
    for (int i =0; i<_arraySubject.count; i++) {
        NSDictionary *dicSubject = _arraySubject[i];
        ZFPopupMenuItem *item = [ZFPopupMenuItem initWithMenuName:dicSubject[@"Names"] image:nil action:@selector(menuSubjectClick:) target:self];
        item.tag = 100 + i;
        [arraySubjectMuen addObject:item];
    }
    return arraySubjectMuen;
}
///科目选择点击事件
- (void)menuSubjectClick:(ZFPopupMenuItem *)item{
    _labSubject.text = item.itemName;
    NSDictionary *dicSelectSubject = _arraySubject[item.tag - 100];
    _intSubJectId = [dicSelectSubject[@"Id"] integerValue];
    _levelTT = 0;
    [_arraySection removeAllObjects];
    if (self.parameterView == 1) {
        //我的收藏
        [self customGetAccessToken:_intSubJectId];
    }
    else if (self.parameterView == 2){
        //我的错题
        //        [self getAboutChaperErrorTopic];
        [self customGetAccessToken:_intSubJectId];
    }
    else if (self.parameterView == 3){
        //我的笔记
        //        [self getAboutChaperNotes];
        [self customGetAccessToken:_intSubJectId];
    }
}
/**
 科目授权
 */
- (void)customGetAccessToken:(NSInteger)subjectId{
    [SVProgressHUD show];
    NSDictionary *dicUser = [_tyUser objectForKey:tyUserUserInfo];
    NSDictionary *dicClass = [_tyUser objectForKey:tyUserClass];
    /**
     [_customTools empowerAndSignatureWithUserId:dicUserInfo[@"userId"] userName:dicUserInfo[@"name"] classId:classId subjectId:_subjectId];
     */
    NSString *classId = [NSString stringWithFormat:@"%@",dicClass[@"Id"]];
    [_customTools empowerAndSignatureWithUserId:dicUser[@"userId"] userCode:dicUser[@"userCode"] classId: classId subjectId:[NSString stringWithFormat:@"%ld",subjectId]];
}
/**
 授权回调
 */
//授权成功
- (void)httpSussessReturnClick{
    _accessToken = [_tyUser objectForKey:tyUserAccessToken];
    if (self.parameterView == 1) {
        [self getAboutChaperCollect];
    }
    //错题
    else if (self.parameterView == 2) {
        [self getAboutChaperErrorTopic];
    }
    //笔记
    else if (self.parameterView == 3){
        [self getAboutChaperNotes];
    }
}
//授权失败
-(void)httpErrorReturnClick{
    [SVProgressHUD dismiss];
}
///获取当前专业下的所有科目
- (void)getAllSubjectWithClass:(NSInteger)classId{
    [SVProgressHUD show];
    NSString *urlString = [NSString stringWithFormat:@"%@api/CourseInfo/%ld",systemHttps,classId];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicSubject = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dicSubject[@"code"] integerValue];
        if (codeId == 1) {
            _arraySubject = dicSubject[@"datas"];
            //            [self getExerciseRe];
            //            NSDictionary *dicFirst = _arraySubject[0];
            //            _intSubJectId = [dicFirst[@"Id"] integerValue];
            //            _labSubject.text = dicFirst[@"Names"];
            _labSubject.userInteractionEnabled = YES;
            if (self.parameterView == 1) {
                [self getAboutChaperCollect];
            }
            else if (self.parameterView == 2){
                [self getAboutChaperErrorTopic];
            }
            else if (self.parameterView == 3){
                [self getAboutChaperNotes];
            }
            
        }
    } RequestFaile:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"网络异常"];
    }];
}
//*****************************************//
//////////////////我的收藏（模块）////////////////////
/**
 获取收藏章节考点信息
 */
- (void)getAboutChaperCollect{
    [SVProgressHUD showWithStatus:@"正在加载..."];
    //api/Collection/GetCollectionAboutChapters?access_token={access_token}&courseId={courseId};
    //    NSDictionary *dicSubject = [_tyUser objectForKey:tyUserSubject];
    NSString *urlString;
    if (_intSubJectId != 0) {
        urlString = [NSString stringWithFormat:@"%@api/Collection/GetCollectionAboutChapters?access_token=%@&courseId=%ld",systemHttps,_accessToken,_intSubJectId];
    }
    else{
        NSDictionary *dicSubject = [_tyUser objectForKey:tyUserSelectSubject];
        urlString = [NSString stringWithFormat:@"%@api/Collection/GetCollectionAboutChapters?access_token=%@&courseId=%ld",systemHttps,_accessToken,[dicSubject[@"Id"] integerValue]];
    }
    
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicCollect =[NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dicCollect[@"code"] integerValue];
        if (codeId == 1) {
            _arrayAllChap = dicCollect[@"datas"];
            if (_arrayAllChap.count > 0) {
                for (NSDictionary *dicArr in _arrayAllChap) {
                    NSInteger le = [dicArr[@"Level"] integerValue];
                    if (le > _levelTT) {
                        _levelTT = le;
                    }
                }
                _tableViewCollect.tableFooterView = [UIView new];
                [self getFirstLevelAndDate];
            }
            ///没有收藏关于该科目的试题
            else{
                [self addNilDataViewForTableFooterView];
            }
            
        }
        [_refreshHeader endRefreshing];
        [SVProgressHUD dismiss];
    } RequestFaile:^(NSError *error) {
        [_refreshHeader endRefreshing];
        [SVProgressHUD showErrorWithStatus:@"网络异常"];
    }];
}
/////////////////我的收藏（模块）////////////////////
//****************************************//

//****************************************//
//////////////////我的错题（模块）////////////////////
/**
 获取错题章节考点信息
 */
- (void)getAboutChaperErrorTopic{
    //api/Error/GetErrorAboutChapters?access_token={access_token}&courseId={courseId}
    [SVProgressHUD showWithStatus:@"正在加载..."];
    NSString *urlString;
    if (_intSubJectId != 0) {
        urlString = [NSString stringWithFormat:@"%@api/Error/GetErrorAboutChapters?access_token=%@&courseId=%ld",systemHttps,_accessToken,_intSubJectId];
    }
    else{
        NSDictionary *dicSubject = [_tyUser objectForKey:tyUserSelectSubject];
        urlString = [NSString stringWithFormat:@"%@api/Error/GetErrorAboutChapters?access_token=%@&courseId=%ld",systemHttps,_accessToken,[dicSubject[@"Id"] integerValue]];
    }
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicError =[NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dicError[@"code"] integerValue];
        if (codeId == 1) {
            _arrayAllChap = dicError[@"datas"];
            if (_arrayAllChap.count > 0) {
                for (NSDictionary *dicArr in _arrayAllChap) {
                    NSInteger le = [dicArr[@"Level"] integerValue];
                    if (le > _levelTT) {
                        _levelTT = le;
                    }
                }
                _tableViewCollect.tableFooterView = [UIView new];
                [self getFirstLevelAndDate];
            }
            ///没有收藏关于该科目的试题
            else{
                [self addNilDataViewForTableFooterView];
            }
        }
        [_refreshHeader endRefreshing];
        [SVProgressHUD dismiss];
        
    } RequestFaile:^(NSError *error) {
        [_refreshHeader endRefreshing];
        [SVProgressHUD showErrorWithStatus:@"网络异常"];
    }];
}
////////////// 我的错题（模块）////////////////
//****************************************//

//****************************************//
//////////////////我的笔记（模块）////////////
/**
 获取笔记章节考点信息
 */
- (void)getAboutChaperNotes{
    [SVProgressHUD show];
    NSString *urlString;
    if (_intSubJectId != 0) {
        urlString = [NSString stringWithFormat:@"%@api/Note/GetMyNotesAboutChapters?access_token=%@&courseId=%ld",systemHttps,_accessToken,_intSubJectId];
    }
    else{
        NSDictionary *dicSubject = [_tyUser objectForKey:tyUserSelectSubject];
        urlString = [NSString stringWithFormat:@"%@api/Note/GetMyNotesAboutChapters?access_token=%@&courseId=%ld",systemHttps,_accessToken,[dicSubject[@"Id"] integerValue]];
    }
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicNotes =[NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dicNotes[@"code"] integerValue];
        if (codeId == 1) {
            _arrayAllChap = dicNotes[@"datas"];
            if (_arrayAllChap.count > 0) {
                for (NSDictionary *dicArr in _arrayAllChap) {
                    NSInteger le = [dicArr[@"Level"] integerValue];
                    if (le > _levelTT) {
                        _levelTT = le;
                    }
                }
                _tableViewCollect.tableFooterView = [UIView new];
                [self getFirstLevelAndDate];
            }
            ///没有收藏关于该科目的试题
            else{
                [self addNilDataViewForTableFooterView];
            }
            
        }
        [_refreshHeader endRefreshing];
        [SVProgressHUD dismiss];
        
    } RequestFaile:^(NSError *error) {
        [_refreshHeader endRefreshing];
        [SVProgressHUD showErrorWithStatus:@"网络异常"];
    }];
    
}

//****************************************//
//////////////////我的笔记（模块）////////////////////


///当没有收藏选中科目下的试题时，显示空数据视图信息
- (void)addNilDataViewForTableFooterView{
    _arrayTableData = nil;
    [_tableViewCollect reloadData];
    if (self.parameterView == 1) {
        _viewNilData = [[ViewNullData alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Height - 69- 49 - 40) showText:@"没有收藏关于该科目的试题~"];
    }
    else if (self.parameterView == 2){
        _viewNilData = [[ViewNullData alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Height - 69- 49 - 40) showText:@"没有关于该科目的错题~"];
    }
    else if (self.parameterView == 3){
        _viewNilData = [[ViewNullData alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Height - 69- 49 - 40) showText:@"没有关于该科目的笔记~"];
    }
    
    _tableViewCollect.tableFooterView = _viewNilData;
}
/////////////////递归///////////////////
- (void)chappppppp:(NSArray *)arrayL{
    NSMutableArray *arrayLjian1 = [NSMutableArray array];
    for (NSDictionary *dic in _arrayAllChap) {
        if ([dic[@"Level"] integerValue] == _levelTT - 1) {
            [arrayLjian1 addObject:dic];
        }
    }
    NSMutableArray *arrayZ = [NSMutableArray array];
    for (NSDictionary *dicjian1 in arrayLjian1) {
        NSMutableArray *arrayCh = [NSMutableArray array];
        NSMutableDictionary *dicCh = [NSMutableDictionary dictionary];
        for (NSDictionary *dicL in arrayL) {
            if ([dicjian1[@"Id"]integerValue] == [dicL[@"ParentId"]integerValue]) {
                [arrayCh addObject:dicL];
            }
        }
        [dicCh setObject:arrayCh forKey:@"node"];
        [dicCh setObject:dicjian1[@"Names"] forKey:@"Names"];
        [dicCh setObject:[NSString stringWithFormat:@"%ld",[dicjian1[@"Id"] integerValue]]forKey:@"Id"];
        [dicCh setObject:[NSString stringWithFormat:@"%ld",[dicjian1[@"ParentId"] integerValue]]forKey:@"ParentId"];
        
        [arrayZ addObject:dicCh];
    }
    _levelTT = _levelTT - 1;
    if (_levelTT == 1) {
        _arrayZong = arrayZ;
        return;
    }
    [self chappppppp:arrayZ];
}
/////////////////递归////////////////////

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
    [_tableViewCollect reloadData];
}
///////////////////////////////////
///  tableView代理
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _arrayTableData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 45)];
    if (section == 0) {
        view.frame = CGRectMake(0, 0, Scr_Width, 90);
        UIView *viewA = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Scr_Width, 45)];
        viewA.backgroundColor = [UIColor groupTableViewBackgroundColor];
        UIView *viewL = [[UIView alloc]initWithFrame:CGRectMake(0, 43, Scr_Width, 2)];
        viewL.backgroundColor = ColorWithRGB(190, 200, 252);
        [viewA addSubview:viewL];
        UILabel *labChp = [[UILabel alloc]initWithFrame:CGRectMake(20, 45 - 2 - 30, 120, 30)];
        labChp.text = @"按章节归类";
        labChp.backgroundColor = ColorWithRGB(190, 200, 252);
        labChp.textAlignment = NSTextAlignmentCenter;
        labChp.textColor = ColorWithRGB(90, 144, 266);
        labChp.font =[UIFont systemFontOfSize:16.0];
        labChp.layer.masksToBounds = YES;
        labChp.layer.cornerRadius = 1;
        [viewA addSubview:labChp];
        [view addSubview:viewA];
        
    }
    view.backgroundColor = ColorWithRGB(200, 200, 200);
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
    NSString *titleString;
    //收藏
    if (_parameterView == 1) {
        titleString = [NSString stringWithFormat:@"%@ (★收藏:%ld)",dicHeader[@"Names"],[dicHeader[@"CollectionNum"] integerValue]];
    }
    //错题
    else if (self.parameterView == 2){
        titleString = [NSString stringWithFormat:@"%@ (★错题:%ld)",dicHeader[@"Names"],[dicHeader[@"ErrorNum"] integerValue]];
    }
    //笔记
    else if (self.parameterView == 3){
        titleString = [NSString stringWithFormat:@"%@ (📒笔记:%ld)",dicHeader[@"Names"],[dicHeader[@"NoteNum"] integerValue]];
    }
    //标题属性字符串
    NSMutableAttributedString *attriTitle = [[NSMutableAttributedString alloc] initWithString:titleString];
    //收藏
    if (_parameterView == 1) {
        [attriTitle addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor]
                           range:NSMakeRange([NSString stringWithFormat:@"%@",dicHeader[@"Names"]].length + 1,6+[NSString stringWithFormat:@"%ld",[dicHeader[@"CollectionNum"] integerValue]].length)];
        UIFont *titleFont = [UIFont systemFontOfSize:12.0];
        [attriTitle addAttribute:NSFontAttributeName value:titleFont
                           range:NSMakeRange([NSString stringWithFormat:@"%@",dicHeader[@"Names"]].length + 1,6+[NSString stringWithFormat:@"%ld",[dicHeader[@"CollectionNum"] integerValue]].length)];
    }
    //错题
    else if (self.parameterView == 2){
        [attriTitle addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor]
                           range:NSMakeRange([NSString stringWithFormat:@"%@",dicHeader[@"Names"]].length + 1,6+[NSString stringWithFormat:@"%ld",[dicHeader[@"ErrorNum"] integerValue]].length)];
        UIFont *titleFont = [UIFont systemFontOfSize:12.0];
        [attriTitle addAttribute:NSFontAttributeName value:titleFont
                           range:NSMakeRange([NSString stringWithFormat:@"%@",dicHeader[@"Names"]].length + 1,6+[NSString stringWithFormat:@"%ld",[dicHeader[@"ErrorNum"] integerValue]].length)];
    }
    //笔记
    else if (self.parameterView == 3){
        [attriTitle addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor]
                           range:NSMakeRange([NSString stringWithFormat:@"%@",dicHeader[@"Names"]].length + 1,7+[NSString stringWithFormat:@"%ld",[dicHeader[@"NoteNum"] integerValue]].length)];
        UIFont *titleFont = [UIFont systemFontOfSize:12.0];
        [attriTitle addAttribute:NSFontAttributeName value:titleFont
                           range:NSMakeRange([NSString stringWithFormat:@"%@",dicHeader[@"Names"]].length + 1,7+[NSString stringWithFormat:@"%ld",[dicHeader[@"NoteNum"] integerValue]].length)];
    }
    
    UILabel *labText = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, Scr_Width - 10 - 110, view.frame.size.height)];
    //    labText.text = dicHeader[@"Names"];
    labText.numberOfLines = 0;
    labText.font = [UIFont systemFontOfSize:13.0];
    [labText setAttributedText:attriTitle];
    [view addSubview:labText];
    
    UIButton *btnLook = [UIButton buttonWithType:UIButtonTypeCustom];
    btnLook.frame = CGRectMake(Scr_Width - 100, 0, 45, 45);
    btnLook.titleLabel.font = [UIFont systemFontOfSize:12.5];
    [btnLook setTitle:@"🔍查看" forState:UIControlStateNormal];
    [btnLook setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    [btnLook addTarget:self action:@selector(sectionLookClick:) forControlEvents:UIControlEventTouchUpInside];
    btnLook.tag = 1000 + section;
    [view addSubview:btnLook];
    
    UIButton *btnTopic = [UIButton buttonWithType:UIButtonTypeCustom];
    btnTopic.frame = CGRectMake(Scr_Width - 50, 0, 45, 45);
    btnTopic.titleLabel.font = [UIFont systemFontOfSize:12.5];
    [btnTopic setTitle:@"📓做题" forState:UIControlStateNormal];
    [btnTopic setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    [btnTopic addTarget:self action:@selector(sectionTopicClick:) forControlEvents:UIControlEventTouchUpInside];
    btnTopic.tag = 1000 + section;
    [view addSubview:btnTopic];
    if (section == 0) {
        button.frame = CGRectMake(0, 45, Scr_Width, 45);
        labText.frame = CGRectMake(10, 45, Scr_Width - 10 - 100, 45);
        btnLook.frame =CGRectMake(Scr_Width - 100, 45, 45, 45);
        btnTopic.frame =CGRectMake(Scr_Width - 50, 45, 45, 45);
    }
    return view;
}

///////////////section按钮///////////////////
//查看
- (void)sectionLookClick:(UIButton *)button{
    NSDictionary *dicDate = _arrayTableData[button.tag - 1000];
    NSDictionary *dicHeader = dicDate[@"id"];
    NSLog(@"section id = %ld == Name = %@",[dicHeader[@"Id"] integerValue], dicHeader[@"Names"]);
    //        [self getCollectTopicWithChaperId:[dicHeader[@"Id"] integerValue]];
    if (_parameterView == 1) {
        NSInteger collectCount = [dicHeader[@"CollectionNum"] integerValue];
        if (collectCount == 0) {
            [SVProgressHUD showInfoWithStatus:@"没有收藏的试题"];
            return;
        }
    }
    else if (self.parameterView == 2){
        NSInteger errorCount = [dicHeader[@"ErrorNum"] integerValue];
        if (errorCount == 0) {
            [SVProgressHUD showInfoWithStatus:@"没有错题"];
            return;
        }
    }
    else if (self.parameterView == 3){
        NSInteger noteCount = [dicHeader[@"NoteNum"] integerValue];
        if (noteCount == 0) {
            [SVProgressHUD showInfoWithStatus:@"没有试题笔记"];
            return;
        }
    }
    
    if (_parameterView != 3) {
        StartLookViewController *vc = [[StartLookViewController alloc]initWithNibName:@"StartLookViewController" bundle:nil];
        vc.chaperId = [dicHeader[@"Id"] integerValue];
        vc.parameterView = _parameterView;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else{
        
        [self performSegueWithIdentifier:@"mynote" sender:[NSString stringWithFormat:@"%ld",[dicHeader[@"Id"] integerValue]]];
    }
}
//做题
- (void)sectionTopicClick:(UIButton *)button{
    NSDictionary *dicDate = _arrayTableData[button.tag - 1000];
    NSDictionary *dicHeader = dicDate[@"id"];
    SelectParTopicViewController *selectVc = [[SelectParTopicViewController alloc]initWithNibName:@"SelectParTopicViewController" bundle:nil];
    selectVc.chaperName = dicHeader[@"Names"];
    selectVc.chaperId = [dicHeader[@"Id"] integerValue];
    [self.navigationController pushViewController:selectVc animated:YES];
//    NSLog(@"section Name= %@",dicHeader[@"Names"]);
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
    
    [_tableViewCollect reloadSections:[NSIndexSet indexSetWithIndex:sectoinId] withRowAnimation:UITableViewRowAnimationFade];
}
///////////////section按钮///////////////////

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 90;
    }
    return 45;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 1)];
    view.backgroundColor = [UIColor lightGrayColor];
    //    if (section == _arrayTableData.count - 1) {
    //        view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    //    }
    return view;
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

    
    UILabel *labT = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, Scr_Width - 60, 50)];
    labT.numberOfLines = 0;
    labT.font = [UIFont systemFontOfSize:15.0];
    
    //?????????????????
    //标题
    NSString *titleString;
    if (_parameterView == 1) {
        titleString = [NSString stringWithFormat:@"%@  ★收藏:%ld",dic[@"Names"],[dic[@"CollectionNum"] integerValue]];
    }
    else if (self.parameterView == 2){
        titleString = [NSString stringWithFormat:@"%@  ★错题:%ld",dic[@"Names"],[dic[@"ErrorNum"] integerValue]];
    }
    else if (self.parameterView == 3){
        titleString = [NSString stringWithFormat:@"%@  📓笔记:%ld",dic[@"Names"],[dic[@"NoteNum"] integerValue]];
    }
    //    titleString = [NSString stringWithFormat:@"%@  ★收藏:%ld题",dic[@"Names"],[dic[@"CollectionNum"] integerValue]];
    
    //标题属性字符串
    NSMutableAttributedString *attriTitle = [[NSMutableAttributedString alloc] initWithString:titleString];
    //收藏
    if (_parameterView == 1) {
        [attriTitle addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor]
                           range:NSMakeRange([NSString stringWithFormat:@"%@",dic[@"Names"]].length + 2,4+[NSString stringWithFormat:@"%ld",[dic[@"CollectionNum"] integerValue]].length)];
        UIFont *titleFont = [UIFont systemFontOfSize:12.0];
        [attriTitle addAttribute:NSFontAttributeName value:titleFont
                           range:NSMakeRange([NSString stringWithFormat:@"%@",dic[@"Names"]].length + 2,4+[NSString stringWithFormat:@"%ld",[dic[@"CollectionNum"] integerValue]].length)];
    }
    //错题
    else if (self.parameterView == 2){
        [attriTitle addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor]
                           range:NSMakeRange([NSString stringWithFormat:@"%@",dic[@"Names"]].length + 2,4+[NSString stringWithFormat:@"%ld",[dic[@"ErrorNum"] integerValue]].length)];
        UIFont *titleFont = [UIFont systemFontOfSize:12.0];
        [attriTitle addAttribute:NSFontAttributeName value:titleFont
                           range:NSMakeRange([NSString stringWithFormat:@"%@",dic[@"Names"]].length + 2,4+[NSString stringWithFormat:@"%ld",[dic[@"ErrorNum"] integerValue]].length)];
    }
    //笔记
    else if (self.parameterView == 3){
        [attriTitle addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor]
                           range:NSMakeRange([NSString stringWithFormat:@"%@",dic[@"Names"]].length + 2,5+[NSString stringWithFormat:@"%ld",[dic[@"NoteNum"] integerValue]].length)];
        UIFont *titleFont = [UIFont systemFontOfSize:12.0];
        [attriTitle addAttribute:NSFontAttributeName value:titleFont
                           range:NSMakeRange([NSString stringWithFormat:@"%@",dic[@"Names"]].length + 2,5+[NSString stringWithFormat:@"%ld",[dic[@"NoteNum"] integerValue]].length)];
    }
    
    [labT setAttributedText:attriTitle];
    [cell.contentView addSubview:labT];
    MGSwipeButton *btnLook = [MGSwipeButton buttonWithTitle:@"查 看" icon:nil backgroundColor:ColorWithRGB(200, 200, 200) callback:^BOOL(MGSwipeTableCell *sender) {
        //收藏试题
        if (_parameterView == 1) {
            NSInteger collectCount = [dic[@"CollectionNum"] integerValue];
            if (collectCount  == 0) {
                [SVProgressHUD showInfoWithStatus:@"没有收藏的试题"];
                return NO;
            }
        }
        //错题试题
        else if (self.parameterView == 2){
            NSInteger errorCount = [dic[@"ErrorNum"] integerValue];
            if (errorCount == 0) {
                [SVProgressHUD showInfoWithStatus:@"没有错题"];
                return NO;

            }
        }
        //笔记试题
        else if (self.parameterView == 3){
             NSInteger noteCount = [dic[@"NoteNum"] integerValue];
            if (noteCount == 0) {
                [SVProgressHUD showInfoWithStatus:@"没有试题笔记"];
                return NO;

            }
        }
        ///收藏和试题
        if (_parameterView != 3) {
            StartLookViewController *vc = [[StartLookViewController alloc]initWithNibName:@"StartLookViewController" bundle:nil];
            vc.chaperId = [dic[@"Id"] integerValue];
            vc.parameterView = _parameterView;
            [self.navigationController pushViewController:vc animated:YES];

        }
        ///笔记
        else{
            [self performSegueWithIdentifier:@"mynote" sender:[NSString stringWithFormat:@"%ld",[dic[@"Id"] integerValue]]];
        }
        return YES;
    }];
    
    [btnLook setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    btnLook.titleLabel.font = [UIFont systemFontOfSize:15.0];
    MGSwipeButton *btnTopic = [MGSwipeButton buttonWithTitle:@"做 题" icon:nil backgroundColor:ColorWithRGB(109, 188, 254) callback:^BOOL(MGSwipeTableCell *sender) {
        NSLog(@"%ld",[dic[@"Id"] integerValue]);
        //        [self performSegueWithIdentifier:@"dotopic" sender:[NSString stringWithFormat:@"%ld",[dic[@"Id"] integerValue]]];
        NSLog(@"%ld == %ld",indexPath.section,indexPath.row);
        SelectParTopicViewController *selectVc = [[SelectParTopicViewController alloc]initWithNibName:@"SelectParTopicViewController" bundle:nil];
        selectVc.chaperId = [dic[@"Id"] integerValue];
        selectVc.chaperName = dic[@"Names"];
        [self.navigationController pushViewController:selectVc animated:YES];
        return YES;
    }];
    [btnTopic setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    btnTopic.titleLabel.font = [UIFont systemFontOfSize:15.0];
    cell.rightButtons = @[btnTopic,btnLook];
    cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"mynote"]) {
         MyNoteViewController *noteVc = segue.destinationViewController;
        noteVc.chaperId = [sender integerValue];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
