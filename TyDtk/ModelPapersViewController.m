//
//  ModelPapersViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/4/6.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "ModelPapersViewController.h"

@interface ModelPapersViewController ()<CustomToolDelegate,UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
//授权工具
@property (nonatomic,strong) CustomTools *customTools;
//本地信息存储
@property (nonatomic,strong) NSUserDefaults *tyUser;
//朦层
@property (nonatomic,strong) MZView *mzView;
//头试图
@property (nonatomic,strong) ActiveVIew *hearhVIew;
//令牌
@property (nonatomic,strong)NSString *accessToken;
//储存的专业信息
@property (nonatomic,strong) NSDictionary *dicUserClass;
//是否允许授权
@property (nonatomic,assign) BOOL allowToken;
//请求的试卷的年份
@property (nonatomic,assign) NSString *paterYear;
//请求的试卷类型
@property (nonatomic,assign) NSString *paterLevel;
//请求的当前页
@property (nonatomic,assign) NSInteger paterIndexPage;
@end

@implementation ModelPapersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _allowToken = YES;
    _paterIndexPage = 1;

}
- (void)viewWillAppear:(BOOL)animated{
    //试卷授权一次
    if (_allowToken) {
        _paterLevel = @"0";
        _paterYear =@"0";
        [self getAccessToken];
    }
    else{
        //新数据从传递的科目Id中请求获取
        [self getModelPapersData];
    }
    _allowToken = NO;
}
/**
 授权，收取令牌
 */
- (void)getAccessToken{
    _customTools = [[CustomTools alloc]init];
    _customTools.delegateTool = self;
    _tyUser = [NSUserDefaults standardUserDefaults];
    //获取储存的专业信息
    NSDictionary *dicUserInfo = [_tyUser objectForKey:tyUserUser];
    _dicUserClass = [_tyUser objectForKey:tyUserClass];
    if (!_hearhVIew) {
        _hearhVIew= [[[NSBundle mainBundle] loadNibNamed:@"ActiveView" owner:self options:nil]lastObject];
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Width/2 + 20)];
        [view addSubview:_hearhVIew];
        view.backgroundColor = [UIColor redColor];
        _myTableView.tableHeaderView = view;
    }
    [_hearhVIew.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",systemHttpImgs,_dicUserClass[@"ImageUrl"]]]];
    _hearhVIew.labTitle.text = _dicUserClass[@"Names"];
    _hearhVIew.labRemark.text = _dicUserClass[@"Names"];
    NSInteger personNum = [_dicUserClass[@"CourseNum"] integerValue];
    _hearhVIew.labSubjectNumber.text = [NSString stringWithFormat:@"%ld",personNum];
    _hearhVIew.labPersonNumber.text = @"0";
    _hearhVIew.labPrice.text = @"0.0";

    if (!_mzView) {
        _mzView = [[MZView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Height)];
    }
    //授权并收取令牌
    NSString *classId = [NSString stringWithFormat:@"%@",_dicUserClass[@"Id"]];
    [_customTools empowerAndSignatureWithUserId:dicUserInfo[@"userId"] userName:dicUserInfo[@"name"] classId:classId subjectId:_subjectId];
}
/**
 授权成功回调，用与第一次授权加载数据
 */
- (void)httpSussessReturnClick{
    _accessToken = [_tyUser objectForKey:tyUserAccessToken];
    //获取试卷信息
    [self getModelPapersData];
    
}
/**
 授权失败
 */
- (void)httpErrorReturnClick{
    
}
/**
 获取试卷数据
 */
- (void)getModelPapersData{
    [SVProgressHUD show];
    //获取试卷级别
    [self.view addSubview:_mzView];
    [self getModelPaterLevel];
    
    NSLog(@"%@",_subjectId);
    NSString *urlString = [NSString stringWithFormat:@"%@api/Paper/GetPapers?access_token=%@&courseId=%@&page=%ld&level=%@&year=%@",systemHttps,_accessToken,_subjectId,_paterIndexPage,_paterLevel,_paterYear];
    
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicModelPapers = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"%@",dicModelPapers);
        [_mzView removeFromSuperview];
        [SVProgressHUD dismiss];
    } RequestFaile:^(NSError *error) {
        
    }];
}
/**
 获取当前专业下的试卷级别,
 */
- (void)getModelPaterLevel{
    NSString *urlString = [NSString stringWithFormat:@"%@api/Paper/GetLevels?access_token=%@",systemHttps,_accessToken];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicPaterLevel = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"%@",dicPaterLevel);
    } RequestFaile:^(NSError *error) {
        
    }];
}
///////////////////////////////////////
//tableview 代理
///////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellmodel" forIndexPath:indexPath];
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
