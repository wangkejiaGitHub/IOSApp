//
//  MyExamViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/6/13.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "MyExamViewController.h"
#import "ExamTableViewCell.h"
#import "EditSetExamViewController.h"
@interface MyExamViewController ()<UITableViewDataSource,UITableViewDelegate,ExamCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableViewExam;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonLiftItem;

@property (nonatomic,strong) NSUserDefaults *tyUser;
@property (nonatomic,strong) NSString *accessToken;
@property (nonatomic,strong) NSMutableArray *arrayIsActived;
@property (nonatomic,strong) NSMutableArray *arrayNoActived;
@property (nonatomic,assign) CGFloat cellHeight;
//下拉刷新
@property (nonatomic,strong) MJRefreshNormalHeader *refreshHeader;
@property (nonatomic,strong) NSArray *arrayCurrActive;
///1.未激活，2.已激活
@property (nonatomic,assign) NSInteger intCurrActive;
@end

@implementation MyExamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isFirstLoad = YES;
    // Do any additional setup after loading the view.
    _tyUser = [NSUserDefaults standardUserDefaults];
    _accessToken = [_tyUser objectForKey:tyUserAccessToken];
    _arrayIsActived = [NSMutableArray array];
    _arrayNoActived = [NSMutableArray array];
    
    _refreshHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefereshClick:)];
    _tableViewExam.mj_header = _refreshHeader;
    
    _cellHeight = 210;
    _tableViewExam.separatorStyle = UITableViewCellSeparatorStyleNone;
    _intCurrActive = 1;
    [self getExamInfo];
    
}
- (void)viewDidAppear:(BOOL)animated{
    ///修改之后刷新列表
    if (!_isFirstLoad) {
        [_arrayIsActived removeAllObjects];
        [_arrayNoActived removeAllObjects];
        [self getExamInfo];
    }
    [_tableViewExam reloadData];
}
//下拉刷新
- (void)headerRefereshClick:(MJRefreshNormalHeader *)refresh{
    [_arrayIsActived removeAllObjects];
    [_arrayNoActived removeAllObjects];
    [self getExamInfo];
}
///获取所有考试信息
- (void)getExamInfo{
    [SVProgressHUD show];
    NSString *urlString = [NSString stringWithFormat:@"%@api/ExamSet/GetExamSetList?access_token=%@",systemHttps,_accessToken];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicExam = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dicExam[@"code"] integerValue];
        if (codeId == 1) {
            NSArray *arrayExam = dicExam[@"datas"];
            for (NSDictionary *dicAc in arrayExam) {
                NSInteger isActived = [dicAc[@"IsActived"] integerValue];
                if (isActived == 1) {
                    [_arrayIsActived addObject:dicAc];
                }
                else{
                    [_arrayNoActived addObject:dicAc];
                }
            }
            
            if (_intCurrActive == 1) {
                _arrayCurrActive = _arrayNoActived;
            }
            else{
                _arrayCurrActive = _arrayIsActived;
            }
        }
        [_refreshHeader endRefreshing];
        [_tableViewExam reloadData];
        [SVProgressHUD dismiss];
    } RequestFaile:^(NSError *error) {
        [_refreshHeader endRefreshing];
        [SVProgressHUD showErrorWithStatus:@"网络异常"];
    }];
}
///激活。未激活按钮
- (IBAction)btnActiveClick:(UIBarButtonItem *)sender {
    [ZFPopupMenu setMenuBackgroundColorWithRed:0.6 green:0.4 blue:0.2 aphla:0.9];
    [ZFPopupMenu setTextColorWithRed:1 green:1 blue:1 aphla:1.0];
    [ZFPopupMenu setHighlightedImage:[UIImage imageNamed:@"cancelBg"]];
    ZFPopupMenu *popupMenu = [[ZFPopupMenu alloc] initWithItems:[self LevelsMenuItemArray]];
    CGRect rectBtn;
    rectBtn.origin.y = 60;
    rectBtn.origin.x = Scr_Width - 30;
    [popupMenu showInView:self.navigationController.view fromRect:rectBtn layoutType:Vertical];
    [self.navigationController.view addSubview:popupMenu];
}

//返回试题类型菜单item数组
- (NSArray *)LevelsMenuItemArray{
    NSMutableArray *arrayTypeMuen = [NSMutableArray array];
    ZFPopupMenuItem *item1 = [ZFPopupMenuItem initWithMenuName:@"未激活" image:nil action:@selector(menuTypeClick:) target:self];
    item1.tag = 100 + 1;
    ZFPopupMenuItem *item2 = [ZFPopupMenuItem initWithMenuName:@"已激活" image:nil action:@selector(menuTypeClick:) target:self];
    item2.tag = 100 + 2;
    [arrayTypeMuen addObject:item1];
    [arrayTypeMuen addObject:item2];
    return arrayTypeMuen;
}
//激活，未激活切换点击事件
- (void)menuTypeClick:(ZFPopupMenuItem *)item{
    _buttonLiftItem.title = item.itemName;
    if (item.tag == 101) {
        NSLog(@"未激活");
        _intCurrActive = 1;
        _arrayCurrActive = _arrayNoActived;
    }
    else{
        _intCurrActive = 2;
        _arrayCurrActive = _arrayIsActived;
        NSLog(@"已激活");
    }
    [_tableViewExam reloadData];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_arrayCurrActive.count > 0) {
        return _arrayCurrActive.count + 1;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < _arrayCurrActive.count) {
        return _cellHeight;
    }
    return 100;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < _arrayCurrActive.count) {
        ExamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellexam" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegateExam = self;
        NSDictionary *dicExam = _arrayCurrActive[indexPath.row];
        _cellHeight = [cell setCellModelValueWithDictionary:dicExam];
        return cell;
    }
    else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"celladd" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView *view = (UIView *)[cell.contentView viewWithTag:100];
        view.layer.masksToBounds = YES;
        view.layer.cornerRadius = 5;
        view.layer.borderWidth = 2;
        view.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        UIButton *btn = (UIButton *)[cell.contentView viewWithTag:101];
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = 3;
        btn.userInteractionEnabled = NO;
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == _arrayCurrActive.count) {
        self.navigationController.tabBarController.selectedIndex = 0;
    }
}
//删除或设置默认后回调刷新考试信息
- (void)reFreshExamInfo{
    [_arrayIsActived removeAllObjects];
    [_arrayNoActived removeAllObjects];
    [self getExamInfo];
}
//编辑考试信息回调跳转到编辑考试信息页面
- (void)editExamInfo:(NSDictionary *)dicExam{
    [self performSegueWithIdentifier:@"editexam" sender:dicExam];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"editexam"]) {
        EditSetExamViewController *editvc = segue.destinationViewController;
        editvc.dicExam = sender;
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
