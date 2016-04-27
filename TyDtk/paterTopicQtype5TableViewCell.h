//
//  paterTopicQtype5TableViewCell.h
//  TyDtk
//
//  Created by 天一文化 on 16/4/27.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface paterTopicQtype5TableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labNumber;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labNumberWidth;
@property (weak, nonatomic) IBOutlet UILabel *labTopicType;
@property (weak, nonatomic) IBOutlet UIWebView *webViewTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webViewTitleHeight;
@property (weak, nonatomic) IBOutlet UIImageView *imageCollect;
@property (weak, nonatomic) IBOutlet UIButton *buttonCollect;
- (CGFloat)setvalueForCellModel:(NSDictionary *)dic topicIndex:(NSInteger)index;
@end
