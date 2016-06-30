//
//  OrderInfoViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/6/30.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "OrderInfoViewController.h"
#import "OrderHeardView.h"
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
        [self addTableViewFooterView];
    }
    else{
        _tableViewOrder.tableFooterView = [UIView new];
    }
}
///如果未付款，添加付款按钮
- (void)addTableViewFooterView{
    UIView *viewFooter = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 90)];
    UIButton *btnPay = [UIButton buttonWithType:UIButtonTypeCustom];
    btnPay.frame = CGRectMake(30, 30, Scr_Width - 60, 35);
    btnPay.layer.masksToBounds = YES;
    btnPay.layer.cornerRadius = 3;
    btnPay.backgroundColor = ColorWithRGB(55, 155, 255);
    [btnPay setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnPay setTitle:@"付 款" forState:UIControlStateNormal];
    [viewFooter addSubview:btnPay];
    _tableViewOrder.tableFooterView = viewFooter;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *arrayProduct = _dicOrder[@"shopOrderitems"];
    return arrayProduct.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *viewSec = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 40)];
    viewSec.backgroundColor = ColorWithRGB(200, 200, 200);
    
    UILabel *labTitle = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, 80, 20)];
    labTitle.text = @"商品详情";
    labTitle.font = [UIFont systemFontOfSize:16.0];
    labTitle.textColor = ColorWithRGB(55, 155, 255);
    [viewSec addSubview:labTitle];
    return viewSec;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"productcell" forIndexPath:indexPath];
    NSArray *arrayProduct = _dicOrder[@"shopOrderitems"];
    NSDictionary *dicProduct = arrayProduct[indexPath.row];
    UIImageView *imagePro = (UIImageView *)[cell.contentView viewWithTag:9];
    [imagePro sd_setImageWithURL:[NSURL URLWithString:dicProduct[@"imgUrl"]]];
    UILabel *labName = (UILabel *)[cell.contentView viewWithTag:10];
    labName.text = dicProduct[@"productName"];
    UILabel *labCount = (UILabel *)[cell.contentView viewWithTag:11];
    labCount.text = [NSString stringWithFormat:@"数量：%ld",[dicProduct[@"productQuantity"] integerValue]];
    UILabel *labMoney = (UILabel *)[cell.contentView viewWithTag:12];
    labMoney.text = [NSString stringWithFormat:@"价格：￥%.2f",[dicProduct[@"productPrice"] floatValue]];
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
