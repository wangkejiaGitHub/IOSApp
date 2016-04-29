//
//  IndexViewController.m
//  TyDtk
//  专业分类首页
//  Created by 天一文化 on 16/3/21.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "IndexViewController.h"
#import "LocationViewController.h"
#import "SecoundSubjectViewController.h"
#import <CoreLocation/CoreLocation.h>
@interface IndexViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,CLLocationManagerDelegate,AgainLocationDelegate>
//地区按钮
@property (weak, nonatomic) IBOutlet UIButton *buttonLeftItem;
//collcetionView
@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;
//背景图片
@property (weak, nonatomic) IBOutlet UIImageView *imageBackGround;
//collectionView左右边距
@property (nonatomic,assign) CGFloat cellEdglr;
//定位
@property (nonatomic,strong) CLLocationManager *locManager;
//所有专业分类
@property (nonatomic,strong) NSMutableArray *arraySubject;
//所有专业
@property (nonatomic,strong) NSMutableArray *arraySecoundSubject;
//网络监控
@property (nonatomic,strong) Reachability *conn;
//
@property (nonatomic,strong) UILabel *labText;
@end

@implementation IndexViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addDataView];
    [self getCurrProvince];
    [self getSubjectClass];
    
}

//页面加载，设置页面的背景图片等
- (void)addDataView{
//    self.tabBarController.tabBar.tintColor = [UIColor redColor];
    self.navigationController.tabBarItem.selectedImage = [[UIImage imageNamed:@"btm_icon1_hover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [_buttonLeftItem setTitle:@"地区" forState:UIControlStateNormal];
    _arraySubject = [NSMutableArray array];
    _arraySecoundSubject = [NSMutableArray array];
    _cellEdglr = 40;
    _imageBackGround.image = systemBackGrdImg;
    //开始网络监控
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netWorkChange) name:kReachabilityChangedNotification object:nil];
    _conn = [Reachability reachabilityForInternetConnection];
    [_conn startNotifier];
}
/**
 网络发生变化时触发
 */
- (void)netWorkChange{
    [_labText removeFromSuperview];
    [self getSubjectClass];
}
//网络异常时添加提示信息
- (void)addLabelForNilNework{
    _labText = [[UILabel alloc]initWithFrame:CGRectMake(20, (Scr_Height-30)/2, Scr_Width - 40, 30)];
    _labText.text = @"请检查网络链接";
    _labText.textColor = [UIColor grayColor];
    _labText.font = [UIFont systemFontOfSize:16.0];
    _labText.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_labText];
    [_buttonLeftItem setTitle:@"地区" forState:UIControlStateNormal];
}
//选择城市按钮
- (IBAction)cityBtnClick:(UIButton *)sender {
    [self performSegueWithIdentifier:@"location" sender:_buttonLeftItem.titleLabel.text];
}
//页面跳转调用
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"location"]) {
        LocationViewController *locationVc = segue.destinationViewController;
        locationVc.currLocation = sender;
        locationVc.locationDelegate = self;
    }
    else if ([segue.identifier isEqualToString:@"ssubject"]){
        SecoundSubjectViewController *secoundVC = segue.destinationViewController;
        secoundVC.arraySubject = _arraySubject;
        secoundVC.arraySecoundSubject = _arraySecoundSubject;
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        secoundVC.selectSubject = indexPath.row;
        if (indexPath.row == _arraySubject.count) {
            secoundVC.selectSubject = 0;
        }
    }
}
//重新定位回调
- (void)againLocationClick:(NSString *)proVince{
    if (proVince == nil) {
        [self getCurrProvince];
    }
    else{
        if (proVince.length == 4) {
            proVince = [proVince substringToIndex:3];
        }
        if (proVince.length>=5) {
            proVince = [proVince substringToIndex:2];
        }
        [_buttonLeftItem setTitle:proVince forState:UIControlStateNormal];
    }
}
/**
 定位当前所在省
 */
- (void)getCurrProvince{
    _locManager = [[CLLocationManager alloc]init];
    _locManager.delegate = self;
    _locManager.distanceFilter = 10.0;
    _locManager.desiredAccuracy=kCLLocationAccuracyBestForNavigation;
    
    //如果系统在8.0以上，提醒用户是否允许本应获取当前位置
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] > 8.0){
        [_locManager requestWhenInUseAuthorization];// 前台定位
        //  [locationManager requestAlwaysAuthorization];// 前后台同时定位
    }
    [_locManager startUpdatingLocation];
}
//定位代理
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *curr = [locations lastObject];
    CLGeocoder *gender = [[CLGeocoder alloc]init];
    [gender reverseGeocodeLocation:curr completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark *addressPla = [placemarks lastObject];
        //addressPla.administrativeArea 省级
        // addressPla.locality 市级
        // addressPla.name 具体位置信息（街道等）
        [_buttonLeftItem setTitle:addressPla.administrativeArea forState:UIControlStateNormal];
        //结束定位
        [_locManager stopUpdatingLocation];
    }];
}
//数据请求，获取专业信息
- (void)getSubjectClass{
    [SVProgressHUD showWithStatus:@"加载中..."];
    [HttpTools getHttpRequestURL:[NSString stringWithFormat:@"%@api/Classify/GetAll",systemHttps] RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        
        NSDictionary *dicSubject =[NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        
        NSArray *arrayDatas = dicSubject[@"datas"];
        
        for (NSDictionary *dicArr in arrayDatas) {
            NSInteger ParentId = [dicArr[@"ParentId"] integerValue];
            if (ParentId==0) {
                [_arraySubject addObject:dicArr];
                //                /////
                //                for (NSString *keys in dicArr.allKeys) {
                //                    NSLog(@"%@ == %@",keys,dicArr[keys]);
                //                }
                //                //////
            }
            else{
                [_arraySecoundSubject addObject:dicArr];
            }
        }
        [_myCollectionView reloadData];
        [SVProgressHUD dismiss];
        
    } RequestFaile:^(NSError *error) {
        [SVProgressHUD showInfoWithStatus:@"网络异常"];
        [_arraySubject removeAllObjects];
        [_arraySecoundSubject removeAllObjects];
        [_myCollectionView reloadData];
        [self addLabelForNilNework];
    }];
}
//每段 cell 个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (_arraySubject.count > 0) {
        return _arraySubject.count + 1;
    }
    return 0;
}
// 四周边距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(30, _cellEdglr, 20, _cellEdglr);
}
// cell 大小（设置根据屏幕大小适配）
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((Scr_Width - _cellEdglr*2 -50)/2, (Scr_Width - _cellEdglr*2 -50)/2 + 30);
}
//每行cell间距
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 30;
}
// 返回cell
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"indexcell" forIndexPath:indexPath];
    if (_arraySubject.count > 0) {
        UIImageView *imageCell = (UIImageView *)[cell.contentView viewWithTag:10];
        UILabel *labText = (UILabel *)[cell.contentView viewWithTag:11];
        if (indexPath.row<_arraySubject.count) {
            NSDictionary *dicCell = _arraySubject[indexPath.row];
            NSString *imgUrl = [NSString stringWithFormat:@"%@%@",systemHttpImgs,dicCell[@"ImageUrl"]];
            [imageCell sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
            labText.text = dicCell[@"Names"];
        }
        else{
            [imageCell sd_setImageWithURL:[NSURL URLWithString:systemMoreImg]];
            labText.text = @"更多";
        }
        
    }
    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = 5;
    UIView *selectView =[[UIView alloc]initWithFrame:CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height)];
    selectView.backgroundColor = [UIColor lightGrayColor];
    cell.selectedBackgroundView = selectView;
    cell.backgroundColor = ColorWithRGBWithAlpp(218, 218, 218, 0.3);
    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = 5;
    return cell;
}
// 选中cell
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"ssubject" sender:indexPath];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
