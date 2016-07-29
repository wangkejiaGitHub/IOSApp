//
//  UserIndexViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/4/5.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "UserIndexViewController.h"
#import "TableHeardView.h"
#import "MyCollectViewController.h"
#import "SelectSubjectViewController.h"
#import "LoginViewController.h"
#import "ExerciseRecordViewController.h"
#import "ImageEnlargeViewController.h"
@interface UserIndexViewController ()<UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,HeardImgDelegate,LoginDelegate,LCActionSheetDelegate>
///用于判断用户是否登录
@property (nonatomic,assign) BOOL isLoginUser;
@property (weak, nonatomic) IBOutlet UITableView *tableViewList;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewBg;
@property (nonatomic,strong) UIImagePickerController *imagePickerG;
@property (nonatomic,strong) TableHeardView *tableHeardView;
@property (nonatomic,strong) NSUserDefaults *tyUser;
@property (nonatomic,strong) NSDictionary *dicUser;
@property (nonatomic,strong) NSArray *arrayCellTitle;
@property (nonatomic,strong) NSArray *arrayCellImage;
@property (nonatomic,strong) ViewNullData *viewDataNil;
/////////专业分类科目信息////////////////
//所有专业分类
@property (nonatomic,strong) NSMutableArray *arraySubject;
//所有专业
@property (nonatomic,strong) NSMutableArray *arraySecoundSubject;

@property (nonatomic,strong) LoginUser *loginUser;
@property (nonatomic ,strong) ODRefreshControl *refreshHeard;
@end

@implementation UserIndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _tableViewList.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _tyUser = [NSUserDefaults standardUserDefaults];
    _loginUser = [[LoginUser alloc]init];
    _loginUser.delegateLogin = self;
    _refreshHeard = [[ODRefreshControl alloc]initInScrollView:_tableViewList];
//    _refreshHeard.tintColor = ColorWithRGB(90, 144, 266);
    _refreshHeard.tintColor = [UIColor lightGrayColor];
    _refreshHeard.activityIndicatorViewColor = [UIColor blackColor];
    [_refreshHeard addTarget:self action:@selector(refreshHeardClick:) forControlEvents:UIControlEventValueChanged];
    
    [self viewLoad];
}
- (void)viewLoad{
    _arrayCellTitle = @[@"个人资料",@"当前科目",@"我的订单",@"我的考试",@"做题记录",@"我的收藏",@"我的错题",@"我的笔记"];
    _arrayCellImage = @[@"persenself",@"course",@"order",@"quest",@"learnrecord",@"collect",@"errquests",@"ebook"];
    [self addTableViewHeardView];
    /////专业分类科目信息
    _arraySubject = [NSMutableArray array];
    _arraySecoundSubject = [NSMutableArray array];
}
- (void)viewWillAppear:(BOOL)animated{
    [self userLoginStatus];
    [SVProgressHUD dismiss];
}
///下拉刷新
- (void)refreshHeardClick:(ODRefreshControl *)refresh{
    ///刷新控件显示时间
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        ///此处刷新
        [self userLoginStatus];
    });
}
///判断用户的登录状态
- (void)userLoginStatus{
    if ([_tyUser objectForKey:tyUserUserInfo]) {
        _isLoginUser = YES;
        //获取用户信息
        [self getUserInfo];
    }
    else{
        _isLoginUser = NO;
        _tableHeardView.labUserName.text = @"点击登录点题库";
        _tableHeardView.imageHeardImg.image = [UIImage imageNamed:@"imgNullPer"];
        [_refreshHeard endRefreshing];
    }
    [_tableViewList reloadData];
    
}

///添加tableView头试图
- (void)addTableViewHeardView{
    _tableHeardView = [[[NSBundle mainBundle] loadNibNamed:@"TableHeardViewForUser" owner:self options:nil]lastObject];
    _tableHeardView.frame = CGRectMake(0, 0, Scr_Width, 200);
    _tableHeardView.delegateImg = self;
    _tableViewList.tableHeaderView = _tableHeardView;
}
///判断是否登录
- (BOOL)loginTest{
    if ([_tyUser objectForKey:tyUserUserInfo]) {
        _dicUser = [_tyUser objectForKey:tyUserUserInfo];
        return YES;
    }
    return NO;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return _arrayCellTitle.count;
    }
    return 1;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section != 0) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 30)];
        view.backgroundColor = [UIColor clearColor];
        return view;
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section != 0) {
        return 30;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 1) {
        return 30;
    }
    return 1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 1) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 30)];
        view.backgroundColor = [UIColor clearColor];
    }
    return nil;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellUser" forIndexPath:indexPath];
    UILabel *labTitle =(UILabel *)[cell.contentView viewWithTag:11];
    UIImageView *img = (UIImageView *)[cell.contentView viewWithTag:10];
    UILabel *labSiubject = (UILabel *)[cell.contentView viewWithTag:12];
    if (indexPath.section == 0) {
        img.image = [UIImage imageNamed:_arrayCellImage[indexPath.row]];
        labTitle.text = _arrayCellTitle[indexPath.row];
        if (indexPath.row == 1) {
            if ([_tyUser objectForKey:tyUserSelectSubject]) {
                NSDictionary *dicCurrSubject = [_tyUser objectForKey:tyUserSelectSubject];
                labSiubject.text= dicCurrSubject[@"Names"];
            }
            else{
                labSiubject.text = @"未选择科目";
            }
        }
        else{
            labSiubject.text = @"";
        }
    }
    else{
        img.image = [UIImage imageNamed:@"about"];
        labTitle.text = @"关于我们";
        labSiubject.text = @"";
    }
    return  cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        UIStoryboard *Scommon = CustomStoryboard(@"TyCommon");
        ///除了科目选择其他要验证科目
        if (indexPath.row != 1) {
            ///判断是否登录
            if (_isLoginUser) {
                if (indexPath.row == 0) {
                    //个人资料
                    [self performSegueWithIdentifier:@"userinfo" sender:nil];
                }
                else if (indexPath.row == 2){
                    //我的订单
                    [self performSegueWithIdentifier:@"myorder" sender:nil];
                }
                else if (indexPath.row == 3){
                    if ([_tyUser objectForKey:tyUserSelectSubject]) {
                        //我的考试
                        [self performSegueWithIdentifier:@"myexam" sender:nil];
                    }
                    else{
                        [SVProgressHUD showInfoWithStatus:@"还没有选择过相关科目"];
                    }
                    
                }
                //做题记录
                else if (indexPath.row == 4){
                    if ([_tyUser objectForKey:tyUserSelectSubject]) {
                        ExerciseRecordViewController *execVc = [Scommon instantiateViewControllerWithIdentifier:@"ExerciseRecordViewController"];
                        [self.navigationController pushViewController:execVc animated:YES];
                    }
                    else{
                        [SVProgressHUD showInfoWithStatus:@"还没有选择过相关科目"];
                    }
                    
                }
                //我的收藏
                else if (indexPath.row == 5){
                    if ([_tyUser objectForKey:tyUserSelectSubject]) {
                        MyCollectViewController *collectVc = [Scommon instantiateViewControllerWithIdentifier:@"MyCollectViewController"];
                        collectVc.parameterView = 1;
                        [self.navigationController pushViewController:collectVc animated:YES];
                    }
                    else{
                        [SVProgressHUD showInfoWithStatus:@"还没有选择过相关科目"];
                    }
                }
                //我的错题
                else if (indexPath.row == 6){
                    if ([_tyUser objectForKey:tyUserSelectSubject]) {
                        MyCollectViewController *collectVc = [Scommon instantiateViewControllerWithIdentifier:@"MyCollectViewController"];
                        collectVc.parameterView = 2;
                        [self.navigationController pushViewController:collectVc animated:YES];
                    }
                    else{
                        [SVProgressHUD showInfoWithStatus:@"还没有选择过相关科目"];
                    }
                    
                }
                //我的笔记
                else if (indexPath.row == 7){
                    if ([_tyUser objectForKey:tyUserSelectSubject]) {
                        MyCollectViewController *collectVc = [Scommon instantiateViewControllerWithIdentifier:@"MyCollectViewController"];
                        collectVc.parameterView = 3;
                        [self.navigationController pushViewController:collectVc animated:YES];
                    }
                    else{
                        [SVProgressHUD showInfoWithStatus:@"还没有选择过相关科目"];
                    }
                }

            }
            ///未登录
            else{
                [SVProgressHUD showInfoWithStatus:@"您还没有登录"];
                UIStoryboard *sCommon = CustomStoryboard(@"TyCommon");
                LoginViewController *loginVc =  [sCommon instantiateViewControllerWithIdentifier:@"LoginViewController"];
                loginVc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:loginVc animated:YES];
            }
        }
        ///row == 1
        else{
            [self getSubjectClass];
        }
    }
    else{
        //关于我们
        [self performSegueWithIdentifier:@"aboutwe" sender:nil];
    }
}
/////获取用户信息
- (void)getUserInfo{
    NSDictionary *dicUser = [_tyUser objectForKey:tyUserUserInfo];
    [_loginUser getUserInformationoWithJeeId:dicUser[@"jeeId"]];
}
///获取用户信息回调
- (void)getUserInfoIsDictionary:(NSDictionary *)dicUser messagePara:(NSInteger)msgPara{
    ///成功
    if (msgPara == 1) {
        //标题属性字符串
        NSMutableAttributedString *attriTitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"欢迎回来：%@",dicUser[@"userName"]]];
        [attriTitle addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange(5,[NSString stringWithFormat:@"%@",dicUser[@"userName"]].length)];
        UIFont *titleFont = [UIFont systemFontOfSize:19.0];
        [attriTitle addAttribute:NSFontAttributeName value:titleFont
                           range:NSMakeRange(5,[NSString stringWithFormat:@"%@",dicUser[@"userName"]].length)];
        [_tableHeardView.labUserName setAttributedText:attriTitle];
        if (![dicUser[@"headImg"] isEqualToString:@""]) {
            [_tableHeardView.imageHeardImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",systemHttpsTyUser,dicUser[@"headImg"]]]];
        }
        else{
            _tableHeardView.imageHeardImg.image = [UIImage imageNamed:@"heardNilImg"];
        }
    }
    ///超时
    else if (msgPara == 0 && dicUser == nil){
        ///用户没有手动退出，则意为超时，需要重新登录
        NSDictionary *dicAccount = [_tyUser objectForKey:tyUserAccount];
        [_loginUser LoginAppWithAccount:dicAccount[@"acc"] password:dicAccount[@"pwd"]];

    }
    //网络异常
    else{
        [SVProgressHUD showErrorWithStatus:@"网络异常"];
        _tableHeardView.imageHeardImg.image = [UIImage imageNamed:@"imgNullPer"];
        _tableHeardView.labUserName.text = @"请检查您的网络";
    }
    
    [_refreshHeard endRefreshing];
}
///自动登录不成功，回调，退出或跳转到登录界面
- (void)loginUserErrorString:(NSString *)errorStr{
    ///提示是否跳转到登录页面
    LXAlertView *loginAlert = [[LXAlertView alloc]initWithTitle:@"账户错误" message:@"您的账户或密码已过期，是否重修登录" cancelBtnTitle:@"不登录" otherBtnTitle:@"重新登录" clickIndexBlock:^(NSInteger clickIndex) {
        if (clickIndex == 0) {
            ///不登录 （清除所有信息，使用户保持退出状态）
            [_tyUser removeObjectForKey:tyUserAccount];
            [_tyUser removeObjectForKey:tyUserUserInfo];
            [_tyUser removeObjectForKey:tyUserAccessToken];
            
            if ([_tyUser objectForKey:tyUserSelectSubject]) {
                ///退出后用默认的账号授权
                [_loginUser empFirstComeAppWithUserId:defaultUserId userCode:defaultUserCode];
            }
            [self userLoginStatus];
        }
        else{
            ///重新登录
            UIStoryboard *sCommon = CustomStoryboard(@"TyCommon");
            LoginViewController *loginVc = [sCommon instantiateViewControllerWithIdentifier:@"LoginViewController"];
            loginVc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:loginVc animated:YES];
        }
    }];
    
    loginAlert.animationStyle = LXASAnimationTopShake;
    [loginAlert showLXAlertView];
}
//////////////////专业科目信息//////////////////
//数据请求，获取专业信息
- (void)getSubjectClass{
    [SVProgressHUD show];
    [_arraySubject removeAllObjects];
    [_arraySecoundSubject removeAllObjects];
    [HttpTools getHttpRequestURL:[NSString stringWithFormat:@"%@api/Classify/GetAll",systemHttps] RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicSubject =[NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        
        NSArray *arrayDatas = dicSubject[@"datas"];
        
        for (NSDictionary *dicArr in arrayDatas) {
            NSInteger ParentId = [dicArr[@"ParentId"] integerValue];
            if (ParentId==0) {
                [_arraySubject addObject:dicArr];
            }
            else{
                [_arraySecoundSubject addObject:dicArr];
            }
        }
        [self performSegueWithIdentifier:@"selectSubject" sender:nil];
        [SVProgressHUD dismiss];
        
    } RequestFaile:^(NSError *error) {
        [SVProgressHUD showInfoWithStatus:@"网络异常"];
        [_arraySubject removeAllObjects];
        [_arraySecoundSubject removeAllObjects];
    }];
}
///点击头像回调
///imgParameter:0、未登录（跳转到登录界面）1、已登录（换头像）
- (void)ImgButtonClick:(NSInteger)imgParameter{
    if (imgParameter == 0) {
        UIStoryboard *sCommon = CustomStoryboard(@"TyCommon");
        LoginViewController *loginVc =  [sCommon instantiateViewControllerWithIdentifier:@"LoginViewController"];
        loginVc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:loginVc animated:YES];
    }
    else{
//        ///换头像
//        UIAlertController *alertImg = [UIAlertController alertControllerWithTitle:@"我的头像" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
//        UIAlertAction *acPhoto = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [self persentImagePicker:1];
//        }];
//        
//        UIAlertAction *acCream = [UIAlertAction actionWithTitle:@"手机相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [self persentImagePicker:0];
//        }];
//        
//        UIAlertAction *acLook = [UIAlertAction actionWithTitle:@"查看大图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            NSDictionary *dic = [_tyUser objectForKey:tyUserUserInfo];
//            ImageEnlargeViewController *imageEnlargeVC = [[ImageEnlargeViewController alloc]init];
//            imageEnlargeVC.imageUrlArrays = @[[NSString stringWithFormat:@"%@%@",systemHttpsTyUser,dic[@"headImg"]]];
//            imageEnlargeVC.imageIndex = 1;
//            [self presentViewController:imageEnlargeVC animated:YES completion:nil];
//        }];
//        UIAlertAction *acCan = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
//        [alertImg addAction:acPhoto];
//        [alertImg addAction:acCream];
//        [alertImg addAction:acLook];
//        [alertImg addAction:acCan];
//        [self.navigationController presentViewController:alertImg animated:YES completion:nil];
        
        LCActionSheet *AlertImg = [LCActionSheet sheetWithTitle:@"我的头像" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拍照",@"手机相册",@"查看大图",nil];
        AlertImg.animationDuration = 0.2;
        [AlertImg show];
    }
}
///点击提示按钮
- (void)actionSheet:(LCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{

    ///拍照
    if (buttonIndex == 1) {
         [self persentImagePicker:1];
    }
    ///手机相册
    else if (buttonIndex == 2){
        [self persentImagePicker:0];
    }
    ///查看大图
    else if (buttonIndex == 3){
        NSDictionary *dic = [_tyUser objectForKey:tyUserUserInfo];
        ImageEnlargeViewController *imageEnlargeVC = [[ImageEnlargeViewController alloc]init];
        imageEnlargeVC.imageUrlArrays = @[[NSString stringWithFormat:@"%@%@",systemHttpsTyUser,dic[@"headImg"]]];
        imageEnlargeVC.imageIndex = 1;
        [self presentViewController:imageEnlargeVC animated:YES completion:nil];
    }
}
///调用本地相册或摄像头(picParameter:0、手机相册，1、手机摄像头
- (void)persentImagePicker:(NSInteger)picParameter{
    if (!_imagePickerG) {
        _imagePickerG = [[UIImagePickerController alloc]init];
        _imagePickerG.delegate = self;
    }
    
    if (picParameter == 0) {
        _imagePickerG.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    else{
        // 前面的摄像头是否可用
        if ([self isFrontCameraAvailable]) {
            _imagePickerG.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        // 后面的摄像头是否可用
        else if ([self isFirstResponder]){
            _imagePickerG.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else{
            [SVProgressHUD showInfoWithStatus:@"没有相机可用~"];
            return;
        }
    }
    _imagePickerG.allowsEditing = YES;
    [self.navigationController presentViewController:_imagePickerG animated:YES completion:nil];
}
// 前面的摄像头是否可用
- (BOOL)isFrontCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

// 后面的摄像头是否可用
- (BOOL)isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}
///选择图片完成（从相册或者拍照完成）
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [SVProgressHUD show];
    ///如果是拍照先把修剪前的照片保存到本地
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImage *imageCream = [info objectForKey:UIImagePickerControllerOriginalImage];
        [self imageTopicSave:imageCream];
    }
    //将修剪后的图片
    UIImage *imageUp = [info objectForKey:UIImagePickerControllerEditedImage];
    //压缩后的图片
    //UIImage *imageYS = [UIImage imageWithData:[self imageData:imageUp]];
    NSDictionary *dicUserIn = [_tyUser objectForKey:tyUserUserInfo];
    
    NSString *urlString = [NSString stringWithFormat:@"%@app/uploadimg;JSESSIONID=%@?formSystem=902",systemHttpsTyUser,dicUserIn[@"jeeId"]];
    NSDictionary *dicPara = @{@"userId":dicUserIn[@"userId"]};
    
    [HttpTools uploadHttpRequestURL:urlString RequestPram:dicPara UploadData:[self imageData:imageUp] RequestSuccess:^(id respoes) {
        [SVProgressHUD showSuccessWithStatus:@"图片上传成功"];
        [picker dismissViewControllerAnimated:YES completion:nil];
        
    } RequestFaile:^(NSError *erro) {
        [picker dismissViewControllerAnimated:YES completion:nil];
        [SVProgressHUD showInfoWithStatus:@"图片上传失败"];
    } UploadProgress:^(NSProgress *uploadProgress) {
        NSLog(@"%@",uploadProgress);
    }];
}

///压缩图片
-(NSData *)imageData:(UIImage *)myimage{
    NSData *data=UIImageJPEGRepresentation(myimage, 1.0);
    if (data.length>300*1024) {
        if (data.length>1024*1024) {//1M以及以上
            data=UIImageJPEGRepresentation(myimage, 0.1);
        }else if (data.length>512*1024) {//0.5M-1M
            data=UIImageJPEGRepresentation(myimage, 0.5);
        }else if (data.length>300*1024) {//0.25M-0.5M
            data=UIImageJPEGRepresentation(myimage, 0.9);
        }
    }
    return data;
}

///取消选择图片
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

///保存图片到本地相册
-(void)imageTopicSave:(UIImage *)image{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image: didFinishSavingWithError: contextInfo:), nil);
}
///保存到本地手机后回调
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error == nil) {
        // [SVProgressHUD showSuccessWithStatus:@"已成功保存到相册！"];
    }
    else{
        [SVProgressHUD showInfoWithStatus:@"图片未能保存到本地"];
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    //选择科目
    if ([segue.identifier isEqualToString:@"selectSubject"]){
        SelectSubjectViewController *selectSubVc = segue.destinationViewController;
        selectSubVc.arraySubject = _arraySubject;
        selectSubVc.arraySecoundSubject = _arraySecoundSubject;
        selectSubVc.selectSubject = 0;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
