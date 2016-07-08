//
//  ErrorView.h
//  TyDtk
//
//  Created by 天一文化 on 16/4/28.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface ErrorView : UIView
@property (weak, nonatomic) IBOutlet UIButton *buttonSubmit;
@property (weak, nonatomic) IBOutlet UIButton *buttonClear;
@property (weak, nonatomic) IBOutlet UIButton *buttonCenter;
@property (weak, nonatomic) IBOutlet UITextView *textViewError;
@property (weak, nonatomic) IBOutlet UIButton *buttonErrorType;

@property (nonatomic,assign) NSInteger questionId;
@end
