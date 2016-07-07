//
//  ActiveSubjectViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/6/29.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "ActiveSubjectViewController.h"
#import "OrderInfoViewController.h"
@interface ActiveSubjectViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableViewProduct;
@property (nonatomic,strong) NSUserDefaults *tyUser;
//用户信息
@property (nonatomic,strong) NSDictionary *dicUserInfo;
//商品信息
@property (nonatomic,strong) NSMutableArray *arrayProduct;
//
@property (nonatomic,strong) NSArray *arrayTitle;
//激活码文本框
@property (nonatomic,strong) UITextField *textFile;
@end
@implementation ActiveSubjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"科目激活";
    _tyUser = [NSUserDefaults standardUserDefaults];
    _dicUserInfo = [_tyUser objectForKey:tyUserUserInfo];
    _arrayTitle = @[@"专业类别",@"所属专业",@"科目",@"价格"];
    _arrayProduct = [NSMutableArray array];
    _tableViewProduct.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addLiftButtonitem];
    [self getProductInfoWithSubjectId];
    // Do any additional setup after loading the view from its nib.
}
///添加navi左边按钮
- (void)addLiftButtonitem{
    UIBarButtonItem *BtnItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"top_backbtn"] style:UIBarButtonItemStylePlain target:self action:@selector(liftButtonitemClick:)];
    self.navigationItem.leftBarButtonItem = BtnItem;
}
///pop
- (void)liftButtonitemClick:(UIBarButtonItem *)buttonItem{
    [self.navigationController popViewControllerAnimated:YES];
}
///添加tableView头试图，显示科目图片
- (void)addTableViewHeardView{
    ///待开发
}
///添加tableView尾试图（激活码输入，激活按钮）
- (void)addTableViewFooterView{
    UIView *viewFooter = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 90)];
    UIButton *buttonAc = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonAc.frame = CGRectMake(30, 30, Scr_Width - 60, 35);
    buttonAc.backgroundColor = ColorWithRGB(88, 155, 255);
    buttonAc.layer.masksToBounds = YES;
    buttonAc.layer.cornerRadius = 3;
    [buttonAc setTitle:@"下单购买" forState:UIControlStateNormal];
    [buttonAc setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [buttonAc addTarget:self action:@selector(buttonActiveClick:) forControlEvents:UIControlEventTouchUpInside];
    [viewFooter addSubview:buttonAc];
    //激活
    if (self.payParameter == 0) {
        viewFooter.frame = CGRectMake(0, 0, Scr_Width, 140);
        buttonAc.frame = CGRectMake(30, 90, Scr_Width - 60, 35);
        [buttonAc setTitle:@"激 活" forState:UIControlStateNormal];
        _textFile = [[UITextField alloc]initWithFrame:CGRectMake(30, 30, Scr_Width - 60, 40)];
        _textFile.borderStyle = UITextBorderStyleRoundedRect;
        _textFile.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        _textFile.placeholder = @"输入码激活";
        _textFile.delegate = self;
        _textFile.clearButtonMode = UITextFieldViewModeAlways;
        [viewFooter addSubview:_textFile];
        //添加手势
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
        [_tableViewProduct addGestureRecognizer:tapGest];
    }
    _tableViewProduct.tableFooterView = viewFooter;
}
- (void)tapClick:(UITapGestureRecognizer *)tapGest{
    [_textFile resignFirstResponder];
}
///激活按钮
- (void)buttonActiveClick:(UIButton *)button{
    ///激活
    if (self.payParameter == 0) {
        if ([_textFile.text isEqualToString:@""]) {
            [SVProgressHUD showInfoWithStatus:@"请输入激活码"];
            return;
        }
        [self activeSubject];
    }
    ///下单购买
    else{
        [self createProductOrder];
    }
}
///根据科目id获取商品信息
- (void)getProductInfoWithSubjectId{
    [SVProgressHUD show];
    NSString *urlString = [NSString stringWithFormat:@"%@/ty/mobile/order/productInfo?productId=%ld&jeeId=%@&fromSystem=902",systemHttpsKaoLaTopicImg,_subjectId,_dicUserInfo[@"jeeId"]];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicProduct = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        if ([dicProduct[@"code"] integerValue] == 1) {
            NSDictionary *dicDatas = dicProduct[@"datas"];
            NSDictionary *dicData = dicDatas[@"data"];
            [_arrayProduct addObject:dicData[@"pclassName"]];
            [_arrayProduct addObject:dicData[@"className"]];
            [_arrayProduct addObject:dicData[@"name"]];
            [_arrayProduct addObject:[NSString stringWithFormat:@"￥%.2f",[dicData[@"price"] floatValue]]];
            [self addTableViewFooterView];
            [_tableViewProduct reloadData];
        }
        [SVProgressHUD dismiss];
    } RequestFaile:^(NSError *error) {
         [SVProgressHUD showInfoWithStatus:@"操作异常！"];
    }];
}
/**
 激活科目
 */
- (void)activeSubject{
    [SVProgressHUD show];
    NSString *urlString = [NSString stringWithFormat:@"%@/ty/mobile/order/payCode?code=%@&productId=%ld&jeeId=%@&fromSystem=902",systemHttpsKaoLaTopicImg,_textFile.text,_subjectId,_dicUserInfo[@"jeeId"]];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicAc = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSDictionary *dicDatas = dicAc[@"datas"];
        if ([dicDatas[@"status"] integerValue] == 0) {
            [SVProgressHUD showInfoWithStatus:dicDatas[@"message"]];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            [SVProgressHUD showSuccessWithStatus:dicDatas[@"data"]];
        }
        
    }RequestFaile:^(NSError *error) {
       [SVProgressHUD showInfoWithStatus:@"操作异常！"];
    }];
}
/**
 创建订单
 */
- (void)createProductOrder{
//    /ty/mobile/order/orderCreate?productId=662&fromSystem=4
    [SVProgressHUD showWithStatus:@"订单创建中..."];
    NSString *urlString = [NSString stringWithFormat:@"%@/ty/mobile/order/orderCreate?productId=%ld&jeeId=%@&fromSystem=902",systemHttpsKaoLaTopicImg,_subjectId,_dicUserInfo[@"jeeId"]];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicOrder = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        if ([dicOrder[@"code"] integerValue] == 1) {
            NSDictionary *dicDatas = dicOrder[@"datas"];
            NSDictionary *dicOrderInfo = dicDatas[@"data"];
            [self goOrderInfoView:dicOrderInfo];
        }
        [SVProgressHUD dismiss];
    } RequestFaile:^(NSError *error) {
        [SVProgressHUD showInfoWithStatus:@"操作异常！"];
    }];
}
///跳转到订单详情页面
- (void)goOrderInfoView:(NSDictionary *)dicOrder{
    UIStoryboard *sUser = CustomStoryboard(@"TyUserIn");
    OrderInfoViewController *orderVc = [sUser instantiateViewControllerWithIdentifier:@"OrderInfoViewController"];
    orderVc.dicOrder = dicOrder;
    [self.navigationController pushViewController:orderVc animated:YES];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrayProduct.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellac" forIndexPath:indexPath];
    UILabel *labTitle = (UILabel *)[cell.contentView viewWithTag:10];
    labTitle.text = _arrayTitle[indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    UILabel *labName = (UILabel *)[cell.contentView viewWithTag:11];
    labName.text = _arrayProduct[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
//换行或者return
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    //控制激活码在15个字符
    if (textField.text.length > 14 && ![string isEqualToString:@""]) {
        return NO;
    }
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}
@end
