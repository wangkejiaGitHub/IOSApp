//
//  MyExamViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/6/13.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "MyExamViewController.h"
#import "ExamTableViewCell.h"
#import "EditExamViewController.h"
@interface MyExamViewController ()<UITableViewDataSource,UITableViewDelegate,ExamCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableViewExam;

@property (nonatomic,strong) NSUserDefaults *tyUser;
@property (nonatomic,strong) NSString *accessToken;
@property (nonatomic,strong) NSMutableArray *arrayIsActived;
@property (nonatomic,strong) NSMutableArray *arrayNoActived;
@property (nonatomic,assign) CGFloat cellHeight;

@end

@implementation MyExamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tyUser = [NSUserDefaults standardUserDefaults];
    _accessToken = [_tyUser objectForKey:tyUserAccessToken];
    _arrayIsActived = [NSMutableArray array];
    _arrayNoActived = [NSMutableArray array];
    _cellHeight = 210;
    _tableViewExam.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self getExamInfo];
}
///获取所有考试信息
- (void)getExamInfo{
    [SVProgressHUD showWithStatus:@"记载中..."];
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
            
//            for (int i = 0; i<_arrayNoActived.count - 1; i++) {
//                for (int j = 0; j<_arrayNoActived.count - 1 - i; j++) {
//                    NSDictionary *dicL = _arrayNoActived[j];
//                    NSDictionary *dicN = _arrayNoActived[j+1];
//                    NSInteger isDefaultL = [dicL[@"IsDefault"] integerValue];
//                    NSInteger isDefaultN = [dicN[@"IsDefault"] integerValue];
//                    if (isDefaultN == 1 && isDefaultL == 0) {
//                        [_arrayNoActived exchangeObjectAtIndex:i withObjectAtIndex:i+1];
//                    }
//
//                }
//            }
           
        }
        [_tableViewExam reloadData];
        [SVProgressHUD dismiss];
        NSLog(@"%@",dicccc);
    } RequestFaile:^(NSError *error) {
        [SVProgressHUD showInfoWithStatus:@"操作异常！"];
    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrayNoActived.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return _cellHeight;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ExamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellexam" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegateExam = self;
    NSDictionary *dicExam = _arrayNoActived[indexPath.row];
    _cellHeight = [cell setCellModelValueWithDictionary:dicExam];
    return cell;
}
//删除或设置默认后刷新考试信息
- (void)reFreshExamInfo{
    [_arrayIsActived removeAllObjects];
    [_arrayNoActived removeAllObjects];
    [self getExamInfo];
}
//编辑考试信息
- (void)editExamInfo:(NSDictionary *)dicExam{
    EditExamViewController *editExamVc =[[EditExamViewController alloc]initWithNibName:@"EditExamViewController" bundle:nil];
    editExamVc.dicExam = dicExam;
    [self.navigationController pushViewController:editExamVc animated:YES];
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
