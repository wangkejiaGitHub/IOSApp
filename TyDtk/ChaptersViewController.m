//
//  ChaptersViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/4/6.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "ChaptersViewController.h"

@interface ChaptersViewController ()<CustomToolDelegate,UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
//授权工具
@property (nonatomic,strong) CustomTools *customTools;
//本地信息存储
@property (nonatomic,strong) NSUserDefaults *tyUser;
//朦层
@property (nonatomic,strong) MZView *mzView;

@property (nonatomic,strong) NSMutableArray *arrayChapterId;
@property (nonatomic,strong) NSMutableArray *arrayChapter;
@property (nonatomic,strong) NSDictionary *dicUserClass;
@property (nonatomic,strong) ActiveVIew *hearhVIew;
@end

@implementation ChaptersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _arrayChapterId = [NSMutableArray array];
    _arrayChapter = [NSMutableArray array];

    [self viewWillShow];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [self getAccessToken];
}
/**
 获取tableView的头试图，并设置其参数值
 */
- (void)viewWillShow{
    if (!_tyUser) {
        _tyUser = [NSUserDefaults standardUserDefaults];
    }
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
    
    
}
/**
 科目授权，获取令牌
 */
- (void)getAccessToken{
    if (!_customTools) {
        _customTools = [[CustomTools alloc]init];
        _customTools.delegateTool = self;
    }
    if (!_tyUser) {
        _tyUser = [NSUserDefaults standardUserDefaults];
    }
    //获取储存的专业信息
    _dicUserClass = [_tyUser objectForKey:tyUserClass];
    NSDictionary *dicUserInfo = [_tyUser objectForKey:tyUserUser];
    if (!_mzView) {
        _mzView = [[MZView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Height)];
    }
    [self.view addSubview:_mzView];
    //授权并收取令牌
    [SVProgressHUD show];
    NSString *classId = [NSString stringWithFormat:@"%@",_dicUserClass[@"Id"]];
    [_customTools empowerAndSignatureWithUserId:dicUserInfo[@"userId"] userName:dicUserInfo[@"name"] classId:classId subjectId:_subjectId];
}
/**
 获取令牌成功，并开始回调
 */
- (void)httpSussessReturnClick{
    NSString *acc = [_tyUser objectForKey:tyUserAccessToken];
    [self getChaptersInfo:acc];
}
/**
 获取令牌失败
 */
- (void)httpErrorReturnClick{
    [_mzView removeFromSuperview];
}

/**
 获取章节考点信息,并根据节点进行章节分类
 */
- (void)getChaptersInfo:(NSString *)accessToken{
    NSString *urlString = [NSString stringWithFormat:@"%@api/Chapter/GetAll?access_token=%@",systemHttps,accessToken];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        
        NSArray *arrayAllChapter = dic[@"datas"];
        //层级（用于获取最大层级）
        NSInteger leave = 0;
        
        for (NSDictionary *dicArr in arrayAllChapter) {
            NSInteger le = [dicArr[@"Level"] integerValue];
            if (le > leave) {
                leave = le;
            }
        }
        //获取层级上的Id
        for (int i = 1; i<=leave; i++) {
            NSMutableArray *arrayLea = [NSMutableArray array];
            for (NSDictionary *dicLea in arrayAllChapter) {
                NSInteger interLea = [dicLea[@"Level"] integerValue];
                if (interLea == i) {
                    NSInteger perId = [dicLea[@"Id"] integerValue];
                    [arrayLea addObject:[NSString stringWithFormat:@"%ld",perId]];
                }
            }
            [_arrayChapterId addObject:arrayLea];
        }
        //根据每一级的层级，找到层级下面包含的信息
        for (int i = 0; i<_arrayChapterId.count; i++) {
            NSArray *arrayId = _arrayChapterId[i];
            NSMutableDictionary *dicChapter = [NSMutableDictionary dictionary];
            for (NSString *perIid in arrayId) {
                NSMutableArray *arrayIII = [NSMutableArray array];
                for (NSDictionary *dicCh in arrayAllChapter) {
                    NSString *persenId = [NSString stringWithFormat:@"%@",dicCh[@"ParentId"]];
                    if ([persenId isEqualToString:perIid]) {
                        [arrayIII addObject:dicCh];
                    }
                }
                [dicChapter setValue:arrayIII forKey:perIid];
            }
            [_arrayChapter addObject:dicChapter];
        }
        ///////////////////////////
        ///////////////////////////
        NSDictionary *dicTest = [_arrayChapter lastObject];
        NSMutableArray *arrayTest = [NSMutableArray array];
        for (NSString *idTest in dicTest.allKeys) {
            for (NSDictionary *dicAlltest in arrayAllChapter) {
                NSInteger dicId = [dicAlltest[@"Id"] integerValue];
                if ([idTest integerValue] == dicId) {
                    [arrayTest addObject:dicAlltest];
                }
            }
        }
        /////////////////////////
        /////////////////////////
        [_mzView removeFromSuperview];
        //重新刷新数据，让tableView返回到顶部
        [_myTableView setContentOffset:CGPointMake(0, 0) animated:YES];
        [_myTableView reloadData];
        [SVProgressHUD dismiss];
    } RequestFaile:^(NSError *error) {
        [_mzView removeFromSuperview];
        [SVProgressHUD showInfoWithStatus:@"网络异常"];
    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 100;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellsub" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    return cell;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
