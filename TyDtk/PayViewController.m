//
//  PayViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/6/28.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "PayViewController.h"

@interface PayViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableViewPay;
@property (nonatomic,strong) NSArray *arrayCellImg;
@property (nonatomic,assign) NSInteger selectRow;
@property (nonatomic,strong) UIButton *btnPay;
@end

@implementation PayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"科目激活";
    _arrayCellImg = @[@"",@"alipay",@"wxpay"];
    self.tableViewPay.backgroundColor = [UIColor whiteColor];
    
    UIView *viewFooter = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 200)];
    viewFooter.backgroundColor = [UIColor whiteColor];
    
    _btnPay = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnPay.frame = CGRectMake(30, 50, Scr_Width - 60, 45);
    _btnPay.backgroundColor = ColorWithRGB(90, 144, 266);
    [_btnPay setTitle:@"激 活" forState:UIControlStateNormal];
    _btnPay.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [_btnPay setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _btnPay.layer.masksToBounds = YES;
    _btnPay.layer.cornerRadius = 3;
    [_btnPay addTarget:self action:@selector(buttonPayClick:) forControlEvents:UIControlEventTouchUpInside];
    [viewFooter addSubview:_btnPay];
    _tableViewPay.tableFooterView = viewFooter;
}
//激活或购买科目
- (void)buttonPayClick:(UIButton *)button{
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellpay" forIndexPath:indexPath];
    for (id subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    
    UIImageView *imageVS = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 30, 30)];
    [cell.contentView addSubview:imageVS];
    
    if (indexPath.row == _selectRow) {
        imageVS.image = [UIImage imageNamed:@"ico_check_circle"];
    }
    else{
        imageVS.image = [UIImage imageNamed:@"ico_circle_o"];
    }
    UIImageView *imagePay = [[UIImageView alloc]initWithFrame:CGRectMake(60, 10, 120, 40)];
    imagePay.image = [UIImage imageNamed:_arrayCellImg[indexPath.row]];
    [cell.contentView addSubview:imagePay];
    
    
    if (indexPath.row == 2) {
        imagePay.frame = CGRectMake(60, 10, 140, 40);
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _selectRow = indexPath.row;
    [_tableViewPay reloadData];
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
