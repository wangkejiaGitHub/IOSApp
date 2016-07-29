//
//  SelectSubjectViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/6/22.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//
#import "SelectSubjectViewController.h"
#import "viewSelectSubject.h"
@interface SelectSubjectViewController ()<UITableViewDataSource,UITableViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,SelectSubjectDelegate,CustomToolDelegate>
///判断用户是否登录
@property (nonatomic,assign) BOOL isLoginUser;
//tableVIew 的宽度（页面适配）
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabViewWidthCount;
//collectionView
@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;
//tableView
@property (weak, nonatomic) IBOutlet UITableView *myTabViewSubject;
//背景图片
@property (weak, nonatomic) IBOutlet UIImageView *imageBackGrd;
@property (nonatomic,strong) NSUserDefaults *tyUser;
//当前选中的第一大科目下的所有第二大科目
@property (nonatomic,strong) NSMutableArray *arrayCurrSelectSubject;
@property (nonatomic,strong) ViewNullData *viewNullData;
///动画
@property (nonatomic,assign) BOOL isAnimation;
///选择科目
@property (nonatomic,strong) viewSelectSubject *viewSelectSubject;
@property (nonatomic,strong) NSDictionary *dicSelectSubject;
@property (nonatomic,strong) CustomTools *customTool;
@property (nonatomic,strong) NSDictionary *dicClass;
@end

@implementation SelectSubjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tyUser = [NSUserDefaults standardUserDefaults];
    if ([_tyUser objectForKey:tyUserUserInfo]) {
        _isLoginUser = YES;
    }
    else{
        _isLoginUser = NO;
    }
    [self viewLoad];
}
- (void)viewLoad{
    [SVProgressHUD showWithStatus:@"加载中..."];
    //    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    
    _arrayCurrSelectSubject = [NSMutableArray array];
    _myTabViewSubject.tableFooterView = [UIView new];
    [_myTabViewSubject selectRowAtIndexPath:[NSIndexPath indexPathForRow:_selectSubject inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    //背景图片拉伸
    UIImage *image = [[UIImage imageNamed:@"mainbg"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    _imageBackGrd.image = image;
    [self currSelectSubject];
}
/****************************************
 ****************************************
 提前获取试题的纠错类型，并存在 NSUserDefaults
 ****************************************
 ****************************************/
- (void)getTopicErrorType{
    NSString *urlString = [NSString stringWithFormat:@"%@api/Correct/GetCorrectLevels",systemHttps];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dic[@"code"] integerValue];
        if (codeId == 1) {
            NSArray *arrayError = dic[@"datas"];
            NSUserDefaults *tyUser = [NSUserDefaults standardUserDefaults];
            [tyUser setObject:arrayError forKey:tyUserErrorTopic];
        }
    } RequestFaile:^(NSError *error) {
        
    }];
}
/***************************************
 ****************************************/

- (void)viewDidAppear:(BOOL)animated{
    [SVProgressHUD dismiss];
}
/**
 当前选中的科目
 */
- (void)currSelectSubject{
    [_arrayCurrSelectSubject removeAllObjects];
    [_viewNullData removeFromSuperview];
    if (_arraySubject.count == 0) {
        [SVProgressHUD showInfoWithStatus:@"网络异常"];
        _viewNullData = [[ViewNullData alloc]initWithFrame:CGRectMake(_tabViewWidthCount.constant, 0, Scr_Width - _tabViewWidthCount.constant, Scr_Height) showText:@"点击左边菜单刷新"];
        [self.view addSubview:_viewNullData];
        return;
    }
    NSDictionary *dicCurrSubject = _arraySubject[_selectSubject];
    NSInteger currSubjectId = [dicCurrSubject[@"Id"] integerValue];
    for (NSDictionary *dicSecoundSub in _arraySecoundSubject) {
        NSInteger subjectParentId = [dicSecoundSub[@"ParentId"] integerValue];
        if (currSubjectId == subjectParentId) {
            [_arrayCurrSelectSubject addObject:dicSecoundSub];
        }
    }
}
- (void)addLabelWhenCollectionViewNullData{
    
}
////////////////////////
///// tableView代理
////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arraySubject.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"scell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    NSDictionary *dicCell = _arraySubject[indexPath.row];
    UILabel *labText = (UILabel *)[cell.contentView viewWithTag:10];
    labText.text = dicCell[@"Names"];
    UIImageView *imageCell = (UIImageView *)[cell.contentView viewWithTag:11];
    NSString *imgUrl = [NSString stringWithFormat:@"%@%@",systemHttpImgs,dicCell[@"ImageUrl"]];
    [imageCell sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _selectSubject = indexPath.row;
    [self currSelectSubject];
    [_myCollectionView reloadData];
    [_myCollectionView setContentOffset:CGPointMake(0, 0) animated:YES];
}
////////////////////////
///// collcetion代理
////////////////////////
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _arrayCurrSelectSubject.count;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(15, 10, 10, 10);
}
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 25;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(((Scr_Width-_tabViewWidthCount.constant)-10), ((Scr_Width-_tabViewWidthCount.constant)-10)/2 - 10+30);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"sscell" forIndexPath:indexPath];
    NSDictionary *dicCurrSubject = _arrayCurrSelectSubject[indexPath.row];
    //专业名称
    UILabel *labnName = (UILabel *)[cell.contentView viewWithTag:14];
    labnName.text = dicCurrSubject[@"Names"];
    //图片
    UIImageView *imageCell = (UIImageView *)[cell.contentView viewWithTag:10];
    NSString *imgUrl = [NSString stringWithFormat:@"%@%@",systemHttpImgs,dicCurrSubject[@"ImageUrl"]];
    [imageCell sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
    imageCell.layer.masksToBounds = YES;
    imageCell.layer.cornerRadius = 5;
    //科目
    NSInteger courseNum = [dicCurrSubject[@"CourseNum"] integerValue];
    NSString *courseNumString = [NSString stringWithFormat:@"%ld",courseNum];
    NSString *labText = [NSString stringWithFormat:@"%@科目",courseNumString];
    NSMutableAttributedString *labAtt = [[NSMutableAttributedString alloc]initWithString:labText];
    [labAtt addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, courseNumString.length)];
    UILabel *labSub = (UILabel *)[cell.contentView viewWithTag:11];
    labSub.attributedText = labAtt;
    //学习人数
    UILabel *labPersonNub = (UILabel *)[cell.contentView viewWithTag:12];
    labPersonNub.adjustsFontSizeToFitWidth = YES;
    NSString *studyNum = [NSString stringWithFormat:@"%ld 人在学",[dicCurrSubject[@"StudyNum"]integerValue]];
    //
    NSMutableAttributedString *labPerson = [[NSMutableAttributedString alloc]initWithString:studyNum];
    [labPerson addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, [NSString stringWithFormat:@"%ld",[dicCurrSubject[@"StudyNum"] integerValue]].length)];
    labPersonNub.attributedText = labPerson;

    cell.backgroundColor = ColorWithRGBWithAlpp(218, 218, 218, 0.5);
    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = 5;
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%f",Scr_Height/3);
    NSDictionary *dic = _arrayCurrSelectSubject[indexPath.row];
    NSInteger courseNumId = [dic[@"CourseNum"] integerValue];
    if (courseNumId == 0) {
        [SVProgressHUD showInfoWithStatus:@"暂时还没有科目哦~"];
        return;
    }
    _dicClass = dic;
    _isAnimation = !_isAnimation;
    if (_isAnimation) {
        [self getAllSubject:dic];
    }
    else{
        [self viewBigAnimation];
        [_viewSelectSubject removeFromSuperview];
    }
    
}
//试图还原动画
- (void)viewBigAnimation{
    CABasicAnimation *cba1=[CABasicAnimation animationWithKeyPath:@"position"];
    cba1.fromValue=[NSValue valueWithCGPoint:CGPointMake(self.view.center.x, self.view.center.y - 30)];
    cba1.toValue=[NSValue valueWithCGPoint:self.view.center];

    CABasicAnimation *cba2=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
    cba2.fromValue=[NSNumber numberWithFloat:0.85];
    cba2.toValue=[NSNumber numberWithFloat:1];
    
    CAAnimationGroup *grop = [CAAnimationGroup animation];
    grop.animations = @[cba1,cba2];
    grop.duration = 0.3;
    grop.removedOnCompletion=NO;
    grop.fillMode=kCAFillModeForwards;
    grop.delegate = self;
    [self.navigationController.tabBarController.view.layer addAnimation:grop forKey:@"big"];
}
//试图缩小动画
- (void)viewSmallAnimation{
    CABasicAnimation *cba1=[CABasicAnimation animationWithKeyPath:@"position"];
    cba1.fromValue=[NSValue valueWithCGPoint:self.view.center];
    cba1.toValue=[NSValue valueWithCGPoint:CGPointMake(self.view.center.x, self.view.center.y - 30)];
    
    
    CABasicAnimation *cba2=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
    cba2.fromValue=[NSNumber numberWithFloat:1];
    cba2.toValue=[NSNumber numberWithFloat:0.85];
    
    CAAnimationGroup *grop = [CAAnimationGroup animation];
    grop.animations = @[cba1,cba2];
    grop.duration = 0.3;
    grop.removedOnCompletion=NO;
    grop.fillMode=kCAFillModeForwards;
    grop.delegate = self;
    [self.navigationController.tabBarController.view.layer addAnimation:grop forKey:@"small"];
}

/**
 获取专业下所有科目
 */
- (void)getAllSubject:(NSDictionary *)dic{
    [SVProgressHUD show];
    NSInteger subId = [dic[@"Id"] intValue];
    NSString *urlString = [NSString stringWithFormat:@"%@api/CourseInfo/%ld",systemHttps,subId];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicSubject = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dicSubject[@"code"] integerValue];
        if (codeId == 1) {
            NSArray *arrry = dicSubject[@"datas"];
            if (arrry.count > 0) {
                [self viewSmallAnimation];
                _viewSelectSubject = [[viewSelectSubject alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Height) arraySubject:arrry className:dic[@"Names"]];
                _viewSelectSubject.delegateSelect = self;
                UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
                [keyWindow addSubview:_viewSelectSubject];
                [SVProgressHUD dismiss];
            }
            else{
                _isAnimation = NO;
                [SVProgressHUD showInfoWithStatus:@"科目暂时还未开放哦"];
            }
        }
        else{
            [SVProgressHUD showInfoWithStatus:dicSubject[@"errmsg"]];
        }
    } RequestFaile:^(NSError *error) {
        httpsErrorShow;
    }];
}
///科目选择回调
- (void)selectSubjectViewDismiss:(NSDictionary *)dicSubject{
    _dicSelectSubject = dicSubject;
    _isAnimation = !_isAnimation;
    [_viewSelectSubject removeFromSuperview];
    [self viewBigAnimation];
}

///动画结束代理（主要判断选过科目之后的动画，执行授权操作）
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (anim == [self.navigationController.tabBarController.view.layer animationForKey:@"big"]) {
        if (_dicSelectSubject != nil) {
            [self getAccessToken];
        }
    }
}
///重新授权，重置令牌
- (void)getAccessToken{
    [SVProgressHUD show];
    _customTool = [[CustomTools alloc]init];
    _customTool.delegateTool = self;
    NSString *classId = [NSString stringWithFormat:@"%ld",[_dicClass[@"Id"] integerValue]];
    NSString *subjectId = [NSString stringWithFormat:@"%ld",[_dicSelectSubject[@"Id"] integerValue]];
    ///登录状态下的授权
    if (_isLoginUser) {
        //获取储存的专业信息
        NSDictionary *dicUserInfo = [_tyUser objectForKey:tyUserUserInfo];
        [_customTool empowerAndSignatureWithUserId:dicUserInfo[@"userId"] userCode:dicUserInfo[@"userCode"] classId:classId subjectId:subjectId];
    }
    ///未登录状态下的授权
    else{
        [_customTool empowerAndSignatureWithUserId:defaultUserId userCode:defaultUserCode classId:classId subjectId:subjectId];
    }
}
- (void)httpSussessReturnClick{
    [SVProgressHUD dismiss];
    [_tyUser setObject:_dicClass forKey:tyUserClass];
    [_tyUser setObject:_dicSelectSubject forKey:tyUserSelectSubject];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)httpErrorReturnClick{
    [SVProgressHUD dismiss];
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
