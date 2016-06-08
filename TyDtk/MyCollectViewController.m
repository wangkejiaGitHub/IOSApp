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
@interface MyCollectViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableViewCollect;

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
@end

@implementation MyCollectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _arraySection = [NSMutableArray array];
    _levelTT = 0;
    _arrayLinS = [NSMutableArray array];
    _tyUser = [NSUserDefaults standardUserDefaults];
    _accessToken = [_tyUser objectForKey:tyUserAccessToken];
    [self getAboutChaperCollect];
    // Do any additional setup after loading the view.
}
///获取收藏试题相关的章节考点
- (void)getAboutChaperCollect{
    [SVProgressHUD showWithStatus:@"正在加载..."];
    //api/Collection/GetCollectionAboutChapters?access_token={access_token}&courseId={courseId};
    NSDictionary *dicSubject = [_tyUser objectForKey:tyUserSubject];
    NSString *urlString = [NSString stringWithFormat:@"%@api/Collection/GetCollectionAboutChapters?access_token=%@&courseId=%ld",systemHttps,_accessToken,[dicSubject[@"Id"] integerValue]];
    
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicCollect =[NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dicCollect[@"code"] integerValue];
        if (codeId == 1) {
            _arrayAllChap = dicCollect[@"datas"];
            
            for (NSDictionary *dicArr in _arrayAllChap) {
                NSInteger le = [dicArr[@"Level"] integerValue];
                if (le > _levelTT) {
                    _levelTT = le;
                }
            }
            [self getFirstLevelAndDate];
        }
        NSLog(@"%@",dicCollect);
        [SVProgressHUD dismiss];
    } RequestFaile:^(NSError *error) {
        
    }];
}
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

- (void)getFirstLevelAndDate{
    NSMutableArray *arrayFirstLevel = [NSMutableArray array];
    
    for (NSDictionary *dicFirst in _arrayAllChap) {
        if ([dicFirst[@"Level"] integerValue] == 1) {
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
    view.backgroundColor = ColorWithRGB(200, 200, 200);
    NSDictionary *dicDate = _arrayTableData[section];
    NSDictionary *dicHeader = dicDate[@"id"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(20, 0, Scr_Width-20, view.frame.size.height);
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
    return 45;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
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
    UILabel *labT = [[UILabel alloc]initWithFrame:CGRectMake(25, 0, Scr_Width - 40, 60)];
    labT.numberOfLines = 0;
    labT.font = [UIFont systemFontOfSize:15.0];
    labT.text = dic[@"Names"];
    [cell.contentView addSubview:labT];

    MGSwipeButton *btnLook = [MGSwipeButton buttonWithTitle:@"查 看" backgroundColor:[UIColor lightGrayColor] callback:^BOOL(MGSwipeTableCell *sender) {
        return YES;
    }];
    [btnLook setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    btnLook.titleLabel.font = [UIFont systemFontOfSize:15.0];
    MGSwipeButton *btnTopic = [MGSwipeButton buttonWithTitle:@"做 题" backgroundColor:ColorWithRGB(109, 188, 254) callback:^BOOL(MGSwipeTableCell *sender) {
         NSLog(@"%ld == %ld",indexPath.section,indexPath.row);
        return YES;
    }];
    [btnTopic setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    btnTopic.titleLabel.font = [UIFont systemFontOfSize:15.0];
    cell.rightButtons = @[btnTopic,btnLook];
    cell.rightSwipeSettings.transition = MGSwipeTransitionRotate3D;
    return cell;
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
