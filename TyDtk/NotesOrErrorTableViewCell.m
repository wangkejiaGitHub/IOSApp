//
//  NotesOrErrorTableViewCell.m
//  TyDtk
//
//  Created by 天一文化 on 16/4/19.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "NotesOrErrorTableViewCell.h"
@interface NotesOrErrorTableViewCell()<UITextViewDelegate>
@end
@implementation NotesOrErrorTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _textVIew.layer.masksToBounds = YES;
    _textVIew.layer.cornerRadius = 3;
//    _textVIew.backgroundColor = ColorWithRGB(232, 223, 200);
    _textVIew.layer.borderWidth = 1;
    _textVIew.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    [_button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    [_buttonClear setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    _textVIew.delegate = self;
    _button.layer.masksToBounds = YES;
    _button.layer.cornerRadius = 5;
    _button.backgroundColor = ColorWithRGB(218, 218, 218);
    _buttonClear.layer.masksToBounds = YES;
    _buttonClear.layer.cornerRadius = 5;
    _buttonClear.backgroundColor = ColorWithRGB(218, 218, 218);
}
- (IBAction)buttonClick:(UIButton *)sender {
    NSLog(@"submitButton");
}
- (IBAction)clearButtonClick:(UIButton *)sender {
    _textVIew.text = @"";
}

//换行时失去焦点
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}
- (void)textViewDidBeginEditing:(UITextView *)textView{
//    textView.layer.borderWidth = 1;
    textView.layer.borderColor = [[UIColor grayColor] CGColor];
}
- (void)textViewDidEndEditing:(UITextView *)textView{
//    textView.layer.borderWidth = 0;
    textView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
