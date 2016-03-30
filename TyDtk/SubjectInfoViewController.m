//
//  SubjectInfoViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/3/30.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "SubjectInfoViewController.h"
@interface SubjectInfoViewController ()<CustomToolDelegate>
//用户信息，以及所需全局信息
@property (nonatomic,strong) NSUserDefaults *tyUser;
//从tyUser中获取到的用户信息
@property (nonatomic,strong) NSDictionary *dicUser;
//科目授权
@property (nonatomic,strong) CustomTools *customTool;
@end

@implementation SubjectInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self viewLoad];
}
- (void)viewLoad{
    _tyUser = tyNSUserDefaults;
    _dicUser = [_tyUser objectForKey:tyUserUser];
    _customTool = [[CustomTools alloc]init];
    _customTool.delegateTool = self;
    [_customTool empowerAndSignatureWithUserId:_dicUser[@"userId"] userName:_dicUser[@"name"] classId:@"105" subjectId:@"661"];
    
    [_tyUser removeObjectForKey:tyUserUser];
    [_tyUser removeObjectForKey:tyUserAccessToken];
}
- (IBAction)buttonClick:(UIButton *)sender {
 [_customTool empowerAndSignatureWithUserId:_dicUser[@"userId"] userName:_dicUser[@"name"] classId:@"105" subjectId:@"662"];
}
- (void)httpSussessReturnClick{
    NSString *acc = [_tyUser objectForKey:tyUserAccessToken];
    NSLog(@"%@",acc);
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
