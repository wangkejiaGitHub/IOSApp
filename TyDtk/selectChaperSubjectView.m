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
@property (nonatomic,strong) NSString *chaperName;
//section折叠数组
@property (nonatomic ,strong) NSMutableArray *arraySection;
@end
@implementation selectChaperSubjectView
- (id)initWithFrame:(CGRect)frame arrayChaperSubject:(NSArray *)arrayZZZ chaperName:(NSString *)chaperName{
    self = [super initWithFrame:frame];
    if (self) {
        _arraySection = [NSMutableArray array];
        _arrayZZZData = arrayZZZ;
        _chaperName = chaperName;
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
    UIView *viewZ = [[UIView alloc]initWithFrame:CGRectMake(0, Scr_Height/3, Scr_Width, Scr_Height - (Scr_Height/3))];
    viewZ.backgroundColor = [UIColor whiteColor];
    [self addSubview:viewZ];
    _tableViewChaper = [[UITableView alloc]initWithFrame:CGRectMake(10, Scr_Height, Scr_Width - 20, Scr_Height - (Scr_Height/3)) style:UITableViewStyleGrouped];
    _tableViewChaper.showsVerticalScrollIndicator = NO;
    _tableViewChaper.delegate = self;
    _tableViewChaper.dataSource = self;
    _tableViewChaper.backgroundColor = [UIColor whiteColor];
    _tableViewChaper.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableViewChaper.userInteractionEnabled = YES;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width-20, 50)];
    view.backgroundColor = [UIColor whiteColor];
    UIView *viewL = [[UIView alloc]initWithFrame:CGRectMake(0, 48, Scr_Width - 20, 2)];
    viewL.backgroundColor = ColorWithRGB(190, 200, 252);
    [view addSubview:viewL];
    UILabel *labChaperName = [[UILabel alloc]initWithFrame:CGRectMake(0, 13, Scr_Width - 40, 30)];
    labChaperName.text = _chaperName;
    labChaperName.textColor = ColorWithRGB(90, 144, 266);
    labChaperName.font = [UIFont systemFontOfSize:16.0];
    labChaperName.backgroundColor = [UIColor clearColor];
    labChaperName.numberOfLines = 0;
    [view addSubview:labChaperName];
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
    UIView *viewH = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width - 20, 45)];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width - 20, 45)];
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
    btnDoTopic.frame = CGRectMake(Scr_Width - 20 - 55, 11, 50, 23);
    btnDoTopic.layer.masksToBounds = YES;
    btnDoTopic.layer.cornerRadius = 3;
    btnDoTopic.backgroundColor = ColorWithRGB(200, 200, 200);
    [btnDoTopic setTitle:@"做题" forState:UIControlStateNormal];
    btnDoTopic.layer.borderWidth = 1;
    btnDoTopic.layer.borderColor = [ColorWithRGBWithAlpp(0, 0, 0, 0.3) CGColor];
    [btnDoTopic setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    btnDoTopic.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [btnDoTopic addTarget:self action:@selector(BtnDoTopicClick:) forControlEvents:UIControlEventTouchUpInside];
    btnDoTopic.tag = 1000 + section;
    [view addSubview:btnDoTopic];
    //title字符
    NSString *titleString = [NSString stringWithFormat:@"%@（总共%ld题）",dicHeader[@"Names"],[dicHeader[@"Quantity"] integerValue]];
    //标题属性字符串
    NSMutableAttributedString *attriTitle = [[NSMutableAttributedString alloc] initWithString:titleString];
    
    [attriTitle addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor]
                       range:NSMakeRange([NSString stringWithFormat:@"%@",dicHeader[@"Names"]].length,5+[NSString stringWithFormat:@"%ld",[dicHeader[@"Quantity"] integerValue]].length)];
    UIFont *titleFont = [UIFont systemFontOfSize:12.0];
    [attriTitle addAttribute:NSFontAttributeName value:titleFont
                       range:NSMakeRange([NSString stringWithFormat:@"%@",dicHeader[@"Names"]].length ,5+[NSString stringWithFormat:@"%ld",[dicHeader[@"Quantity"] integerValue]].length)];
    UILabel *labText = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, Scr_Width - 20 - 50 - 20, view.frame.size.height)];
    labText.numberOfLines = 0;
    labText.font = [UIFont systemFontOfSize:13.0];
        [labText setAttributedText:attriTitle];
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
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(25, (50-9)/2, 9, 9)];
    view.backgroundColor = ColorWithRGB(90, 144, 266);
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 4.5;
    [cell.contentView addSubview:view];
    if (arrayData.count > 1) {
        UIView *viewLY = [[UIView alloc]initWithFrame:CGRectMake(29, 0, 1, 50)];
        if (indexPath.row == 0) {
            viewLY.frame = CGRectMake(29, 25, 1, 25);
        }
        else if (indexPath.row == arrayData.count - 1){
            viewLY.frame = CGRectMake(29, 0, 1, 25);
        }
        viewLY.backgroundColor = ColorWithRGB(90, 144, 266);
        [cell.contentView addSubview:viewLY];

    }
    NSString *titleString = [NSString stringWithFormat:@"%@（总共%ld题）",dic[@"Names"],[dic[@"Quantity"] integerValue]];
    //标题属性字符串
    NSMutableAttributedString *attriTitle = [[NSMutableAttributedString alloc] initWithString:titleString];
    
    [attriTitle addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor]
                       range:NSMakeRange([NSString stringWithFormat:@"%@",dic[@"Names"]].length,5+[NSString stringWithFormat:@"%ld",[dic[@"Quantity"] integerValue]].length)];
    UIFont *titleFont = [UIFont systemFontOfSize:12.0];
    [attriTitle addAttribute:NSFontAttributeName value:titleFont
                       range:NSMakeRange([NSString stringWithFormat:@"%@",dic[@"Names"]].length ,5+[NSString stringWithFormat:@"%ld",[dic[@"Quantity"] integerValue]].length)];
    
    UILabel *labT = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, Scr_Width - 60, 50)];
    labT.numberOfLines = 0;
    labT.font = [UIFont systemFontOfSize:13.0];
    [labT setAttributedText:attriTitle];
    
    MGSwipeButton *btnTopic = [MGSwipeButton buttonWithTitle:@"做 题" icon:nil backgroundColor:ColorWithRGB(109, 188, 254) callback:^BOOL(MGSwipeTableCell *sender) {
        [self.delegateChaper selectSubjectViewDismiss:dic];
        return YES;
    }];
    cell.rightButtons = @[btnTopic];

    [cell.contentView addSubview:labT];
    return cell;
}

@end
