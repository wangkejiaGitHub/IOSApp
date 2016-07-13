//
//  PracticeNavViewController.m
//  TyDtk
//   练习中心
//  Created by 天一文化 on 16/6/23.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "PracticeNavViewController.h"

@interface PracticeNavViewController ()

@end

@implementation PracticeNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tabBarItem.selectedImage = [[UIImage imageNamed:@"btm_icon4_hover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
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
