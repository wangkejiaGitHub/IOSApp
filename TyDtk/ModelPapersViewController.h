//
//  ModelPapersViewController.h
//  TyDtk
//
//  Created by 天一文化 on 16/4/6.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DataDoneDelegatePater<NSObject>
- (void)doneBlockPater;
@end
@interface ModelPapersViewController : UIViewController
@property (nonatomic,strong) NSString *subjectId;
@property (nonatomic,assign) id <DataDoneDelegatePater> deledateData;
@end
