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
@end

@implementation MyCollectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.parameterView == 1) {
        self.title = @"我的收藏";
    }
    else if (self.parameterView == 2){
        self.title = @"我的错题";
    }
    else if (self.parameterView == 3){
        self.title = @"我的笔记";
    }
    _customTools = [[CustomTools alloc]init];
    _customTools.delegateTool = self;
    _arraySection = [NSMutableArray array];
    _levelTT = 0;
    _arrayLinS = [NSMutableArray array];
    _tyUser = [NSUserDefaults standardUserDefaults];
    _labSubject.userInteractionEnabled = NO;
    [self addTapGestForLabelSubject];
    _accessToken = [_tyUser objectForKey:tyUserAccessToken];
    NSDictionary *dicSubject = [_tyUser objectForKey:tyUserSubject];
    _labSubject.text = dicSubject[@"Names"];
    _labSubject.textColor = ColorWithRGB(90, 144, 266);
    NSDictionary *dicClass = [_tyUser objectForKey:tyUserClass];
    NSInteger classId = [dicClass[@"Id"] integerValue];
    [self getAllSubjectWithClass:classId];
    _tableViewCollect.tableFooterView = [UIView new];
}

- (void)viewWillAppear:(BOOL)animated{
    
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
        [self getAboutChaperCollect];
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
    NSLog(@"%@",item.itemName);
}
/**
 科目授权
 */
- (void)customGetAccessToken:(NSInteger)subjectId{
    [SVProgressHUD show];
    NSDictionary *dicUser = [_tyUser objectForKey:tyUserUser];
    NSDictionary *dicClass = [_tyUser objectForKey:tyUserClass];
    /**
     [_customTools empowerAndSignatureWithUserId:dicUserInfo[@"userId"] userName:dicUserInfo[@"name"] classId:classId subjectId:_subjectId];
     */
    NSString *classId = [NSString stringWithFormat:@"%@",dicClass[@"Id"]];
    [_customTools empowerAndSignatureWithUserId:dicUser[@"userId"] userName:dicUser[@"name"] classId: classId subjectId:[NSString stringWithFormat:@"%ld",subjectId]];
}
/**
 授权回调
 */
//授权成功
- (void)httpSussessReturnClick{
    _accessToken = [_tyUser objectForKey:tyUserAccessToken];
    //错题
    if (self.parameterView == 2) {
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
        [SVProgressHUD dismiss];
    }];
}
//*****************************************//
//////////////////我的收藏////////////////////
- (void)getAboutChaperCollect{
    [SVProgressHUD showWithStatus:@"正在加载..."];
    //api/Collection/GetCollectionAboutChapters?access_token={access_token}&courseId={courseId};
//    NSDictionary *dicSubject = [_tyUser objectForKey:tyUserSubject];
    NSString *urlString;
    if (_intSubJectId != 0) {
         urlString = [NSString stringWithFormat:@"%@api/Collection/GetCollectionAboutChapters?access_token=%@&courseId=%ld",systemHttps,_accessToken,_intSubJectId];
    }
    else{
        NSDictionary *dicSubject = [_tyUser objectForKey:tyUserSubject];
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
        NSLog(@"%@",dicCollect);
        [SVProgressHUD dismiss];
    } RequestFaile:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}
/////////////////我的收藏////////////////////
//****************************************//

//****************************************//
//////////////////我的错题////////////////////
- (void)getAboutChaperErrorTopic{
    //api/Error/GetErrorAboutChapters?access_token={access_token}&courseId={courseId}
    [SVProgressHUD showWithStatus:@"正在加载..."];
    NSString *urlString;
    if (_intSubJectId != 0) {
        urlString = [NSString stringWithFormat:@"%@api/Error/GetErrorAboutChapters?access_token=%@&courseId=%ld",systemHttps,_accessToken,_intSubJectId];
    }
    else{
        NSDictionary *dicSubject = [_tyUser objectForKey:tyUserSubject];
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
        NSLog(@"%@",dicError);
        [SVProgressHUD dismiss];
        
    } RequestFaile:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}


//////////////////我的错题////////////////////
//****************************************//

//****************************************//
//////////////////我的笔记////////////////////
- (void)getAboutChaperNotes{
    [SVProgressHUD show];
    NSString *urlString;
    if (_intSubJectId != 0) {
        urlString = [NSString stringWithFormat:@"%@api/Note/GetMyNotesAboutChapters?access_token=%@&courseId=%ld",systemHttps,_accessToken,_intSubJectId];
    }
    else{
         NSDictionary *dicSubject = [_tyUser objectForKey:tyUserSubject];
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
        NSLog(@"%@",dicNotes);
        [SVProgressHUD dismiss];

    } RequestFaile:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
    
}

//****************************************//
//////////////////我的笔记////////////////////


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
/////////////////递归////////////////////
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

///根据章节考点id获取该章节考点下的包含的所有的试题数
- (NSInteger)getCountTopicWithChaperId:(NSInteger)chaperId{
    NSString *idString = [NSString stringWithFormat:@"%ld",chaperId];
    NSInteger countTopic = 0;
    for (NSDictionary *dic in _arrayAllChap) {
        NSString *parentPath = dic[@"ParentPath"];
        NSRange ran = [parentPath rangeOfString:idString];
        if (ran.length > 0) {
            countTopic = countTopic + 1;
        }
    }
    return countTopic;
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
    return 60;
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
    button.frame = CGRectMake(20, 0, Scr_Width-20, view.frame.size.height);
    if (section == 0) {
        button.frame = CGRectMake(20, 45, Scr_Width, 45);
    }
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [button setTitle:dicHeader[@"Names"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonSectionClick:) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font = [UIFont systemFontOfSize:13.0];
    button.tag = 100 + section;
    [view addSubview:button];
    return view;
}
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
//    MGSwipeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
//    NSDictionary *dicData = _arrayTableData[indexPath.section];
//    NSArray *arrayData = dicData[@"node"];
//    NSDictionary *dic = arrayData[indexPath.row];
//    UILabel *labTitle = (UILabel *)[cell.contentView viewWithTag:10];
//    labTitle.text = dic[@"Names"];

//    return cell;
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
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(25, (60-8)/2, 8, 8)];
    view.backgroundColor = ColorWithRGB(90, 144, 266);
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 4;
    [cell.contentView addSubview:view];
    UILabel *labT = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, Scr_Width - 50, 60)];
    labT.numberOfLines = 0;
    labT.font = [UIFont systemFontOfSize:15.0];
    labT.text = dic[@"Names"];
    NSInteger countTopic = [self getCountTopicWithChaperId:[dic[@"Id"] integerValue]];
    NSString *strText = [NSString stringWithFormat:@"%@==%ld",dic[@"Names"],countTopic];
    labT.text = strText;
    [cell.contentView addSubview:labT];
    MGSwipeButton *btnLook = [MGSwipeButton buttonWithTitle:@"查 看" icon:[UIImage imageNamed:@"qydp_01"] backgroundColor:ColorWithRGB(200, 200, 200) callback:^BOOL(MGSwipeTableCell *sender) {
        
        return YES;
    }];
    [btnLook setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    btnLook.titleLabel.font = [UIFont systemFontOfSize:15.0];
    MGSwipeButton *btnTopic = [MGSwipeButton buttonWithTitle:@"做 题" icon:[UIImage imageNamed:@"qydp_01"] backgroundColor:ColorWithRGB(109, 188, 254) callback:^BOOL(MGSwipeTableCell *sender) {
        NSLog(@"%ld",[dic[@"Id"] integerValue]);
//        [self performSegueWithIdentifier:@"dotopic" sender:[NSString stringWithFormat:@"%ld",[dic[@"Id"] integerValue]]];
         NSLog(@"%ld == %ld",indexPath.section,indexPath.row);
        return YES;
    }];
    [btnTopic setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    btnTopic.titleLabel.font = [UIFont systemFontOfSize:15.0];
    cell.rightButtons = @[btnTopic,btnLook];
    cell.rightSwipeSettings.transition = MGSwipeTransitionRotate3D;
    return cell;
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    
//}
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
