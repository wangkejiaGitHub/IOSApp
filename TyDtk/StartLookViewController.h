//
//  StartLookViewController.h
//  TyDtk
//
//  Created by 天一文化 on 16/6/17.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartLookViewController : UIViewController
///需要查看的所有试题数组
//@property (nonatomic,strong)NSArray *arrayLookTopic;
/// 1:(我的收藏试题) 2:(我的错题试题)
@property (nonatomic,assign) NSInteger parameterView;
@property (nonatomic,assign) NSInteger chaperId;
@end
