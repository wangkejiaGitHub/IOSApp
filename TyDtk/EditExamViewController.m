//
//  EditExamViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/6/13.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "EditExamViewController.h"
#import "MyExamViewController.h"
@interface EditExamViewController ()<UITextFieldDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textTime;
@property (weak, nonatomic) IBOutlet UITextView *textViewRemark;
@property (weak, nonatomic) IBOutlet UIButton *buttonDefult;
@property (weak, nonatomic) IBOutlet UIButton *buttonReset;
@property (weak, nonatomic) IBOutlet UIButton *buttonSave;
@property (weak, nonatomic) IBOutlet UIView *viewLine;
@property (weak, nonatomic) IBOutlet UIView *viewHeader;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewWidth;

//时间选择器
@property (nonatomic,strong) UIDatePicker *datePickerDate;
//用于显示时间选择器的试图
@property (nonatomic,strong) UIView *viewDatePicker;
//用于记录备注信息
@property (nonatomic,strong) NSString *stringRemark;
@property (nonatomic,strong) NSUserDefaults *tyUser;
@property (nonatomic,strong) NSString *accessToken;

@property (nonatomic ,assign) CGFloat rectH;
@end

@implementation EditExamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
  
    [self ViewLoad];
}
//View即将呈现(加载)
- (void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    
    if (Scr_Height < 560) {
        _textViewWidth.constant = 50;
    }
    NSLog(@"%f",Scr_Height);
}
//View即将消失或隐藏
-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

///////////
//键盘监听//
//键盘出现//
- (void)keyboardShow:(NSNotification *)note{
    [self keyboardHide:nil];
    NSDictionary *userInfo = [note userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    //键盘高度
    CGFloat keyBoardHeight = keyboardRect.size.height;
    CGFloat cH = Scr_Height - keyBoardHeight;
    CGFloat textFoldH = _textViewRemark.frame.origin.y;
    //如果键盘能够覆盖文本框，让试图向上移动
    if (cH < (textFoldH + 40 + 69)) {
        _rectH =(textFoldH + 40 + 69) - cH;
        CGRect rect = self.view.frame;
        rect.origin.y = rect.origin.y-_rectH -15;
        [UIView animateWithDuration:0.2 animations:^{
            self.view.frame = rect;
        }];
    }
}
///////////
//键盘监听//
//键盘消失//
- (void)keyboardHide:(NSNotification *)note{
    if (_rectH > 0) {
        CGRect rect = self.view.frame;
        rect.origin.y = rect.origin.y+_rectH +15;
        [UIView animateWithDuration:0.2 animations:^{
            self.view.frame = rect;
        }];
    }
    _rectH = 0;
}


///viewDidLoad
- (void)ViewLoad{
    self.title = @"修改考试信息";
    _tyUser = [NSUserDefaults standardUserDefaults];
    _accessToken = [_tyUser objectForKey:tyUserAccessToken];
    _textViewRemark.layer.masksToBounds = YES;
    _textViewRemark.layer.cornerRadius = 5;
    _textViewRemark.layer.borderColor = [ColorWithRGB(200, 200, 200) CGColor];
    _textViewRemark.layer.borderWidth = 1;
    _buttonReset.layer.masksToBounds = YES;
    _buttonReset.layer.cornerRadius = 2;
    _buttonReset.backgroundColor =[UIColor lightGrayColor];
    _buttonSave.layer.masksToBounds = YES;
    _buttonSave.layer.cornerRadius = 3;
    
//    labChp.backgroundColor = ColorWithRGB(190, 200, 252);
//    labChp.textAlignment = NSTextAlignmentCenter;
//    labChp.textColor = ColorWithRGB(90, 144, 266);
    
    _viewLine.backgroundColor = ColorWithRGB(190, 200, 252);
    NSString *examName = _dicExam[@"CourseName"];
//    CGSize labSize = sizeWithStrinfLength(examName, 16.0, 20);
    UILabel *labName = [[UILabel alloc]init];
    labName.font = [UIFont systemFontOfSize:16.0];
    labName.text = examName;
    labName.backgroundColor = ColorWithRGB(190, 200, 252);
    labName.textColor = ColorWithRGB(90, 144, 266);
    labName.textAlignment = NSTextAlignmentCenter;
    CGSize labSize = [labName sizeThatFits:CGSizeMake(MAXFLOAT, 20)];
    labName.frame = CGRectMake(20, 28, labSize.width + 30, 30);
    [_viewHeader addSubview:labName];
    NSString *time = _dicExam[@"ExamTime"];
    time = [time substringToIndex:10];
    _textTime.text = time;
    _textViewRemark.text = _dicExam[@"Note"];
    _stringRemark = _dicExam[@"Note"];
    [self addTapGest];
    
    ///根据是否是默认考试，显示不同的button的图片
    //没有默认
    if ([_dicExam[@"IsDefault"] integerValue] == 0) {
        [_buttonDefult setImage:[UIImage imageNamed:@"check_unchecked"] forState:UIControlStateNormal];
    }
    //默认
    else{
        ///默认选中
        _buttonDefult.selected = YES;
        [_buttonDefult setImage:[UIImage imageNamed:@"check_checked"] forState:UIControlStateNormal];
    }
    for (NSString *kee in _dicExam) {
        NSLog(@"%@ == %@",kee,_dicExam[kee]);
    }

}


//添加手势按钮
- (void)addTapGest{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
    [self.view addGestureRecognizer:tap];
}
///手势按钮点击事件
- (void)tapClick:(UITapGestureRecognizer *)tapGest{
    [_textViewRemark resignFirstResponder];
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = _viewDatePicker.frame;
        rect.origin.y = Scr_Height;
        _viewDatePicker.frame = rect;
    }];
}
///将要输入时间文本框，弹出时间选择器
- (void)selectDateForText{
    if (!_viewDatePicker) {
        _viewDatePicker = [[UIView alloc]initWithFrame:CGRectMake(0, Scr_Height, Scr_Width, 200)];
        _viewDatePicker.backgroundColor = [UIColor whiteColor];
        _viewDatePicker.layer.masksToBounds = YES;
        _viewDatePicker.layer.cornerRadius = 5;
        _viewDatePicker.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        _viewDatePicker.layer.borderWidth = 2;
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
///时间选择（或取消时间选择）后触发
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
//设为默认按钮
- (IBAction)buttonDefultClick:(UIButton *)sender {
    _buttonDefult.selected = !_buttonDefult.selected;
    if (_buttonDefult.selected) {
        [_buttonDefult setImage:[UIImage imageNamed:@"check_checked"] forState:UIControlStateNormal];
    }
    else{
        [_buttonDefult setImage:[UIImage imageNamed:@"check_unchecked"] forState:UIControlStateNormal];
    }
}
//重置按钮
- (IBAction)buttonResetClick:(UIButton *)sender {
    if ([_textViewRemark.text isEqualToString:_stringRemark]) {
        return;
    }
    LXAlertView *lx = [[LXAlertView alloc]initWithTitle:@"温馨提示" message:@"重置将还原上次保存备注，确定重置？" cancelBtnTitle:@"取消" otherBtnTitle:@"重置" clickIndexBlock:^(NSInteger clickIndex) {
        if (clickIndex == 1) {
            _textViewRemark.text = _stringRemark;
        }
    }];
    
//    lx.animationStyle = LXASAnimationTopShake;
    [lx showLXAlertView];
}
///保存考试信息
- (IBAction)buttonSaveClick:(UIButton *)sender {
    if (_textViewRemark.text.length > 100) {
        [SVProgressHUD showInfoWithStatus:@"备注说明字符过长"];
        return;
    }
    [self saveExamInfo];
//    ///如果选择了设置默认
//    if (_buttonDefult.selected) {
//        [self setExamDefault];
//    }
//    else{
//        [self saveExamInfo];
//    }
    
    
}
///设置默认
- (void)setExamDefault{
    NSString *urlString = [NSString stringWithFormat:@"%@api/ExamSet/SetDefault/%@?access_token=%@",systemHttps,_dicExam[@"Id"],_accessToken];
    [HttpTools postHttpRequestURL:urlString RequestPram:nil RequestSuccess:^(id respoes) {
        NSDictionary *dicExam = (NSDictionary *)respoes;
        NSInteger codeId = [dicExam[@"code"] integerValue];
        if (codeId == 1) {
        [self saveExamInfo];
        }
        NSLog(@"%@",dicExam);
    } RequestFaile:^(NSError *erro) {
        
    }];
}

/**
 保存考试信息
 */
- (void)saveExamInfo{
    [SVProgressHUD show];
    NSMutableDictionary *dicModel =[NSMutableDictionary dictionaryWithDictionary:_dicExam];
    [dicModel setObject:_textTime.text forKey:@"ExamTime"];
    [dicModel setObject:_textViewRemark.text forKey:@"Note"];
    if (_buttonDefult.selected) {
        [dicModel setObject:@"1" forKey:@"IsDefault"];
    }
    else{
        [dicModel setObject:@"0" forKey:@"IsDefault"];
    }
    // POST api/ExamSet/Update?access_token={access_token}
    NSString *urlString = [NSString stringWithFormat:@"%@api/ExamSet/Update?access_token=%@",systemHttps,_accessToken];
    [HttpTools postHttpRequestURL:urlString RequestPram:dicModel RequestSuccess:^(id respoes) {
        NSDictionary *dicUpdate = (NSDictionary *)respoes;
        NSInteger codeId = [dicUpdate[@"code"] integerValue];
        if (codeId == 1) {
            [SVProgressHUD showSuccessWithStatus:@"保存成功！"];
            NSInteger index = [[self.navigationController viewControllers] indexOfObject:self];
            MyExamViewController *vc = [[self.navigationController viewControllers] objectAtIndex:index -1 ];
            NSLog(@"%@",vc);
            vc.isFirstLoad = NO;
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            [SVProgressHUD showInfoWithStatus:@"操作失败！"];
        }
    } RequestFaile:^(NSError *erro) {
        [SVProgressHUD showInfoWithStatus:@"操作异常！"];
    }];
    
}
//textfield代理
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [self selectDateForText];
    return NO;
}
//textView代理
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
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
