//
//  PaterTopicQtype6TableViewCell.m
//  TyDtk
//
//  Created by 天一文化 on 16/4/19.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "PaterTopicQtype6TableViewCell.h"

@implementation PaterTopicQtype6TableViewCell

- (void)awakeFromNib {
    // Initialization code
    _webViewTitle.backgroundColor = [UIColor clearColor];
    _webViewTitle.scrollView.scrollEnabled = NO;
    _webViewTitle.opaque = NO;
}

- (CGFloat)setvalueForCellModel:(NSDictionary *)dic topicIndex:(NSInteger)index{
    CGFloat allowRet = 0;
    
    //判断视图是否有图片

    NSDictionary *dicImg = dic[@"ImageDictionary"];
    NSString *topicTitle = dic[@"title"];
    topicTitle = [topicTitle stringByReplacingOccurrencesOfString:@"\n\r" withString:@"\n"];
    topicTitle = [topicTitle stringByReplacingOccurrencesOfString:@"\n\n" withString:@"<br/>"];
    topicTitle = [topicTitle stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
    topicTitle = [topicTitle stringByReplacingOccurrencesOfString:@" " withString:@""];
//    for (int i =0 ; i<4; i++) {
//        topicTitle = [topicTitle stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//        topicTitle = [topicTitle stringByReplacingOccurrencesOfString:@"\t" withString:@""];
//        topicTitle = [topicTitle stringByReplacingOccurrencesOfString:@"\r" withString:@""];
//    }
    if (dicImg.allKeys.count>0) {
        NSString *keysFirst = [dicImg.allKeys firstObject];
        NSRange ran = [topicTitle rangeOfString:keysFirst];
        topicTitle = [topicTitle substringToIndex:ran.location-4];
    }
    //主要针对医学题目进行适配
    NSInteger leng = topicTitle.length;
    if ([topicTitle rangeOfString:@"A"].location == 0 && [topicTitle rangeOfString:@"B"].length>0) {
        if (leng>80) {
            _webTitleHeight.constant = 153;
        }
        else{
            _webTitleHeight.constant = 130;
        }
    }
    else{
        //题目
        UILabel *labTitleTest = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, Scr_Width-30, 0)];
        labTitleTest.text = topicTitle;
        NSLog(@"%@ ====== %ld",topicTitle,topicTitle.length);
        labTitleTest.numberOfLines = 0;
        labTitleTest.font = [UIFont systemFontOfSize:19];
        if (Scr_Width > 320) {
            labTitleTest.font = [UIFont systemFontOfSize:18.5];
        }
        CGSize labSize = [labTitleTest sizeThatFits:CGSizeMake(labTitleTest.frame.size.width, MAXFLOAT)];
        _webTitleHeight.constant = labSize.height;

    }
    
    [_webViewTitle loadHTMLString:topicTitle baseURL:nil];
    if (Scr_Width > 330) {
        _webTitleHeight.constant = _webTitleHeight.constant+20;
    }

    //试题编号
    _labNumber.text = [NSString stringWithFormat:@"%ld、",index];
    _labNumberWidth.constant = _labNumber.text.length*10+15;
    //试题类型（案例分析）
    _labTitleType.text = [NSString stringWithFormat:@"(%@)",dic[@"typeName"]];
    
    allowRet = _webViewTitle.frame.origin.y+_webTitleHeight.constant+50;
    return allowRet;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
