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
@property (nonatomic,strong)  NotesView *noteView;
@property (nonatomic,strong) UIScrollView *scrolViewNotes;
@end

@implementation NotesDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"试题笔记";
    _scrolViewNotes = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64+44, Scr_Width, Scr_Height - 64 -44)];
    _scrolViewNotes.delegate = self;
    _scrolViewNotes.pagingEnabled = YES;
    [self.view addSubview:_scrolViewNotes];
    _scrolViewNotes.contentSize = CGSizeMake(Scr_Width * 3, _scrolViewNotes.bounds.size.height);
    NotesUserViewController *notesUsvc = [[NotesUserViewController alloc]init];
    [self addChildViewController:notesUsvc];
    NotesElseUserViewController *notesElsevc = [[NotesElseUserViewController alloc]init];
    [self addChildViewController:notesElsevc];
    
    NotesUserViewController *userVc = self.childViewControllers[0];
    userVc.questionId = [_questionId integerValue];
    userVc.view.frame = CGRectMake(0, 0, Scr_Width, _scrolViewNotes.bounds.size.height);
    
    NotesElseUserViewController *elseVc = self.childViewControllers[1];
    elseVc.questionId = [_questionId integerValue];
    elseVc.view.frame = CGRectMake(Scr_Width,0, Scr_Width, _scrolViewNotes.bounds.size.height);
    [_scrolViewNotes addSubview:userVc.view];
    [_scrolViewNotes addSubview:elseVc.view];
    
    [self addNotesView];
}
- (void)addNotesView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(Scr_Width*2, 0, Scr_Width, _scrolViewNotes.bounds.size.height)];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [_scrolViewNotes addSubview:view];
    if (!_noteView) {
        _noteView = [[[NSBundle mainBundle] loadNibNamed:@"NotesView" owner:self options:nil]lastObject];
        _noteView.frame = CGRectMake(30, 50, Scr_Width - 60, 200);
        _noteView.layer.masksToBounds = YES;
        _noteView.layer.cornerRadius = 5;
        _noteView.questionId = [_questionId integerValue];
        _noteView.buttonCenter.userInteractionEnabled = NO;
        _noteView.buttonCenter.alpha = 0.4;
        _noteView.isHiden = YES;
        [view addSubview:_noteView];
    }
}
- (IBAction)segmentNotesClick:(UISegmentedControl *)sender {
    [_noteView.textVIewNote resignFirstResponder];
    [_scrolViewNotes setContentOffset:CGPointMake(sender.selectedSegmentIndex*Scr_Width, 0) animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [_noteView.textVIewNote resignFirstResponder];
    NSInteger selectIndex = scrollView.contentOffset.x/Scr_Width;
    _segmentedNots.selectedSegmentIndex = selectIndex;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
