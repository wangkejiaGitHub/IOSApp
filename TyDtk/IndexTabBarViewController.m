//
//  IndexTabBarViewController.m
//  TyDtk
//  程序入口
//  Created by 天一文化 on 16/5/26.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "IndexTabBarViewController.h"
#import "GuideView.h"
#import "DtkNavViewController.h"
#import "PracticeNavViewController.h"
#import "UserNavViewController.h"
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
    //引导页加载完后，删除
    
    /////////////////////////////////////////////////////////
    UIStoryboard *sTyDtk = CustomStoryboard(@"TyDtk");
    UIStoryboard *sTyPractice = CustomStoryboard(@"TyPractice");
    UIStoryboard *sTyUser = CustomStoryboard(@"TyUser");
    //
    DtkNavViewController *dtkNavi = [sTyDtk instantiateViewControllerWithIdentifier:@"DtkNavViewController"];
    PracticeNavViewController *praNavi = [sTyPractice instantiateViewControllerWithIdentifier:@"PracticeNavViewController"];
    UserNavViewController *userNavi = [sTyUser instantiateViewControllerWithIdentifier:@"UserNavViewController"];
    self.viewControllers = @[dtkNavi,praNavi,userNavi];
}
//左滑或点击button回调
- (void)GuideViewDismiss{
//    [UIView animateWithDuration:0.3 animations:^{
//        CGRect rect = _scrollViewFirst.frame;
//        rect.origin.x = -Scr_Width;
//        _scrollViewFirst.frame = rect;
//    }];
//    [self firstViewDismiss];
    ///下次进入不再出现
    [_tyUser setObject:@"yes" forKey:tyUserFirstLoad];
}

- (void)firstViewDismiss{
    CABasicAnimation *cba1=[CABasicAnimation animationWithKeyPath:@"position"];
    cba1.fromValue=[NSValue valueWithCGPoint:CGPointMake(self.view.center.x, self.view.center.y)];
    cba1.toValue=[NSValue valueWithCGPoint:CGPointMake(self.view.center.x - Scr_Width, self.view.center.y)];
    cba1.duration = 0.3;
    cba1.removedOnCompletion=NO;
    cba1.fillMode=kCAFillModeForwards;
    cba1.delegate = self;
    [_scrollViewFirst.layer addAnimation:cba1 forKey:@"first"];
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (anim == [_scrollViewFirst.layer animationForKey:@"first"]) {
        [_scrollViewFirst removeFromSuperview];
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
