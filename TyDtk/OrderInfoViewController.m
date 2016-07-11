//
//  OrderInfoViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/6/30.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "OrderInfoViewController.h"
#import "OrderHeardView.h"
#import "PayMoneyViewController.h"
@interface OrderInfoViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableViewOrder;

@end

@implementation OrderInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"订单详情";
    [self addTableViewHeardOrderView];
}
///添加头试图（展示订单信息）
- (void)addTableViewHeardOrderView{
    OrderHeardView *orderView = [[[NSBundle mainBundle] loadNibNamed:@"OrderHeardView" owner:self options:nil]lastObject];
    orderView.frame = CGRectMake(0, 0, Scr_Width, 200);
    orderView.labOrderId.text = _dicOrder[@"id"];
    orderView.labOrderTime.text = _dicOrder[@"createDateString"];
    orderView.labOrderCount.text = [NSString stringWithFormat:@"%ld",[_dicOrder[@"productTotalQuantity"] integerValue]];;
    orderView.labOrderMoney.text = [NSString stringWithFormat:@"￥%.2f",[_dicOrder[@"productTotalPrice"] floatValue]];
    orderView.labOrderPayStatus.text = _dicOrder[@"paymentStatusName"];
    _tableViewOrder.tableHeaderView = orderView;
    ///未付款
    if ([_dicOrder[@"paymentStatus"] integerValue] == 5001) {
        orderView.labOrderPayStatus.textColor = [UIColor redColor];
        [self addTableViewFooterView];
    }
    else{
        orderView.labOrderPayStatus.text = [NSString stringWithFormat:@"%@（%@）",_dicOrder[@"paymentStatusName"],_dicOrder[@"paymentConfigName"]];
        _tableViewOrder.tableFooterView = [UIView new];
    }
}
///如果未付款，添加付款按钮
- (void)addTableViewFooterView{
    UIView *viewFooter = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 90)];
    UIView *viewL = [[UIView alloc]initWithFrame:CGRectMake(15, 0, Scr_Width - 15, 1)];
    viewL.backgroundColor = [UIColor lightGrayColor];
    [viewFooter addSubview:viewL];
    UIButton *btnPay = [UIButton buttonWithType:UIButtonTypeCustom];
    btnPay.frame = CGRectMake(30, 30, Scr_Width - 60, 45);
    btnPay.layer.masksToBounds = YES;
    btnPay.layer.cornerRadius = 3;
    btnPay.backgroundColor = ColorWithRGB(55, 155, 255);
    [btnPay setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnPay setTitle:@"付 款" forState:UIControlStateNormal];
    [btnPay addTarget:self action:@selector(btnPayClick:) forControlEvents:UIControlEventTouchUpInside];
    [viewFooter addSubview:btnPay];
    _tableViewOrder.tableFooterView = viewFooter;
}
///付款按钮
- (void)btnPayClick:(UIButton *)button{
    UIStoryboard *sCommon = CustomStoryboard(@"TyCommon");
    PayMoneyViewController *payVc = [sCommon instantiateViewControllerWithIdentifier:@"PayMoneyViewController"];
    payVc.payMoneyAll = [_dicOrder[@"totalAmount"] floatValue];
    payVc.dicOrder = _dicOrder;
    [self.navigationController pushViewController:payVc animated:YES];
    NSLog(@"付款");
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *arrayProduct = _dicOrder[@"shopOrderitems"];
    return arrayProduct.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *viewSec = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 40)];
    viewSec.backgroundColor = ColorWithRGB(200, 200, 200);
    
    UILabel *labTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 80, 20)];
    labTitle.text = @"商品详情";
    labTitle.font = [UIFont systemFontOfSize:16.0];
    labTitle.textColor = ColorWithRGB(55, 155, 255);
    [viewSec addSubview:labTitle];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(Scr_Width - 80, 15/2, 70, 25);
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 3;
    btn.backgroundColor = ColorWithRGB(55, 155, 255);
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    ///设置显示付款状态按钮字符串
    ///未付款
    if ([_dicOrder[@"paymentStatus"] integerValue] == 5001) {
        [btn setTitle:@"付 款" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnPayClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    ///已付款
    else{
        [btn setTitle:@"已付款" forState:UIControlStateNormal];
    }
    [viewSec addSubview:btn];
    return viewSec;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"productcell" forIndexPath:indexPath];
    NSArray *arrayProduct = _dicOrder[@"shopOrderitems"];
    NSDictionary *dicProduct = arrayProduct[indexPath.row];
    UILabel *labName = (UILabel *)[cell.contentView viewWithTag:10];
    labName.text = dicProduct[@"productName"];
    UILabel *labCount = (UILabel *)[cell.contentView viewWithTag:11];
    labCount.text = [NSString stringWithFormat:@"%ld",[dicProduct[@"productQuantity"] integerValue]];
    UILabel *labMoney = (UILabel *)[cell.contentView viewWithTag:12];
    labMoney.text = [NSString stringWithFormat:@"￥%.2f",[dicProduct[@"productPrice"] floatValue]];
    
    UILabel *labType = (UILabel *)[cell.contentView viewWithTag:13];
    labType.text = [NSString stringWithFormat:@"%@",dicProduct[@"typeName"]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
