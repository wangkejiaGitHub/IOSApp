//
//  TableHeardView.m
//  TyDtk
//
//  Created by 天一文化 on 16/5/26.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "TableHeardView.h"

@implementation TableHeardView
-(void)awakeFromNib{
    NSLog(@"awakeFromNib");
    _buttonUserImage.layer.masksToBounds = YES;
    _buttonUserImage.layer.cornerRadius = _buttonUserImage.bounds.size.height/2;
}
@end
