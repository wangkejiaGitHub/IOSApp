//
//  PatersTopicViewController.m
//  TyDtk
//  试题展示页面，用于每道试试题的展示
//  (可用于从章节考点、模拟试卷、每周精选、智能出题页面所选试题或试卷展示)
//  Created by 天一文化 on 16/4/11.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "PatersTopicViewController.h"
#import "NotesOrErrorTableViewCell.h"
#import "PaterTopicQtype6TableViewCell.h"
#import "paterTopicQtype5TableViewCell.h"
#import "paterTopicQtype1and2TableViewCell.h"
@interface PatersTopicViewController ()<UITableViewDelegate,UITableViewDataSource,ErrorDelegate,ErrorViewDelegate,TopicCellDelegateTest>
@property (weak, nonatomic) IBOutlet UITableView *tableViewPater;
//需要返回的cell的高
@property (nonatomic,assign) CGFloat cellHeight;
//需要返回的cell的高
@property (nonatomic,assign) CGFloat cellSubHeight;
//需要返回的tableView头的高
@property (nonatomic,assign) CGFloat cellHeardHeight;
//纠错参数字典
@property (nonatomic,strong) NSMutableDictionary *dicError;
//所有错误类别数组
@property (nonatomic,strong) NSArray *arrayErrorType;
@property (nonatomic,strong) NSArray *arraySubQuestion;
@property (nonatomic,assign) NSInteger qType;
//判断是否是第一次加载
@property (nonatomic,assign) BOOL isFirstLoad;
@property (nonatomic,assign) BOOL isNotes;
@property (nonatomic,assign) BOOL isError;
@property (nonatomic,strong) NSString *stringNotes;
@property (nonatomic,strong) NSString *stringError;
//添加朦层
@property (nonatomic,strong) MZView *viewMz;
//暂时保存用户答案，cell复用
@property (nonatomic,strong) NSDictionary *dicUserAnswer;
@end

@implementation PatersTopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isFirstLoad = YES;
    // Do any additional setup after loading the view.
    _stringError = @"";
    _stringNotes = @"";
    _tableViewPater.tableFooterView = [UIView new];
    _tableViewPater.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableViewPater.backgroundColor = [UIColor whiteColor];
    _qType = [_dicTopic[@"qtype"] integerValue];
    if (_qType == 6) {
        _arraySubQuestion = _dicTopic[@"subQuestion"];
    }
    if (_qType == 3) {
        NSLog(@"%@",_dicTopic);
    }
    NSLog(@"fsfsfaf");
    _cellHeight = 130;
    _cellSubHeight = 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //第一段
    if (section == 0) {
        //如果是一题多问
        if (_qType == 6) {
            return _arraySubQuestion.count + 1;
        }
        return 1;
    }
    else if (section == 1){
        if (_isNotes) {
            return 1;
            
        }
        return 0;
    }
    else{
        if (_isError) {
            return 1;
        }
        return 0;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_qType == 6) {
        return 1;
    }
    else{
        return 3;
    }
    
}
//section头的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        //topicTitle 通过参数传递
        if (_topicTitle!=nil) {
            UILabel *lab = [[UILabel alloc]init];
            lab.numberOfLines = 0;
            lab.font = [UIFont systemFontOfSize:15.0];
            lab.text = _topicTitle;
            CGSize labSize = [lab sizeThatFits:CGSizeMake(Scr_Width-10, MAXFLOAT)];
            _cellHeardHeight = labSize.height;
            lab = nil;
            return _cellHeardHeight+20;
        }
        return 1;
    }
    else{
        return 30;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (section == 0) {
        if (_topicTitle!=nil) {
            UIView *viewTitle = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, _cellHeardHeight+20)];
            viewTitle.backgroundColor = ColorWithRGB(210, 210, 205);
            
            UILabel *labTitle = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, Scr_Width-20, _cellHeardHeight)];
            labTitle.numberOfLines = 0;
            labTitle.font = [UIFont systemFontOfSize:15.0];
            labTitle.text = _topicTitle;
            [viewTitle addSubview:labTitle];
            return viewTitle;
        }
        return nil;
    }
    else{
        //  arrow_right   arrow_down arrow_up
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 30)];
        view.backgroundColor = [UIColor groupTableViewBackgroundColor];
        view.layer.masksToBounds = YES;
        view.layer.cornerRadius = 5;
        UIImageView *imageV = [[UIImageView alloc]initWithFrame:CGRectMake(Scr_Width-30, 10, 16, 8)];
        if (section == 1) {
            if (_isNotes) {
                imageV.image = [UIImage imageNamed:@"arrow_up"];
            }
            else{
                imageV.image = [UIImage imageNamed:@"arrow_down"];
            }
        }
        else
        {
            if (_isError) {
                imageV.image = [UIImage imageNamed:@"arrow_up"];
            }
            else{
                imageV.image = [UIImage imageNamed:@"arrow_down"];
            }
        }
        
        [view addSubview:imageV];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, Scr_Width, 30);
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        button.backgroundColor = [UIColor clearColor];
        button.titleLabel.font = [UIFont systemFontOfSize:13.0];
        if (section == 1) {
            [button setTitle:@"笔记 >>" forState:UIControlStateNormal];
        }
        else{
            [button setTitle:@"纠错 >>" forState:UIControlStateNormal];
        }
        button.tag = 100+section;
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(sectionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        return view;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (_qType == 6) {
            if (indexPath.row == 0) {
                return _cellHeight;
            }
            else{
                return _cellSubHeight;
            }
        }
        else{
            return _cellHeight;
        }
    }
    else{
        return 120;
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger topicQuestionId = [_dicTopic[@"questionId"] integerValue];
    if (indexPath.section == 0) {
        //先判断题的类型
        //选择题
        if (_qType == 1 | _qType == 2) {
            paterTopicQtype1and2TableViewCell *cellSelect = (paterTopicQtype1and2TableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"TopicQtype1and2Cell"];
            if (cellSelect == nil) {
                cellSelect = [[[NSBundle mainBundle] loadNibNamed:@"TopicQtype1and2Cell" owner:self options:nil]lastObject];
            }
            //            paterTopicQtype1and2TableViewCell *cellSelect = [[[NSBundle mainBundle] loadNibNamed:@"TopicQtype1and2Cell" owner:self options:nil]lastObject];
            
            if (_dicTopic.allKeys > 0) {
                cellSelect.topicType = _qType;
                cellSelect.indexTopic = _topicIndex;
                cellSelect.delegateCellClick = self;
                _cellHeight = [cellSelect setvalueForCellModel:_dicTopic topicIndex:_topicIndex];
            }
            cellSelect.selectionStyle = UITableViewCellSelectionStyleNone;
            return cellSelect;
        }
        //一题多问题
        else if (_qType == 6){
            //第一个cell用于显示试题题目和相关图片
            if (indexPath.row == 0) {
                PaterTopicQtype6TableViewCell *cellSubQu = [[[NSBundle mainBundle] loadNibNamed:@"paterTopicQtype6Cell" owner:self options:nil]lastObject];
                cellSubQu.delegateTopic = self;
                cellSubQu.selectionStyle = UITableViewCellSelectionStyleNone;
                _cellHeight = [cellSubQu setvalueForCellModel:_dicTopic topicIndex:_topicIndex];
                return cellSubQu;
            }
            else{
                //一题多问下面的小题
                //先判断小题的类型
                NSDictionary *dicSubQues = _arraySubQuestion[indexPath.row - 1];
                NSInteger qtypeSubQues = [dicSubQues[@"qtype"] integerValue];
                //小题类型为选择题
                if (qtypeSubQues == 1 | qtypeSubQues == 2) {
                    paterTopicQtype1and2TableViewCell *cellSelectTopic = (paterTopicQtype1and2TableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"TopicQtype1and2Cell"];
                    if (cellSelectTopic == nil) {
                        cellSelectTopic = [[[NSBundle mainBundle] loadNibNamed:@"TopicQtype1and2Cell" owner:self options:nil]lastObject];
                    }
                    cellSelectTopic.topicType = qtypeSubQues;
                    cellSelectTopic.indexTopic = indexPath.row;
                    cellSelectTopic.delegateCellClick = self;
                    cellSelectTopic.dicSelectDone = [NSMutableDictionary dictionaryWithDictionary: _dicUserAnswer];
                    cellSelectTopic.selectionStyle = UITableViewCellSelectionStyleNone;
                    _cellSubHeight = [cellSelectTopic setvalueForCellModel:dicSubQues topicIndex:indexPath.row];
                    return cellSelectTopic;
                }
                else{
                    paterTopicQtype5TableViewCell *cellQtype5 = [[[NSBundle mainBundle] loadNibNamed:@"paterTopicQtype5Cell" owner:self options:nil]lastObject];
                    cellQtype5.selectionStyle = UITableViewCellSelectionStyleNone;
                    _cellSubHeight = [cellQtype5 setvalueForCellModel:dicSubQues topicIndex:indexPath.row];
                    return cellQtype5;
                }
            }
        }
        return nil;
        
    }
    else{
        if (indexPath.section == 1) {
            NotesOrErrorTableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:@"cellNotes" forIndexPath:indexPath];
            UITextView *textView = [cell1.contentView viewWithTag:10];
            textView.text = _stringNotes;
            cell1.questionId = topicQuestionId;
            cell1.delegateError = self;
            cell1.selectionStyle = UITableViewCellSelectionStyleNone;
            cell1.isNoteses = 1;
            return cell1;
        }
        else{
            NotesOrErrorTableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:@"cellNotes" forIndexPath:indexPath];
            UITextView *textView = [cell2.contentView viewWithTag:10];
            textView.text = _stringError;
            cell2.questionId = topicQuestionId;
            cell2.isNoteses = 0;
            cell2.delegateError = self;
            cell2.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell2;
        }
        
    }
}
//点击section笔记或者纠错触发
- (void)sectionBtnClick:(UIButton*)sender{
    NSInteger sectionIndex = sender.tag - 100;
    if (sectionIndex == 1) {
        _isNotes = !_isNotes;
    }
    else{
        _isError = !_isError;
    }
    [_tableViewPater reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
}
//提交纠错回调
- (void)submitError:(NSDictionary *)dicError isNotes:(NSInteger)isNotes{
    if (!_viewMz) {
        _viewMz = [[MZView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, Scr_Height)];
    }
    //笔记
    if (isNotes == 1) {
        _dicError = [NSMutableDictionary dictionaryWithDictionary:dicError];
        _stringNotes = _dicError[@"note"];
        [self saveNotesRequest];
    }
    //纠错
    else{
        [self.view addSubview:_viewMz];
        _dicError = [NSMutableDictionary dictionaryWithDictionary:dicError];
        NSUserDefaults *tyUser = [NSUserDefaults standardUserDefaults];
        NSArray *array = [tyUser objectForKey:tyUserErrorTopic];
        ErrorTopicView *viewError = [[ErrorTopicView alloc]initWithFrame:CGRectMake(50, Scr_Height+(Scr_Height - (40*(array.count+2)+20))/2,Scr_Width - 100, 40*(array.count+2)+20) errorTypeArray:array];
        viewError.delegateViewError  = self;
        //    [self.view addSubview:viewError];
        [self.view addSubview:viewError];
        [UIView animateWithDuration:0.2 animations:^{
            CGRect rect = viewError.frame;
            rect.origin.y =(Scr_Height - (40*(array.count+2)+20) - 45)/2;
            viewError.frame = rect;
        }];
        
    }
}
//点击弹出纠错类型回调
- (void)viewCellClick:(NSString *)selectType{
    if (selectType != nil) {
        //提交
        [_dicError setObject:selectType forKey:@"Levels"];
        _stringError = _dicError[@"Content"];
        [self submitErrorRequest];
    }
    else{
        //取消提交
        [_viewMz removeFromSuperview];
    }
}
/**
 提交纠错，请求服务器
 */
- (void)submitErrorRequest{
    NSUserDefaults *tyUser = [NSUserDefaults standardUserDefaults];
    NSString *accessToken = [tyUser objectForKey:tyUserAccessToken];
    NSString *urlString = [NSString stringWithFormat:@"%@api/Correct/Submit?access_token=%@",systemHttps,accessToken];
    [HttpTools postHttpRequestURL:urlString RequestPram:_dicError RequestSuccess:^(id respoes) {
        NSDictionary *dic = (NSDictionary *)respoes;
        
        NSInteger codeId = [dic[@"code"] integerValue];
        if (codeId == 1) {
            NSDictionary *dicData = dic[@"datas"];
            [SVProgressHUD showSuccessWithStatus:dicData[@"msg"]];
            _isError = NO;
            [_tableViewPater reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
        }
        else{
            [SVProgressHUD showInfoWithStatus:@"操作失败"];
        }
        [_viewMz removeFromSuperview];
    } RequestFaile:^(NSError *erro) {
        
    }];
}
/**
 保存笔记，请求服务器
 */
- (void)saveNotesRequest{
    NSUserDefaults *tyUser = [NSUserDefaults standardUserDefaults];
    NSString *accessToken = [tyUser objectForKey:tyUserAccessToken];
    NSString *urlString = [NSString stringWithFormat:@"%@api/Note/Save?access_token=%@",systemHttps,accessToken];
    [HttpTools postHttpRequestURL:urlString RequestPram:_dicError RequestSuccess:^(id respoes) {
        NSDictionary *dic = (NSDictionary *)respoes;
        NSInteger codeId = [dic[@"code"] integerValue];
        if (codeId == 1) {
            NSDictionary *dicData = dic[@"datas"];
            [SVProgressHUD showSuccessWithStatus:dicData[@"msg"]];
            _isNotes = NO;
            [_tableViewPater reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        }
        else{
            [SVProgressHUD showInfoWithStatus:@"操作失败"];
        }
    } RequestFaile:^(NSError *erro) {
        
    }];
    
}
//保存图片回调
- (void)imageSaveQtype1:(UIImage *)image{
    [self imageTopicSave:image];
}
- (void)imageSaveQtype1Test:(UIImage *)image{
    [self imageTopicSave:image];
}
//
-(void)imageTopicSave:(UIImage *)image{
    UIAlertController *alertSaveImage = [UIAlertController alertControllerWithTitle:@"图片保存" message:@"保存到本地相册？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionSa = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image: didFinishSavingWithError: contextInfo:), nil);
    }];
    [alertSaveImage addAction:actionSa];
    UIAlertAction *actionCe = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertSaveImage addAction:actionCe];
    [self presentViewController:alertSaveImage animated:YES completion:nil];
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error == nil) {
        [SVProgressHUD showSuccessWithStatus:@"已成功保存到相册！"];
    }
    else{
        [SVProgressHUD showInfoWithStatus:@"保存失败！"];
    }
}
//暂时保存用户答案，用于cell复用使用
- (void)saveUserAnswerUseDictonary:(NSDictionary *)dic{
    _dicUserAnswer = dic;
    
    NSLog(@"%@",_dicUserAnswer);
}
//self.cell上的点击选项按钮（A、B、C、D..）代理回调
- (void)topicCellSelectClickTest:(NSInteger)indexTpoic selectDone:(NSDictionary *)dicUserAnswer isRefresh:(BOOL)isResfresh{
    [self.delegateRefreshTiopicCard refreshTopicCard:indexTpoic selectDone:dicUserAnswer isRefresh:isResfresh];
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
