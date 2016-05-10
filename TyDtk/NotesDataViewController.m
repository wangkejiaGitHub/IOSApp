//
//  NotesDataViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/5/9.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "NotesDataViewController.h"
#import "NotesUserViewController.h"
#import "NotesElseUserViewController.h"
@interface NotesDataViewController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedNots;
@property (weak, nonatomic) IBOutlet UIScrollView *scrolViewNotes;
@end

@implementation NotesDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"试题笔记";
    _scrolViewNotes.contentSize = CGSizeMake(Scr_Width * 3, _scrolViewNotes.bounds.size.height - 64);
    
    NotesUserViewController *notesUsvc = [[NotesUserViewController alloc]init];
    [self addChildViewController:notesUsvc];
    NotesElseUserViewController *notesElsevc = [[NotesElseUserViewController alloc]init];
    [self addChildViewController:notesElsevc];
    
    NotesUserViewController *userVc = self.childViewControllers[0];
    userVc.questionId = [_questionId integerValue];
    userVc.view.frame = CGRectMake(0, 0, Scr_Width, _scrolViewNotes.bounds.size.height - 64);
    
    NotesElseUserViewController *elseVc = self.childViewControllers[1];
    elseVc.questionId = [_questionId integerValue];
    elseVc.view.frame = CGRectMake(Scr_Width,0, Scr_Width, _scrolViewNotes.bounds.size.height - 64);
    [_scrolViewNotes addSubview:userVc.view];
    [_scrolViewNotes addSubview:elseVc.view];
}
- (IBAction)segmentNotesClick:(UISegmentedControl *)sender {
    [_scrolViewNotes setContentOffset:CGPointMake(sender.selectedSegmentIndex*Scr_Width, 0) animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger selectIndex = scrollView.contentOffset.x/Scr_Width;
    _segmentedNots.selectedSegmentIndex = selectIndex;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
