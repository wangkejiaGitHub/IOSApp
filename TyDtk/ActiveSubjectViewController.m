//
//  ActiveSubjectViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/6/29.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "ActiveSubjectViewController.h"

@interface ActiveSubjectViewController ()
@property (nonatomic,strong) NSUserDefaults *tyUser;
@property (nonatomic,strong) NSDictionary *dicUserInfo;
@end

@implementation ActiveSubjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tyUser = [NSUserDefaults standardUserDefaults];
    _dicUserInfo = [_tyUser objectForKey:tyUserUserInfo];
    
    [self getProductInfoWithSubjectId];
    // Do any additional setup after loading the view from its nib.
}
///根据科目id获取商品信息
- (void)getProductInfoWithSubjectId{
    NSString *urlString = [NSString stringWithFormat:@"%@/ty/mobile/order/productInfo?productId=%ld&jeeId=%@&fromSystem=902",systemHttpsKaoLaTopicImg,_subjectId,_dicUserInfo[@"jeeId"]];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicProduct = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"%@",dicProduct);
    } RequestFaile:^(NSError *error) {
        
    }];
}
///激活科目
- (void)activeSubject{
    NSString *urlString = [NSString stringWithFormat:@"%@/ty/mobile/order/payCode?code=B1340B34G618&productId=%ld&jeeId=%@&fromSystem=902",systemHttpsKaoLaTopicImg,_subjectId,_dicUserInfo[@"jeeId"]];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicAc = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"%@",dicAc);
    } RequestFaile:^(NSError *error) {
        
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
