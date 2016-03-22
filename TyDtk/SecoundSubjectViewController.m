//
//  SecoundSubjectViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/3/22.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "SecoundSubjectViewController.h"

@interface SecoundSubjectViewController ()<UITableViewDataSource,UITableViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;

@property (weak, nonatomic) IBOutlet UITableView *myTabViewSubject;
@property (weak, nonatomic) IBOutlet UIImageView *imageBackGrd;
@end

@implementation SecoundSubjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self viewLoad];
}
- (void)viewLoad{
    self.title = @"选择科目";
    _myTabViewSubject.tableFooterView = [UIView new];
    [_myTabViewSubject selectRowAtIndexPath:[NSIndexPath indexPathForRow:_selectSubject inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    UIImage *image = [[UIImage imageNamed:@"mainbg"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    _imageBackGrd.image = image;
}
/////////////////////////
///// tableView代理
////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arraySubject.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"scell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    NSDictionary *dicCell = _arraySubject[indexPath.row];
    UILabel *labText = (UILabel *)[cell.contentView viewWithTag:10];
    labText.text = dicCell[@"Names"];
    UIImageView *imageCell = (UIImageView *)[cell.contentView viewWithTag:11];
    NSString *imgUrl = [NSString stringWithFormat:@"%@%@",systemHttpImgs,dicCell[@"ImageUrl"]];
    [imageCell sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
    return cell;
    
}
/////////////////////////
///// collcetion代理
////////////////////////
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _arraySecoundSubject.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"sscell" forIndexPath:indexPath];
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
