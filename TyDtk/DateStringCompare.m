//
//  DateStringCompare.m
//  TyDtk
//  过去时间与现在时间差值
//  Created by 天一文化 on 16/6/6.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "DateStringCompare.h"

@implementation DateStringCompare
+(NSString *)dataStringCompareWithNowTime:(NSString *)dateString{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];//设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];
    //设置一个字符串的时间
    //    NSMutableString *datestring = [NSMutableString stringWithFormat:@"%@",@"20141202052740"];
    //注意 如果20141202052740必须是数字，如果是UNIX时间，不需要下面的插入字符串。
    //    [datestring insertString:@"-" atIndex:4];
    //    [datestring insertString:@"-" atIndex:7];
    //    [datestring insertString:@" " atIndex:10];
    //    [datestring insertString:@":" atIndex:13];
    //    [datestring insertString:@":" atIndex:16];
//    NSLog(@"datestring==%@",dateString);
    NSDateFormatter * dm = [[NSDateFormatter alloc]init];
    //指定输出的格式   这里格式必须是和上面定义字符串的格式相同，否则输出空
    [dm setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSDate * newdate = [dm dateFromString:dateString];
    long dd = (long)[datenow timeIntervalSince1970] - [newdate timeIntervalSince1970];
    NSString *timeString=@"";
//    NSLog(@"%ld",dd/86400);
    if (dd/3600<1){
        timeString = [NSString stringWithFormat:@"%ld", dd/60];
        timeString=[NSString stringWithFormat:@"%@分钟前", timeString];
    }
    if (dd/3600>1&&dd/86400<1){
        timeString = [NSString stringWithFormat:@"%ld", dd/3600];
        timeString=[NSString stringWithFormat:@"%@小时前", timeString];
    }
    if (dd/86400>= 1){
        timeString = [NSString stringWithFormat:@"%ld", dd/86400];
        timeString=[NSString stringWithFormat:@"%@天前", timeString];
    }
    return timeString;
}
@end
