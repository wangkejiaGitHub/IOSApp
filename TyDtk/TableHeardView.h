//
//  TableHeardView.h
//  TyDtk
//
//  Created by 天一文化 on 16/5/26.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol HeardImgDelegate<NSObject>
///imgParameter:0、未登录（跳转到登录界面）1、已登录（换头像）
- (void)ImgButtonClick:(NSInteger)imgParameter;
@end
@interface TableHeardView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *imageViewBack;
@property (weak, nonatomic) IBOutlet UIImageView *imageHeardImg;
@property (weak, nonatomic) IBOutlet UILabel *labUserName;
@property (nonatomic,assign) id<HeardImgDelegate> delegateImg;
@end
