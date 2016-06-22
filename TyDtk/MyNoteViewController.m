//
//  MyNoteViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/6/22.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "MyNoteViewController.h"

@interface MyNoteViewController ()
@property (nonatomic,strong) NSUserDefaults *tyUser;
@property (nonatomic,strong) NSString *accessToken;

@property (nonatomic,assign) NSInteger pageCurr;
@property (nonatomic,assign) NSInteger pageCount;
@end

@implementation MyNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _tyUser = [NSUserDefaults standardUserDefaults];
    _tyUser = [_tyUser objectForKey:tyUserAccessToken];
    
    _pageCount = 0;
    _pageCurr = 1;
    [self getNoteWipthChaperId];
    
}
///根据章节id获取该章节下满所有的试题笔记
- (void)getNoteWipthChaperId{
//    NSString
    NSString *urlString = [NSString stringWithFormat:@"%@api/Note/GetUserChapterNotes?access_token=%@&chapterId=%ld&page=%ld&size=20",systemHttps,_accessToken,_chaperId,_pageCurr];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicNote = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"%@",dicNote);
    } RequestFaile:^(NSError *error) {
        
    }];
}
//- (void)
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
