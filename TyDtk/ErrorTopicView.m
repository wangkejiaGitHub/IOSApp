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
@property (nonatomic,strong) NSMutableArray *arrraySelectError;
@end
@implementation ErrorTopicView
-(id)initWithFrame:(CGRect)frame errorTypeArray:(NSArray *)array{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        self.layer.shadowOffset = CGSizeMake(0, 2);
        self.layer.shadowOpacity = 0.80;
        _arrayErrorType = array;
        [self addTableViewSelectType];
    }
    return self;
}
//添加
- (void)addTableViewSelectType{
    _arrraySelectError = [NSMutableArray array];
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 10, self.bounds.size.width, self.bounds.size.height - 20) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.showsVerticalScrollIndicator = NO;
    [self addSubview:tableView];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrayErrorType.count + 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
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
        btn.frame = CGRectMake(10, 5, self.bounds.size.width - 20, 30);
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = 8;
        btn.layer.borderWidth = 1.0;
        btn.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        btn.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        btn.tag = 100 + indexPath.row;
        btn.backgroundColor = [UIColor whiteColor];
        [btn setTitle:dic[@"Names"] forState:UIControlStateNormal];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btn];
        
    }
    else if(indexPath.row == _arrayErrorType.count){
        UILabel *labSubmit = [[UILabel alloc]initWithFrame:CGRectMake(10, 3, self.bounds.size.width - 20,34)];
        labSubmit.text = @"提交";
        labSubmit.font = [UIFont systemFontOfSize:20.0];
        labSubmit.textColor = [UIColor whiteColor];
        labSubmit.textAlignment = NSTextAlignmentCenter;
        labSubmit.layer.masksToBounds = YES;
        labSubmit.layer.cornerRadius = 5;
        labSubmit.backgroundColor = [UIColor blueColor];
        [cell.contentView addSubview:labSubmit];
    }
    else{
        UILabel *labSubmit = [[UILabel alloc]initWithFrame:CGRectMake(10, 2, self.bounds.size.width - 20,34)];
        labSubmit.text = @"取消";
        labSubmit.font = [UIFont systemFontOfSize:20.0];
        labSubmit.textColor = [UIColor redColor];
        labSubmit.textAlignment = NSTextAlignmentCenter;
        labSubmit.layer.masksToBounds = YES;
        labSubmit.layer.cornerRadius = 5;
        labSubmit.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [cell.contentView addSubview:labSubmit];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}
- (void)btnClick:(UIButton *)sender{
    sender.selected = !sender.selected;
    NSDictionary *dicError =_arrayErrorType[sender.tag - 100];
    NSInteger errorId = [dicError[@"Id"] integerValue];
    if (sender.selected) {
        sender.backgroundColor = [UIColor greenColor];
        [sender setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_arrraySelectError addObject:[NSString stringWithFormat:@"%ld",errorId]];
        
    }
    else{
        sender.backgroundColor = [UIColor whiteColor];
        [sender setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_arrraySelectError removeObject:[NSString stringWithFormat:@"%ld",errorId]];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == _arrayErrorType.count) {
        //提交
        NSString *selectError = [_arrraySelectError componentsJoinedByString:@","];
        [self.delegateViewError viewCellClick:selectError];
        [self removeFromSuperview];
    }
    else if (indexPath.row == _arrayErrorType.count + 1){
        //取消
        [self.delegateViewError viewCellClick:nil];
        [self removeFromSuperview];
    }
}
@end
