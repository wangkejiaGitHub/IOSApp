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
#import "LoginViewController.h"

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
    ///加载引导页
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
    ////////////////////////////////////////////////////////////
    _loginUser = [[LoginUser alloc]init];
    _loginUser.delegateLogin = self;
    ///提前获取纠错类型
    if (![_tyUser objectForKey:tyUserErrorTopic]) {
         [self getTopicErrorType];
    }
    ///如果是在用户没有手动退出的时候、每次进入程序先登录，防止登录超时
    if ([_tyUser objectForKey:tyUserUserInfo]) {
        ///使用在本地储存的最新登录成功后的账户和密码登录(acc、pwd标示)
        NSDictionary *dicAccount = [_tyUser objectForKey:tyUserAccount];
        [_loginUser LoginAppWithAccount:dicAccount[@"acc"] password:dicAccount[@"pwd"]];
    }
}
//左滑或点击button回调  引导页加载完后，删除
- (void)GuideViewDismiss{
    [self firstViewDismiss];
    ///下次进入不再出现
    [_tyUser setObject:@"yes" forKey:tyUserFirstLoad];
}
///移除引导页动画
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
//    NSLog(@"IndexTabBarController");
}
///在用户未手动退出的时候，登录成功后回调（此代理在这里只有登录成功才会回调，不做任何操作）
- (void)getUserInfoIsDictionary:(NSDictionary *)dicUser messagePara:(NSInteger)msgPara{
    ///未超时
    if (msgPara == 1) {
        [_tyUser setObject:dicUser forKey:tyUserUserInfo];
    }
}
///自动登录失败（密码错误：可能在其他平台修改了登录密码）
- (void)loginUserErrorString:(NSString *)errorStr{
    [SVProgressHUD showInfoWithStatus:@"您的账户或密码已过期"];
    [_tyUser removeObjectForKey:tyUserAccount];
    [_tyUser removeObjectForKey:tyUserUserInfo];
    [_tyUser removeObjectForKey:tyUserAccessToken];
    ///判断是否已选过科目，如果选过用默认账户授权
    if ([_tyUser objectForKey:tyUserSelectSubject]) {
        ///退出后用默认的账号授权
        [_loginUser empFirstComeAppWithUserId:defaultUserId userCode:defaultUserCode];
    }
    
    
    LXAlertView *loginAlert = [[LXAlertView alloc]initWithTitle:@"账户错误" message:@"您的账户或密码已修改或过期，是否重修登录" cancelBtnTitle:@"暂不登录" otherBtnTitle:@"去登录" clickIndexBlock:^(NSInteger clickIndex) {
        if (clickIndex == 1) {
            UINavigationController *nav = self.viewControllers[0];
            ///重新登录
            UIStoryboard *sCommon = CustomStoryboard(@"TyCommon");
            LoginViewController *loginVc = [sCommon instantiateViewControllerWithIdentifier:@"LoginViewController"];
            loginVc.hidesBottomBarWhenPushed = YES;
            [nav pushViewController:loginVc animated:YES];
        }
    }];
    loginAlert.animationStyle = LXASAnimationTopShake;
    [loginAlert showLXAlertView];
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
