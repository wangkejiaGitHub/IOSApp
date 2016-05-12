//
//  NotesView.m
//  TyDtk
//
//  Created by 天一文化 on 16/4/28.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "NotesView.h"
@interface NotesView()<UITextViewDelegate>
@end
@implementation NotesView
- (void)awakeFromNib{
    _buttonSave.layer.masksToBounds = YES;
    _buttonSave.layer.cornerRadius = 3;

    _buttonClear.layer.masksToBounds = YES;
    _buttonClear.layer.cornerRadius = 3;

    _buttonCenter.layer.masksToBounds = YES;
    _buttonCenter.layer.cornerRadius = 3;
    _textVIewNote.layer.masksToBounds = YES;
    _textVIewNote.layer.cornerRadius = 5;
    _textVIewNote.textColor = [UIColor brownColor];
    _textVIewNote.delegate = self;
}
//保存笔记
- (IBAction)buttonSaveClick:(UIButton *)sender {
    //笔记信息是否为空
    if ([_textVIewNote.text isEqualToString:@""]) {
        [SVProgressHUD showInfoWithStatus:@"笔记信息不能为空"];
        return;
    }
    LXAlertView *alert = [[LXAlertView alloc]initWithTitle:@"温馨提示" message:@"要保存笔记信息吗?" cancelBtnTitle:@"取消" otherBtnTitle:@"保存" clickIndexBlock:^(NSInteger clickIndex) {
        if (clickIndex == 1) {
            [self saveNotesMessage];
        }
    }];
    [alert showLXAlertView];
    //保存笔记
}
//清空笔记内容
- (IBAction)buttonClearClick:(UIButton *)sender {
    if (_textVIewNote.text.length > 0) {
        LXAlertView *alert = [[LXAlertView alloc]initWithTitle:@"温馨提示" message:@"要清空笔记信息吗?" cancelBtnTitle:@"取消" otherBtnTitle:@"清空" clickIndexBlock:^(NSInteger clickIndex) {
            if (clickIndex == 1) {
                _textVIewNote.text = @"";
            }
        }];
        [alert showLXAlertView];
    }
}
//取消
- (IBAction)buttonCenterClick:(UIButton *)sender {
    [self removeFromSuperview];
}
/**
 保存笔记，请求服务器
 */
- (void)saveNotesMessage{
    [SVProgressHUD showWithStatus:@"保存中..."];
    NSUserDefaults *tyUser = [NSUserDefaults standardUserDefaults];
    NSString *accessToken = [tyUser objectForKey:tyUserAccessToken];
    NSString *urlString = [NSString stringWithFormat:@"%@api/Note/Save?access_token=%@",systemHttps,accessToken];
    NSDictionary *dicPat = @{@"note":_textVIewNote.text,@"id":[NSString stringWithFormat:@"%ld",_questionId]};
    [HttpTools postHttpRequestURL:urlString RequestPram:dicPat RequestSuccess:^(id respoes) {
        NSDictionary *dic = (NSDictionary *)respoes;
        NSInteger codeId = [dic[@"code"] integerValue];
        if (codeId == 1) {
            NSDictionary *dicData = dic[@"datas"];
            [SVProgressHUD showSuccessWithStatus:dicData[@"msg"]];
            _textVIewNote.text = @"";
            if (!_isHiden) {
                [self removeFromSuperview];
            }
            else{
                [_textVIewNote becomeFirstResponder];
            }
        }
        else{
            [SVProgressHUD showInfoWithStatus:@"操作失败"];
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
