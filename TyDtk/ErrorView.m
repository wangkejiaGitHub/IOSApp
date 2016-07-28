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
    _buttonErrorType.layer.masksToBounds = YES;
    _buttonErrorType.layer.cornerRadius = 3;
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
    //纠错信息是否为空
    if ([_textViewError.text isEqualToString:@""]) {
        [SVProgressHUD showInfoWithStatus:@"纠错信息不能为空"];
        return;
    }
    //是否选择错误类型
    if (_arrayErrorTypeSelect.count == 0) {
        [SVProgressHUD showInfoWithStatus:@"请选择至少一种错误类型"];
        return;
    }
    //提交纠错信息
    LXAlertView *alert = [[LXAlertView alloc]initWithTitle:@"温馨提示" message:@"要提交纠错信息吗?" cancelBtnTitle:@"取消" otherBtnTitle:@"提交" clickIndexBlock:^(NSInteger clickIndex) {
        if (clickIndex == 1) {
            [self submitErrorMessage];
        }
    }];
    [alert showLXAlertView];
}
//清空
- (IBAction)buttonClearClick:(UIButton *)sender {
    if (_textViewError.text.length > 0) {
        LXAlertView *alert = [[LXAlertView alloc]initWithTitle:@"温馨提示" message:@"要清空纠错信息吗?" cancelBtnTitle:@"取消" otherBtnTitle:@"清空" clickIndexBlock:^(NSInteger clickIndex) {
            if (clickIndex == 1) {
                _textViewError.text = @"";
            }
        }];
        [alert showLXAlertView];
    }
}
//取消
- (IBAction)buttonCenter:(UIButton *)sender {
    [self removeFromSuperview];
}
//错误类型
- (IBAction)buttonTypeClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        sender.backgroundColor = [UIColor purpleColor];
        [self addTableVIewTypeForSelf];
    }
    else{
        [sender setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        sender.backgroundColor = [UIColor clearColor];
        [UIView animateWithDuration:0.2 animations:^{
            CGRect rect = _viewErrorType.frame;
            rect.origin.x = rect.origin.x + 80;
            _viewErrorType.frame = rect;
        }];
    }
}
/**
 添加错误类型选择的view
 */
- (void)addTableVIewTypeForSelf{
    if (!_viewErrorType) {
        _viewErrorType = [[UIView alloc]initWithFrame:CGRectMake(self.bounds.size.width, 50, 80, 25*_arrayErrorType.count)];
        _viewErrorType.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _viewErrorType.layer.masksToBounds = YES;
        _viewErrorType.layer.cornerRadius = 3;
        [self addSubview:_viewErrorType];
        
        for (int i = 0; i<_arrayErrorType.count; i++) {
            NSDictionary *dicType = _arrayErrorType[i];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame= CGRectMake(0, 1+i*25, 80, 23);
            btn.tag = 100 + i;
            [btn setTitle:dicType[@"Names"] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:15.0];
            btn.backgroundColor = ColorWithRGB(200, 200, 200);
            [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            btn.layer.masksToBounds = YES;
            btn.layer.cornerRadius = 3;
            btn.titleLabel.font = [UIFont systemFontOfSize:13.0];
            [btn addTarget:self action:@selector(btnTypeClick:) forControlEvents:UIControlEventTouchUpInside];
            [_viewErrorType addSubview:btn];
        }
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = _viewErrorType.frame;
        rect.origin.x = rect.origin.x - 80;
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
}
/**
 提交纠错信息
 */
- (void)submitErrorMessage{
    [SVProgressHUD showWithStatus:@"提交中..."];
    NSUserDefaults *tyUser = [NSUserDefaults standardUserDefaults];
    NSString *accessToken = [tyUser objectForKey:tyUserAccessToken];
    NSString *levels = [_arrayErrorTypeSelect componentsJoinedByString:@","];
    NSString *urlString = [NSString stringWithFormat:@"%@api/Correct/Submit?access_token=%@",systemHttps,accessToken];
    NSDictionary *dicPat = @{@"Levels":levels,@"Content":_textViewError.text,@"QuestionId":[NSString stringWithFormat:@"%ld",_questionId]};
    [HttpTools postHttpRequestURL:urlString RequestPram:dicPat RequestSuccess:^(id respoes) {
        NSDictionary *dicError =(NSDictionary *)respoes;
        NSInteger codeId = [dicError[@"code"] integerValue];
        if (codeId == 1) {
            NSDictionary *dicMsg = dicError[@"datas"];
            [SVProgressHUD showSuccessWithStatus:dicMsg[@"msg"]];
            [self removeFromSuperview];
        }
    } RequestFaile:^(NSError *erro) {
        
    }];
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
