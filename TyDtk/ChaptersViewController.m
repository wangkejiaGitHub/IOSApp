//
//  ChaptersViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/4/6.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "ChaptersViewController.h"

@interface ChaptersViewController ()<CustomToolDelegate>
@property (weak, nonatomic) IBOutlet UILabel *labTest;

@property (nonatomic,strong) CustomTools *customTools;
@property (nonatomic,strong) NSUserDefaults *tyUser;
@property (nonatomic,strong) MZView *mzView;
@property (nonatomic,strong) NSMutableArray *arrayChapterId;
@property (nonatomic,strong) NSMutableArray *arrayChapter;
@end

@implementation ChaptersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _arrayChapterId = [NSMutableArray array];
    _arrayChapter = [NSMutableArray array];
    
}
- (void)viewWillAppear:(BOOL)animated{
    _labTest.text = _subjectId;
    [self getAccessToken];
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
    NSDictionary *dicUserClass = [_tyUser objectForKey:tyUserClass];
    NSDictionary *dicUserInfo = [_tyUser objectForKey:tyUserUser];
    if (!_mzView) {
        _mzView = [[MZView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Height)];
    }
    [self.view addSubview:_mzView];
    //授权并收取令牌
    [SVProgressHUD show];
    NSString *classId = [NSString stringWithFormat:@"%@",dicUserClass[@"Id"]];
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
 获取章节考点信息
 */
- (void)getChaptersInfo:(NSString *)accessToken{
    NSString *urlString = [NSString stringWithFormat:@"%@api/Chapter/GetAll?access_token=%@",systemHttps,accessToken];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        
        NSArray *arrayAllChapter = dic[@"datas"];
        NSLog(@"%@",dic);
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
        NSLog(@"%@",_arrayChapterId);
        NSLog(@"%@",_arrayChapter);
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
        NSLog(@"%@",_arrayChapter);
        [_mzView removeFromSuperview];
        [SVProgressHUD dismiss];
    } RequestFaile:^(NSError *error) {
        [_mzView removeFromSuperview];
        [SVProgressHUD showInfoWithStatus:@"网络异常"];
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
