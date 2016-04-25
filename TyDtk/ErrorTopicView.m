//
//  ErrorTopicView.m
//  TyDtk
//
//  Created by 天一文化 on 16/4/25.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "ErrorTopicView.h"
@interface ErrorTopicView()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) NSArray *arrayErrorType;
@end
@implementation ErrorTopicView
-(id)initWithFrame:(CGRect)frame errorTypeArray:(NSArray *)array{
    self = [super initWithFrame:frame];
    if (self) {
        _arrayErrorType = array;
        [self addTableViewSelectType];
    }
    return self;
}
//添加
- (void)addTableViewSelectType{
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:tableView];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrayErrorType.count + 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellErr"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellErr"];
    }
    for (id subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    if (indexPath.row < _arrayErrorType.count) {
        NSDictionary *dic = _arrayErrorType[indexPath.row];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(10, 5, 100, 20);
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = 8;
        btn.layer.borderWidth = 1.0;
        btn.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        btn.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        btn.tag = 100 + indexPath.row;
        btn.backgroundColor = [UIColor whiteColor];
        [btn setTitle:dic[@"Names"] forState:UIControlStateNormal];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btn];
        
    }
    else{
        cell.textLabel.text = @"提交";
        cell.textLabel.font = [UIFont systemFontOfSize:20.0];
        cell.textLabel.textColor = [UIColor blueColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    return cell;
}
- (void)btnClick:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        sender.backgroundColor = [UIColor lightGrayColor];
    }
    else{
        sender.backgroundColor = [UIColor whiteColor];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == _arrayErrorType.count) {
        NSLog(@"fasfsafa");
        
        [self removeFromSuperview];
    }
}
@end
