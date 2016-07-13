//
//  EditSetExamViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/7/13.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "EditSetExamViewController.h"
#import "MyExamViewController.h"
@interface EditSetExamViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UITextViewDelegate>
///时间文本
@property (nonatomic,strong)UITextField *textExamTime;
///备注文本
@property (nonatomic,strong) UITextView *textRemakeView;
///设为默认按钮
@property (nonatomic,strong) UIButton *buttonSetDefult;
///重置按钮
@property (nonatomic,strong) UIButton *buttonReset;
@property (weak, nonatomic) IBOutlet UITableView *tableViewExam;

//时间选择器
@property (nonatomic,strong) UIDatePicker *datePickerDate;
//用于显示时间选择器的试图
@property (nonatomic,strong) UIView *viewDatePicker;
//用于记录备注信息
@property (nonatomic,strong) NSString *stringRemark;
@property (nonatomic,strong) NSUserDefaults *tyUser;
@property (nonatomic,strong) NSString *accessToken;

@end

@implementation EditSetExamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tyUser = [NSUserDefaults standardUserDefaults];
    _accessToken = [_tyUser objectForKey:tyUserAccessToken];
    // Do any additional setup after loading the view.
    _tableViewExam.tableFooterView = [UIView new];
    _tableViewExam.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addTableHeardView];
}
///添加头试图
- (void)addTableHeardView{
    ///tableView头试图
    UIView *viewHeard = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 380)];
    viewHeard.backgroundColor = [UIColor whiteColor];
    _tableViewExam.tableHeaderView = viewHeard;
    //////
    //////
    UIView *viewTitle = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 60)];
    UIView *viewL = [[UIView alloc]initWithFrame:CGRectMake(0, 58, Scr_Width, 2)];
    viewL.backgroundColor = ColorWithRGB(190, 200, 252);
    [viewTitle addSubview:viewL];
    UILabel *labName = [[UILabel alloc]init];
    labName.font = [UIFont systemFontOfSize:16.0];
    labName.text = _dicExam[@"CourseName"];
    labName.backgroundColor = ColorWithRGB(190, 200, 252);
    labName.textColor = ColorWithRGB(90, 144, 266);
    labName.textAlignment = NSTextAlignmentCenter;
    CGSize labSize = [labName sizeThatFits:CGSizeMake(MAXFLOAT, 20)];
    labName.frame = CGRectMake(20, 28, labSize.width + 30, 30);
    [viewTitle addSubview:labName];
    [viewHeard addSubview: viewTitle];
    
    ///添加显示的考试信息内容试图
    UIView *viewExam = [[UIView alloc]initWithFrame:CGRectMake(0, 60, Scr_Width, 300)];
    
    UILabel *labTime =[[UILabel alloc]initWithFrame:CGRectMake(30, 10, 80, 20)];
    labTime.font = [UIFont systemFontOfSize:15.0];
    labTime.text = @"考试时间：";
    [viewExam addSubview:labTime];
    
    _textExamTime = [[UITextField alloc]initWithFrame:CGRectMake(30, labTime.frame.origin.y + labTime.frame.size.height + 5, Scr_Width - 60, 30)];
    _textExamTime.font = [UIFont systemFontOfSize:14.0];
    _textExamTime.borderStyle = UITextBorderStyleRoundedRect;
    _textExamTime.delegate =self;
    NSString *time = _dicExam[@"ExamTime"];
    time = [time substringToIndex:10];
    _textExamTime.text = time;
    [viewExam addSubview:_textExamTime];
    
    UILabel *labRemark = [[UILabel alloc]initWithFrame:CGRectMake(30, _textExamTime.frame.origin.y + _textExamTime.frame.size.height + 20, 80, 20)];
    labRemark.font = [UIFont systemFontOfSize:15.0];
    labRemark.text = @"备注说明：";
    [viewExam addSubview:labRemark];
    
    _textRemakeView = [[UITextView alloc]initWithFrame:CGRectMake(30, labRemark.frame.origin.y + labRemark.frame.size.height + 5, Scr_Width - 60, 150)];
    _textRemakeView.delegate = self;
    _textRemakeView.backgroundColor = [UIColor clearColor];
    _textRemakeView.layer.masksToBounds = YES;
    _textRemakeView.layer.cornerRadius = 5;
    _textRemakeView.layer.borderWidth = 1;
    _textRemakeView.layer.borderColor = [ColorWithRGB(200, 200, 200) CGColor];
    _textRemakeView.font = [UIFont systemFontOfSize:16.0];
    _textRemakeView.textColor = [UIColor brownColor];
    _textRemakeView.text = _dicExam[@"Note"];
    _stringRemark = _dicExam[@"Note"];
    [viewExam addSubview:_textRemakeView];
    
    UILabel *labAlert = [[UILabel alloc]initWithFrame:CGRectMake(30, _textRemakeView.frame.origin.y + _textRemakeView.frame.size.height + 3, Scr_Width - 60, 20)];
    labAlert.font = [UIFont systemFontOfSize:13.0];
    labAlert.textColor = [UIColor lightGrayColor];
    labAlert.text = @"小提示：最多可输入100个字符！";
    [viewExam addSubview:labAlert];
    
    _buttonSetDefult = [UIButton buttonWithType:UIButtonTypeCustom];
    _buttonSetDefult.frame = CGRectMake(30, labAlert.frame.origin.y + labAlert.frame.size.height + 3, 80, 20);
    _buttonSetDefult.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_buttonSetDefult setTitle:@"设为默认" forState:UIControlStateNormal];
    [_buttonSetDefult setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
     _buttonSetDefult.imageEdgeInsets = UIEdgeInsetsMake(0,-5,0,_buttonSetDefult.titleLabel.bounds.size.width);
    [_buttonSetDefult addTarget:self action:@selector(buttonSetDefultClick:) forControlEvents:UIControlEventTouchUpInside];
    ///根据是否是默认考试，显示不同的button的图片
    //没有默认
    if ([_dicExam[@"IsDefault"] integerValue] == 0) {
        [_buttonSetDefult setImage:[UIImage imageNamed:@"check_unchecked"] forState:UIControlStateNormal];
    }
    //默认
    else{
        ///默认选中
        _buttonSetDefult.selected = YES;
        [_buttonSetDefult setImage:[UIImage imageNamed:@"check_checked"] forState:UIControlStateNormal];
    }
    [viewExam addSubview:_buttonSetDefult];
    
    _buttonReset = [UIButton buttonWithType:UIButtonTypeCustom];
    _buttonReset.frame = CGRectMake(Scr_Width - 30 - 60, labAlert.frame.origin.y + labAlert.frame.size.height + 3, 60, 20);
    _buttonReset.titleLabel.font = [UIFont systemFontOfSize:14.0];
    _buttonReset.backgroundColor = ColorWithRGB(200, 200, 200);
    [_buttonReset setTitle:@"重置" forState:UIControlStateNormal];
    [_buttonReset setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _buttonReset.layer.masksToBounds = YES;
    _buttonReset.layer.cornerRadius = 2;
    [_buttonReset addTarget:self action:@selector(buttonResetClick:) forControlEvents:UIControlEventTouchUpInside];
    [viewExam addSubview:_buttonReset];
    
    [viewHeard addSubview:viewExam];
    
    [self addTapGestForTextTime];
}
///添加手势
- (void)addTapGestForTextTime{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapSelectTime:)];
    [self.view addGestureRecognizer:tap];
    
}
///时间选择手势
- (void)tapSelectTime:(UITapGestureRecognizer *)tap{
    [_textRemakeView resignFirstResponder];
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = _viewDatePicker.frame;
        rect.origin.y = Scr_Height;
        _viewDatePicker.frame = rect;
    }];
    
}
///设置默认按钮
- (void)buttonSetDefultClick:(UIButton *)butotn{
    _buttonSetDefult.selected = !_buttonSetDefult.selected;
    if (_buttonSetDefult.selected) {
        [_buttonSetDefult setImage:[UIImage imageNamed:@"check_checked"] forState:UIControlStateNormal];
    }
    else{
        [_buttonSetDefult setImage:[UIImage imageNamed:@"check_unchecked"] forState:UIControlStateNormal];
    }

}
///重置按钮
- (void)buttonResetClick:(UIButton *)button{
    if ([_textRemakeView.text isEqualToString:_stringRemark]) {
        return;
    }
    LXAlertView *lx = [[LXAlertView alloc]initWithTitle:@"温馨提示" message:@"重置将还原上次保存备注，确定重置？" cancelBtnTitle:@"取消" otherBtnTitle:@"重置" clickIndexBlock:^(NSInteger clickIndex) {
        if (clickIndex == 1) {
            _textRemakeView.text = _stringRemark;
        }
    }];
    
    [lx showLXAlertView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"examcell" forIndexPath:indexPath];
    UIButton *btn = (UIButton *)[cell.contentView viewWithTag:10];
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 3;
    [btn addTarget:self action:@selector(buttonSaveExamClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
///保存考试信息
- (void)buttonSaveExamClick:(UIButton *)button{
    if (_textRemakeView.text.length > 100) {
        [SVProgressHUD showInfoWithStatus:@"备注说明字符过长"];
        return;
    }
    [self saveExamInfo];
}
/**
 保存考试信息
 */
- (void)saveExamInfo{
    [SVProgressHUD show];
    NSMutableDictionary *dicModel =[NSMutableDictionary dictionaryWithDictionary:_dicExam];
    [dicModel setObject:_textExamTime.text forKey:@"ExamTime"];
    [dicModel setObject:_textRemakeView.text forKey:@"Note"];
    if (_buttonSetDefult.selected) {
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
            [SVProgressHUD showSuccessWithStatus:@"保存成功"];
            NSInteger index = [[self.navigationController viewControllers] indexOfObject:self];
            MyExamViewController *vc = [[self.navigationController viewControllers] objectAtIndex:index -1 ];
            vc.isFirstLoad = NO;
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            [SVProgressHUD showInfoWithStatus:@"操作失败"];
        }
    } RequestFaile:^(NSError *erro) {
        [SVProgressHUD showErrorWithStatus:@"网络异常"];
    }];
    
}

///将要输入时间文本框，弹出时间选择器
- (void)selectDateForText{
    if (!_viewDatePicker) {
        _viewDatePicker = [[UIView alloc]initWithFrame:CGRectMake(0, Scr_Height, Scr_Width, 200)];
        _viewDatePicker.backgroundColor = [UIColor whiteColor];
        _viewDatePicker.layer.masksToBounds = YES;
        _viewDatePicker.layer.cornerRadius = 5;
        _viewDatePicker.layer.borderColor = [[UIColor groupTableViewBackgroundColor] CGColor];
        _viewDatePicker.layer.borderWidth = 1;
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
        _textExamTime.text = selectTime;
    }
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = _viewDatePicker.frame;
        rect.origin.y = Scr_Height;
        _viewDatePicker.frame = rect;
    }];
}
///开始编辑时间，弹出时间选择器
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
///隐藏时间选择器
- (void)textViewDidBeginEditing:(UITextView *)textView{
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = _viewDatePicker.frame;
        rect.origin.y = Scr_Height;
        _viewDatePicker.frame = rect;
    }];

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
