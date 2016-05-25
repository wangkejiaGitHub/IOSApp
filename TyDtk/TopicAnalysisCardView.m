//
//  TopicAnalysisCardView.m
//  TyDtk
//
//  Created by 天一文化 on 16/5/7.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "TopicAnalysisCardView.h"
@interface TopicAnalysisCardView()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>
@property (nonatomic,strong) UICollectionView *collectionCard;
//parameter（1章节练习，2模拟试卷，3每周精选，4智能出题）等
@property (nonatomic,assign) NSInteger parameter;
@end
@implementation TopicAnalysisCardView
- (id)initWithFrame:(CGRect)frame arrayTopic:(NSArray *)arrayTopic{
    self = [super initWithFrame:frame];
    if (self) {
        
//        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _arrayTopic = arrayTopic;

        [self addCollectionView:frame];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame arrayTopic:(NSArray *)arrayTopic paperParameter:(NSInteger)parameter{
    self = [super initWithFrame:frame];
    if (self) {
        _parameter = parameter;
        _arrayTopic = arrayTopic;
        
        [self addCollectionView:frame];
    }
    return self;
}
- (void)addCollectionView:(CGRect)frame{
    UICollectionViewFlowLayout *ly = [[UICollectionViewFlowLayout alloc]init];
    _collectionCard = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) collectionViewLayout:ly];
    [_collectionCard registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"anaLysiscell"];
    [_collectionCard registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"heardview1"];
    _collectionCard.delegate = self;
    _collectionCard.dataSource = self;
    _collectionCard.backgroundColor = ColorWithRGBWithAlpp(200, 200, 200, 0.8);
    [self addSubview:_collectionCard];
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if (_parameter == 2) {
        return _arrayTopic.count;
    }
    else if (_parameter == 3){
        return 1;
    }
    return 0;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    //根据不同的模块返回
    if (_parameter == 2) {
        NSDictionary *dicPater = _arrayTopic[section];
        NSArray *arrayTop = dicPater[@"Questions"];
        return arrayTop.count;
    }
    else if (_parameter == 3){
        return _arrayTopic.count;
    }
    return 0;
    
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((Scr_Width-20-5*10)/6, (Scr_Width-20-5*10)/6);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if (_parameter == 2) {
        if (section == 0) {
            return CGSizeMake(Scr_Width, 80+40);
        }
        return CGSizeMake(Scr_Width, 40);
    }
    else if (_parameter == 3){
        return CGSizeMake(Scr_Width, 120);
    }
    return CGSizeMake(0, 0);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *reView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"heardview1" forIndexPath:indexPath];
        for (id subView in reView.subviews) {
            [subView removeFromSuperview];
        }
        reView.backgroundColor = ColorWithRGBWithAlpp(80, 200, 250, 0.8);
        if (_parameter == 2) {
            NSDictionary *dicCurr = _arrayTopic[indexPath.section];
            NSDictionary *dicCaption = dicCurr[@"Caption"];
            UILabel *labCaptionTypeName = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, Scr_Width-10, reView.bounds.size.height)];
            labCaptionTypeName.text = dicCaption[@"CaptionTypeName"];
            labCaptionTypeName.font = [UIFont systemFontOfSize:16.0];
            labCaptionTypeName.textColor = [UIColor blueColor];
            if (indexPath.section == 0) {
                labCaptionTypeName.frame = CGRectMake(10, 80, Scr_Width-10, 40);
                UIView *viewTitle = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 80)];
                viewTitle.backgroundColor = [UIColor groupTableViewBackgroundColor];
                [reView addSubview:viewTitle];
                
                UILabel *labNoDo = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, 70, 30)];
                labNoDo.text = @"未做的题";
                labNoDo.font = [UIFont systemFontOfSize:14.0];
                [viewTitle addSubview:labNoDo];
                
                UIView *viewNoDo = [[UIView alloc]initWithFrame:CGRectMake(90, 12.5, 15, 15)];
                viewNoDo.backgroundColor = ColorWithRGB(200, 200, 200);
                [viewTitle addSubview:viewNoDo];
                
                UILabel *labType6 = [[UILabel alloc]initWithFrame:CGRectMake(Scr_Width-100, 5, 70, 30)];
                labType6.font = [UIFont systemFontOfSize:14.0];
                labType6.text = @"一题多问";
                [viewTitle addSubview:labType6];
                
                UIView *viewType6 = [[UIView alloc]initWithFrame:CGRectMake(Scr_Width - 30, 12.5, 15, 15)];
                viewType6.backgroundColor = [UIColor brownColor];
                [viewTitle addSubview:viewType6];
                
                UILabel *labNo = [[UILabel alloc]initWithFrame:CGRectMake(20, 5+35, 70, 30)];
                labNo.text = @"答错的题";
                labNo.font = [UIFont systemFontOfSize:14.0];
                [viewTitle addSubview:labNo];
                
                UIView *viewNo = [[UIView alloc]initWithFrame:CGRectMake(90, 12.5+35, 15, 15)];
                viewNo.backgroundColor = [UIColor redColor];
                [viewTitle addSubview:viewNo];
                
                UILabel *labRight = [[UILabel alloc]initWithFrame:CGRectMake(Scr_Width-100, 5+35, 70, 30)];
                labRight.font = [UIFont systemFontOfSize:14.0];
                labRight.text = @"答对的题";
                [viewTitle addSubview:labRight];
                
                UIView *viewRight = [[UIView alloc]initWithFrame:CGRectMake(Scr_Width - 30, 12.5+35, 15, 15)];
                viewRight.backgroundColor = [UIColor greenColor];
                [viewTitle addSubview:viewRight];
            }
            [reView addSubview:labCaptionTypeName];
             return reView;
        }
        else if (_parameter == 3){
            UIView *viewTitle = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 80)];
            viewTitle.backgroundColor = [UIColor groupTableViewBackgroundColor];
            [reView addSubview:viewTitle];
            
            UILabel *labNoDo = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, 70, 30)];
            labNoDo.text = @"未做的题";
            labNoDo.font = [UIFont systemFontOfSize:14.0];
            [viewTitle addSubview:labNoDo];
            
            UIView *viewNoDo = [[UIView alloc]initWithFrame:CGRectMake(90, 12.5, 15, 15)];
            viewNoDo.backgroundColor = ColorWithRGB(200, 200, 200);
            [viewTitle addSubview:viewNoDo];
            
            UILabel *labType6 = [[UILabel alloc]initWithFrame:CGRectMake(Scr_Width-100, 5, 70, 30)];
            labType6.font = [UIFont systemFontOfSize:14.0];
            labType6.text = @"一题多问";
            [viewTitle addSubview:labType6];
            
            UIView *viewType6 = [[UIView alloc]initWithFrame:CGRectMake(Scr_Width - 30, 12.5, 15, 15)];
            viewType6.backgroundColor = [UIColor brownColor];
            [viewTitle addSubview:viewType6];
            
            UILabel *labNo = [[UILabel alloc]initWithFrame:CGRectMake(20, 5+35, 70, 30)];
            labNo.text = @"答错的题";
            labNo.font = [UIFont systemFontOfSize:14.0];
            [viewTitle addSubview:labNo];
            
            UIView *viewNo = [[UIView alloc]initWithFrame:CGRectMake(90, 12.5+35, 15, 15)];
            viewNo.backgroundColor = [UIColor redColor];
            [viewTitle addSubview:viewNo];
            
            UILabel *labRight = [[UILabel alloc]initWithFrame:CGRectMake(Scr_Width-100, 5+35, 70, 30)];
            labRight.font = [UIFont systemFontOfSize:14.0];
            labRight.text = @"答对的题";
            [viewTitle addSubview:labRight];
            
            UIView *viewRight = [[UIView alloc]initWithFrame:CGRectMake(Scr_Width - 30, 12.5+35, 15, 15)];
            viewRight.backgroundColor = [UIColor greenColor];
            
            UILabel *labTitle = [[UILabel alloc]initWithFrame:CGRectMake(10, 85, 50, 30)];
            labTitle.text = @"题号";
            [reView addSubview:labTitle];
            
            [viewTitle addSubview:viewRight];
            
            return reView;
        }
    }
    return nil;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"anaLysiscell" forIndexPath:indexPath];
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
    cell.backgroundColor = [UIColor greenColor];
    NSDictionary *dicAnalysis = [[NSDictionary alloc]init];
    //模拟试卷
    if (_parameter == 2) {
        NSDictionary *dicPater = _arrayTopic[indexPath.section];
        NSArray *arrayTop = dicPater[@"Questions"];
        dicAnalysis = arrayTop[indexPath.row];
        
    }
    //每周精选
    else if (_parameter == 3){
        dicAnalysis = _arrayTopic[indexPath.row];
    }
    NSInteger levelAnalysis = [dicAnalysis[@"level"] integerValue];
    NSInteger qtype = [dicAnalysis[@"qtype"] integerValue];
    if (qtype != 6) {
        if (levelAnalysis == 0) {
            cell.backgroundColor = ColorWithRGB(200, 200, 200);
        }
        else if (levelAnalysis == 1){
            cell.backgroundColor = [UIColor greenColor];
        }
        else if (levelAnalysis == 2){
            cell.backgroundColor = [UIColor redColor];
        }
    }
    else{
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
