//
//  PaterTopicTableViewCell.m
//  TyDtk
//  试题展示cell类，用于试题信息展示，cell上的控件适配
//  Created by 天一文化 on 16/4/11.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "PaterTopicTableViewCell.h"

@implementation PaterTopicTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (CGFloat)setvalueForCellModel:(NSDictionary *)dic topicIndex:(NSInteger)index{
    if (index == 13) {
        NSLog(@"fsf");
    }
    //判断视图是否有图片
    NSDictionary *dicImg = dic[@"ImageDictionary"];
    NSString *topicTitle = dic[@"title"];
    if (dicImg.allKeys.count>0) {
        NSString *keysFirst = [dicImg.allKeys firstObject];
        NSRange ran = [topicTitle rangeOfString:keysFirst];
        topicTitle = [topicTitle substringToIndex:ran.location-4];
    }
    //题目
    _labTopicTitle.text = topicTitle;
    //试题编号
    _labTopicNumber.text = [NSString stringWithFormat:@"%ld、",index];
    _labNumberWidth.constant = _labTopicNumber.text.length*10+15;
    //试题类型（单选，多选）
    _labTopicType.text = [NSString stringWithFormat:@"(%@)",dic[@"typeName"]];
    CGSize labSize = [_labTopicTitle sizeThatFits:CGSizeMake(_labTopicTitle.frame.size.width, MAXFLOAT)];
    _labTitleHeight.constant = labSize.height;
    //添加选项(添加之前先删除所有手动添加的控件)
    //开始添加
    NSInteger seleNum = [dic[@"SelectNum"] integerValue];
    if (seleNum > 0) {
        NSString *selectOptions = dic[@"options"];
        selectOptions = [selectOptions stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        NSData *dataSting = [selectOptions dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *arrayOptions = [NSJSONSerialization JSONObjectWithData:dataSting options:NSJSONReadingMutableLeaves error:nil];
        
        NSString *arraySelect = [arrayOptions componentsJoinedByString:@""];
        arraySelect = [arraySelect stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n\n"];
        arraySelect = [arraySelect stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n\n"];
        _labSelectOp.text = arraySelect;
        CGSize sizeLabSelect = [_labSelectOp sizeThatFits:CGSizeMake(Scr_Width-30, MAXFLOAT)];
        _labSelectHeight.constant = sizeLabSelect.height;
        
    }
    NSLog(@"topic =========== %ld",index);
    return _labTopicTitle.frame.origin.y + _labTitleHeight.constant + 30+_labSelectHeight.constant;
}
@end
