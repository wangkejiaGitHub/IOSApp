//
//  MZView.m
//  TyDtk
//
//  Created by 天一文化 on 16/3/25.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "MZView.h"

@implementation MZView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addMengZengForView];
    }
    return self;
}
- (void)addMengZengForView{
    self.backgroundColor = ColorWithRGBWithAlpp(0, 0, 0, 0.3);
}
@end
