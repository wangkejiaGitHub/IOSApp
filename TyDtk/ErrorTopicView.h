//
//  ErrorTopicView.h
//  TyDtk
//
//  Created by 天一文化 on 16/4/25.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ErrorViewDelegate<NSObject>
- (void)viewCellClick:(NSString *)selectType;
@end
@interface ErrorTopicView : UIView
- (id)initWithFrame:(CGRect)frame errorTypeArray:(NSArray *)array;
@property (nonatomic,assign) id <ErrorViewDelegate> delegateViewError;
@end
