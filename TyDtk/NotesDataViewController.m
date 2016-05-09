//
//  NotesDataViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/5/9.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "NotesDataViewController.h"

@interface NotesDataViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedNots;
@property (weak, nonatomic) IBOutlet UIScrollView *scrolViewNotes;

@end

@implementation NotesDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)segmentNotesClick:(UISegmentedControl *)sender {
    NSInteger index = sender.selectedSegmentIndex;
    if (index == 0) {
        
    }
    else if(index == 1){
        
    }
    else if (index == 2){
        
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
