//
//  EditExamViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/6/13.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "EditExamViewController.h"

@interface EditExamViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UITextField *textTime;
@property (weak, nonatomic) IBOutlet UITextView *textViewRemark;
@property (nonatomic,strong) UIDatePicker *datePickerDate;
@property (nonatomic,strong) UIView *viewDatePicker;
@end

@implementation EditExamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"修改考试信息";
    _textViewRemark.layer.masksToBounds = YES;
    _textViewRemark.layer.cornerRadius = 5;
    _textViewRemark.layer.borderColor = [ColorWithRGB(200, 200, 200) CGColor];
    _textViewRemark.layer.borderWidth = 1;
    _labTitle.text = [NSString stringWithFormat:@"(%@)",_dicExam[@"CourseName"]];
    NSString *time = _dicExam[@"ExamTime"];
    time = [time substringToIndex:10];
    _textTime.text = time;
    _textViewRemark.text = _dicExam[@"Note"];
    
    [self addTapGest];
}
- (void)addTapGest{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
    [self.view addGestureRecognizer:tap];
}
- (void)tapClick:(UITapGestureRecognizer *)tapGest{
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = _viewDatePicker.frame;
        rect.origin.y = Scr_Height;
        _viewDatePicker.frame = rect;
    }];
}
- (void)selectDateForText{
    if (!_viewDatePicker) {
        _viewDatePicker = [[UIView alloc]initWithFrame:CGRectMake(0, Scr_Height, Scr_Width, 200)];
        _viewDatePicker.backgroundColor = [UIColor whiteColor];
        _datePickerDate = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 150)];
        _datePickerDate.backgroundColor = [UIColor clearColor];
        _datePickerDate.datePickerMode = UIDatePickerModeDate;
        [_viewDatePicker addSubview:_datePickerDate];
        
        UIButton *btnCan = [UIButton buttonWithType:UIButtonTypeCustom];
        btnCan.frame = CGRectMake(20, 160, 60, 25);
        [btnCan setTitle:@"取消" forState:UIControlStateNormal];
        btnCan.layer.masksToBounds = YES;
        btnCan.layer.cornerRadius = 3;
        btnCan.backgroundColor = [UIColor lightGrayColor];
        btnCan.tag = 100;
        btnCan.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [btnCan addTarget:self action:@selector(btnDateClick:) forControlEvents:UIControlEventTouchUpInside];
        [_viewDatePicker addSubview:btnCan];
        
        UIButton *btnSe = [UIButton buttonWithType:UIButtonTypeCustom];
        btnSe.frame = CGRectMake(Scr_Width - 80, 160, 60, 25);
        [btnSe setTitle:@"选择" forState:UIControlStateNormal];
        btnSe.layer.masksToBounds = YES;
        btnSe.layer.cornerRadius = 3;
        btnSe.backgroundColor = [UIColor lightGrayColor];
        btnSe.tag = 101;
        btnSe.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [btnSe addTarget:self action:@selector(btnDateClick:) forControlEvents:UIControlEventTouchUpInside];
        [_viewDatePicker addSubview:btnSe];
        
        [self.view addSubview:_viewDatePicker];
    }
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = _viewDatePicker.frame;
        rect.origin.y = Scr_Height - 49 - 200;
        _viewDatePicker.frame = rect;
    }];
}
- (void)btnDateClick:(UIButton *)button{
    if (button.tag == 101) {
        //选取时间
        NSDate *dateSelect = _datePickerDate.date;
        NSString *selectTime = [NSString stringWithFormat:@"%@",dateSelect];
        selectTime = [selectTime substringToIndex:10];
        NSLog(@"%@",selectTime);
        _textTime.text = selectTime;
    }
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = _viewDatePicker.frame;
        rect.origin.y = Scr_Height;
        _viewDatePicker.frame = rect;
    }];
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    NSLog(@"hhhahahah");
    [self selectDateForText];
    return NO;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
