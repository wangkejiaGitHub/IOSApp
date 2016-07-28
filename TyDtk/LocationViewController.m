//
//  LocationViewController.m
//  TyDtk
//  定位
//  Created by 天一文化 on 16/3/21.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "LocationViewController.h"
@interface LocationViewController ()<UITableViewDataSource,UITableViewDelegate,ViewNullDataDelegate>
//tableView
@property (weak, nonatomic) IBOutlet UITableView *myTabVIewPronice;
//id对应字典
@property (nonatomic,strong) NSMutableDictionary *dicPronice;
//所有省份的Id
@property (nonatomic,strong) NSArray *arrayProvniceAllId;
//所有省份的name
@property (nonatomic,strong) NSArray *arrayProvniceAllName;
//所有省份首字母数组
@property (nonatomic,strong) NSArray *arrayProvniceFirstLetter;
//首字母查找字典
@property (nonatomic,strong) NSMutableDictionary *dicFirstProvniceFirstLetter;
//tableView的头试图
@property (nonatomic ,strong) UIView *viewTabHeardView;
//@property (nonatomic ,strong) UIView *viewNullData;
@property (nonatomic ,strong) ViewNullData *viewNullData;
@end

@implementation LocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self viewLoad];
    [self getAllProVince];
}
- (void)viewLoad{
    self.title = @"选择地区";
    _dicPronice = [NSMutableDictionary dictionary];
    _dicFirstProvniceFirstLetter = [NSMutableDictionary dictionary];
    _myTabVIewPronice.sectionIndexColor = [UIColor grayColor];
    _myTabVIewPronice.sectionIndexBackgroundColor = [UIColor clearColor];
    _myTabVIewPronice.separatorStyle = UITableViewCellSeparatorStyleNone;
}
//数据为空时显示
- (void)addViewWhenDataIsNull{
    _viewNullData = [[ViewNullData alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Height) showText:nil];
    _viewNullData.delegateNullData = self;
    
    [self.view addSubview:_viewNullData];
}
//数据为空时点击屏幕
- (void)nullDataTapGestClick{
    [_viewNullData removeFromSuperview];
    [self getAllProVince];
}
//添加tableView的头试图
- (void)addHeardViewForTableView{
    if (!_viewTabHeardView) {
        _viewTabHeardView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 60)];
        _viewTabHeardView.backgroundColor =ColorWithRGB(218, 218, 218);
        
        UILabel *labTextLoca = [[UILabel alloc]initWithFrame:CGRectMake(10, 15, 80, 30)];
        labTextLoca.text = @"当前地区:";
        //    labTextLoca.backgroundColor = [UIColor redColor];
        labTextLoca.font = [UIFont systemFontOfSize:17.0];
        [_myTabVIewPronice addSubview:labTextLoca];
        
        UILabel *labPrivince = [[UILabel alloc]initWithFrame:CGRectMake(91, 15, 100, 30)];
        labPrivince.text = _currLocation;
        labPrivince.font = [UIFont systemFontOfSize:18.0];
        labPrivince.textColor = [UIColor blueColor];
        [_myTabVIewPronice addSubview:labPrivince];
        
        UIButton *btnLocation = [UIButton buttonWithType:UIButtonTypeCustom];
        btnLocation.frame = CGRectMake((Scr_Width-100), 15, 80, 30);
        btnLocation.backgroundColor = [UIColor blueColor];
        [btnLocation setTitle:@"重新定位" forState:UIControlStateNormal];
        [btnLocation setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnLocation.layer.masksToBounds = YES;
        btnLocation.layer.cornerRadius = 5;
        btnLocation.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [btnLocation addTarget:self action:@selector(btnLocationClick:) forControlEvents:UIControlEventTouchUpInside];
        [_viewTabHeardView addSubview:btnLocation];
    }
    _myTabVIewPronice.tableHeaderView = _viewTabHeardView;
}
//重新定位按钮
- (void)btnLocationClick:(UIButton *)button{
        if (_dicPronice.allKeys.count==0) {
    
            [SVProgressHUD showInfoWithStatus:@"网络异常"];
        }
        [_locationDelegate againLocationClick:nil];
        [self.navigationController popViewControllerAnimated:YES];
}

//获取所有省份信息
- (void)getAllProVince{
    [SVProgressHUD showWithStatus:@"加载中..."];
    NSString *stringUrl = [NSString stringWithFormat:@"%@api/Common/GetAreas",systemHttps];
    
    [HttpTools getHttpRequestURL:stringUrl RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSArray *arrayDic = dic[@"datas"];
        if (arrayDic.count>0) {
            for (NSDictionary *dicDatas in arrayDic) {
                [_dicPronice setValue:dicDatas[@"Id"] forKey:dicDatas[@"Names"]];
            }
            //所有省份Id数组
            _arrayProvniceAllId = [_dicPronice allValues];
            //所有省份名称排序后的数组
            _arrayProvniceAllName = [NSMutableArray arrayWithArray:[self compareProvnice:[_dicPronice allKeys]]];
            
            [self setValueForDicFirstProvniceFirstLetter];
            [self addHeardViewForTableView];
            _myTabVIewPronice.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            [SVProgressHUD dismiss];
        }
        else{
            [SVProgressHUD showInfoWithStatus:dic[@"errmsg"]];
            _myTabVIewPronice.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
        [_myTabVIewPronice reloadData];
    } RequestFaile:^(NSError *error) {
        _myTabVIewPronice.separatorStyle = UITableViewCellSeparatorStyleNone;
        [SVProgressHUD showErrorWithStatus:@"网络异常"];
        [self addViewWhenDataIsNull];
    }];
}
// 省名称排序
-(NSArray *)compareProvnice:(NSArray *)array{
    NSMutableDictionary *dicName = [NSMutableDictionary dictionary];
    NSMutableArray *arrayCompare = [NSMutableArray array];
    NSMutableArray *arrayFirstLetter = [NSMutableArray array];
    for (NSString *keys in array) {
        NSString *pinYinKey = [ChineseToPinyin pinyinFromChiniseString:keys];
        if ([[dicName allKeys]containsObject:pinYinKey]) {
            pinYinKey = [NSString stringWithFormat:@"%@%@",pinYinKey,pinYinKey];
        }
        if ([pinYinKey isEqualToString:@"ZHONGQINGSHI"]) {
            pinYinKey = @"CHONGQINGSHI";
        }
        [dicName setValue:keys forKey:pinYinKey];
        NSString *firstLetter = [pinYinKey substringToIndex:1];
        if (![arrayFirstLetter containsObject:firstLetter]) {
            [arrayFirstLetter addObject:firstLetter];
        }
    }
    _arrayProvniceFirstLetter = [arrayFirstLetter sortedArrayUsingSelector:@selector(compare:)];
    NSArray *arrayAllpinYinKey = [[dicName allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *pinYinKey in arrayAllpinYinKey) {
        [arrayCompare addObject:dicName[pinYinKey]];
    }
    return arrayCompare;
}
- (void)setValueForDicFirstProvniceFirstLetter{
    for (NSString *letter in _arrayProvniceFirstLetter) {
        NSMutableArray *arrayL = [NSMutableArray array];
        for (NSString *name in _arrayProvniceAllName) {
            NSString *nameFirstLetter = [[ChineseToPinyin pinyinFromChiniseString:name]substringToIndex:1];
            if ([name isEqualToString:@"重庆市"]) {
                nameFirstLetter = @"C";
            }
            if ([letter isEqualToString:nameFirstLetter]) {
                [arrayL addObject:name];
            }
        }
        [_dicFirstProvniceFirstLetter setValue:arrayL forKey:letter];
    }
}
//tableView 代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  
    NSString *letter = _arrayProvniceFirstLetter[section];
    NSArray *array = _dicFirstProvniceFirstLetter[letter];
    return array.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _arrayProvniceFirstLetter.count;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 30)];
    sectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel *labSec = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, 30, 20)];
    labSec.text = _arrayProvniceFirstLetter[section];
    [sectionView addSubview:labSec];
    return sectionView;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section{
    return 30;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellprovnice" forIndexPath:indexPath];
    NSString *letter = _arrayProvniceFirstLetter[indexPath.section];
    NSArray *array = _dicFirstProvniceFirstLetter[letter];
    UILabel *labProvince = (UILabel *)[cell.contentView viewWithTag:10];
    labProvince.text = array[indexPath.row];
    return cell;
}
- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return _arrayProvniceFirstLetter;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *array = _dicFirstProvniceFirstLetter[_arrayProvniceFirstLetter[indexPath.section]];
    NSString *provniceName = array[indexPath.row];
    [_locationDelegate againLocationClick:provniceName];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
