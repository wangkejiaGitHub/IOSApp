//
//  DtkNavViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/6/23.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "DtkNavViewController.h"
#import "IndexViewController.h"
@interface DtkNavViewController ()

@end

@implementation DtkNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    UIStoryboard *sTyDty = CustomStoryboard(@"TyDtk");
//    IndexViewController *indexVc = [sTyDty instantiateViewControllerWithIdentifier:@"IndexViewController"];
//    self.viewControllers = @[indexVc];
        self.tabBarItem.selectedImage = [[UIImage imageNamed:@"btm_icon1_hover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
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
