//
//  LocationViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/3/21.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "LocationViewController.h"

@interface LocationViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labLocation;
@property (weak, nonatomic) IBOutlet UIButton *buttonLocation;
@property (nonatomic,strong) NSArray *arrayPronice;
@end

@implementation LocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self viewLoad];
    [self getAllProVince];
}
- (void)viewLoad{
    self.title = @"选择城市";
    _buttonLocation.backgroundColor = [UIColor blueColor];
    _buttonLocation.layer.masksToBounds = YES;
    _buttonLocation.layer.cornerRadius = 5;
    _labLocation.text = _currLocation;
    
}
- (IBAction)locationBtnClick:(UIButton *)sender {
    
}
- (void)getAllProVince{
    NSString *stringUrl = [NSString stringWithFormat:@"%@api/Common/GetAreas",systemHttps];
    
    [HttpTools getHttpRequestURL:stringUrl RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSArray *arr = dic[@"datas"];
        for (NSDictionary *dicc in arr) {
            NSLog(@"%@",dicc.allKeys);
        }
        NSLog(@"%@",dic);
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
