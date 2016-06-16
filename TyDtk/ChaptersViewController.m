//
//  ChaptersViewController.m
//  TyDtk
//  章节考点
//  Created by 天一文化 on 16/4/6.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "ChaptersViewController.h"

@interface ChaptersViewController ()<CustomToolDelegate,UITableViewDataSource,UITableViewDelegate,ActiveDelegate>
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
@property (nonatomic,strong) NSArray *arrayAllChapter;
@property (nonatomic,strong) NSMutableArray *arrayFirstChapter;
@property (nonatomic,strong) ActiveVIew *hearhVIew;
//section折叠数组
@property (nonatomic ,strong) NSMutableArray *arraySection;
//////////////////////////////////////////////////////////
@property (nonatomic,assign) NSInteger intAllChapterCount;
@property (nonatomic,assign) NSInteger Leeeeee;
@property (nonatomic,strong) NSMutableArray *arrayTest;
@end

@implementation ChaptersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _arrayTest = [NSMutableArray array];
    // Do any additional setup after loading the view.
    _arrayChapterId = [NSMutableArray array];
    _arrayChapter = [NSMutableArray array];
    _arrayFirstChapter = [NSMutableArray array];
    _arraySection = [NSMutableArray array];

    [self viewWillShow];
    
}
- (void)viewDidAppear:(BOOL)animated{
//    self.tabBarController.tabBar.hidden = NO;
    self.navigationController.tabBarController.tabBar.hidden = YES;
    [_arrayChapterId removeAllObjects];
    [_arrayFirstChapter removeAllObjects];
    [_arrayChapter removeAllObjects];
    [_arraySection removeAllObjects];
    
    [self getAccessToken];
}
- (void)viewWillAppear:(BOOL)animated{
    
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
        _hearhVIew.delegateAtive = self;
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Width/2 + 20)];
        [view addSubview:_hearhVIew];
        view.backgroundColor = [UIColor clearColor];
        _myTableView.tableHeaderView = view;
    }
    [_hearhVIew.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",systemHttpImgs,_dicUserClass[@"ImageUrl"]]]];
    _hearhVIew.labTitle.text = _dicUserClass[@"Names"];
    _hearhVIew.labRemark.text = _dicUserClass[@"Names"];
//    NSInteger personNum = [_dicUserClass[@"CourseNum"] integerValue];
//    _hearhVIew.labSubjectNumber.text = [NSString stringWithFormat:@"%ld",personNum];
//    _hearhVIew.labPersonNumber.text = @"0";
    _hearhVIew.labPrice.text = @"0.0";
    
    
}
/**
 头试图回调代理
 */
//激活码做题回调代理
- (void)activeForPapersClick{
    NSLog(@"激活码做题");
}
//获取激活码回调代理
- (void)getActiveMaClick{
    NSLog(@"如何获取激活码");
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
        
        _arrayAllChapter = dic[@"datas"];
   
        /////////////////////////////////
        _intAllChapterCount = _arrayAllChapter.count;
        //层级（用于获取最大层级）
        NSInteger leave = 0;
        
        for (NSDictionary *dicArr in _arrayAllChapter) {
            NSInteger le = [dicArr[@"Level"] integerValue];
            if (le > leave) {
                leave = le;
            }
        }
        ///////////////////////////////////////////
        
        //最后一层的所有字典
        NSMutableArray *arrayNewLast = [NSMutableArray array];
        for (NSDictionary *dic in _arrayAllChapter) {
            if ([dic[@"Level"] integerValue] == leave) {
                [arrayNewLast addObject:dic];
            }
        }
        //每一层的个数
        NSMutableDictionary *dicNew = [NSMutableDictionary dictionary];
        for (int i = 1; i<=leave; i++) {
            NSMutableArray *arrayN = [NSMutableArray array];
            for (NSDictionary *dic in _arrayAllChapter) {
                if ([dic[@"Level"] integerValue] == i) {
                    [arrayN addObject:dic];
                }
            }
            [dicNew setValue:arrayN forKey:[NSString stringWithFormat:@"%d",i]];
        }
//        NSLog(@"%@",arrayNewLast);
//        NSLog(@"%@",dicNew);
//        for (NSInteger i = dicNew.allKeys.count; i>0; i--) {
//            NSArray *arrayL = dicNew[[NSString stringWithFormat:@"%ld",i - 1]];
//            NSArray *arrayN = dicNew[[NSString stringWithFormat:@"%ld",i]];
//            for (NSDictionary *dicL in arrayL) {
//                
//                for (NSDictionary *dicN in arrayN) {
//                    
//                }
//            }
//        }
        ///////////////////////////////////////////
        
        //获取层级上的Id
        for (int i = 1; i<=leave; i++) {
            NSMutableArray *arrayLea = [NSMutableArray array];
            for (NSDictionary *dicLea in _arrayAllChapter) {
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
                for (NSDictionary *dicCh in _arrayAllChapter) {
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
            for (NSDictionary *dicAlltest in _arrayAllChapter) {
                NSInteger dicId = [dicAlltest[@"Id"] integerValue];
                if ([idTest integerValue] == dicId) {
                    [arrayTest addObject:dicAlltest];
                }
            }
        }
        /////////////////////////
        /////////////////////////
        for (NSDictionary *dicc in _arrayAllChapter) {
            NSInteger perId = [dicc[@"ParentId"] integerValue];
            if (perId == 0) {
                [_arrayFirstChapter addObject:dicc];
            }
        }
        [_mzView removeFromSuperview];
        //重新刷新数据，让tableView返回到顶部
        [_myTableView reloadData];
        [SVProgressHUD dismiss];
    } RequestFaile:^(NSError *error) {
        [_mzView removeFromSuperview];
        [SVProgressHUD showInfoWithStatus:@"网络异常"];
    }];
}

/////////////////////////////
- (NSArray *)getCellArray:(NSInteger)teId{
    NSMutableArray *arrayCurrRow = [NSMutableArray array];
    for (NSDictionary *dicRow in _arrayAllChapter) {
        NSInteger currPid = [dicRow[@"ParentId"] integerValue];
        if (currPid == teId) {
            [arrayCurrRow addObject:dicRow];
        }
    }
    return arrayCurrRow;
}
////////////////////////////
//tableView 代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    NSDictionary *dicFirst = _arrayChapter[0];
//    //获取Id
//    NSString *perId = dicFirst.allKeys[section];
//    NSArray *arrayChild = [dicFirst objectForKey:perId];
//    return arrayChild.count;
    NSString *sectionS = [NSString stringWithFormat:@"%ld",section];
    if ([_arraySection containsObject:sectionS]) {
        NSDictionary *dicCurr = _arrayFirstChapter[section];
        NSInteger dicId = [dicCurr[@"Id"] integerValue];
        NSArray *array = [self getCellArray:dicId];
        return array.count;
    }
    else{
        return 0;
    }
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _arrayFirstChapter.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSDictionary *dicCurr = _arrayFirstChapter[section];
    UIView *heardView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 40)];
    heardView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel *labNames = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, Scr_Width - 10, 40)];
    labNames.numberOfLines = 0;
    labNames.font = [UIFont systemFontOfSize:15.0];
    labNames.text = dicCurr[@"Names"];
    [heardView addSubview:labNames];
    
    UIButton *btn =[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, Scr_Width, 40);
    btn.backgroundColor = [UIColor clearColor];
    btn.tag = section + 1000;
    [btn addTarget:self action:@selector(sectionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [heardView addSubview:btn];
    return heardView;
}
- (void)sectionBtnClick:(UIButton *)sender{
        NSString *secString = [NSString stringWithFormat:@"%ld",sender.tag - 1000];
    if ([_arraySection containsObject:secString]) {
        [_arraySection removeObject:secString];
    }
    else{
        [_arraySection addObject:secString];
    }
    [_myTableView reloadSections:[NSIndexSet indexSetWithIndex:sender.tag - 1000] withRowAnimation:UITableViewRowAnimationAutomatic];
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
