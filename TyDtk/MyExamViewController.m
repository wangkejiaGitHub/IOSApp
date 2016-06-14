//
//  MyExamViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/6/13.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "MyExamViewController.h"
#import "ExamTableViewCell.h"
#import "EditExamViewController.h"
@interface MyExamViewController ()<UITableViewDataSource,UITableViewDelegate,ExamCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableViewExam;

@property (nonatomic,strong) NSUserDefaults *tyUser;
@property (nonatomic,strong) NSString *accessToken;
@property (nonatomic,strong) NSMutableArray *arrayIsActived;
@property (nonatomic,strong) NSMutableArray *arrayNoActived;
@property (nonatomic,assign) CGFloat cellHeight;
//下拉菜单
@property (nonatomic,strong) DTKDropdownMenuView *menuView;
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
    _cellHeight = 210;
    _tableViewExam.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self getExamInfo];
    
}
- (void)viewDidAppear:(BOOL)animated{
    if (!_isFirstLoad) {
        [_arrayIsActived removeAllObjects];
        [_arrayNoActived removeAllObjects];
        [self getExamInfo];
    }
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
            
            //            for (int i = 0; i<_arrayNoActived.count - 1; i++) {
            //                for (int j = 0; j<_arrayNoActived.count - 1 - i; j++) {
            //                    NSDictionary *dicL = _arrayNoActived[j];
            //                    NSDictionary *dicN = _arrayNoActived[j+1];
            //                    NSInteger isDefaultL = [dicL[@"IsDefault"] integerValue];
            //                    NSInteger isDefaultN = [dicN[@"IsDefault"] integerValue];
            //                    if (isDefaultN == 1 && isDefaultL == 0) {
            //                        [_arrayNoActived exchangeObjectAtIndex:i withObjectAtIndex:i+1];
            //                    }
            //
            //                }
            //            }
            
        }
        [_tableViewExam reloadData];
        [SVProgressHUD dismiss];
    } RequestFaile:^(NSError *error) {
        [SVProgressHUD showInfoWithStatus:@"操作异常！"];
    }];
}
///添加激活状态选项
- (void)addNavRightItem{

    NSMutableArray *arrayMenuItem = [NSMutableArray array];
    DTKDropdownItem *item1 = [DTKDropdownItem itemWithTitle:@"未激活" callBack:^(NSUInteger index, id info) {
        
    }];
    [arrayMenuItem addObject:item1];
    
    DTKDropdownItem *item2 = [DTKDropdownItem itemWithTitle:@"已激活" callBack:^(NSUInteger index, id info) {
        
    }];
    [arrayMenuItem addObject:item2];
//    _menuView = [DTKDropdownMenuView dropdownMenuViewForNavbarTitleViewWithFrame:CGRectMake(46, 0, Scr_Width - 92, 44) dropdownItems:arrayMenuItem];
//    _menuView.currentNav = self.navigationController;
//    _menuView.dropWidth = menuStringLength*19 - 15;
//    if (menuStringLength <= 10) {
//        _menuView.dropWidth = 200;
//    }
//    _menuView.titleFont = [UIFont systemFontOfSize:13.0];
//    _menuView.textColor = [UIColor brownColor];
//    _menuView.titleColor = [UIColor purpleColor];
//    _menuView.textFont = [UIFont systemFontOfSize:13.f];
//    _menuView.cellSeparatorColor = [UIColor lightGrayColor];
//    _menuView.textFont = [UIFont systemFontOfSize:14.f];
//    _menuView.animationDuration = 0.2f;
//    self.navigationItem.titleView = _menuView;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrayNoActived.count + 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < _arrayNoActived.count) {
        return _cellHeight;
    }
    return 100;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (_arrayNoActived.count > 0) {
//        
//    }
    if (indexPath.row < _arrayNoActived.count) {
        ExamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellexam" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegateExam = self;
        NSDictionary *dicExam = _arrayNoActived[indexPath.row];
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
        UILabel *lab = (UILabel *)[cell.contentView viewWithTag:101];
        lab.layer.masksToBounds = YES;
        lab.layer.cornerRadius = 3;
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == _arrayNoActived.count) {
        self.navigationController.tabBarController.selectedIndex = 0;
    }
}
//删除或设置默认后刷新考试信息
- (void)reFreshExamInfo{
    [_arrayIsActived removeAllObjects];
    [_arrayNoActived removeAllObjects];
    [self getExamInfo];
}
//编辑考试信息
- (void)editExamInfo:(NSDictionary *)dicExam{
    EditExamViewController *editExamVc =[[EditExamViewController alloc]initWithNibName:@"EditExamViewController" bundle:nil];
    editExamVc.dicExam = dicExam;
    [self.navigationController pushViewController:editExamVc animated:YES];
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
