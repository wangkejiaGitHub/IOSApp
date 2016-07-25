//
//  TopicNumberCard.m
//  TyDtk
//
//  Created by 天一文化 on 16/7/16.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "TopicNumberCard.h"
@interface TopicNumberCard()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>
@end
@implementation TopicNumberCard
- (id)initWithFrame:(CGRect)frame withTopicNumber:(NSInteger)topicNumber{
    self = [super initWithFrame:frame];
    if (self) {
        _topicNumber = topicNumber;
        self.backgroundColor = [UIColor clearColor];
        [self addCollectionViewCard:frame];
    }
    return self;
}
- (void)addCollectionViewCard:(CGRect)frame{
    UICollectionViewFlowLayout *la = [[UICollectionViewFlowLayout alloc]init];
    _collectionViewCard = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) collectionViewLayout:la];
    [_collectionViewCard registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellnum"];
    [_collectionViewCard registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"heardviewnum"];
    _collectionViewCard.backgroundColor = ColorWithRGBWithAlpp(200, 200, 200, 0.8);
    _collectionViewCard.delegate = self;
    _collectionViewCard.dataSource = self;
    [self addSubview:_collectionViewCard];
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _topicNumber;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((Scr_Width-20-5*10)/6, (Scr_Width-20-5*10)/6);
}
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
//    return CGSizeMake(Scr_Width, 40);
//}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellnum" forIndexPath:indexPath];
    for (id subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    UILabel *labNumber =[[UILabel alloc]initWithFrame:CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.width)];
    labNumber.text = [NSString stringWithFormat:@"%ld",indexPath.row + 1];
    labNumber.textAlignment = NSTextAlignmentCenter;
    labNumber.font = [UIFont systemFontOfSize:15.0];
    labNumber.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:labNumber];
    cell.backgroundColor = ColorWithRGB(200, 200, 200);
    cell.layer.borderWidth = 1;
    cell.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.delegateNumberTop getTopicNumber:indexPath.row];
}
@end

