//
//  ViewNullData.h
//  TyDtk
//  数据为空时显示的view层
//  Created by 天一文化 on 16/3/25.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ViewNullDataDelegate<NSObject>
/** 
 点击屏幕触发事件
 */
- (void)nullDataTapGestClick;
@end
@interface ViewNullData : UIView
@property (nonatomic,assign) id <ViewNullDataDelegate> delegateNullData;
/**
 showText:数据为空时需要在屏幕上显示的文字，如果为Nil，默认“点我刷新数据”
 */
- (id)initWithFrame:(CGRect)frame showText:(NSString *)showText;
@end
