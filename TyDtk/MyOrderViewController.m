//
//  MyOrderViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/6/13.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "MyOrderViewController.h"
#import "OrderInfoViewController.h"
@interface MyOrderViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableViewOrder;
@property (nonatomic,strong) NSUserDefaults *tyUser;
@property (nonatomic,strong) NSDictionary *dicUserInfo;
///订单列表数组(可追加)
@property (nonatomic,strong) NSMutableArray *arrayOrderList;
///请求订单总页数
@property (nonatomic,assign) NSInteger intPages;
///当前页
@property (nonatomic,assign) NSInteger intCurrPage;
///每页返回的数量
@property (nonatomic,assign) NSInteger intPageSize;
//上拉刷新控件
@property (nonatomic,strong) MJRefreshBackNormalFooter *refreshFooter;
//没有订单时显示的view
@property (nonatomic,strong) ViewNullData *viewNilData;
//朦层
@property (nonatomic,strong) MZView *viewMz;
@end

@implementation MyOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tyUser = [NSUserDefaults standardUserDefaults];
    _dicUserInfo = [_tyUser objectForKey:tyUserUserInfo];
    _tableViewOrder.separatorStyle = UITableViewCellSeparatorStyleNone;
    _arrayOrderList = [NSMutableArray array];
    _intPageSize = 10;
    _intPages = 0;
    _intCurrPage = 1;
    [SVProgressHUD show];
    [self getAllOrderList];
}
///添加上拉刷新
- (void)addRefreshForTableViewOrder{
    //设置tableView的上拉控件
    _refreshFooter = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshClick:)];
    [_refreshFooter setTitle:@"上拉查看更多订单" forState:MJRefreshStateIdle];
    [_refreshFooter setTitle:@"松开加载更多订单" forState:MJRefreshStatePulling];
    [_refreshFooter setTitle:@"正在为您加载更多订单..." forState:MJRefreshStateRefreshing];
    [_refreshFooter setTitle:@"您的订单已全部加载完毕" forState:MJRefreshStateNoMoreData];
    _tableViewOrder.mj_footer = _refreshFooter;
    _tableViewOrder.tableFooterView = [UIView new];
}
///添加tableView头试图
- (void)addTableViewHeardView{
    UIView *viewHeard = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 50)];
    viewHeard.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(0, 48, Scr_Width, 2)];
    viewLine.backgroundColor = ColorWithRGB(190, 200, 252);
    [viewHeard addSubview:viewLine];
    UILabel *labText = [[UILabel alloc]initWithFrame:CGRectMake(20, 18, 133, 30)];
    labText.text = @"我的订单列表";
    labText.textAlignment = NSTextAlignmentCenter;
    labText.backgroundColor = ColorWithRGB(190, 200, 252);
    labText.textColor = ColorWithRGB(90, 144, 266);
    labText.font = [UIFont systemFontOfSize:16.0];
    [viewHeard addSubview:labText];
    _tableViewOrder.tableHeaderView = viewHeard;
}
///上拉刷新
- (void)footerRefreshClick:(MJRefreshBackNormalFooter *)refreshFooter{
    [self getAllOrderList];
}
///获取订单列表
- (void)getAllOrderList{
    if (_intPages != 0) {
        [SVProgressHUD show];
        if (_intCurrPage > _intPages) {
            [SVProgressHUD dismiss];
            [_refreshFooter endRefreshingWithNoMoreData];
            return;
        }
    }
    NSString *urlString = [NSString stringWithFormat:@"%@/ty/mobile/order/orderList?jeeId=%@&fromSystem=902&pageIndex=%ld&pageCount=%ld",systemHttpsKaoLaTopicImg,_dicUserInfo[@"jeeId"],_intCurrPage,_intPageSize];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicOrder = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        if ([dicOrder[@"code"] integerValue] == 1) {
            NSDictionary *dicDatas = dicOrder[@"datas"];
            if ([dicDatas[@"status"] integerValue] == 1) {
                NSArray *arrayOrderList = dicDatas[@"data"];
                if (arrayOrderList.count != 0) {
                    if (_intPages == 0) {
                        [self addRefreshForTableViewOrder];
                        [self addTableViewHeardView];
                    }
                    for (NSDictionary *dicOrderList in arrayOrderList) {
                        [_arrayOrderList addObject:dicOrderList];
                    }
                    _tableViewOrder.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                }
                else{
                    if (!_viewNilData) {
                        _viewNilData = [[ViewNullData alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Height) showText:@"没有订单信息"];
                        [self.view addSubview:_viewNilData];
                    }
                }
            }
            NSDictionary *dicPage = dicOrder[@"page"];
            _intPages = [dicPage[@"pages"] integerValue];
            _intCurrPage = _intCurrPage + 1;
            [_refreshFooter endRefreshing];
            [_tableViewOrder reloadData];
            [_viewMz removeFromSuperview];
            [SVProgressHUD dismiss];
        }
    } RequestFaile:^(NSError *error) {
        [_viewMz removeFromSuperview];
        [SVProgressHUD showInfoWithStatus:@"操作异常！"];
    }];
}
///删除订单
- (void)deleteOrderWithOrderId:(NSString *)orderId{
    [SVProgressHUD show];
    if (!_viewMz) {
        _viewMz = [[MZView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Height)];
    }
    [self.view addSubview:_viewMz];
    NSString *urlString = [NSString stringWithFormat:@"%@/ty/mobile/order/orderDel?orderSN=%@&jeeId=%@&fromSystem=902",systemHttpsKaoLaTopicImg,orderId,_dicUserInfo[@"jeeId"]];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicOrderMes = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        if ([dicOrderMes[@"code"] integerValue] == 1) {
            NSDictionary *dicData = dicOrderMes[@"datas"];
            if ([dicData[@"status"] integerValue] == 1) {
                [SVProgressHUD showSuccessWithStatus:dicData[@"data"]];
                [_arrayOrderList removeAllObjects];
                _intCurrPage = 1;
                _intPages = 0;
                [self getAllOrderList];
            }
            else{
                [_viewMz removeFromSuperview];
                [SVProgressHUD showSuccessWithStatus:dicData[@"message"]];
            }
        }
    } RequestFaile:^(NSError *error) {
        [_viewMz removeFromSuperview];
        [SVProgressHUD showInfoWithStatus:@"操作异常！"];
    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrayOrderList.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 170;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellorder" forIndexPath:indexPath];
    NSDictionary *dicOrder = _arrayOrderList[indexPath.row];
    UILabel *labTime = (UILabel *)[cell.contentView viewWithTag:10];
    labTime.adjustsFontSizeToFitWidth = YES;
    UILabel *labCount = (UILabel *)[cell.contentView viewWithTag:11];
    UILabel *labMoney = (UILabel *)[cell.contentView viewWithTag:12];
    UILabel *labPayStutas = (UILabel *)[cell.contentView viewWithTag:13];
    UILabel *labOrderId = (UILabel *)[cell.contentView viewWithTag:14];
    labTime.text = dicOrder[@"createDateString"];
    labCount.text = [NSString stringWithFormat:@"%ld",[dicOrder[@"productTotalQuantity"] integerValue]];
    labMoney.text = [NSString stringWithFormat:@"￥%.2f",[dicOrder[@"productTotalPrice"] floatValue]];
    //完成支付
    if ([dicOrder[@"paymentStatus"] integerValue] != 5001) {
        labPayStutas.text = [NSString stringWithFormat:@"%@（%@）",dicOrder[@"paymentStatusName"],dicOrder[@"paymentConfigName"]];
        labPayStutas.textColor = [UIColor lightGrayColor];
    }
    else{
        labPayStutas.text = dicOrder[@"paymentStatusName"];
        labPayStutas.textColor = [UIColor redColor];
    }
    labOrderId.text = dicOrder[@"id"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dicOrder = _arrayOrderList[indexPath.row];
    [self performSegueWithIdentifier:@"orderinfo" sender:dicOrder];
    
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删 除";
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView setEditing:NO animated:YES];
    NSDictionary *dicOrder = _arrayOrderList[indexPath.row];
    [self deleteOrderWithOrderId:dicOrder[@"id"]];
//    NSLog(@"fdsfs");
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"orderinfo"]) {
        OrderInfoViewController *orderVc = segue.destinationViewController;
        orderVc.dicOrder = sender;
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
