//
//  selectChaperSubjectView.m
//  TyDtk
//
//  Created by 天一文化 on 16/6/27.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "selectChaperSubjectView.h"
#import "MGSwipeTableCell.h"
@interface selectChaperSubjectView()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) UITableView *tableViewChaper;
@property (nonatomic,strong) NSArray *arrayZZZData;
//section折叠数组
@property (nonatomic ,strong) NSMutableArray *arraySection;
@end
@implementation selectChaperSubjectView
- (id)initWithFrame:(CGRect)frame arrayChaperSubject:(NSArray *)arrayZZZ{
    self = [super initWithFrame:frame];
    if (self) {
        _arraySection = [NSMutableArray array];
        _arrayZZZData = arrayZZZ;
        self.backgroundColor = ColorWithRGBWithAlpp(0, 0, 0, 0.6);
//        [self addTableViewChaperSubject];
        [self addTapGest];
        [self addTableViewChaperSubject];
    }
    return self;
}
//点击消失
- (void)addTapGest{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Height/3)];
    view.backgroundColor = [UIColor clearColor];
    [self addSubview:view];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
    [view addGestureRecognizer:tap];
}
- (void)tapClick:(UITapGestureRecognizer *)tapGest{
    ///消失view
    [self.delegateChaper selectSubjectViewDismiss:nil];
}

- (void)addTableViewChaperSubject{
    _tableViewChaper = [[UITableView alloc]initWithFrame:CGRectMake(0, Scr_Height, Scr_Width, Scr_Height - (Scr_Height/3)) style:UITableViewStyleGrouped];
    _tableViewChaper.delegate = self;
    _tableViewChaper.dataSource = self;
    _tableViewChaper.backgroundColor = [UIColor whiteColor];
    _tableViewChaper.userInteractionEnabled = YES;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 20)];
    view.backgroundColor = [UIColor whiteColor];
    _tableViewChaper.tableHeaderView = view;
    _tableViewChaper.tableFooterView = [UIView new];
    [self addSubview:_tableViewChaper];
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = _tableViewChaper.frame;
        rect.origin.y =Scr_Height/3;
        _tableViewChaper.frame = rect;
    }];

}
///////tableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _arrayZZZData.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSString *str = [NSString stringWithFormat:@"%ld",section];
    if ([_arraySection containsObject:str]) {
        NSDictionary *dicData = _arrayZZZData[section];
        NSArray *arrayData = dicData[@"node"];
        return arrayData.count;
    }
    else{
        return 0;
    }

}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *viewH = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 45)];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(5, 0, Scr_Width - 10, 45)];
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 5;
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    NSDictionary *dicDate = _arrayZZZData[section];
    NSDictionary *dicHeader = dicDate[@"id"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, Scr_Width - 20, view.frame.size.height);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    //    [button setTitle:dicHeader[@"Names"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonSectionClick:) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font = [UIFont systemFontOfSize:13.0];
    button.tag = 100 + section;
    [view addSubview:button];
    /////
    UIButton *btnDoTopic = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDoTopic.frame = CGRectMake(Scr_Width - 20 - 50, 0, 50, 45);
    [btnDoTopic setTitle:@"做题" forState:UIControlStateNormal];
    btnDoTopic.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [btnDoTopic setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    btnDoTopic.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [btnDoTopic addTarget:self action:@selector(BtnDoTopicClick:) forControlEvents:UIControlEventTouchUpInside];
    btnDoTopic.tag = 1000 + section;
    [view addSubview:btnDoTopic];
//
//    //title字符
    NSString *titleString;
    
    titleString = [NSString stringWithFormat:@"%@（总共00题）★笔记：%ld  ★收藏:%ld",dicHeader[@"Names"],[dicHeader[@"NoteNum"] integerValue],[dicHeader[@"CollectionNum"] integerValue]];
    
    UILabel *labText = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, Scr_Width - 20 - 50, view.frame.size.height)];
    //    labText.text = dicHeader[@"Names"];
    labText.numberOfLines = 0;
    labText.font = [UIFont systemFontOfSize:13.0];
    //    [labText setAttributedText:attriTitle];
    labText.text = titleString;
    [view addSubview:labText];
    [viewH addSubview:view];
    return viewH;
}
//section折叠
- (void)buttonSectionClick:(UIButton *)sender{
    NSInteger sectoinId = sender.tag - 100;
    NSString *str = [NSString stringWithFormat:@"%ld",sectoinId];
    if ([_arraySection containsObject:str]) {
        [_arraySection removeObject:str];
    }
    else{
        [_arraySection addObject:str];
    }
    
    [_tableViewChaper reloadSections:[NSIndexSet indexSetWithIndex:sectoinId] withRowAnimation:UITableViewRowAnimationAutomatic];
}
///做题
- (void)BtnDoTopicClick:(UIButton *)button{
    NSDictionary *dicDate = _arrayZZZData[button.tag - 1000];
    NSDictionary *dicHeader = dicDate[@"id"];
    [self.delegateChaper selectSubjectViewDismiss:dicHeader];

}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 30)];
    view.backgroundColor = [UIColor whiteColor];
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 45;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == _arrayZZZData.count - 1) {
        return 30;
    }
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dicData = _arrayZZZData[indexPath.section];
    NSArray *arrayData = dicData[@"node"];
    NSDictionary *dic = arrayData[indexPath.row];
    NSString *cellIdentifer = @"programmaticCell";
    MGSwipeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (!cell) {
        cell = [[MGSwipeTableCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifer];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    for (id subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(25, (50-8)/2, 8, 8)];
    view.backgroundColor = ColorWithRGB(90, 144, 266);
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 4;
    [cell.contentView addSubview:view];
    UILabel *labT = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, Scr_Width - 60, 50)];
    labT.numberOfLines = 0;
    labT.font = [UIFont systemFontOfSize:13.0];
    NSString *titleString;
    
    titleString = [NSString stringWithFormat:@"%@（总共00题）★笔记：%ld  ★收藏:%ld",dic[@"Names"],[dic[@"NoteNum"] integerValue],[dic[@"CollectionNum"] integerValue]];
    labT.text = titleString;
    
    MGSwipeButton *btnTopic = [MGSwipeButton buttonWithTitle:@"做 题" icon:nil backgroundColor:ColorWithRGB(109, 188, 254) callback:^BOOL(MGSwipeTableCell *sender) {
        [self.delegateChaper selectSubjectViewDismiss:dic];
        return YES;
    }];
    cell.rightButtons = @[btnTopic];

    [cell.contentView addSubview:labT];
    return cell;
}

@end
