//
//  TopicCardCollectionView.m
//  TyDtk
//
//  Created by 天一文化 on 16/4/13.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "TopicCardCollectionView.h"
@interface TopicCardCollectionView()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>
@property (nonatomic,assign) NSInteger intHour;
@property (nonatomic,assign) NSInteger intMinutes;
@property (nonatomic,assign) NSInteger intSecond;
//parameter（1章节练习，2模拟试卷，3每周精选，4智能出题）等
@property (nonatomic,assign) NSInteger parameter;
@end

@implementation TopicCardCollectionView
- (id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout withTopicArray:(NSArray *)arrayTopic paperParameter:(NSInteger)parameter{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        _parameter = parameter;
        _arrayisMakeTopic = [NSMutableArray array];
        _arrayTopic = arrayTopic;
        /////////计时器数据/////////
        _intHour = 0;
        _intMinutes = 0;
        _intSecond = 0;
        _labTimeString = [[UILabel alloc]initWithFrame:CGRectMake((Scr_Width-65)/2, 5, 65, 30)];
        _labTimeString.font = [UIFont systemFontOfSize:15.0];
        _labTimeString.textColor = [UIColor purpleColor];
        _timerCard = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(addTimer) userInfo:nil repeats:YES];
        _timerCard.fireDate = [NSDate distantPast];
        /////////计时器数据/////////
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
/**
 添加用时计时器
 */
- (void)addTimer{
    NSString *hourString = @"";
    NSString *minutesString = @"";
    NSString *secondString = @"";
    _intSecond = _intSecond + 1;
    if (_intSecond >59) {
        _intSecond = 0;
        _intMinutes = _intMinutes + 1;
        if (_intMinutes > 59) {
            _intMinutes = 0;
            _intSecond = 0;
            _intHour = _intHour + 1;
        }
    }
    hourString = [NSString stringWithFormat:@"%ld",_intHour];
    minutesString = [NSString stringWithFormat:@"%ld",_intMinutes];
    secondString = [NSString stringWithFormat:@"%ld",_intSecond];
    if (_intSecond < 10) {
        secondString = [NSString stringWithFormat:@"0%@",secondString];
    }
    
    if (_intMinutes < 10) {
        minutesString = [NSString stringWithFormat:@"0%@",minutesString];
    }
    
    if (_intHour < 10) {
        hourString = [NSString stringWithFormat:@"0%@",hourString];
    }
    _labTimeString.text = [NSString stringWithFormat:@"%@:%@:%@",hourString,minutesString,secondString];
}
//////////////////////
//代理
//////////////////////
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
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if (_parameter == 2) {
        return _arrayTopic.count;
    }
    else if (_parameter == 3){
        return 1;
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
            return CGSizeMake(Scr_Width, 80);
        }
        return CGSizeMake(Scr_Width, 40);
    }
    else if (_parameter == 3){
        return CGSizeMake(Scr_Width, 80);
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
        UICollectionReusableView *reView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"heardview" forIndexPath:indexPath];
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
                labCaptionTypeName.frame = CGRectMake(10, 40, Scr_Width-10, 40);
                UIView *viewTitle = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 40)];
                viewTitle.backgroundColor = [UIColor groupTableViewBackgroundColor];
                [reView addSubview:viewTitle];
                
                UILabel *labDone = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 70, 30)];
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
                
                [viewTitle addSubview:_labTimeString];
                
            }
            [reView addSubview:labCaptionTypeName];
            return reView;
        }
        else if (_parameter == 3){
            UIView *viewTitle = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 40)];
            viewTitle.backgroundColor = [UIColor groupTableViewBackgroundColor];
            [reView addSubview:viewTitle];
            
            UILabel *labDone = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 70, 30)];
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
            
            [viewTitle addSubview:_labTimeString];
            
            UILabel *labTitle = [[UILabel alloc]initWithFrame:CGRectMake(10, 45, 50, 30)];
            labTitle.text = @"题号";
            [reView addSubview:labTitle];
            return reView;
        }
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
}
@end
