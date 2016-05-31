//
//  ActiveVIew.h
//  TyDtk
//
//  Created by 天一文化 on 16/4/7.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ActiveDelegate<NSObject>
///激活码做题
- (void)activeForPapersClick;
///获取激活码
- (void)getActiveMaClick;
@end
@interface ActiveVIew : UIView
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labPrice;
@property (weak, nonatomic) IBOutlet UILabel *labRemark;
@property (weak, nonatomic) IBOutlet UIButton *buttonActive;
@property (weak, nonatomic) IBOutlet UILabel *labGetActiveAcc;
//@property (weak, nonatomic) IBOutlet UILabel *labSubjectNumber;
//
//@property (weak, nonatomic) IBOutlet UILabel *labPersonNumber;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonHeight;
@property (nonatomic,strong) NSString *subjectId;
@property (nonatomic,assign) id<ActiveDelegate> delegateAtive;
- (void)setActiveValue:(NSDictionary *)dicSubject;
@end
