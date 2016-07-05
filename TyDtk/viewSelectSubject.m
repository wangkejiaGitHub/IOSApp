//
//  viewSelectSubject.m
//  TyDtk
//
//  Created by 天一文化 on 16/6/24.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "viewSelectSubject.h"
@interface viewSelectSubject()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) UITableView *tableViewSub;
@property (nonatomic,strong) NSArray *arraySubject;
@property (nonatomic,assign) CGFloat cellHeight;
@property (nonatomic,strong) NSString *className;
@end
@implementation viewSelectSubject
- (id)initWithFrame:(CGRect)frame arraySubject:(NSArray *)arraySubject className:(NSString *)className{
    self = [super initWithFrame:frame];
    if (self) {
        _className = className;
        _cellHeight = 40;
        _arraySubject = arraySubject;
        self.backgroundColor = ColorWithRGBWithAlpp(0, 0, 0, 0.6);
        [self addTapGestForSelf];
        [self addTabeViewSubject];
    }
    return self;
}
- (void)addTapGestForSelf{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Height -(_arraySubject.count*_cellHeight + 60))];
    view.backgroundColor = [UIColor clearColor];
    [self addSubview:view];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
    [view addGestureRecognizer:tap];
}
- (void)tapClick:(UITapGestureRecognizer *)tapGest{
    ///消失view
    [self.delegateSelect selectSubjectViewDismiss:nil];
}
- (void)addTabeViewSubject{
    _tableViewSub = [[UITableView alloc]initWithFrame:CGRectMake(0, Scr_Height, Scr_Width, _arraySubject.count*_cellHeight + 70) style:UITableViewStylePlain];
    _tableViewSub.delegate = self;
    _tableViewSub.dataSource = self;
    _tableViewSub.backgroundColor = [UIColor whiteColor];
    _tableViewSub.userInteractionEnabled = YES;
    _tableViewSub.showsVerticalScrollIndicator = NO;
    [self addSubview:_tableViewSub];
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = _tableViewSub.frame;
        rect.origin.y =Scr_Height - _cellHeight*_arraySubject.count - 60;
        _tableViewSub.frame = rect;
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arraySubject.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 30;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 40)];
    UILabel *labName = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, Scr_Width, 20)];
    labName.font = [UIFont systemFontOfSize:19.0];
    labName.backgroundColor = [UIColor clearColor];
    labName.textColor = ColorWithRGB(55, 155, 255);
    labName.text = [NSString stringWithFormat:@"（%@）",_className];
    labName.textAlignment = NSTextAlignmentCenter;
    [view addSubview:labName];
    view.backgroundColor = ColorWithRGB(233, 233, 233);
    return view;
}
//- (uivi)
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return _cellHeight;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cells"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cells"];
    }
    for (id subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    NSDictionary *dicSubject = _arraySubject[indexPath.row];
    UILabel *labName =[[UILabel alloc]initWithFrame:CGRectMake(20, 10, Scr_Width - 40, 20)];
    labName.textAlignment = NSTextAlignmentCenter;
    labName.text = dicSubject[@"Names"];
    labName.font = [UIFont systemFontOfSize:16.0];
    labName.textColor = [UIColor brownColor];
    [cell.contentView addSubview:labName];
    cell.backgroundColor = ColorWithRGB(200, 200, 200);
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dicSubject = _arraySubject[indexPath.row];
    ///执行操作：选中科目，消失试图
    [self.delegateSelect selectSubjectViewDismiss:dicSubject];
}
@end
