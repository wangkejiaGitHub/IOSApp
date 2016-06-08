//
//  MKPeopleHeadTableViewCell.h
//  ChildrenCloud
//
//  Created by 张平 on 15/8/5.
//  Copyright (c) 2015年 Moekee. All rights reserved.
//

#import "MKTreeView.h"
#import "MKPeopleHeadTableViewCell.h"
#import "KOTreeItem.h"
#import "RATreeView.h"
#import "MKPeopleSelectTableCell.h"
#import "MKSelectArray.h"

//屏幕大小
#define SCREEN                     [[UIScreen mainScreen]bounds]
#define SCREEN_WIDTH               [[UIScreen mainScreen]bounds].size.width

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define ARROW_IMG   1070
#define RIGHT_IMG   1080
#define SELECT_BTN  1090
#define BOOKMARK_WORD_LIMT  250

@interface MKTreeView () <RATreeViewDelegate, RATreeViewDataSource>

@property (strong, nonatomic) NSArray *data;
@property (strong, nonatomic) id expanded;
@property (strong, nonatomic) RATreeView *treeView;
@property (strong, nonatomic) NSMutableArray *selectedArray; /**<存放全选*/
@property (strong, nonatomic) id item;
@property (strong, nonatomic) RATreeNodeInfo *treeInfo;
@property (assign, nonatomic) BOOL isFail;
@property (assign, nonatomic) BOOL isFirst;
@property (assign, nonatomic) BOOL isSelectBtn;
@property (assign, nonatomic) BOOL haveHeadView;
@property (assign, nonatomic) BOOL isEqualX;

@end

@implementation MKTreeView

@synthesize treeItems;
@synthesize selectedTreeItems;
@synthesize item0, item1_1, item1_1_1, item1_1_1_1;

+ (MKTreeView *)instanceView
{
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"MKTreeView" owner:nil options:nil];
    return [nibs objectAtIndex:0];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (MKTreeView *) initTreeWithFrame:(CGRect)rect dataArray:(NSArray *)nodeArray haveHiddenSelectBtn:(BOOL)isHidden haveHeadView:(BOOL)haveHeadView isEqualX:(BOOL)isEqualX
{
    self.frame = rect;
    self.selectedArray = [[NSMutableArray alloc]init];
    self.treeItems     = [[NSMutableArray alloc] init];
    self.groups = [[NSMutableArray alloc]init];
    
    CGFloat treeViewY;
    if (haveHeadView) {
        treeViewY = 0;
    }
    else
    {
        treeViewY = - 40;
    }
    _treeView = [[RATreeView alloc] initWithFrame:CGRectMake(0, treeViewY, rect.size.width, rect.size.height)];
    
    
    UINib *headNib = [UINib nibWithNibName:@"MKPeopleHeadTableViewCell" bundle:nil];
    UINib *rowNib = [UINib nibWithNibName:@"MKPeopleSelectTableCell" bundle:nil];
    [_treeView registerNib:headNib forCellReuseIdentifier:headCellID];
    [_treeView registerNib:rowNib forCellReuseIdentifier:rowCellID];
    
    for (UIView *subS in _treeView.subviews)
    {
        if ([subS isKindOfClass:[UITableView class]])
        {
            subS.frame = CGRectMake(0, 0, SCREEN_WIDTH, _treeView.frame.size.height);
        }
    }
    
    _treeView.delegate   = self;
    _treeView.dataSource = self;
    _treeView.separatorStyle = RATreeViewCellSeparatorStyleNone;
    [_treeView registerNib:[UINib nibWithNibName:@"MKPeopleSelectTableCell" bundle:nil]forCellReuseIdentifier:rowCellID];
    [self addSubview:_treeView];
    
    self.nodeArray    = nodeArray;
    self.isSelectBtn  = isHidden;
    self.haveHeadView = haveHeadView;
    self.isEqualX     = isEqualX;
    
    [self treeDataSetting];
    if ([MKPeopleCellModel sharedPeople].node.count == 0)
    {
        self.isFirst = YES;
    }
    return self;

}

- (void)treeDataSetting
{
    //根据自己的的数据源进行解析
    NSMutableArray *mutableOne = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.nodeArray.count; i ++)
    {
        NSArray *modelOneArray = [[self.nodeArray objectAtIndex:i] valueForKey:@"node"];
        NSMutableArray *mutabletwo = [[NSMutableArray alloc] init];
        
        for (int j = 0; j < modelOneArray.count; j ++)
        {
            NSArray *modelTwoArray = [[modelOneArray objectAtIndex:j] valueForKey:@"node"];
            NSMutableArray *mutableThree = [[NSMutableArray alloc] init];
            for (int k = 0; k < modelTwoArray.count; k ++)
            {
                NSArray *modelThreeArray = [[modelTwoArray objectAtIndex:k] valueForKey:@"node"];
                
                if (modelThreeArray.count == 0)
                {
                    MKPeopleCellModel *modelFour = [MKPeopleCellModel dataObjectWithName:[[modelTwoArray objectAtIndex:k] valueForKey:@"Names"] children:nil];
                    modelFour.mobile = [[modelTwoArray objectAtIndex:k] valueForKey:@"Id"];
                    modelFour.mobileID = [[modelTwoArray objectAtIndex:k] valueForKey:@"Id"];
                    [mutableThree addObject:modelFour];
                }
                else
                {
                    NSMutableArray *mutableFour = [[NSMutableArray alloc] init];
                    for (int l = 0; l < modelThreeArray.count; l ++)
                    {
                        MKPeopleCellModel *modelFour = [MKPeopleCellModel dataObjectWithName:[[modelThreeArray objectAtIndex:l] valueForKey:@"Names"] children:nil];
                        modelFour.mobile = [[modelThreeArray objectAtIndex:l] valueForKey:@"Id"];
                        modelFour.mobileID = [[modelThreeArray objectAtIndex:l] valueForKey:@"Id"];
                        [mutableFour addObject:modelFour];
                    }
                    MKPeopleCellModel *modelThree = [MKPeopleCellModel dataObjectWithName:[[modelTwoArray objectAtIndex:k] valueForKey:@"Names"] children:mutableFour];
                    [mutableThree addObject:modelThree];
                }
            }
            MKPeopleCellModel *modelTwo = [MKPeopleCellModel dataObjectWithName:[[modelOneArray objectAtIndex:j] valueForKey:@"Names"] children:mutableThree];
            [mutabletwo addObject:modelTwo];
        }
        MKPeopleCellModel *modelOne = [MKPeopleCellModel dataObjectWithName:[[self.nodeArray objectAtIndex:i] valueForKey:@"Names"] children:mutabletwo];
        [mutableOne addObject:modelOne];
    }
    
    MKPeopleCellModel *model = [MKPeopleCellModel dataObjectWithName:@"选择收件人" children:mutableOne];
    self.data = [NSArray arrayWithObject:model];
    [_treeView reloadData];
}

#pragma mark TreeView Data Source

- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    MKPeopleHeadTableViewCell *headCell = [_treeView dequeueReusableCellWithIdentifier:headCellID];
    MKPeopleSelectTableCell *rowCell = [_treeView dequeueReusableCellWithIdentifier:rowCellID];
    
    if (headCell == nil)
    {
        headCell = [[MKPeopleHeadTableViewCell alloc] init];
    }
    if (rowCell == nil) {
        rowCell = [[MKPeopleSelectTableCell alloc] init];
    }
    
    if (!_haveHeadView) {
        headCell.choseConnectImage.hidden = YES;
        headCell.choseConnectLabel.hidden = YES;
        headCell.choseCountLabel.hidden   = YES;
        headCell.lineView.hidden          = YES;
        headCell.backgroundColor = [UIColor clearColor];
    }
    
    headCell.selectionStyle = UITableViewCellSelectionStyleNone;
    rowCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    headCell.choseCountLabel.text = [NSString stringWithFormat:@"(%ld)",[[MKSelectArray sharedInstance] initObject].selectArray.count];
    //标题
    if (_isEqualX) {
        rowCell.titleLabel.frame = CGRectMake(40 + 0 * treeNodeInfo.treeDepthLevel, 7, 190, 20);
    }
    else
    {
        rowCell.titleLabel.frame = CGRectMake(40 + 15 * treeNodeInfo.treeDepthLevel, 7, 190, 20);
    }
    
    rowCell.titleLabel.font = [UIFont systemFontOfSize:13];
    rowCell.titleLabel.textColor = [UIColor colorWithRed:0x33/255.f green:0x33/255.f blue:0x33/255.f alpha:1.0f];
    rowCell.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    //去除掉首尾的空白字符和换行字符
    NSString *nameStr = ((MKPeopleCellModel *)item).name;
    nameStr = [nameStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    nameStr = [nameStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    nameStr = [nameStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSMutableString *titleStr = [NSMutableString stringWithString:nameStr];
    
    rowCell.titleLabel.text = titleStr;
    
    if (!self.isSelect)
    {
//        headCell.choseConnectImage.image = [UIImage imageNamed:@"ico_fold"];
    }
    else
    {
        [UIView animateWithDuration:0.f animations:^{
            headCell.choseConnectImage.transform = CGAffineTransformMakeRotation(M_PI * (180)/180);}];
    }
    headCell.choseConnectImage.tag = ARROW_IMG;
    
    
    //左侧勾选按钮
    if (!self.isSelectBtn) {
        rowCell.chooseButton.frame = CGRectMake(CGRectGetMinX(rowCell.titleLabel.frame)- 27 - 5, -2, 20, 20);
        rowCell.chooseButton.center = CGPointMake(rowCell.chooseButton.center.x, rowCell.titleLabel.center.y);
    }
    else
    {
        if (_isEqualX) {
            rowCell.titleLabel.frame = CGRectMake(10 + 0 * treeNodeInfo.treeDepthLevel, 7, 190, 20);
        }
        else
        {
            rowCell.titleLabel.frame = CGRectMake(10 + 25 * treeNodeInfo.treeDepthLevel, 7, 190, 20);
        }
        rowCell.chooseButton.hidden = YES;
    }
    
    //右侧三角箭头图标
    rowCell.arrowImageView.frame = CGRectMake(self.frame.size.width - 40, 10, 17, 17);
    if (treeNodeInfo.expanded == YES)
    {
        rowCell.arrowImageView.image = [UIImage imageNamed:@"ico_blue_arrow_up"];
    }
    else
    {
        rowCell.arrowImageView.image = [UIImage imageNamed:@"ico_blue_arrow"];
    }
    
    rowCell.arrowImageView.tag   = RIGHT_IMG;
    
    if (treeNodeInfo.treeDepthLevel == 4) {
        rowCell.arrowImageView.hidden = YES;
    }
    else
    {
        rowCell.arrowImageView.hidden = NO;
    }
    rowCell.item = item;
    rowCell.treeNodeInfo = treeNodeInfo;
    rowCell.delegate = self;
    if (treeNodeInfo.positionInSiblings == 0 && treeNodeInfo.treeDepthLevel == 0){
        return headCell;
    }
    
    //初始化的时候检查cell有没有被勾选
    MKPeopleCellModel *model = item;
    if (self.isSend)
    {
        model.isCheck = NO;
        rowCell.select = NO;
    }
    else
    {
        rowCell.select = model.isCheck;
    }
    return rowCell;
}

#pragma mark MKPeopleTableCellDelegate
- (void)treeTableViewCell:(MKPeopleSelectTableCell *)cell tapIconWithTreeItem:(id)item WithInfo:(RATreeNodeInfo *)treeNodeInfo
{
    self.isSend = NO;
    cell.select = !cell.select;
    [self recursion:treeNodeInfo index:treeNodeInfo.positionInSiblings treeTableViewCell:cell];
    
    if (cell.select == NO)
    {
        [self parent:treeNodeInfo treeTableViewCell:cell treeLever:treeNodeInfo.treeDepthLevel];
    }
    
    MKPeopleCellModel *model = treeNodeInfo.parent.item;
    NSArray *childArray = [model peoples];
    NSInteger selectCount = 0;

    for (int i = 0; i < childArray.count; i ++)
    {
        MKPeopleCellModel *model = [childArray objectAtIndex:i];
        if (model.isCheck)
        {
            selectCount ++;
        }
        if (selectCount == childArray.count)
        {
            [self childChangeParent:treeNodeInfo treeTableViewCell:cell treeLever:treeNodeInfo.treeDepthLevel childArray:childArray selectCount:selectCount];
        }
    }
    [self.treeView reloadData];
}

#pragma mark - Child节点选择改变父节点
- (id)childChangeParent:(RATreeNodeInfo*)treeNodeInfo treeTableViewCell:(MKPeopleSelectTableCell *)cell treeLever:(NSInteger)lever childArray:(NSArray *)childArray selectCount:(NSInteger)selectCount
{
    MKPeopleCellModel *model = treeNodeInfo.parent.item;
    if ([model.name isEqualToString:@"选择收件人"]) {
        return model.name;
    }
    else
    {
        if (selectCount != childArray.count)
        {
            return model.name;
        }
        else
        {
            MKPeopleCellModel *model = treeNodeInfo.parent.item;
            model.isCheck = cell.select;
            NSInteger selectCount = 0;
            
            MKPeopleCellModel *parentModel = [treeNodeInfo.parent parent].item;
            for (int i = 0; i < [parentModel peoples].count; i ++)
            {
                MKPeopleCellModel *childModel = [[parentModel peoples] objectAtIndex:i];
                if (childModel.isCheck)
                {
                    selectCount ++;
                }
            }
            [self childChangeParent:treeNodeInfo.parent treeTableViewCell:cell treeLever:(lever - 1) childArray:[parentModel peoples] selectCount:selectCount];
            return treeNodeInfo.parent;
        }

    }
    return nil;
}


#pragma maek - Parent节点
- (id)parent:(RATreeNodeInfo*)treeNodeInfo treeTableViewCell:(MKPeopleSelectTableCell *)cell treeLever:(NSInteger)lever
{
    MKPeopleCellModel *model = treeNodeInfo.parent.item;
    if ([model.name isEqualToString:@"选择收件人"]) {
        return model.name;
    }
    else
    {
        MKPeopleCellModel *model = treeNodeInfo.parent.item;
        model.isCheck = cell.select;
        [self parent:treeNodeInfo.parent treeTableViewCell:cell treeLever:(lever - 1)];
        return treeNodeInfo.parent;
    }
    return nil;
}

#pragma mark 递归
-(id)recursion:(RATreeNodeInfo*)treeNodeInfo index:(NSInteger)index treeTableViewCell:(MKPeopleSelectTableCell *)cell
{
//    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    if ([treeNodeInfo children].count == 0)
    {
        MKPeopleCellModel *model = treeNodeInfo.item;
        model.isCheck = cell.select;
        if (model.mobile != nil)
        {
            if (cell.select == YES && (treeNodeInfo.treeDepthLevel == 4 || treeNodeInfo.treeDepthLevel == 3)) {
                if (![[[MKSelectArray sharedInstance] initObject].selectArray containsObject:[NSDictionary dictionaryWithObjectsAndKeys:model.mobileID, @"Id", model.mobile, @"Id", nil]]) {
                    [[[MKSelectArray sharedInstance] initObject].selectArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:model.mobileID, @"Id", model.mobile, @"Id", nil]];
                }
            }
            else if (cell.select == NO && (treeNodeInfo.treeDepthLevel == 4 || treeNodeInfo.treeDepthLevel == 3))
            {
                [[[MKSelectArray sharedInstance] initObject].selectArray removeObject:[NSDictionary dictionaryWithObjectsAndKeys:model.mobileID, @"Id", model.mobile, @"Id", nil]];
            }
        }
        self.treeView.isClose = YES;
        NSLog(@"%@",[[MKSelectArray sharedInstance] initObject].selectArray);
        return [treeNodeInfo.item name]; //RADataObject  叶子节点  要 return 节点
    }
    else
    {
        MKPeopleCellModel *model = treeNodeInfo.item;
        model.isCheck = cell.select;
        NSMutableArray * datas = [[NSMutableArray alloc]init];
        NSArray * dics = [treeNodeInfo children];
        for (RATreeNodeInfo *child in dics)
        {
            [datas addObject:[self recursion:child index:((NSInteger)index + 1) treeTableViewCell:cell]];
        }
        return [treeNodeInfo children];//RADataObject  根节点   要return
    }
    return nil;
}

- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item
{
    if (item == nil) {
        return [self.data count];
    }
    MKPeopleCellModel *data = item;
    return [data.peoples count];
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item
{
    MKPeopleCellModel *data = item;
    if (item == nil) {
        return [self.data objectAtIndex:index];
    }
    return [data.peoples objectAtIndex:index];
}

#pragma mark TreeView Delegate methods
- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    return 40;
}

- (NSInteger)treeView:(RATreeView *)treeView indentationLevelForRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    return 3 * treeNodeInfo.treeDepthLevel;
}

#pragma mark TreeView Delegate methods
- (BOOL)treeView:(RATreeView *)treeView shouldExpandRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    if (treeNodeInfo.children.count) {
        return YES;
    }
    return NO;
}

- (BOOL)treeView:(RATreeView *)treeView shouldItemBeExpandedAfterDataReload:(id)item treeDepthLevel:(NSInteger)treeDepthLevel
{
    if (_haveHeadView) {
        if ([item isEqual:self.expanded]) {
            return YES;
        }
        return NO;
    }
    else
    {
        if (treeDepthLevel == 0) {
            return YES;
        }
        return NO;
    }
}

- (void)treeView:(RATreeView *)treeView willDisplayCell:(UITableViewCell *)cell forItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    cell.backgroundColor = UIColorFromRGB(0xF7F7F7);
}

- (void)treeView:(RATreeView *)treeView didSelectRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    if (treeNodeInfo.positionInSiblings == 0 &&treeNodeInfo.treeDepthLevel == 0)//若是选择收件栏cell，旋转图标
    {
        UIImageView *imgView = (UIImageView *)[self viewWithTag:ARROW_IMG];
        if(treeNodeInfo.expanded){
            self.isSelect = NO;
            [UIView animateWithDuration:0.5f animations:^{
                imgView.transform = CGAffineTransformMakeRotation(M_PI * (0)/180);}];
        }
        else
        {
            self.isSelect = YES;
            UIImageView *imgView = (UIImageView *)[self viewWithTag:ARROW_IMG];
            [UIView animateWithDuration:0.5f animations:^{
                    imgView.transform = CGAffineTransformMakeRotation(M_PI * (180)/180);}];
        }
    }
    else//若不是，旋转选中的Cell的右侧图标
    {
        MKPeopleSelectTableCell *cell = (MKPeopleSelectTableCell *)[treeView cellForItem:item];
        if (treeNodeInfo.expanded == YES)
        {
            cell.arrowImageView.image = [UIImage imageNamed:@"ico_blue_arrow"];
        }
        else
        {
            cell.arrowImageView.image = [UIImage imageNamed:@"ico_blue_arrow_up"];
            if (treeNodeInfo.children.count == 0)
            {
                if ([self.delegate respondsToSelector:@selector(itemSelectInfo:)]) {
                    [self.delegate itemSelectInfo:item];
                }
            }
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
