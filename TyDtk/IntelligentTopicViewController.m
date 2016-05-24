//
//  IntelligentTopicViewController.m
//  TyDtk
//  智能出题
//  Created by 天一文化 on 16/5/24.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "IntelligentTopicViewController.h"

@interface IntelligentTopicViewController ()<UITableViewDataSource,UITableViewDelegate>
//0.613

@property (weak, nonatomic) IBOutlet UITableView *tableViewIn;
@property (nonatomic,assign) CGFloat viewCellWidth;
@property (nonatomic,strong) NSMutableArray *arraySelectView;

@end

@implementation IntelligentTopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _arraySelectView = [NSMutableArray array];
    _viewCellWidth = (Scr_Width-10-10-15-15)/3;
    // Do any additional setup after loading the view.
    _tableViewIn.separatorStyle = UITableViewCellSeparatorStyleNone;
    UIView *viewHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 0.613*Scr_Width)];
    viewHeader.backgroundColor = [UIColor clearColor];
    UIImageView *imageV = [[UIImageView alloc]initWithFrame:viewHeader.frame];
    imageV.image = [UIImage imageNamed:@"sma_img1"];
    [viewHeader addSubview:imageV];
    _tableViewIn.tableHeaderView = viewHeader;
    _tableViewIn.tableFooterView = [UIView new];
//    [self addViewSelectItem];
}
- (void)addViewSelectItem{
    ///试图之间的间隔
    CGFloat spea = 15;
    ///试图的宽高适配
    UIView *cccccc = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 0.613*Scr_Width)];
    cccccc.backgroundColor = [UIColor lightGrayColor];
    CGFloat viewWidth = (Scr_Width-10-10-spea-spea)/3;
    for (int i = 0; i<3; i++) {
        UIView *viewS = [[UIView alloc]initWithFrame:CGRectMake(10+(viewWidth+spea)*i, 0, viewWidth, viewWidth)];
        viewS.backgroundColor = [UIColor whiteColor];
        viewS.tag = 100 + i;
        viewS.layer.borderWidth = 1;
        viewS.layer.borderColor = [[UIColor lightGrayColor]CGColor];
        [cccccc addSubview:viewS];
    }
//    _tableViewIn.tableHeaderView = cccccc;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100 + _viewCellWidth + 100 + 100;
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
    //间隔
    CGFloat spea = 15;
    for (int i = 0; i<3; i ++) {
        UIView *viewSele = [[UIView alloc]initWithFrame:CGRectMake(10+(_viewCellWidth+spea)*i, 100, _viewCellWidth, _viewCellWidth)];
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
    UILabel *labAlert = [[UILabel alloc]initWithFrame:CGRectMake(20, 110 + _viewCellWidth + 10, Scr_Width - 40, 60)];
    labAlert.tag = 1000;
    labAlert.numberOfLines = 0;
    labAlert.textColor = [UIColor lightGrayColor];
    labAlert.font = [UIFont systemFontOfSize:15.0];
    //    labAlert.backgroundColor = [UIColor groupTableViewBackgroundColor];
    //    labAlert.layer.masksToBounds = YES;
    //    labAlert.layer.cornerRadius = 3;
    labAlert.text = @"按照你收藏夹里的收藏的经典试题，来进行自由组卷，让你能更好的掌握考试的知识点。";
    [cell.contentView addSubview:labAlert];
    
    UIButton *btnDoTopic = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDoTopic.frame = CGRectMake(50, labAlert.frame.origin.y + 70, Scr_Width - 100, 40);
    btnDoTopic.layer.masksToBounds = YES;
    btnDoTopic.layer.cornerRadius = 5;
    btnDoTopic.tag = 1111;
    btnDoTopic.backgroundColor = [UIColor orangeColor];
    [btnDoTopic setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnDoTopic setTitle:@"开始做题" forState:UIControlStateNormal];
    [cell.contentView addSubview:btnDoTopic];
    return cell;
}
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
