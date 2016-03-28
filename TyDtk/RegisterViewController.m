//
//  RegisterViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/3/21.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "RegisterViewController.h"
@interface RegisterViewController ()
@property (nonatomic,strong) UIView *viewLine;
@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self viewLoad];
}
- (void)viewLoad{
    self.title = @"新用户注册";
    _viewLine = [[UIView alloc]initWithFrame:CGRectMake(0, 64+48, (Scr_Width/2), 2)];
    _viewLine.backgroundColor = [UIColor redColor];
    [self.view addSubview:_viewLine];
    
    UIViewController *viewC = [self.storyboard instantiateViewControllerWithIdentifier:@"TestViewController"];
    [self addChildViewController:viewC];
    
    TestViewController *tTest= self.childViewControllers[0];
    tTest.view.frame = CGRectMake(0, (64+50), Scr_Width, Scr_Height - (64+50));
    [self.view addSubview:tTest.view];
    
}
- (IBAction)btnPwdClick:(UIButton *)sender {
    CGRect rect = _viewLine.frame;
    rect.origin.x =(Scr_Width/2)*sender.tag;
    [UIView animateWithDuration:0.2 animations:^{
        _viewLine.frame = rect;
    }];
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
