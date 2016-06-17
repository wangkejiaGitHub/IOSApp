//
//  AddNewNote.m
//  TyDtk
//
//  Created by 天一文化 on 16/6/17.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "AddNewNote.h"
@interface AddNewNote()<UITextViewDelegate>

@end
@implementation AddNewNote

- (void)awakeFromNib{
    _imageViewBg.image = systemBackGrdImg;
    _textViewNote.backgroundColor = [UIColor whiteColor];
    _textViewNote.layer.masksToBounds = YES;
    _textViewNote.layer.cornerRadius = 3;
    _textViewNote.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _textViewNote.layer.borderWidth = 1;
    _buttonSave.layer.masksToBounds = YES;
    _buttonSave.layer.cornerRadius = 3;
    _textViewNote.delegate = self;
    UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapNoteClick:)];
    [self addGestureRecognizer:tapView];
}
- (void)tapNoteClick:(UITapGestureRecognizer *)tapGest{
    [_textViewNote resignFirstResponder];
}
- (IBAction)buttonSaveClick:(UIButton *)sender {
    //笔记信息是否为空
    if ([_textViewNote.text isEqualToString:@""]) {
        [SVProgressHUD showInfoWithStatus:@"笔记信息不能为空"];
        return;
    }
    else if (_textViewNote.text.length > 300){
        [SVProgressHUD showInfoWithStatus:@"字符过长！"];
        return;
    }
    LXAlertView *alert = [[LXAlertView alloc]initWithTitle:@"温馨提示" message:@"要保存笔记信息吗?" cancelBtnTitle:@"取消" otherBtnTitle:@"保存" clickIndexBlock:^(NSInteger clickIndex) {
        if (clickIndex == 1) {
            [self saveNotesMessage];
        }
    }];
    alert.animationStyle = LXASAnimationTopShake;
    [alert showLXAlertView];

}
- (IBAction)buttonClearClick:(UIButton *)sender {
    if (![_textViewNote.text isEqualToString:@""]) {
        LXAlertView *alert = [[LXAlertView alloc]initWithTitle:@"温馨提示" message:@"确认要清空笔记内容？" cancelBtnTitle:@"取消" otherBtnTitle:@"清空" clickIndexBlock:^(NSInteger clickIndex) {
            if (clickIndex == 1) {
                _textViewNote.text = @"";
            }
        }];
        alert.animationStyle = LXASAnimationTopShake;
        [alert showLXAlertView];
    }
}
/**
 保存笔记，请求服务器
 */
- (void)saveNotesMessage{
    [SVProgressHUD showWithStatus:@"保存中..."];
    NSUserDefaults *tyUser = [NSUserDefaults standardUserDefaults];
    NSString *accessToken = [tyUser objectForKey:tyUserAccessToken];
    NSString *urlString = [NSString stringWithFormat:@"%@api/Note/Save?access_token=%@",systemHttps,accessToken];
    NSDictionary *dicPat = @{@"note":_textViewNote.text,@"id":[NSString stringWithFormat:@"%ld",_questionId]};
    [HttpTools postHttpRequestURL:urlString RequestPram:dicPat RequestSuccess:^(id respoes) {
        NSDictionary *dic = (NSDictionary *)respoes;
        NSInteger codeId = [dic[@"code"] integerValue];
        if (codeId == 1) {
            NSDictionary *dicData = dic[@"datas"];
            [SVProgressHUD showSuccessWithStatus:dicData[@"msg"]];
            _textViewNote.text = @"";
            [_textViewNote resignFirstResponder];
        }
        else{
            [SVProgressHUD showInfoWithStatus:@"操作失败"];
        }
    } RequestFaile:^(NSError *erro) {
        
    }];
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }

    return YES;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
