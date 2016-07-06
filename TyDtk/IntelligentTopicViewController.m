//
//  IntelligentTopicViewController.m
//  TyDtk
//  智能出题（待开发...）
//  Created by 天一文化 on 16/5/24.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "IntelligentTopicViewController.h"

@interface IntelligentTopicViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableViewIn;
@property (nonatomic,assign) CGFloat viewCellWidth;
@property (nonatomic,strong) NSMutableArray *arraySelectView;
//本地信息存储
@property (nonatomic,strong) NSUserDefaults *tyUser;
//令牌
@property (nonatomic,strong) NSString *accessToken;
@property (nonatomic,strong) UIButton *btnStartTopic;
@end
@implementation IntelligentTopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tyUser = [NSUserDefaults standardUserDefaults];
    _accessToken = [_tyUser objectForKey:tyUserAccessToken];
    _btnStartTopic = [UIButton buttonWithType:UIButtonTypeCustom];
    self.title = @"智能出题";
    _arraySelectView = [NSMutableArray array];
    _viewCellWidth = (Scr_Width-10-10-15-15)/3;
    _tableViewIn.separatorStyle = UITableViewCellSeparatorStyleNone;
    UIView *viewHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 0.613*Scr_Width)];
    viewHeader.backgroundColor = [UIColor clearColor];
    UIImageView *imageV = [[UIImageView alloc]initWithFrame:viewHeader.frame];
    imageV.image = [UIImage imageNamed:@"sma_img1"];
    [viewHeader addSubview:imageV];
    _tableViewIn.tableHeaderView = viewHeader;
    _tableViewIn.tableFooterView = [UIView new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 270 + _viewCellWidth + 180;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    for (id subView in cell.contentView.subviews) {
        if ([subView isKindOfClass:[UIView class]]) {
            UIView *view = (UIView *)subView;
            if (view.tag > 100) {
                [subView removeFromSuperview];
            }
        }
    }
    UIImageView *imageV = (UIImageView *)[cell.contentView viewWithTag:10];
    UIImage *image = [[UIImage imageNamed:@"sayD"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 30, 30, 30)];
    imageV.image = image;
    UILabel *labTitle = (UILabel *)[cell.contentView viewWithTag:11];
    labTitle.adjustsFontSizeToFitWidth = YES;
    //间隔
    CGFloat spea = 15;
    for (int i = 0; i<3; i ++) {
        UIView *viewSele = [[UIView alloc]initWithFrame:CGRectMake(10+(_viewCellWidth+spea)*i, 275, _viewCellWidth, _viewCellWidth)];
        viewSele.backgroundColor = [UIColor whiteColor];
        viewSele.tag = 111 + i;
        viewSele.layer.borderWidth = 1;
        viewSele.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        [cell.contentView addSubview:viewSele];
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewTapClick:)];
        [viewSele addGestureRecognizer:tapGest];
        UIImageView *imag = [[UIImageView alloc]initWithFrame:CGRectMake(15, 5, _viewCellWidth - 30, _viewCellWidth - 30)];
        UILabel *labText = [[UILabel alloc]initWithFrame:CGRectMake(0, _viewCellWidth - 23, _viewCellWidth, 20)];
        labText.textColor = ColorWithRGB(86, 158, 220);
        labText.textAlignment = NSTextAlignmentCenter;
        labText.font = [UIFont systemFontOfSize:16.0];
        if (i == 0) {
            imag.image = [UIImage imageNamed:@"y_gpicon"];
            labText.text = @"高考频点";
        }
        else if (i == 1){
            imag.image = [UIImage imageNamed:@"y_cticon"];
            labText.text = @"薄弱环节";
        }
        else{
            imag.image = [UIImage imageNamed:@"y_scicon"];
            labText.text = @"收藏试题";
        }
        [viewSele addSubview:labText];
        [viewSele addSubview:imag];
    }
    UILabel *labAlert = [[UILabel alloc]initWithFrame:CGRectMake(20, 280 + _viewCellWidth + 15, Scr_Width - 40, 60)];
    labAlert.tag = 1000;
    labAlert.numberOfLines = 0;
    labAlert.textColor = [UIColor lightGrayColor];
    labAlert.font = [UIFont systemFontOfSize:14.0];
    // labAlert.backgroundColor = [UIColor groupTableViewBackgroundColor];
    // labAlert.layer.masksToBounds = YES;
    // labAlert.layer.cornerRadius = 3;
    labAlert.text = @"按照你收藏夹里的收藏的经典试题，来进行自由组卷，让你能更好的掌握考试的知识点。";
    [cell.contentView addSubview:labAlert];
    
//    UIButton *btnDoTopic = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnStartTopic.frame = CGRectMake(30, labAlert.frame.origin.y + 70, Scr_Width - 60, 40);
    _btnStartTopic.layer.masksToBounds = YES;
    _btnStartTopic.layer.cornerRadius = 5;
    _btnStartTopic.tag = 1111;
    _btnStartTopic.backgroundColor = [UIColor orangeColor];
    [_btnStartTopic setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnStartTopic setTitle:@"开始做题" forState:UIControlStateNormal];
    [_btnStartTopic addTarget:self action:@selector(buttonStartTopic:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:_btnStartTopic];
    return cell;
}
//试图手势
- (void)viewTapClick:(UITapGestureRecognizer *)tapGest{
    CGRect rectView = tapGest.view.frame;
    NSString *tagString = [NSString stringWithFormat:@"%ld",tapGest.view.tag];
    //判断是否包含点击的view
    if ([_arraySelectView containsObject:tagString]) {
        [_arraySelectView removeObject:tagString];
        tapGest.view.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        tapGest.view.backgroundColor = [UIColor whiteColor];
        rectView.origin.y = rectView.origin.y - 15;
        [UIView animateWithDuration:0.3 animations:^{
            tapGest.view.frame = rectView;
        }];
    }
    else{
        [_arraySelectView addObject:tagString];
        tapGest.view.layer.borderColor = [[UIColor orangeColor] CGColor];
        tapGest.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
        rectView.origin.y = rectView.origin.y + 15;
        [UIView animateWithDuration:0.3 animations:^{
            tapGest.view.frame = rectView;
        }];
    }
}
//开始做题按钮
- (void)buttonStartTopic:(UIButton *)sender{
    //[SVProgressHUD showInfoWithStatus:@"暂未开放，我们正在努力~"];
    [self getRidMakeTopic];
}
///开始做题，获取rid
- (void)getRidMakeTopic{
    //api/Smart/MakeSmartQuestions?access_token={access_token}
    NSString *urlString = [NSString stringWithFormat:@"%@api/Smart/MakeSmartQuestions?access_token=%@",systemHttps,_accessToken];
    [HttpTools postHttpRequestURL:urlString RequestPram:nil RequestSuccess:^(id respoes) {
        NSDictionary *dicTopic = (NSDictionary *)respoes;
        NSLog(@"%@",dicTopic);
    } RequestFaile:^(NSError *erro) {
        
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
