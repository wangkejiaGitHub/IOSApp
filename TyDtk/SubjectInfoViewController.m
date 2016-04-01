//
//  SubjectInfoViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/3/30.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "SubjectInfoViewController.h"
@interface SubjectInfoViewController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *ScrolHeardView;

//用户信息，以及所需全局信息
@property (nonatomic,strong) NSUserDefaults *tyUser;
//从tyUser中获取到的用户信息
@property (nonatomic,strong) NSDictionary *dicUser;
//科目授权
@property (nonatomic,strong) CustomTools *
customTool;
//专业下所有科目科目
@property (nonatomic,strong) NSArray *arraySubject;
@end

@implementation SubjectInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self viewLoad];
}
- (void)viewLoad{
    NSLog(@"%@",_dicSubject);
    self.title = _dicSubject[@"Names"];
    [self getAllSubject];
}
-(void)test{
    //    _tyUser = tyNSUserDefaults;
    //    _dicUser = [_tyUser objectForKey:tyUserUser];
    //    _customTool = [[CustomTools alloc]init];
    //    _customTool.delegateTool = self;
    //    [_customTool empowerAndSignatureWithUserId:_dicUser[@"userId"] userName:_dicUser[@"name"] classId:@"105" subjectId:@"661"];
    //
    //    [_tyUser removeObjectForKey:tyUserUser];
    //    [_tyUser removeObjectForKey:tyUserAccessToken];
}
/**
 获取专业下所有科目
 */
- (void)getAllSubject{
    NSInteger subId = [_dicSubject[@"Id"] intValue];
    NSString *urlString = [NSString stringWithFormat:@"%@api/CourseInfo/%ld",systemHttps,subId];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicSubject = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"%@",dicSubject);
        _arraySubject = dicSubject[@"datas"];
        NSLog(@"%@",_arraySubject);
        [self addSubjectButtonForScrolView];
    } RequestFaile:^(NSError *error) {
        
    }];
}
/**
 在scrollView上加上科目
 */
- (void)addSubjectButtonForScrolView{
    CGFloat btn_w = 180;
    CGFloat btn_h = 30;
    //button之间的间距
    CGFloat btn_spa = 10;
    _ScrolHeardView.contentSize = CGSizeMake(btn_w*_arraySubject.count+btn_spa*(_arraySubject.count + 1), 50);
    for (int i =0; i<_arraySubject.count; i++) {
        NSDictionary *dic = _arraySubject[i];
        UIButton *btnSub = [UIButton buttonWithType:UIButtonTypeCustom];
        btnSub.frame = CGRectMake(btn_spa+(btn_w+btn_spa)*i, 10, btn_w, btn_h);
        btnSub.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [btnSub setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnSub setTitle:dic[@"Names"] forState:UIControlStateNormal];
        btnSub.tag = i+1000;
        [btnSub addTarget:self action:@selector(btnScrloClick:) forControlEvents:UIControlEventTouchUpInside];
        if (i == 0) {
            [btnSub setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
        [_ScrolHeardView addSubview:btnSub];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;{
    NSLog(@"%f",scrollView.contentOffset.x);
}
/**
 scrollView上面的科目点击事件
 */
-(void)btnScrloClick:(UIButton *)sender{
    for (id subView in _ScrolHeardView.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *btnCurr = (UIButton *)subView;
            if (sender.tag == btnCurr.tag ) {
                [btnCurr setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                [self setScrollViewContentOffsetWhenBtnClick:btnCurr];
                NSLog(@"UIButton.frame == %f",sender.frame.origin.x + 90 - (Scr_Width/2));
            }
            else{
                [btnCurr setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
        }
    }
}
/**
 当点击scrollView上面的科目时，让科目名字居中
 */
- (void)setScrollViewContentOffsetWhenBtnClick:(UIButton*)currSelectButton{
//    CGFloat btn_spa = 10;
    CGFloat btn_w = 180;
    //button的X坐标
    CGFloat currBtnLocX = currSelectButton.frame.origin.x;
    NSLog(@"%f",currBtnLocX);
    NSLog(@"当前X方向偏移 = %f",_ScrolHeardView.contentOffset.x);
    //button中心点的位置
    CGFloat currBtnCenterLocX = currBtnLocX + (btn_w/2);
    //判断button是否在可偏移的范围之内
    if (currBtnCenterLocX > (Scr_Width/2) && currBtnCenterLocX<(_ScrolHeardView.contentSize.width-(Scr_Width/2))) {

        //计算X方向偏移量
        CGFloat scrollViewOffSizeX = currBtnCenterLocX - (Scr_Width/2);
        NSLog(@"%f",scrollViewOffSizeX);
        [_ScrolHeardView setContentOffset:CGPointMake(scrollViewOffSizeX, 0) animated:YES];

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
