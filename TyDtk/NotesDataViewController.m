//
//  NotesDataViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/5/9.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "NotesDataViewController.h"
#import "NotesUserViewController.h"
@interface NotesDataViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedNots;
@property (weak, nonatomic) IBOutlet UIScrollView *scrolViewNotes;
@end

@implementation NotesDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"试题笔记";
    _segmentedNots.selectedSegmentIndex = 1;
    _scrolViewNotes.contentSize = CGSizeMake(Scr_Width * 3, _scrolViewNotes.bounds.size.height - 64);
    
    NotesUserViewController *notesUsvc = [[NotesUserViewController alloc]init];
    [self addChildViewController:notesUsvc];
    
    NotesUserViewController *userVc = self.childViewControllers[0];
    userVc.questionId = [_questionId integerValue];
    userVc.view.frame = CGRectMake(0, 0, Scr_Width, _scrolViewNotes.bounds.size.height - 64);
    [_scrolViewNotes addSubview:userVc.view];
}
- (IBAction)segmentNotesClick:(UISegmentedControl *)sender {
    NSInteger index = sender.selectedSegmentIndex;
    if (index == 0) {
        NSLog(@"0");
    }
    else if(index == 1){
        NSLog(@"1");
    }
    else if (index == 2){
        NSLog(@"2");
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
