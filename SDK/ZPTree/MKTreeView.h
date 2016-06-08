//
//  MKPeopleHeadTableViewCell.h
//  ChildrenCloud
//
//  Created by 张平 on 15/8/5.
//  Copyright (c) 2015年 Moekee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKPeopleSelectTableCell.h"
#import "MKPeopleCellModel.h"

typedef enum
{
    HaveSelectBtn,
    NoSelectBtn
}ChoseSelectBtn;

static NSString *headCellID = @"headCellID";
static NSString *rowCellID = @"rowCellID";

@class MKTreeView;

@protocol TreeDelegate <NSObject>

- (void)itemSelectInfo:(MKPeopleCellModel *)item;

@end


@interface MKTreeView : UIView<MKPeopleTableCellDelegate>

@property (nonatomic, assign) BOOL isSend;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) NSInteger markNumber;
@property (nonatomic, assign) id<TreeDelegate> delegate;

@property (nonatomic, strong) NSDictionary       *peoplesDic;
@property (nonatomic, strong) KOTreeItem         *item0, *item1_1, *item1_1_1, *item1_1_1_1;
@property (nonatomic, strong) NSMutableArray     *treeItems;
@property (nonatomic, strong) NSMutableArray     *selectedTreeItems;
@property (nonatomic, strong) NSArray            *nodeArray;
@property (nonatomic, strong) NSMutableArray     *groups;
@property (nonatomic, assign) BOOL   isSelect;
@property (nonatomic, assign) BOOL isClicked;

+ (MKTreeView *) instanceView;
- (MKTreeView *) initTreeWithFrame:(CGRect)rect dataArray:(NSArray *) nodeArray haveHiddenSelectBtn:(BOOL)isHidden haveHeadView:(BOOL)haveHeadView isEqualX:(BOOL)isEqualX;

@end
