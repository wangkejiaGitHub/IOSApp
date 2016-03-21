//
//  IndexViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/3/21.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "IndexViewController.h"
#import "LocationViewController.h"
#import <CoreLocation/CoreLocation.h>
@interface IndexViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonLeftItem;
@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;
@property (weak, nonatomic) IBOutlet UIImageView *imageBackGround;
@property (nonatomic,assign) CGFloat cellEdglr;
@property (nonatomic,strong) CLLocationManager *locManager;
//所有第一类科目
@property (nonatomic,strong) NSMutableArray *arraySubject;
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
    self.title = @"选择专业";
    _arraySubject = [NSMutableArray array];
    _cellEdglr = 40;
    UIImage *image = [[UIImage imageNamed:@"mainbg"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    _imageBackGround.image = image;
}
//选择城市
- (IBAction)cityBtnClick:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"location" sender:sender.title];
}
//页面跳转调用
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"location"]) {
        LocationViewController *locationVc = segue.destinationViewController;
        locationVc.currLocation = sender;
    }
}
//定位当前所在省
- (void)getCurrProvince{
    _locManager = [[CLLocationManager alloc]init];
    _locManager.delegate = self;
    _locManager.distanceFilter = 10.0;
    _locManager.desiredAccuracy=kCLLocationAccuracyBestForNavigation;
    [_locManager startUpdatingLocation];
}
//定位代理
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *curr = [locations lastObject];
    CLGeocoder *gender = [[CLGeocoder alloc]init];
    [gender reverseGeocodeLocation:curr completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark *addressPla = [placemarks lastObject];
        _buttonLeftItem.title = addressPla.administrativeArea;
    }];
}
//数据请求，获取专业信息
- (void)getSubjectClass{
    [HttpTools getHttpRequestURL:[NSString stringWithFormat:@"%@api/Classify/GetAll",systemHttps] RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        
        NSDictionary *dicSubject =[NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        
        NSArray *arrayDatas = dicSubject[@"datas"];
        
        for (NSDictionary *dicArr in arrayDatas) {
            NSInteger dataId = [dicArr[@"Id"] integerValue];
            if (dataId<=12) {
                [_arraySubject addObject:dicArr];
                //                /////
                //                for (NSString *keys in dicArr.allKeys) {
                //                    NSLog(@"%@ == %@",keys,dicArr[keys]);
                //                }
                //                //////
            }
        }
        [_myCollectionView reloadData];
        
    } RequestFaile:^(NSError *error) {
        
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
// cell 大小
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
    return cell;
}
// 选中cell
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%ld",indexPath.row);
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
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
