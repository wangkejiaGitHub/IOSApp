//
//  ImageEnlargeViewController.m
//  Init
//
//  Created by  on 16/4/11.
//  Copyright © 2016年 zhaoshijie. All rights reserved.
//

#import "ImageEnlargeViewController.h"
#import "ImageEnlargeCell.h"

@interface ImageEnlargeViewController ()<ImageEnlargeCellDelegate,LCActionSheetDelegate>

// 显示图片的视图
@property (nonatomic,strong) UIImageView *imageView ;

// 显示缩放视图
@property (nonatomic,strong) UICollectionView *collectionView ;
@property (nonatomic,strong) NSUserDefaults *tyUser;
@property (nonatomic,strong) UIImage *imageShow;
@end

@implementation ImageEnlargeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tyUser = [NSUserDefaults standardUserDefaults];
    [self alertShowSaveImage];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init] ;
    flowLayout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) ;
    flowLayout.minimumInteritemSpacing = 0 ;
    flowLayout.minimumInteritemSpacing = 0 ;
    // 设置方法
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal ;
    
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(-5, 0, [UIScreen mainScreen].bounds.size.width+10, [UIScreen mainScreen].bounds.size.height) collectionViewLayout:flowLayout] ;
    self.collectionView.backgroundColor = [UIColor colorWithRed:0.8405 green:0.8318 blue:0.8493 alpha:1.0] ;
    self.collectionView.backgroundColor = [UIColor blackColor];
    self.collectionView.delegate = self ;
    self.collectionView.dataSource = self ;
    self.collectionView.pagingEnabled = YES ;
    self.collectionView.showsHorizontalScrollIndicator = NO ;
    [self.collectionView registerClass:[ImageEnlargeCell class] forCellWithReuseIdentifier:@"cellID"] ;
    [self.view addSubview:self.collectionView] ;
    
    
    // 创建下面页数显示的文本
    self.label = [[UILabel alloc]initWithFrame:CGRectMake(100, [UIScreen mainScreen].bounds.size.height-60, [UIScreen mainScreen].bounds.size.width-200, 20)] ;
    self.label.textAlignment = NSTextAlignmentCenter ;
    self.label.textColor = [UIColor whiteColor] ;
    self.label.text = [NSString stringWithFormat:@"1/%lu",(unsigned long)self.imageUrlArrays.count] ;
    
    [self.view addSubview:self.label] ;
    
    
    // 拿到bundle里面的图片
    NSString *bundlePath = [[NSBundle mainBundle]pathForResource:@"SJClickEnlarge" ofType:@"Bundle"] ;
    NSString *imagePath = [bundlePath stringByAppendingPathComponent:@"sitting_04@2x.png"] ;
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath] ;
    // 自定义返回按键button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom] ;
    button.frame = CGRectMake(10, 20, 30, 30) ;
    [button setImage:image forState:UIControlStateNormal] ;
    [button addTarget:self action:@selector(returnButtonAction) forControlEvents:UIControlEventTouchUpInside] ;
    [self.view addSubview:button] ;
    
    [_collectionView setContentOffset:CGPointMake(Scr_Width*_imageIndex, 0) animated:NO];
}
///提示用户长按图片可以将图片保存到本地
- (void)alertShowSaveImage{
    if (![_tyUser objectForKey:tyUserShowSaveImgAlert]) {
        LXAlertView *alertImage = [[LXAlertView alloc]initWithTitle:@"温馨提示" message:@"长按可以将图片保存到本地哦" cancelBtnTitle:@"我知道了" otherBtnTitle:@"不在提醒" clickIndexBlock:^(NSInteger clickIndex) {
            if (clickIndex == 1) {
                //不在提醒
                NSLog(@"不在提醒");
                [_tyUser setObject:@"yes" forKey:tyUserShowSaveImgAlert];
            }
        }];
        alertImage.animationStyle = LXASAnimationTopShake;
        [alertImage showLXAlertView];
    }
}
#pragma mark button等视图的点击事件-------------------------------------
- (void)returnButtonAction{
    [self dismissViewControllerAnimated:YES completion:nil] ;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.imageUrlArrays.count ;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"cellID" ;
    ImageEnlargeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath] ;
    [cell _initViews:indexPath.row];
    // 传数据
//    cell.intImageIndex = indexPath.row;
    cell.imageUrlString = self.imageUrlArrays[indexPath.row] ;
    cell.delegateImageCell = self;
    // 刷新视图
    [cell setNeedsLayout] ;
    return cell ;
}


#pragma mark - UICollectionView 继承父类的方法------------------------------------
// 减速结束
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    NSLog(@"停止减速，滑动视图停止了");
    
    // 视图停止滑动的时候执行一些操作
    int pageIndex = (int)self.collectionView.contentOffset.x / [UIScreen mainScreen].bounds.size.width ;
    self.label.text = [NSString stringWithFormat:@"%d/%lu",pageIndex+1,(unsigned long)self.imageUrlArrays.count];
}

// 当前滑动视图停止滑动的时候执行一些操作
- (void)scrollDidSroll{

    int pageIndex = (int)self.collectionView.contentOffset.x / [UIScreen mainScreen].bounds.size.width ;
    self.label.text = [NSString stringWithFormat:@"%d/%lu",pageIndex+1,(unsigned long)self.imageUrlArrays.count] ;
    
}
//长按图片保存图片
- (void)enlargeCellSaveImage:(UIImage *)image{
//    LXAlertView *alertView = [[LXAlertView alloc]initWithTitle:@"图片保存" message:@"要将图片保存到本地相册吗？" cancelBtnTitle:nil otherBtnTitle:@"保存" clickIndexBlock:^(NSInteger clickIndex) {
//        //点击保存按钮
//        if (clickIndex == 0) {
//            NSLog(@"fsffffffffdf");
//        }
//    }];
//    [alertView showLXAlertView];
    _imageShow = image;
    LCActionSheet *alertImg = [LCActionSheet sheetWithTitle:@"保存到本地" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"保存", nil];
    [alertImg show];
}
- (void)actionSheet:(LCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self imageTopicSave:_imageShow];
    }
}
//保存图片
-(void)imageTopicSave:(UIImage *)image{
    [SVProgressHUD showWithStatus:@"正在保存图片..."];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image: didFinishSavingWithError: contextInfo:), nil);
}
//保存到本地手机后回调
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error == nil) {
        [SVProgressHUD showSuccessWithStatus:@"已成功保存到相册！"];
    }
    else{
        [SVProgressHUD showInfoWithStatus:@"保存失败！"];
    }
}
@end
