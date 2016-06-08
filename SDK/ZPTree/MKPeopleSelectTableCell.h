//
//  ViewController.m
//  MKTreeTest
//
//  Created by 张平 on 15/12/24.
//  Copyright © 2015年 zhangping. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "BDDynamicTreeNode.h"
#import "RATreeNodeInfo.h"

@class KOTreeItem;
@class MKPeopleSelectTableCell;

typedef enum
{
    CellType_Department, // 目录
    CellType_Group       //细节、具体信息
}CellType;

@protocol MKPeopleTableCellDelegate <NSObject>

- (void)treeTableViewCell:(MKPeopleSelectTableCell *)cell tapIconWithTreeItem:(id)item WithInfo:(RATreeNodeInfo *)treeNodeInfo;

@end

@interface MKPeopleSelectTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *chooseButton;     /**<选择按钮*/
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;        /**<Cell标题*/
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;/**<右侧蓝色箭头*/
@property (weak, nonatomic) IBOutlet UIView *lineView;

@property (assign, nonatomic) BOOL select;
@property (strong, nonatomic) id item;                           /**<相当于cell的indexPath*/
@property (strong, nonatomic) RATreeNodeInfo *treeNodeInfo;      /**<树的节点信息*/
@property (assign, nonatomic) id<MKPeopleTableCellDelegate> delegate;

- (IBAction)selectPeople:(UIButton *)sender;//选人方法

@end
