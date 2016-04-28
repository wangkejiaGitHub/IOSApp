//
//  ErrorView.m
//  TyDtk
//
//  Created by 天一文化 on 16/4/28.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "ErrorView.h"
@interface ErrorView()<UITextViewDelegate>
@property (nonatomic,strong) UIView *viewErrorType;
@property (nonatomic,strong) NSArray *arrayErrorType;
@property (nonatomic,strong) NSMutableArray *arrayErrorTypeSelect;
@end
@implementation ErrorView

-(void)awakeFromNib{
    _buttonSubmit.layer.masksToBounds = YES;
    _buttonSubmit.layer.cornerRadius = 3;
    
    _buttonClear.layer.masksToBounds = YES;
    _buttonClear.layer.cornerRadius = 3;
    
    _buttonCenter.layer.masksToBounds = YES;
    _buttonCenter.layer.cornerRadius = 3;
    
    _textViewError.layer.masksToBounds = YES;
    _textViewError.layer.cornerRadius = 5;
    _textViewError.textColor = [UIColor brownColor];
    _textViewError.delegate = self;
    _arrayErrorType = [NSMutableArray array];
    _arrayErrorTypeSelect = [NSMutableArray array];
    NSUserDefaults *tyUser = [NSUserDefaults standardUserDefaults];
    _arrayErrorType = [tyUser objectForKey:tyUserErrorTopic];
}
//提交
- (IBAction)buttonSubmitClick:(UIButton *)sender {
    if ([_textViewError.text isEqualToString:@""]) {
        [SVProgressHUD showInfoWithStatus:@"纠错信息不能为空"];
        return;
    }
}
//清空
- (IBAction)buttonClearClick:(UIButton *)sender {
    _textViewError.text = @"";
}
//取消
- (IBAction)buttonCenter:(UIButton *)sender {
    [self removeFromSuperview];
}
//错误类型
- (IBAction)buttonTypeClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self addTableVIewTypeForSelf];
    }
    else{
        [UIView animateWithDuration:0.2 animations:^{
            CGRect rect = _viewErrorType.frame;
            rect.origin.x = rect.origin.x + 100;
            _viewErrorType.frame = rect;
        }];
    }
}
/**
 添加错误类型选择的view
 */
- (void)addTableVIewTypeForSelf{
    if (!_viewErrorType) {
        _viewErrorType = [[UIView alloc]initWithFrame:CGRectMake(self.bounds.size.width, 50, 100, 25*_arrayErrorType.count)];
        [self addSubview:_viewErrorType];
        
        for (int i = 0; i<_arrayErrorType.count; i++) {
            NSDictionary *dicType = _arrayErrorType[i];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame= CGRectMake(0, 1+i*25, 100, 23);
            btn.tag = 100 + i;
            [btn setTitle:dicType[@"Names"] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:15.0];
            btn.backgroundColor = ColorWithRGB(200, 200, 200);
            [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            btn.layer.masksToBounds = YES;
            btn.layer.cornerRadius = 3;
            [btn addTarget:self action:@selector(btnTypeClick:) forControlEvents:UIControlEventTouchUpInside];
            [_viewErrorType addSubview:btn];
        }
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = _viewErrorType.frame;
        rect.origin.x = rect.origin.x - 100;
        _viewErrorType.frame = rect;
    }];
}
- (void)btnTypeClick:(UIButton *)button{
    button.selected = !button.selected;
    NSDictionary *dicType = _arrayErrorType[button.tag - 100];
    NSInteger typeId = [dicType[@"Id"] integerValue];
    if (button.selected) {
        button.backgroundColor = [UIColor redColor];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_arrayErrorTypeSelect addObject:[NSString stringWithFormat:@"%ld",typeId]];
    }
    else{
        button.backgroundColor = ColorWithRGB(200, 200, 200);
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                [_arrayErrorTypeSelect removeObject:[NSString stringWithFormat:@"%ld",typeId]];
    }
    
    NSLog(@"%@",_arrayErrorTypeSelect);
}
//换行时失去焦点
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}
@end
