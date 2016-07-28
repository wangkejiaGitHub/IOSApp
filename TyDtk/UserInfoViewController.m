//
//  UserInfoViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/5/31.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "UserInfoViewController.h"
#import "UpdateUserInfoViewController.h"
#import "UptadePwdViewController.h"
#import "ImageEnlargeViewController.h"
@interface UserInfoViewController ()<UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,LoginDelegate,LCActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableViewUser;
@property (nonatomic,strong) NSArray *arrayListName1;
@property (nonatomic,strong) NSArray *arrayListName2;
@property (nonatomic,strong) NSArray *arrayImg1;
@property (nonatomic,strong) NSArray *arrayImg2;
@property (nonatomic,strong) UIImagePickerController *imagePickerG;
//用户信息
@property (nonatomic,strong) NSDictionary *dicUserInfo;
//当前需要修改的参数值
@property (nonatomic,strong) NSString *updateStringCurr;
@property (nonatomic,strong) NSUserDefaults *tyUser;
@property (nonatomic,strong) LoginUser *loginUser;
@end

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _loginUser = [[LoginUser alloc]init];
    _loginUser.delegateLogin = self;
    _tyUser = [NSUserDefaults standardUserDefaults];
    self.title = @"我的信息";
    _arrayListName1 = @[@"用户名",@"手机号",@"邮箱"];
    _arrayImg1 = @[@"u_name",@"u_phone",@"u_emall"];
    _arrayListName2 = @[@"修改密码",@"退出登录"];
    _arrayImg2 = @[@"u_pwd",@"u_out"];
    [SVProgressHUD show];
}
- (void)viewWillAppear:(BOOL)animated{
    [self getUserInfo];
}
///获取用户信息
- (void)getUserInfo{
    NSDictionary *dicUser = [_tyUser objectForKey:tyUserUserInfo];
    [_loginUser getUserInformationoWithJeeId:dicUser[@"jeeId"]];
}
///获取用户信息回调
- (void)getUserInfoIsDictionary:(NSDictionary *)dicUser messagePara:(NSInteger)msgPara{
    ///成功获取信息
    if (msgPara == 1) {
        [SVProgressHUD dismiss];
        _dicUserInfo = dicUser;
        [_tableViewUser reloadData];
    }
    ///获取信息失败(超时)
    else if(dicUser == nil && msgPara == 0){
        [SVProgressHUD dismiss];
        _tableViewUser.userInteractionEnabled = NO;
    }
    else{
        //网络异常
        [SVProgressHUD showErrorWithStatus:@"网络异常"];
        //让当前的tableView失去用户交互
        _tableViewUser.userInteractionEnabled = NO;
    }
}
///登录失败处理，在此不做任何操作
- (void)loginUserErrorString:(NSString *)errorStr{
    NSLog(@"%@",errorStr);
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return _arrayListName1.count + 1;
    }
    return _arrayListName2.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 60;
        }
        return 50;
    }
    return 50;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 40)];
    UILabel *labTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 80, 20)];
    labTitle.font = [UIFont systemFontOfSize:17.0];
    labTitle.textColor = ColorWithRGB(100, 134, 167);
    if (section == 0) {
        UIView *viewL = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 1)];
        viewL.backgroundColor = ColorWithRGB(200, 199, 204);
        [view addSubview:viewL];
        labTitle.text = @"我的信息";
    }
    else{
        labTitle.text = @"系统操作";
    }
    [view addSubview:labTitle];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"imgcell" forIndexPath:indexPath];
            if (_dicUserInfo.allKeys.count > 0) {
                UILabel *labText = (UILabel *)[cell.contentView viewWithTag:10];
                labText.text = @"头像";
                UIImageView *imageVU = (UIImageView *)[cell.contentView viewWithTag:11];
                imageVU.layer.masksToBounds = YES;
                imageVU.layer.cornerRadius = imageVU.frame.size.height/2;
                imageVU.layer.borderWidth = 1;
                imageVU.layer.borderColor = [[UIColor lightGrayColor] CGColor];
                if (![_dicUserInfo[@"headImg"] isEqualToString:@""]) {
                    [imageVU sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",systemHttpsTyUser,_dicUserInfo[@"headImg"]]]];
                }
                else{
                    imageVU.image = [UIImage imageNamed:@"heardNilImg"];
                }
                UIImageView *imgP = (UIImageView *)[cell.contentView viewWithTag:12];
                imgP.layer.masksToBounds = YES;
                imgP.layer.cornerRadius = imgP.bounds.size.width/2;
                imgP.layer.borderWidth = 1;
                imgP.layer.borderColor = [[UIColor lightGrayColor] CGColor];
                imgP.image = [UIImage imageNamed:@"user"];
            }
        }
        else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"usercell" forIndexPath:indexPath];
            UILabel *labText = (UILabel *)[cell.contentView viewWithTag:10];
            if (_dicUserInfo.allKeys.count > 0) {
                UIImageView *imgP = (UIImageView *)[cell.contentView viewWithTag:12];
                imgP.image = [UIImage imageNamed:_arrayImg1[indexPath.row - 1]];
                imgP.layer.masksToBounds = YES;
                imgP.layer.cornerRadius = imgP.bounds.size.width/2;
                imgP.layer.borderWidth = 1;
                imgP.layer.borderColor = [[UIColor lightGrayColor] CGColor];
                labText.text = _arrayListName1[indexPath.row - 1];
                UILabel *labValue = (UILabel *)[cell.contentView viewWithTag:11];
                if (indexPath.row == 1) {
                    labValue.text = _dicUserInfo[@"userName"];
                }
                else if (indexPath.row == 2){
                    if (![_dicUserInfo[@"mobile"]isEqual:[NSNull null]]) {
                        labValue.text =_dicUserInfo[@"mobile"];
                    }
                    else{
                        labValue.text =@"无";
                    }
                    
                }
                else if (indexPath.row == 3){
                    if (![_dicUserInfo[@"email"]isEqual:[NSNull null]]) {
                        labValue.text =_dicUserInfo[@"email"];
                    }
                    else{
                        labValue.text =@"无";
                    }
                }
            }
        }
    }
    else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"usercell" forIndexPath:indexPath];
        UIImageView *imgP = (UIImageView *)[cell.contentView viewWithTag:12];
        imgP.image = [UIImage imageNamed:_arrayImg2[indexPath.row]];
        imgP.layer.masksToBounds = YES;
        imgP.layer.cornerRadius = imgP.bounds.size.width/2;
        imgP.layer.borderWidth = 1;
        imgP.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        UILabel *labText = (UILabel *)[cell.contentView viewWithTag:10];
        labText.text = _arrayListName2[indexPath.row];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //修改头像
    if (indexPath.section == 0&&indexPath.row == 0) {
        ///换头像
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
    //修改基本信息（用户名，手机号，邮箱）
    else if (indexPath.section == 0&&indexPath.row != 0) {
        UILabel *labValue = (UILabel*)[cell.contentView viewWithTag:11];
        _updateStringCurr = labValue.text;
        [self performSegueWithIdentifier:@"updateinfo" sender:[NSString stringWithFormat:@"%ld",indexPath.row]];
    }
    //修改密码
    else if (indexPath.section == 1&&indexPath.row == 0){
        UptadePwdViewController *upVe= [[UptadePwdViewController alloc]initWithNibName:@"UptadePwdViewController" bundle:nil];
        [self.navigationController pushViewController:upVe animated:YES];
    }
    //退出登录
    else if (indexPath.section == 1&&indexPath.row != 0){
        LXAlertView *alertLx = [[LXAlertView alloc]initWithTitle:@"退出登录" message:@"确认退出登录吗？" cancelBtnTitle:@"取消" otherBtnTitle:@"退出" clickIndexBlock:^(NSInteger clickIndex) {
            if (clickIndex == 1) {
                [self logOutUser];
            }
        }];
        [alertLx showLXAlertView];

    }
}
///点击提示框按钮回调
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
    ///如果是拍照先把修剪前的照片保存到本地
    [SVProgressHUD show];
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
        [SVProgressHUD dismiss];
        [picker dismissViewControllerAnimated:YES completion:nil];
        
    } RequestFaile:^(NSError *erro) {
        [picker dismissViewControllerAnimated:YES completion:nil];
        [SVProgressHUD showInfoWithStatus:@"图片上传失败"];
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
        [SVProgressHUD showInfoWithStatus:@"图片未能保存到本地"];
    }
}
///用户退出登录
- (void)logOutUser{
    [SVProgressHUD show];
    NSUserDefaults *tyUser = [NSUserDefaults standardUserDefaults];
    NSDictionary *dicUser = [tyUser objectForKey:tyUserUserInfo];
    ///logout/json
    NSString *urlString = [NSString stringWithFormat:@"%@logout/json?SHAREJSESSIONID=%@",systemHttpsTyUser,dicUser[@"jeeId"]];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicOut = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSInteger codeId = [dicOut[@"code"] integerValue];
        if (codeId == 1) {
            [SVProgressHUD showSuccessWithStatus:@"退出成功"];
            [_tyUser removeObjectForKey:tyUserAccessToken];
            // [_tyUser removeObjectForKey:tyUserClass];
            // [_tyUser removeObjectForKey:tyUserSelectSubject];
            [_tyUser removeObjectForKey:tyUserUserInfo];
            [_tyUser removeObjectForKey:tyUserAccount];
            
            if ([_tyUser objectForKey:tyUserSelectSubject]) {
                ///退出后用默认的账号授权
                [_loginUser empFirstComeAppWithUserId:defaultUserId userCode:defaultUserCode];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            [SVProgressHUD showInfoWithStatus:@"操作失败"];
        }

    } RequestFaile:^(NSError *error) {
        [SVProgressHUD showInfoWithStatus:@"操作失败"];
    }];
}
//传递修改参数
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"updateinfo"]) {
        UpdateUserInfoViewController *updateVc = segue.destinationViewController;
        updateVc.updateInfoPar =[sender integerValue];
        updateVc.stringCurr = _updateStringCurr;
    }
    else if ([segue.identifier isEqualToString:@"updatepwd"]){
        
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
