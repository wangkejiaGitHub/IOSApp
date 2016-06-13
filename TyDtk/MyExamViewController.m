//
//  MyExamViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/6/13.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "MyExamViewController.h"
#import "ExamTableViewCell.h"
@interface MyExamViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableViewExam;

@property (nonatomic,strong) NSUserDefaults *tyUser;
@property (nonatomic,strong) NSString *accessToken;
@property (nonatomic,strong) NSMutableArray *arrayIsActived;
@property (nonatomic,strong) NSMutableArray *arrayNoActived;

@end

@implementation MyExamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tyUser = [NSUserDefaults standardUserDefaults];
    _accessToken = [_tyUser objectForKey:tyUserAccessToken];
    _arrayIsActived = [NSMutableArray array];
    _arrayNoActived = [NSMutableArray array];
    _tableViewExam.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self getExamInfo];
}
///获取所有考试信息
- (void)getExamInfo{
    NSString *urlString = [NSString stringWithFormat:@"%@api/ExamSet/GetExamSetList?access_token=%@",systemHttps,_accessToken];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicExam = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSDictionary *dicccc = dicExam[@"label"];
        for (NSString *kk in dicccc.allKeys) {
            NSLog(@"%@ == %@",kk,dicccc[kk]);
        }
        NSInteger codeId = [dicExam[@"code"] integerValue];
        if (codeId == 1) {
            NSArray *arrayExam = dicExam[@"datas"];
            for (NSDictionary *dicAc in arrayExam) {
                NSInteger isActived = [dicAc[@"IsActived"] integerValue];
                if (isActived == 1) {
                    [_arrayIsActived addObject:dicAc];
                }
                else{
                    [_arrayNoActived addObject:dicAc];
                }
            }
        }
        NSLog(@"%@",dicccc);
    } RequestFaile:^(NSError *error) {
        
    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 20;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return Scr_Width/1.675;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ExamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellexam" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
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
