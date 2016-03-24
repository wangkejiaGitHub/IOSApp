//
//  SecoundSubjectViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/3/22.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "SecoundSubjectViewController.h"

@interface SecoundSubjectViewController ()<UITableViewDataSource,UITableViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabViewWidthCount;
@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;
@property (weak, nonatomic) IBOutlet UITableView *myTabViewSubject;
@property (weak, nonatomic) IBOutlet UIImageView *imageBackGrd;
@property (nonatomic,strong) NSMutableArray *arrayCurrSelectSubject;
@end

@implementation SecoundSubjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self viewLoad];
}
- (void)viewLoad{
    [SVProgressHUD show];
//    NSLog(@"%@",_arraySecoundSubject);
//    NSLog(@"%@",_arraySubject);
    _arrayCurrSelectSubject = [NSMutableArray array];
    self.title = @"选择科目";
    _myTabViewSubject.tableFooterView = [UIView new];
    [_myTabViewSubject selectRowAtIndexPath:[NSIndexPath indexPathForRow:_selectSubject inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    //背景图片拉伸
    UIImage *image = [[UIImage imageNamed:@"mainbg"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    _imageBackGrd.image = image;
    
    [self currSelectSubject];
}
/**
 当前选中的科目
 */
- (void)currSelectSubject{
    [_arrayCurrSelectSubject removeAllObjects];
    if (_arraySubject.count == 0) {
        [SVProgressHUD showErrorWithStatus:@"网络异常"];
        return;
    }
    NSDictionary *dicCurrSubject = _arraySubject[_selectSubject];
    NSInteger currSubjectId = [dicCurrSubject[@"Id"] integerValue];
    for (NSDictionary *dicSecoundSub in _arraySecoundSubject) {
        NSInteger subjectParentId = [dicSecoundSub[@"ParentId"] integerValue];
        if (currSubjectId == subjectParentId) {
            [_arrayCurrSelectSubject addObject:dicSecoundSub];
        }
    }
    
//    NSLog(@"%@",_arrayCurrSelectSubject);
}
- (void)viewDidAppear:(BOOL)animated{
    [SVProgressHUD dismiss];
}
/////////////////////////
///// tableView代理
////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arraySubject.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _selectSubject = indexPath.row;
    [self currSelectSubject];
    [_myCollectionView reloadData];
}
/////////////////////////
///// collcetion代理
////////////////////////
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _arrayCurrSelectSubject.count;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(15, 10, 10, 10);
}
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
//    return 1;
//}
//行间距
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 25;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(((Scr_Width-_tabViewWidthCount.constant)-20), ((Scr_Width-_tabViewWidthCount.constant)-20)/2 - 10);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"sscell" forIndexPath:indexPath];
    NSDictionary *dicCurrSubject = _arrayCurrSelectSubject[indexPath.row];
    //图片
    UIImageView *imageCell = (UIImageView *)[cell.contentView viewWithTag:10];
    NSString *imgUrl = [NSString stringWithFormat:@"%@%@",systemHttpImgs,dicCurrSubject[@"ImageUrl"]];
    [imageCell sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
    imageCell.layer.masksToBounds = YES;
    imageCell.layer.cornerRadius = 5;
    //科目
    NSInteger courseNum = [dicCurrSubject[@"CourseNum"] integerValue];
    NSString *courseNumString = [NSString stringWithFormat:@"%ld",courseNum];
    NSString *labText = [NSString stringWithFormat:@"%@科目",courseNumString];
        NSMutableAttributedString *labAtt = [[NSMutableAttributedString alloc]initWithString:labText];
    [labAtt addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, courseNumString.length)];
    UILabel *labSub = (UILabel *)[cell.contentView viewWithTag:11];
    labSub.attributedText = labAtt;
    //人数
//    cell.backgroundColor = [UIColor redColor];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    NSDictionary *dic = _arrayCurrSelectSubject[indexPath.row];
//    NSLog(@"%@",dic);
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
