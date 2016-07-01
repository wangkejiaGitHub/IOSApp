//
//  ActiveSubjectView.h
//  TyDtk
//
//  Created by 天一文化 on 16/7/1.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ActiveSubjectDelegate<NSObject>
///直接购买商品(PayParameter:0：激活，1：购买)
- (void)paySubjectProductWithPayParameter:(NSInteger)PayParameter;
@end

@interface ActiveSubjectView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labPrice;
@property (weak, nonatomic) IBOutlet UILabel *labRemark;
@property (weak, nonatomic) IBOutlet UIButton *buttonActive;
@property (weak, nonatomic) IBOutlet UIButton *buttonPay;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeight;

@property (nonatomic,strong) NSString *subjectId;
@property (nonatomic,assign) id<ActiveSubjectDelegate> delegateAtive;
- (void)setActiveValue:(NSDictionary *)dicSubject;
@end
