//
//  PayMoneyViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/7/5.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//
#define YYIP @"https://api.mch.weixin.qq.com/pay/unifiedorder"
#import "PayMoneyViewController.h"
///支付宝相关
#import "Order.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>
///微信相关
#import "WXApi.h"
@interface PayMoneyViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableViewPay;
@property (nonatomic,assign) NSInteger intCurrSelect;
@end

@implementation PayMoneyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _intCurrSelect = 0;
    _tableViewPay.tableFooterView = [UIView new];
    _tableViewPay.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.title = @"支付方式";
    [self addTableFooterView];
}
///////////////////////////////////////////////////////////////////////
///////////////////////////////微信相关/////////////////////////////
- (void)viewWillAppear:(BOOL)animated{
    //检测是否装了微信软件
    if ([WXApi isWXAppInstalled]){
        //监听通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getOrderPayResult:) name:@"WXPay" object:nil];
    }
}
#pragma mark - 事件
- (void)getOrderPayResult:(NSNotification *)notification{
    NSLog(@"userInfo: %@",notification.userInfo);
    
    if ([notification.object isEqualToString:@"success"])
    {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示信息" message:@"支付成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else
    {
        [self alert:@"提示" msg:@"支付失败"];
    }
}
//客户端提示信息
- (void)alert:(NSString *)title msg:(NSString *)msg{
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alter show];
}
#pragma mark 移除通知
- (void)dealloc{
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
///////////////////////////////微信相关///////////////////////////////
///////////////////////////////////////////////////////////////////////
- (void)addTableFooterView{
    UIView *viewFooter = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 123)];
    NSString *textString = [NSString stringWithFormat:@"需支付金额：￥%.2f",_payMoneyAll];
    //标题属性字符串
    NSMutableAttributedString *attriTitle = [[NSMutableAttributedString alloc] initWithString:textString];
    
    [attriTitle addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(6,[NSString stringWithFormat:@"%.2f",_payMoneyAll].length+1)];
    UIFont *titleFont = [UIFont systemFontOfSize:20.0];
    [attriTitle addAttribute:NSFontAttributeName value:titleFont
                       range:NSMakeRange(6,[NSString stringWithFormat:@"%.2f",_payMoneyAll].length+1)];
    
    UILabel *labMoney = [[UILabel alloc]initWithFrame:CGRectMake(30, 20, Scr_Width - 60, 30)];
    labMoney.font = [UIFont systemFontOfSize:17.0];
    labMoney.textAlignment = NSTextAlignmentCenter;
    labMoney.textColor = [UIColor lightGrayColor];
    [labMoney setAttributedText:attriTitle];
    UIButton *btnPay = [UIButton buttonWithType:UIButtonTypeCustom];
    btnPay.frame = CGRectMake(30, 70, Scr_Width - 60, 40);
    btnPay.backgroundColor = ColorWithRGB(55, 155, 255);
    btnPay.layer.masksToBounds = YES;
    btnPay.layer.cornerRadius = 3;
    [btnPay setTitle:@"去付款" forState:UIControlStateNormal];
    [btnPay addTarget:self action:@selector(btnPayClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnPay setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [viewFooter addSubview:btnPay];
    [viewFooter addSubview:labMoney];
//    _tableViewPay.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableViewPay.tableFooterView = viewFooter;
    
    UIView *viewHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 30)];
    viewHeader.backgroundColor = [UIColor whiteColor];
    _tableViewPay.tableHeaderView = viewHeader;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"paycell" forIndexPath:indexPath];
    for (id subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    UIImageView *imageS = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 30, 30)];
    if (indexPath.row == _intCurrSelect) {
        imageS.image = [UIImage imageNamed:@"ico_check_circle"];
    }
    else{
        imageS.image = [UIImage imageNamed:@"ico_circle_o"];
    }
    //支付宝
    UIImageView *imagePic =[[UIImageView alloc]initWithFrame:CGRectMake(60, 10, 120, 40)];
    imagePic.image= [UIImage imageNamed:@"alipay"];
    //微信
    if (indexPath.row == 1) {
        imagePic.frame = CGRectMake(60, 10, 135, 40);
        imagePic.image = [UIImage imageNamed:@"wxpay"];
    }
    [cell.contentView addSubview:imageS];
    [cell.contentView addSubview:imagePic];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _intCurrSelect = indexPath.row;
    [_tableViewPay reloadData];
}
///支付按钮
- (void)btnPayClick:(UIButton *)button{
    if (_intCurrSelect == 0) {
        [self alipayPayment];
        NSLog(@"支付宝支付");
    }
    else{
        [self sendNetWorking_WXPay];
        NSLog(@"微信支付");
    }
}
/**
 支付宝支付
 */
- (void)alipayPayment{
/*======================================================================*/
/*===================需要填写商户app申请的=================================*/
    NSString *partner = @"";
    NSString *seller = @"";
    NSString *privateKey = @"";
    //partner和seller获取失败,提示
    if ([partner length] == 0 ||
        [seller length] == 0 ||
        [privateKey length] == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少partner或者seller或者私钥。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.sellerID = seller;
    order.outTradeNO = _dicOrder[@"id"];  //订单ID（由商家自行制定）
    order.subject = @"666"; //商品标题
    order.body = @"001"; //商品描述
    order.totalFee = @"0.01"; //商品价格
    order.notifyURL =  @"http://www.xxx.com"; //回调URL（支付完成通知地址）
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showURL = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"dtkPayCome";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
        }];
    }
}
/**
 微信支付
 */
- (void)sendNetWorking_WXPay{
    NSString * urlStr = [NSString stringWithFormat:@"%@",YYIP];
//    NSString * urlStr = [NSString stringWithFormat:@"%@%@",YYIP,@"wx/pay"];
    
    NSDictionary * parameter = @{
                                 @"pay_type"       : @"1",
                                 @"total_price"    : @"0.01",
                                 @"appointment_id" : @"208"
                                 };
    
    [self sendNetWorkingWith:urlStr andParameter:parameter];
}

#pragma mark 网络请求 -->> post
- (void)sendNetWorkingWith:(NSString *)url andParameter:(NSDictionary *)parameter{
    [HttpTools postHttpRequestURL:url RequestPram:parameter RequestSuccess:^(id respoes) {
//        NSDictionary * result = responseObject[@"result"];
//        
//        NSString * appid         = result[@"appid"];
//        NSString * noncestr      = result[@"noncestr"];
//        NSString * package1      = result[@"package1"];
//        NSString * partnerid     = result[@"partnerid"];
//        NSString * paySign       = result[@"paySign"];
//        NSString * prepayid      = result[@"prepayid"];
//        NSString * timestamp     = result[@"timestamp"];
//    [self WXPayRequest:appid nonceStr:noncestr package:package1 partnerId:partnerid prepayId:prepayid timeStamp:timestamp sign:paySign];
        
    } RequestFaile:^(NSError *erro) {
        
    }];
    
//    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
//    
//    [manager POST:url parameters:parameter progress:^(NSProgress * _Nonnull uploadProgress) {
//        
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        
//        NSLog(@"%@",responseObject);
//        
//        //网络请求回来的8个参数.详见微信开发平台
//        
//        NSDictionary * result = responseObject[@"result"];
//        
//        NSString * appid         = result[@"appid"];
//        NSString * noncestr      = result[@"noncestr"];
//        NSString * package1      = result[@"package1"];
//        NSString * partnerid     = result[@"partnerid"];
//        NSString * paySign       = result[@"paySign"];
//        NSString * prepayid      = result[@"prepayid"];
//        NSString * timestamp     = result[@"timestamp"];
//        
//        
//        //        NSString * err_code      = result[@"err_code"];
//        //        NSString * timeStamp     = result[@"timeStamp"];
//        //        NSString * tradeid       = result[@"tradeid"];
//        
//        
//        [self WXPayRequest:appid nonceStr:noncestr package:package1 partnerId:partnerid prepayId:prepayid timeStamp:timestamp sign:paySign];
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"%@",error);
//    }];
}

#pragma mark - 调起微信支付
- (void)WXPayRequest:(NSString *)appId nonceStr:(NSString *)nonceStr package:(NSString *)package partnerId:(NSString *)partnerId prepayId:(NSString *)prepayId timeStamp:(NSString *)timeStamp sign:(NSString *)sign{
    //调起微信支付
    PayReq* wxreq             = [[PayReq alloc] init];
    
    wxreq.openID              = appId; // 微信的appid
    wxreq.partnerId           = partnerId;
    wxreq.prepayId            = prepayId;
    wxreq.nonceStr            = nonceStr;
    wxreq.timeStamp           = [timeStamp intValue];
    wxreq.package             = package;
    wxreq.sign                = sign;
    
    [WXApi sendReq:wxreq];
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
