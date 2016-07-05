//
//  viewSelectSubject.h
//  TyDtk
//
//  Created by 天一文化 on 16/6/24.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SelectSubjectDelegate<NSObject>
- (void)selectSubjectViewDismiss:(NSDictionary *)dicSubject;
@end
@interface viewSelectSubject : UIView
@property (nonatomic,assign) id <SelectSubjectDelegate> delegateSelect;
- (id)initWithFrame:(CGRect)frame arraySubject:(NSArray *)arraySubject className:(NSString *)className;
@end
