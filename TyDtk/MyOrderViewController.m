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
///当前订单状态（默认是5001：获取的是未付款的订单，付款状态:5003）
@property (nonatomic,assign) NSInteger intPaymentStatus;
//上拉刷新控件
@property (nonatomic,strong) MJRefreshBackNormalFooter *refreshFooter;
//下拉刷新控件
@property (nonatomic,strong) MJRefreshNormalHeader *refreshHeader;
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
//    [self addTableViewHeardView];
    [self addRefreshForTableViewHeader];
    ///默认获取的是未付款的订单:5001
    _intPaymentStatus = 5001;
    
    _intPageSize = 20;
    _intPages = 0;
    _intCurrPage = 1;
    [SVProgressHUD show];
    [self getAllOrderList];
}
///添加下拉刷新
- (void)addRefreshForTableViewHeader{
    _refreshHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerTabRefereshClick:)];
    _tableViewOrder.mj_header = _refreshHeader;
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
    UILabel *labText = [[UILabel alloc]initWithFrame:CGRectMake(15, 18, 113, 30)];
    labText.text = @"我的订单列表";
    labText.textAlignment = NSTextAlignmentCenter;
    labText.backgroundColor = ColorWithRGB(190, 200, 252);
    labText.textColor = ColorWithRGB(90, 144, 266);
    labText.font = [UIFont systemFontOfSize:15.0];
    [viewHeard addSubview:labText];
    
    ///已完成按钮
    UIButton *btnNoPay = [UIButton buttonWithType:UIButtonTypeCustom];
    btnNoPay.frame = CGRectMake(Scr_Width - 60 - 10, 25, 60, 23);
    btnNoPay.backgroundColor = ColorWithRGB(190, 200, 252);
    [btnNoPay setTitle:@"已完成" forState:UIControlStateNormal];
    [btnNoPay setTitleColor:ColorWithRGB(90, 144, 266) forState:UIControlStateNormal];
    btnNoPay.titleLabel.font = [UIFont systemFontOfSize:13.0];
    btnNoPay.layer.masksToBounds = YES;
    btnNoPay.layer.cornerRadius = 2;
    [viewHeard addSubview:btnNoPay];
    
    _tableViewOrder.tableHeaderView = viewHeard;
}
//下拉刷新
- (void)headerTabRefereshClick:(MJRefreshNormalHeader *)header{
    _intPages = 0;
    _intCurrPage = 1;
    [self getAllOrderList];
}
///上拉刷新
- (void)footerRefreshClick:(MJRefreshBackNormalFooter *)refreshFooter{
    [self getAllOrderList];
}
///获取订单列表
- (void)getAllOrderList{
    if (_intPages != 0) {
        if (_intCurrPage > _intPages) {
            [_refreshFooter endRefreshingWithNoMoreData];
            return;
        }
    }
    [SVProgressHUD show];
    NSString *urlString = [NSString stringWithFormat:@"%@/ty/mobile/order/orderList?jeeId=%@&fromSystem=902&pageIndex=%ld&pageCount=%ld&paymentStatus=%ld",systemHttpsKaoLaTopicImg,_dicUserInfo[@"jeeId"],_intCurrPage,_intPageSize,_intPaymentStatus];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicOrder = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        if ([dicOrder[@"code"] integerValue] == 1) {
            ///下拉刷新（防止重复添加菜单列表）
            if (_intCurrPage == 1) {
                [_arrayOrderList removeAllObjects];
            }
            NSDictionary *dicDatas = dicOrder[@"datas"];
            if ([dicDatas[@"status"] integerValue] == 1) {
                NSArray *arrayOrderList = dicDatas[@"data"];
                if (arrayOrderList.count != 0) {
                    if (_intPages == 0) {
                        [self addRefreshForTableViewOrder];
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
            [_refreshHeader endRefreshing];
            [_tableViewOrder reloadData];
            [_viewMz removeFromSuperview];
            [SVProgressHUD dismiss];
        }
    } RequestFaile:^(NSError *error) {
        [_viewMz removeFromSuperview];
        [_refreshFooter endRefreshing];
        [_refreshHeader endRefreshing];
        httpsErrorShow;
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
                [_tableViewOrder setEditing:NO animated:YES];
                [SVProgressHUD showSuccessWithStatus:dicData[@"message"]];
            }
        }
    } RequestFaile:^(NSError *error) {
        [_viewMz removeFromSuperview];
        httpsErrorShow;
    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrayOrderList.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *viewHeard = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 50)];
    viewHeard.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(0, 48, Scr_Width, 2)];
    viewLine.backgroundColor = ColorWithRGB(190, 200, 252);
    [viewHeard addSubview:viewLine];
    UILabel *labText = [[UILabel alloc]initWithFrame:CGRectMake(10, 18, 113, 30)];
    labText.text = @"我的订单列表";
    labText.textAlignment = NSTextAlignmentCenter;
    labText.backgroundColor = ColorWithRGB(190, 200, 252);
    labText.textColor = ColorWithRGB(90, 144, 266);
    labText.font = [UIFont systemFontOfSize:15.0];
    [viewHeard addSubview:labText];
    ///已完成按钮
    UIButton *btnDidPay = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDidPay.frame = CGRectMake(Scr_Width - 60 - 10, 25, 60, 23);
    btnDidPay.backgroundColor = ColorWithRGB(190, 200, 252);
    [btnDidPay setTitle:@"已完成" forState:UIControlStateNormal];
    [btnDidPay setTitleColor:ColorWithRGB(90, 144, 266) forState:UIControlStateNormal];
    btnDidPay.titleLabel.font = [UIFont systemFontOfSize:13.0];
    btnDidPay.layer.masksToBounds = YES;
    btnDidPay.layer.cornerRadius = 2;
//    btnDidPay.layer.borderWidth = 1;
//    btnDidPay.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    btnDidPay.tag = 101;
    [btnDidPay addTarget:self action:@selector(buttonPayStatuClick:) forControlEvents:UIControlEventTouchUpInside];
    [viewHeard addSubview:btnDidPay];
    ///未完成按钮
    UIButton *btnNoPay = [UIButton buttonWithType:UIButtonTypeCustom];
    btnNoPay.frame = CGRectMake(Scr_Width - 60 - 60 - 10 - 10, 25, 60, 23);
    btnNoPay.backgroundColor = ColorWithRGB(190, 200, 252);
    [btnNoPay setTitle:@"未付款" forState:UIControlStateNormal];
    [btnNoPay setTitleColor:ColorWithRGB(90, 144, 266) forState:UIControlStateNormal];
    btnNoPay.titleLabel.font = [UIFont systemFontOfSize:13.0];
    btnNoPay.layer.masksToBounds = YES;
    btnNoPay.layer.cornerRadius = 2;
//    btnNoPay.layer.borderWidth = 1;
//    btnNoPay.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    btnNoPay.tag = 100;
    [btnNoPay addTarget:self action:@selector(buttonPayStatuClick:) forControlEvents:UIControlEventTouchUpInside];
    [viewHeard addSubview:btnNoPay];
    
    if (_intPaymentStatus == 5001) {
        btnNoPay.backgroundColor = [UIColor lightGrayColor];
        [btnNoPay setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    else{
        btnDidPay.backgroundColor = [UIColor lightGrayColor];
        [btnDidPay setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return viewHeard;
}
- (void)buttonPayStatuClick:(UIButton *)button{
    UIView *supViewBtn = button.superview;
    for (id subView in supViewBtn.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)subView;
            if (btn == button) {
                NSLog(@"btn.tag == %ld",btn.tag);
                btn.backgroundColor = [UIColor lightGrayColor];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
            else{
                btn.backgroundColor = ColorWithRGB(190, 200, 252);
                [btn setTitleColor:ColorWithRGB(90, 144, 266) forState:UIControlStateNormal];
            }
        }
    }
    if (button.tag == 100) {
        _intPaymentStatus = 5001;
    }
    else{
        _intPaymentStatus = 5003;
    }
    _intCurrPage = 1;
    _intPages = 0;
    [self getAllOrderList];
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
    return @"删除订单";
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    LXAlertView *deleteAl = [[LXAlertView alloc]initWithTitle:@"订单删除" message:@"确认删除该订单信息吗？" cancelBtnTitle:@"删除" otherBtnTitle:@"保留" clickIndexBlock:^(NSInteger clickIndex) {
        if (clickIndex == 0) {
            //删除
            NSDictionary *dicOrder = _arrayOrderList[indexPath.row];
            [self deleteOrderWithOrderId:dicOrder[@"id"]];
        }
        else{
            //保留
            [tableView setEditing:NO animated:YES];
        }
    }];
    deleteAl.animationStyle = LXASAnimationTopShake;
    [deleteAl showLXAlertView];
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
