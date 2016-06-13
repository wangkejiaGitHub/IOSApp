//
//  ExamTableViewCell.h
//  TyDtk
//  显示所有考试信息的tableViewcell
//  Created by 天一文化 on 16/6/13.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ExamCellDelegate<NSObject>
- (void)reFreshExamInfo;
- (void)editExamInfo:(NSDictionary *)dicExam;
@end
@interface ExamTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *viewL;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UIButton *buttonSet;
@property (weak, nonatomic) IBOutlet UILabel *labTime;
@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;
@property (weak, nonatomic) IBOutlet UIButton *buttonEdit;
@property (weak, nonatomic) IBOutlet UILabel *labRemark;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labRemarkHeight;

@property (nonatomic,assign) id <ExamCellDelegate> delegateExam;
- (CGFloat)setCellModelValueWithDictionary:(NSDictionary *)dicExam;
@end
