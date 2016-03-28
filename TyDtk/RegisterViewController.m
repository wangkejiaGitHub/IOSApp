//
//  RegisterViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/3/21.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "RegisterViewController.h"
#import "PhoneReViewController.h"
#import "EmailReViewController.h"
@interface RegisterViewController ()
@property (nonatomic,strong) UIView *viewLine;
//手机注册页面
@property (nonatomic ,strong) PhoneReViewController *phoneReVc;
//邮箱注册页面
@property (nonatomic ,strong) EmailReViewController *emailReVc;
@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self viewLoad];
}
//页面加载
- (void)viewLoad{
    self.title = @"新用户注册";
    _viewLine = [[UIView alloc]initWithFrame:CGRectMake(0, 64+48, (Scr_Width/2), 2)];
    _viewLine.backgroundColor = [UIColor redColor];
    [self.view addSubview:_viewLine];
    
//    UIViewController *viewC = [self.storyboard instantiateViewControllerWithIdentifier:@"TestViewController"];
//    [self addChildViewController:viewC];
//    
//    TestViewController *tTest= self.childViewControllers[0];
//    tTest.view.frame = CGRectMake(0, (64+50), Scr_Width, Scr_Height - (64+50));
//    [self.view addSubview:tTest.view];
    [self addRegistChildViewControllerForSelf];
    
}
/**
 添加子试图
 */
- (void)addRegistChildViewControllerForSelf{
    UIViewController *viewC1 = [self.storyboard instantiateViewControllerWithIdentifier:@"PhoneReViewController"];
    [self addChildViewController:viewC1];
    UIViewController *viewC2 = [self.storyboard instantiateViewControllerWithIdentifier:@"EmailReViewController"];
    [self addChildViewController:viewC2];
    
    _phoneReVc = self.childViewControllers[0];
    _phoneReVc.view.frame = CGRectMake(0, (64+50), Scr_Width, Scr_Height - (64+50));
    _emailReVc = self.childViewControllers[1];
    _emailReVc.view.frame = CGRectMake(0, (64+50), Scr_Width, Scr_Height - (64+50));
    
    [self.view addSubview:_phoneReVc.view];
                                      
}
//注册方式选择
- (IBAction)btnPwdClick:(UIButton *)sender {
    NSInteger tagSen = sender.tag;
    //下划线的跟踪
    CGRect rect = _viewLine.frame;
    rect.origin.x =(Scr_Width/2)*tagSen;
    [UIView animateWithDuration:0.2 animations:^{
        _viewLine.frame = rect;
    }];
    [_phoneReVc.view removeFromSuperview];
    [_emailReVc.view removeFromSuperview];
    if (tagSen == 0) {
        [self.view addSubview:_phoneReVc.view];
    }
    else{
        [self.view addSubview:_emailReVc.view];
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
