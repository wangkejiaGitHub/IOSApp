//
//  IndexTabBarViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/5/26.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "IndexTabBarViewController.h"
#import "GuideView.h"
@interface IndexTabBarViewController ()<GuideViewDelegate>
@property (nonatomic,strong) GuideView *scrollViewFirst;
@property (nonatomic,strong) NSUserDefaults *tyUser;
@end
@implementation IndexTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"hshhss");
//    _tyUser = [NSUserDefaults standardUserDefaults];
//    [_tyUser removeObjectForKey:tyUserFirstLoad];
//    if (![_tyUser objectForKey:tyUserFirstLoad]) {
////        NSArray *arrayImgName = @[@"img1.jpg",@"img2.jpg",@"img3.jpg"];
////        _scrollViewFirst = [[GuideView alloc]initWithFrame:CGRectMake(0, Scr_Height, Scr_Width, Scr_Height) arrayImgName:arrayImgName];
//        NSArray *arrayImgUrl = @[@"http://api.kaola100.com/Content/Images/face-2.jpg",@"http://api.kaola100.com/Content/Images/face-1.jpg",@"http://api.kaola100.com/Content/Images/face-3.jpg"];
//        _scrollViewFirst  = [[GuideView alloc]initWithFrame:CGRectMake(0, Scr_Height, Scr_Width, Scr_Height) arrayImgUrl:arrayImgUrl];
//        _scrollViewFirst.backgroundColor = [UIColor whiteColor];
//        _scrollViewFirst.delegateGuideView = self;
//        [self.view addSubview:_scrollViewFirst];
//        [UIView animateWithDuration:0.3 animations:^{
//            CGRect rect = _scrollViewFirst.frame;
//            rect.origin.y = 0;
//            _scrollViewFirst.frame = rect;
//        }];
//    }
}
//左滑或点击button回调
- (void)GuideViewDismiss{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = _scrollViewFirst.frame;
        rect.origin.x = -Scr_Width;
        _scrollViewFirst.frame = rect;
    }];
    ///下次进入不再出现
    [_tyUser setObject:@"yes" forKey:tyUserFirstLoad];
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
