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
@interface IndexTabBarViewController ()<GuideViewDelegate,UITabBarControllerDelegate,LoginDelegate>
@property (nonatomic,strong) GuideView *scrollViewFirst;
@property (nonatomic,strong) NSUserDefaults *tyUser;
///用户判断用户是否登录
@property (nonatomic,strong) LoginUser *loginUser;
@end
@implementation IndexTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tyUser = [NSUserDefaults standardUserDefaults];
    _loginUser = [[LoginUser alloc]init];
    _loginUser.delegateLogin = self;
    ///提前获取纠错类型
    if (![_tyUser objectForKey:tyUserErrorTopic]) {
         [self getTopicErrorType];
    }
    ///如果是在用户没有手动退出的时候、先判断是否登录超时（如果是手动退出，不做操作）
    if ([_tyUser objectForKey:tyUserUserInfo]) {
        NSDictionary *dicUserInfo = [_tyUser objectForKey:tyUserUserInfo];
        [_loginUser getUserInformationoWithJeeId:dicUserInfo[@"jeeId"]];
    }
    
    if (![_tyUser objectForKey:tyUserFirstLoad]) {
        NSArray *arrayImgUrl = @[@"http://api.kaola100.com/Content/Images/face-2.jpg",@"http://api.kaola100.com/Content/Images/face-1.jpg",@"http://api.kaola100.com/Content/Images/face-3.jpg"];
        _scrollViewFirst  = [[GuideView alloc]initWithFrame:CGRectMake(0, Scr_Height, Scr_Width, Scr_Height) arrayImgUrl:arrayImgUrl];
        _scrollViewFirst.backgroundColor = [UIColor whiteColor];
        _scrollViewFirst.delegateGuideView = self;
        [self.view addSubview:_scrollViewFirst];
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rect = _scrollViewFirst.frame;
            rect.origin.y = 0;
            _scrollViewFirst.frame = rect;
        }];
    }
    //引导页加载完后，删除
    
    /////////////////////////////////////////////////////////
    self.delegate  = self;
    UIStoryboard *sTyDtk = CustomStoryboard(@"TyDTK");
    UIStoryboard *sTyPractice = CustomStoryboard(@"TyLearn");
    UIStoryboard *sTyUser = CustomStoryboard(@"TyUserIn");
    //
    DtkNavViewController *dtkNavi = [sTyDtk instantiateViewControllerWithIdentifier:@"DtkNavViewController"];
    PracticeNavViewController *praNavi = [sTyPractice instantiateViewControllerWithIdentifier:@"PracticeNavViewController"];
    UserNavViewController *userNavi = [sTyUser instantiateViewControllerWithIdentifier:@"UserNavViewController"];
    self.viewControllers = @[dtkNavi,praNavi,userNavi];
}
//左滑或点击button回调
- (void)GuideViewDismiss{
    [self firstViewDismiss];
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
///测试tabbar选中
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    
}
///在用户未手动退出的时候，判断是否超时回调
- (void)getUserInfoIsDictionary:(NSDictionary *)dicUser messagePara:(NSInteger)msgPara{
    ///登录超时,发起自动登录
    if (msgPara == 0) {
        NSDictionary *dicAccount = [_tyUser objectForKey:tyUserAccount];
        [_loginUser LoginAppWithAccount:dicAccount[@"acc"] password:dicAccount[@"pwd"]];
    }
    ///登录未超时
    else{
        [_tyUser setObject:dicUser forKey:tyUserUserInfo];
    }
}

/****************************************
 ****************************************
 提前获取试题的纠错类型，并存在 NSUserDefaults
 ****************************************
 ****************************************/
- (void)getTopicErrorType{
    
    NSString *urlString = [NSString stringWithFormat:@"%@api/Correct/GetCorrectLevels",systemHttps];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dic[@"code"] integerValue];
        if (codeId == 1) {
            NSArray *arrayError = dic[@"datas"];
            NSUserDefaults *tyUser = [NSUserDefaults standardUserDefaults];
            [tyUser setObject:arrayError forKey:tyUserErrorTopic];
        }
    } RequestFaile:^(NSError *error) {
        
    }];
}
/***************************************
 ****************************************/

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
