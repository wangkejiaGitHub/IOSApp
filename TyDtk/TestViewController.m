//
//  TestViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/3/28.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()<CustomToolDelegate>
@property (nonatomic,strong) CustomTools *customTools;
@property (nonatomic,strong) NSUserDefaults *tyUser;
@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self testZj];
}
- (void)testZj{
    _customTools = [[CustomTools alloc]init];
    _customTools.delegateTool = self;
    
    _tyUser = [NSUserDefaults standardUserDefaults];
    NSDictionary *dicUser = [_tyUser objectForKey:tyUserUser];
    [_customTools empowerAndSignatureWithUserId:dicUser[@"userId"] userName:dicUser[@"name"] classId:@"105" subjectId:@"661"];
    NSLog(@"%@",dicUser);
}
//回调
- (void)httpSussessReturnClick{
    NSString *lingpai = [_tyUser objectForKey:tyUserAccessToken];
    NSString *urlString = [NSString stringWithFormat:@"%@api/Chapter/GetAll?access_token=%@",systemHttps,lingpai];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"%@",dic);
    } RequestFaile:^(NSError *error) {
        
    }];
}
- (void)zhangjie{
    
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
