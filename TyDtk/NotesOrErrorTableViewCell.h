//
//  NotesOrErrorTableViewCell.h
//  TyDtk
//
//  Created by 天一文化 on 16/4/19.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ErrorDelegate<NSObject>
- (void)submitError:(NSDictionary *)dicError;
@end
@interface NotesOrErrorTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextView *textVIew;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIButton *buttonClear;
@property (nonatomic,assign) NSInteger questionId;
@property (nonatomic,assign) NSInteger isNoteses;
@property (nonatomic,assign) id <ErrorDelegate> delegateError;
@end
