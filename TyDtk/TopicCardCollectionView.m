//
//  TopicCardCollectionView.m
//  TyDtk
//
//  Created by 天一文化 on 16/4/13.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "TopicCardCollectionView.h"
@interface TopicCardCollectionView()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>
@end

@implementation TopicCardCollectionView
- (id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout withTopicArray:(NSArray *)arrayTopic{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        _arrayisMakeTopic = [NSMutableArray array];
        _arrayTopic = arrayTopic;
        [self setSelfFrameWithData];
    }
    return self;
}
- (void)setSelfFrameWithData{
    [self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"heardview"];
    self.backgroundColor = ColorWithRGBWithAlpp(200, 200, 200, 0.8);
    self.delegate = self;
    self.dataSource =self;
}

//////////////////////
//代理
//////////////////////
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSDictionary *dicPater = _arrayTopic[section];
    NSArray *arrayTop = dicPater[@"Questions"];
    return arrayTop.count;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return _arrayTopic.count;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((Scr_Width-20-5*10)/6, (Scr_Width-20-5*10)/6);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return CGSizeMake(Scr_Width, 80);
    }
    return CGSizeMake(Scr_Width, 40);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *reView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"heardview" forIndexPath:indexPath];
        for (id subView in reView.subviews) {
            [subView removeFromSuperview];
        }
        reView.backgroundColor = ColorWithRGBWithAlpp(80, 200, 250, 0.8);
        NSDictionary *dicCurr = _arrayTopic[indexPath.section];
        NSDictionary *dicCaption = dicCurr[@"Caption"];
        UILabel *labCaptionTypeName = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, Scr_Width-10, reView.bounds.size.height)];
        labCaptionTypeName.text = dicCaption[@"CaptionTypeName"];
        labCaptionTypeName.font = [UIFont systemFontOfSize:16.0];
        labCaptionTypeName.textColor = [UIColor blueColor];
        if (indexPath.section == 0) {
            labCaptionTypeName.frame = CGRectMake(10, 40, Scr_Width-10, 40);
            UIView *viewTitle = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 40)];
            viewTitle.backgroundColor = [UIColor groupTableViewBackgroundColor];
            [reView addSubview:viewTitle];
            
            UILabel *labDone = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, 70, 30)];
            labDone.text = @"做过的题";
            labDone.font = [UIFont systemFontOfSize:14.0];
            [viewTitle addSubview:labDone];
            
            UIView *viewDone = [[UIView alloc]initWithFrame:CGRectMake(90, 15, 10, 10)];
            viewDone.backgroundColor = [UIColor brownColor];
            [viewTitle addSubview:viewDone];
            
            UIView *viewNo = [[UIView alloc]initWithFrame:CGRectMake(Scr_Width - 30, 15, 10, 10)];
            viewNo.backgroundColor = ColorWithRGB(200, 200, 200);
            [viewTitle addSubview:viewNo];
            
            UILabel *labNo = [[UILabel alloc]initWithFrame:CGRectMake(Scr_Width-100, 5, 70, 30)];
            labNo.font = [UIFont systemFontOfSize:14.0];
            labNo.text = @"未做的题";
            [viewTitle addSubview:labNo];
            
        }
        [reView addSubview:labCaptionTypeName];
        return reView;
    }
    return nil;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    for (id subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    UILabel *labNumber =[[UILabel alloc]initWithFrame:CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.width)];
    labNumber.text = [NSString stringWithFormat:@"%ld",indexPath.row + 1];
    labNumber.textAlignment = NSTextAlignmentCenter;
    labNumber.font = [UIFont systemFontOfSize:15.0];
    labNumber.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:labNumber];
    if (indexPath.section != 0) {
        NSInteger indexRow = 0;
        for (int i = 0; i < indexPath.section; i++) {
            NSDictionary *dicPater = _arrayTopic[i];
            NSArray *arrayTop = dicPater[@"Questions"];
            indexRow = indexRow+arrayTop.count;
        }
        labNumber.text = [NSString stringWithFormat:@"%ld",indexPath.row + 1+indexRow];
    }
    cell.backgroundColor = ColorWithRGB(200, 200, 200);
    NSString *topicNumber = labNumber.text;
    if ([_arrayisMakeTopic containsObject:topicNumber]) {
        cell.backgroundColor = [UIColor brownColor];
    }
    
    cell.layer.borderWidth = 1;
    cell.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
   UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UILabel *labNumber = (UILabel *)[cell.contentView.subviews firstObject];
    [self.delegateCellClick topicCollectonViewCellClick:[labNumber.text integerValue]];
    NSLog(@"%ld",[labNumber.text integerValue]);
}
@end
