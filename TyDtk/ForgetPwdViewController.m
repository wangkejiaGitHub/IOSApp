//
//  ForgetPwdViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/3/21.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "ForgetPwdViewController.h"
#import "PhoneForPwdViewController.h"
#import "EmailForPwdViewController.h"
@interface ForgetPwdViewController ()
@property (weak, nonatomic) IBOutlet UIView *heardView;
@property (weak, nonatomic) IBOutlet UIButton *buttonPhone;
@property (weak, nonatomic) IBOutlet UIButton *buttonEmail;
@property (nonatomic,strong) UIView *viewLine;
@property (nonatomic,assign) CGFloat rgbSize;
@property (nonatomic,strong) PhoneForPwdViewController *pVc;
@property (nonatomic,strong) EmailForPwdViewController *eVc;
@end

@implementation ForgetPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self viewLoad];
}
- (void)viewLoad{
    self.title = @"找回密码";
    _rgbSize = 200;
    _viewLine = [[UIView alloc]initWithFrame:CGRectMake(0, 48, Scr_Width/2, 2)];
    _viewLine.backgroundColor = [UIColor redColor];
    [_heardView addSubview:_viewLine];
    
    UIViewController *view1 = [self.storyboard instantiateViewControllerWithIdentifier:@"PhoneForPwdViewController"];
    [self addChildViewController:view1];
    
    UIViewController *view2 = [self.storyboard instantiateViewControllerWithIdentifier:@"EmailForPwdViewController"];
    [self addChildViewController:view2];
    
    _pVc = self.childViewControllers[0];
    _pVc.view.frame = CGRectMake(0, 50+64, Scr_Width, Scr_Height-50-64);
    [self.view addSubview:_pVc.view];
    
    _buttonPhone.backgroundColor = ColorWithRGB(170, 170, 170);
    _buttonEmail.backgroundColor = ColorWithRGB(_rgbSize, _rgbSize, _rgbSize);
}
/**
 添加子试图
 */
- (void)addChildVIewForSelf:(NSInteger)vcId{
    [_eVc.view removeFromSuperview];
    [_pVc.view removeFromSuperview];
    if (vcId == 0) {
        _pVc = self.childViewControllers[vcId];
        _pVc.view.frame = CGRectMake(0, 50+64, Scr_Width, Scr_Height-50-64);
        [self.view addSubview:_pVc.view];
    }
    else{
        _eVc = self.childViewControllers[vcId];
        _eVc.view.frame = CGRectMake(0, 50+64, Scr_Width, Scr_Height-50-64);
        [self.view addSubview:_eVc.view];
    }
}
- (IBAction)buttonClick:(UIButton *)sender {
    NSInteger tagBtn = sender.tag;
    for (id subView in _heardView.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *currBtn = (UIButton *)subView;
            if (currBtn.tag == tagBtn) {
                currBtn.backgroundColor = ColorWithRGB(170, 170, 170);
            }
            else{
                currBtn.backgroundColor = ColorWithRGB(_rgbSize, _rgbSize, _rgbSize);
            }
        }
    }
    //下划线跟踪
    CGRect rect = _viewLine.frame;
    rect.origin.x = tagBtn*Scr_Width/2;
    [UIView animateWithDuration:0.2 animations:^{
        _viewLine.frame = rect;
    }];
    
    [self addChildVIewForSelf:tagBtn];
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
