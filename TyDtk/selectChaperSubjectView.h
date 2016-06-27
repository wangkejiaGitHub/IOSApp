//
//  selectChaperSubjectView.h
//  TyDtk
//
//  Created by 天一文化 on 16/6/27.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>
///主要使用代理方法
#import "viewSelectSubject.h"
@interface selectChaperSubjectView : UIView
- (id)initWithFrame:(CGRect)frame arrayChaperSubject:(NSArray *)arrayZZZ;
@property (nonatomic,assign) id<SelectSubjectDelegate> delegateChaper;
@end
