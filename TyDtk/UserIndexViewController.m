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
@interface UserIndexViewController ()<UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,HeardImgDelegate>
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
@end

@implementation UserIndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self viewLoad];
}
- (void)viewLoad{
    _imageViewBg.image = systemBackGrdImg;
    self.navigationController.tabBarItem.selectedImage = [[UIImage imageNamed:@"btm_icon4_hover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _arrayCellTitle = @[@"个人资料",@"当前科目",@"我的考试",@"我的订单",@"做题记录",@"我的收藏",@"我的错题",@"我的笔记"];
    _arrayCellImage = @[@"",@"course",@"quest",@"order",@"learnrecord",@"collect",@"errquests",@"ebook"];
    _tyUser = [NSUserDefaults standardUserDefaults];
    [self addTableViewHeardView];
    /////专业分类科目信息
    _arraySubject = [NSMutableArray array];
    _arraySecoundSubject = [NSMutableArray array];
}
- (void)viewWillAppear:(BOOL)animated{
    [SVProgressHUD dismiss];
    [_tableViewList reloadData];
    //登录是否超时（没有其他定义）
    [self getUserInfo];
    //    [self getUserImage];
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
    if ([_tyUser objectForKey:tyUserUser]) {
        _dicUser = [_tyUser objectForKey:tyUserUser];
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
    
    if (indexPath.section == 0) {
        img.image = [UIImage imageNamed:_arrayCellImage[indexPath.row]];
        labTitle.text = _arrayCellTitle[indexPath.row];
        if (indexPath.row == 1) {
            UILabel *labSiubject = (UILabel *)[cell.contentView viewWithTag:12];
            labSiubject.adjustsFontSizeToFitWidth = YES;
            if ([_tyUser objectForKey:tyUserSelectSubject]) {
                NSDictionary *dicCurrSubject = [_tyUser objectForKey:tyUserSelectSubject];
                labSiubject.text= dicCurrSubject[@"Names"];
            }
            else{
                labSiubject.text = @"未选择科目";
            }
        }
    }
    else{
        img.image = [UIImage imageNamed:@"about"];
        labTitle.text = @"关于我们";
    }
    return  cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // _arrayCellTitle = @[@"个人资料",@"当前科目",@"我的考试",@"我的订单",@"做题记录",@"我的收藏",@"我的错题",@"我的笔记"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if ([self loginTest]) {
            UIStoryboard *Scommon = CustomStoryboard(@"TyCommon");
            if (indexPath.row == 0) {
                //个人资料
                [self performSegueWithIdentifier:@"userinfo" sender:nil];
            }
            else if (indexPath.row == 1){
//                //当前科目
                [self getSubjectClass];

            }
            else if (indexPath.row == 2){
                //我的考试
                if ([_tyUser objectForKey:tyUserSubject]) {
                    [self performSegueWithIdentifier:@"myexam" sender:nil];
                }
                else{
                    [SVProgressHUD showInfoWithStatus:@"还没有选择过相关科目"];
                }
                NSLog(@"1");
            }
            else if (indexPath.row == 3){
                //我的订单
                if ([_tyUser objectForKey:tyUserSubject]) {
                    [self performSegueWithIdentifier:@"myorder" sender:nil];
                }
                else{
                    [SVProgressHUD showInfoWithStatus:@"还没有选择过相关科目"];
                }

                NSLog(@"2");
            }
            //做题记录
            else if (indexPath.row == 4){
                if ([_tyUser objectForKey:tyUserSubject]) {
                    ExerciseRecordViewController *execVc = [Scommon instantiateViewControllerWithIdentifier:@"ExerciseRecordViewController"];
                    [self.navigationController pushViewController:execVc animated:YES];
                }
                else{
                    [SVProgressHUD showInfoWithStatus:@"还没有选择过相关科目"];
                }
             
            }
            //我的收藏
            else if (indexPath.row == 5){
                if ([_tyUser objectForKey:tyUserSubject]) {
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
                if ([_tyUser objectForKey:tyUserSubject]) {
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
                if ([_tyUser objectForKey:tyUserSubject]) {
                    MyCollectViewController *collectVc = [Scommon instantiateViewControllerWithIdentifier:@"MyCollectViewController"];
                    collectVc.parameterView = 3;
                    [self.navigationController pushViewController:collectVc animated:YES];
                }
                else{
                    [SVProgressHUD showInfoWithStatus:@"还没有选择过相关科目"];
                }

            }
        }
        else{
            [SVProgressHUD showInfoWithStatus:@"登录超时或未登录"];
            UIStoryboard *sCommon = CustomStoryboard(@"TyCommon");
            LoginViewController *loginVc =  [sCommon instantiateViewControllerWithIdentifier:@"LoginViewController"];
            loginVc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:loginVc animated:YES];
        }
    }
}


/////获取用户信息
- (void)getUserInfo{
//    [SVProgressHUD show];
    NSDictionary *dicUser = [_tyUser objectForKey:tyUserUserInfo];
    NSString *urlString = [NSString stringWithFormat:@"%@front/user/finduserinfo;JSESSIONID=%@",systemHttpsTyUser,dicUser[@"jeeId"]];
    NSLog(@"%@",urlString);
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicUserInfo = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        if (dicUserInfo != nil) {
            _tableHeardView.labUserName.text = dicUserInfo[@"userName"];
            if (![dicUserInfo[@"headImg"] isEqual:[NSNull null]]) {
                [_tableHeardView.imageHeardImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",systemHttpsTyUser,dicUserInfo[@"headImg"]]]];
            }
            else{
                _tableHeardView.imageHeardImg.image = [UIImage imageNamed:@"imgNullPer"];
            }
            _tableHeardView.imageHeardImg.layer.borderWidth = 1;
            _tableHeardView.imageHeardImg.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        }
        else{
//            [SVProgressHUD showInfoWithStatus:@"登录超时或未登录"];
            _tableHeardView.labUserName.text = @"未登录";
            _tableHeardView.imageHeardImg.image = [UIImage imageNamed:@"imgNullPer"];
//？？        [_tyUser removeObjectForKey:tyUserAccessToken];
//            [_tyUser removeObjectForKey:tyUserClass];
//            [_tyUser removeObjectForKey:tyUserSelectSubject];
//            [_tyUser removeObjectForKey:tyUserSubject];
            [_tyUser removeObjectForKey:tyUserUserInfo];
            [_tyUser removeObjectForKey:tyUserUser];
        }
//        [SVProgressHUD dismiss];
    } RequestFaile:^(NSError *error) {
        [SVProgressHUD showInfoWithStatus:@"异常！"];
    }];
    NSLog(@"%@",dicUser);
}
///获取用户头像
- (void)getUserImage{
    NSDictionary *dicUser = [_tyUser objectForKey:tyUserUser];
    NSString *urlString = [NSString stringWithFormat:@"%@front/user/findheadimg;JSESSIONID=%@&userId=%@&formSystem=902",systemHttpsTyUser,dicUser[@"jeeId"],dicUser[@"userId"]];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSString *string = [[NSString alloc]initWithData:repoes encoding:NSUTF8StringEncoding];
        NSLog(@"%@",string);
        if (string.length > 50) {
            [self performSegueWithIdentifier:@"login" sender:nil];
        }
    } RequestFaile:^(NSError *error) {

    }];
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
        ///换头像
        UIAlertController *alertImg = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *acPhoto = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self persentImagePicker:1];
        }];
        
        UIAlertAction *acCream = [UIAlertAction actionWithTitle:@"手机相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self persentImagePicker:0];
        }];
        
        UIAlertAction *acLook = [UIAlertAction actionWithTitle:@"查看大图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *acCan = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertImg addAction:acPhoto];
        [alertImg addAction:acCream];
        [alertImg addAction:acLook];
        [alertImg addAction:acCan];
        [self.navigationController presentViewController:alertImg animated:YES completion:nil];
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
            
        }
        else if ([self isFirstResponder]){
            
        }
        _imagePickerG.sourceType = UIImagePickerControllerSourceTypeCamera;
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
    [picker dismissViewControllerAnimated:YES completion:nil];
        
    } RequestFaile:^(NSError *erro) {
        NSLog(@"%@",erro);
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
//        [SVProgressHUD showSuccessWithStatus:@"已成功保存到相册！"];
    }
    else{
        [SVProgressHUD showInfoWithStatus:@"图片未能保存到本地！"];
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
