//
//  NotesTopicViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/6/23.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "NotesTopicViewController.h"
#import "PaperLookViewController.h"
@interface NotesTopicViewController ()
@property (nonatomic,strong) PaperLookViewController *paperVc;
@end

@implementation NotesTopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"笔记试题";

    PaperLookViewController *paperChvc = [[PaperLookViewController alloc]init];
    [self addChildViewController:paperChvc];
}
- (void)viewWillAppear:(BOOL)animated{
    ///////
    [_paperVc.view removeFromSuperview];
    self.navigationController.tabBarController.tabBar.hidden = NO;
}
- (void)viewDidAppear:(BOOL)animated{
    _paperVc = [self.childViewControllers firstObject];
    _paperVc.dicTopic = _dicNoteTopic;
    _paperVc.topicIndex = 1;
    _paperVc.isLastTopic = NO;
    _paperVc.isFromNote = YES;
    _paperVc.view.frame = CGRectMake(0, 64, Scr_Width, Scr_Height);
    [self.view addSubview:_paperVc.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
