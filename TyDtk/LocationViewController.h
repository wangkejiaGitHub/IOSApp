//
//  LocationViewController.h
//  TyDtk
//
//  Created by 天一文化 on 16/3/21.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AgainLocationDelegate<NSObject>
- (void)againLocationClick:(NSString *)proVince;
@end
@interface LocationViewController : UIViewController
/**当前定位*/
@property (nonatomic,strong) NSString *currLocation;
@property (nonatomic,weak) id <AgainLocationDelegate> locationDelegate;
@end
