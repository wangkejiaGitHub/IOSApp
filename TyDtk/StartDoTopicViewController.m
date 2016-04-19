//
//  StartDoTopicViewController.m
//  TyDtk
//  用户展示所有试题界面，把所有试题都加载在scrollView上进行展示
//  Created by 天一文化 on 16/4/11.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//
#import "StartDoTopicViewController.h"
#import "PatersTopicViewController.h"
@interface StartDoTopicViewController ()<UIScrollViewDelegate,TopicCardDelegate,TopicCardRefreshDelegate>
//所有展示试题的容器
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewPater;
@property (weak, nonatomic) IBOutlet UIButton *buttonRight;

@property (weak, nonatomic) IBOutlet UIButton *lastButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *labTime;
@property (weak, nonatomic) IBOutlet UILabel *labSurplus;

//本地信息存储
@property (nonatomic,strong) NSUserDefaults *tyUser;
//令牌
@property (nonatomic,strong) NSString *accessToken;
//试卷信息数组
@property (nonatomic,strong) NSArray *arrayPaterData;
//scrollview 的宽度，单位是以屏宽的个数去计算
@property (nonatomic,assign) NSInteger scrollContentWidth;
//答题卡
//@property (nonatomic,strong) UICollectionView *collectionViewTopicCard;

@property (nonatomic,strong) TopicCardCollectionView *collectionViewTopicCard;
@property (nonatomic,assign) BOOL isShowTopicCard;
@property (nonatomic,strong) NSTimer *timeLong;
@property (nonatomic,assign) NSInteger timeHo;
@property (nonatomic,assign) NSInteger timeMin;
@property (nonatomic,assign) NSInteger timeSe;
@end

@implementation StartDoTopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tyUser = [NSUserDefaults standardUserDefaults];
    _accessToken = [_tyUser objectForKey:tyUserAccessToken];
    _buttonRight.userInteractionEnabled = NO;
    [_buttonRight setTitle:@"试卷答题卡" forState:UIControlStateNormal];
    // Do any additional setup after loading the view.
    [self setTimeForTopic];
    [self getPaterDatas];
}

- (void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardShow:(NSNotification *)note{
    NSDictionary *userInfo = [note userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    //键盘高度
    CGFloat keyBoardHeight = keyboardRect.size.height;
    
    CGRect rect = self.view.frame;
    rect.origin.y = rect.origin.y - keyBoardHeight+45;
    self.navigationController.tabBarController.view.frame = rect;

}
/////////////
////键盘监听//
////键盘消失//
- (void)keyboardHide:(NSNotification *)note{
    CGRect rect = self.view.frame;
    self.navigationController.tabBarController.view.frame = rect;
}

/**
 获取模拟试卷试题
 */
- (void)getPaterDatas{
    [SVProgressHUD showWithStatus:@"试卷加载中..."];
    NSInteger paterId = [_dicPater[@"Id"] integerValue];
    NSString *urlString = [NSString stringWithFormat:@"%@api/Paper/IOSGetPaperQuestions/%ld?access_token=%@",systemHttps,paterId,_accessToken];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicPater = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        _arrayPaterData = dicPater[@"datas"];
        /////////////////////////////////////////////////////////////////////////////
        //在每一道题中，加一个是否已经做过该题的key（isMake:0(未做),1(做过)），用于刷新答题卡信息
        NSMutableArray *arrayNewPaterData = [NSMutableArray array];
        for (NSDictionary *dic in _arrayPaterData) {
            //去除每一个字典中的第一个key,待存贮
            NSDictionary *dicCaption = dic[@"Caption"];
            NSArray *arrayQuestions = dic[@"Questions"];
            //新的Questions数组
            NSMutableArray *arrayNewDic = [NSMutableArray array];
            for (NSDictionary *dicTopic in arrayQuestions) {
                NSMutableDictionary *dicNewTopic = [NSMutableDictionary dictionaryWithDictionary:dicTopic];
                [dicNewTopic setValue:@"0" forKey:@"isMake"];
                [arrayNewDic addObject:dicNewTopic];
            }
            NSDictionary *diccc = @{@"Caption":dicCaption,@"Questions":arrayNewDic};
            [arrayNewPaterData addObject:diccc];
        }
        _arrayPaterData = arrayNewPaterData;
        //修改原数据添加新key：isMake完成
        ///////////////////////////////////////
        NSLog(@"%ld == %@",paterId,_accessToken);
        _scrollContentWidth = 0;
        for (NSDictionary *dicNum in _arrayPaterData) {
            NSArray *arrayDic = dicNum[@"Questions"];
            _scrollContentWidth = _scrollContentWidth + arrayDic.count;
        }
        _scrollViewPater.contentSize = CGSizeMake(_scrollContentWidth*Scr_Width, _scrollViewPater.bounds.size.height);
        [self addChildViewWithTopicForSelf];
        [self addTimerForPater];
        _buttonRight.userInteractionEnabled = YES;
        //////////////////////////////////////////
//        实例化答题卡
        if (!_collectionViewTopicCard) {
            UICollectionViewFlowLayout *la =[[UICollectionViewFlowLayout alloc]init];
            _collectionViewTopicCard = [[TopicCardCollectionView alloc]initWithFrame:CGRectMake(Scr_Width, 64, Scr_Width,Scr_Height/2) collectionViewLayout:la withTopicArray:_arrayPaterData];
            _collectionViewTopicCard.delegateCellClick = self;
            [self.view addSubview:_collectionViewTopicCard];
        }
        /////////////////////////////////////////////////////////////
        [SVProgressHUD dismiss];
    } RequestFaile:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}
//倒计时时间事件
- (void)setTimeForTopic{
    NSInteger timeLong = [_dicPater[@"TimeLong"] integerValue];
    if (timeLong % 60 == 0) {
        _timeHo = timeLong/60;
        _timeMin = 0;
        _timeMin = 0;
    }
    else{
        _timeHo = timeLong/60;
        _timeMin = timeLong%60;
    }
    _timeSe = 0;
}
/**
 添加试卷剩余时间定时器
 */
- (void)addTimerForPater{
    if (!_timeLong) {
        _timeLong = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeClick:) userInfo:nil repeats:YES];
    }
    _timeLong.fireDate = [NSDate distantPast];
    _labSurplus.text = @"剩余时间";
}
- (void)viewDidDisappear:(BOOL)animated{
    _timeLong = nil;
}
/**
 时间倒计时
 */
- (void)timeClick:(NSTimer*)timer{
    //先判断秒为0
    if (_timeSe == 0) {
        //判断分钟是否同时为0
        if (_timeMin == 0) {
            
            //判断小时是否为0
            if (_timeHo == 0) {
                //倒计时结束
                NSLog(@"倒计时结束");
                _timeLong.fireDate = [NSDate distantFuture];
            }
            else{
                _timeSe = 59;
                _timeMin = 59;
                _timeHo = _timeHo - 1;
            }
        }
        else{
            _timeSe =59;
            _timeMin = _timeMin - 1;
        }
    }
    else{
        _timeSe = _timeSe - 1;
    }
    NSString *hTime;
    NSString *MinTime;
    NSString *seTIme;
    hTime = [NSString stringWithFormat:@"%ld",_timeHo];
    MinTime = [NSString stringWithFormat:@"%ld",_timeMin];
    seTIme = [NSString stringWithFormat:@"%ld",_timeSe];
    if (hTime.length == 1) {
        hTime = [NSString stringWithFormat:@"0%@",hTime];
    }
    if (MinTime.length == 1) {
        MinTime = [NSString stringWithFormat:@"0%@",MinTime];
    }
    if (seTIme.length == 1) {
        seTIme = [NSString stringWithFormat:@"0%@",seTIme];
    }
    _labTime.text = [NSString stringWithFormat:@"%@:%@:%@",hTime,MinTime,seTIme];
}
//打开答题卡
- (IBAction)topicCardClick:(UIButton *)sender {
    _isShowTopicCard = !_isShowTopicCard;
    if (_isShowTopicCard) {
        [self topicCardShow];
    }
    else{
        [self topicCardHiden];
    }
}

//pop
- (IBAction)popButtonClick:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
//上一题
- (IBAction)lastBtnClick:(UIButton *)sender {
    if (_scrollViewPater.contentOffset.x>=Scr_Width) {
        _lastButton.userInteractionEnabled = NO;
        _nextButton.userInteractionEnabled =NO;
        [_scrollViewPater setContentOffset:CGPointMake(_scrollViewPater.contentOffset.x - Scr_Width, 0) animated:YES];
    }
    [self topicCardHiden];
}
//下一题
- (IBAction)nextBtnClick:(UIButton *)sender {
    if (_scrollViewPater.contentOffset.x < _scrollContentWidth*Scr_Width - Scr_Width) {
        _lastButton.userInteractionEnabled = NO;
        _nextButton.userInteractionEnabled =NO;
        [_scrollViewPater setContentOffset:CGPointMake(_scrollViewPater.contentOffset.x + Scr_Width, 0) animated:YES];
    }
    [self topicCardHiden];
}

//添加子试图，（每一个子试图相当于一道题）并依次在scrollView中显示出来
- (void)addChildViewWithTopicForSelf{
    for (int i =0; i<_scrollContentWidth; i++) {
        UIViewController *chVc = [self.storyboard instantiateViewControllerWithIdentifier:@"PatersTopicViewController"];
        [self addChildViewController:chVc];
    }
    for (int i = 0; i<_scrollContentWidth; i++) {
        PatersTopicViewController *paterVc = self.childViewControllers[i];
        paterVc.delegateRefreshTiopicCard =self;
        paterVc.dicTopic = [self getTopicDictionary:i];
        paterVc.topicIndex = i+1;
        paterVc.view.frame = CGRectMake(i*Scr_Width, 0, Scr_Width, self.view.frame.size.height - 64 - 45);
        NSString *topString = [self topicTitle:i];
        paterVc.topicTitle = nil;
        if (topString != nil) {
            paterVc.topicTitle = topString;
        }
        [_scrollViewPater addSubview:paterVc.view];
    }
}
//传递题干信息，每一类试题的第一道题，传递题干信息
- (NSString *)topicTitle:(NSInteger)topicIndex{
    NSInteger countDicF = 0;
    NSInteger countDicL = 0;
    for (NSDictionary *dic in _arrayPaterData) {
        NSArray *array = dic[@"Questions"];
        countDicL = array.count + countDicF;
        if (topicIndex >= countDicF && topicIndex <= countDicL-1) {
            if (topicIndex == countDicF) {
                NSDictionary *dicCaption = dic[@"Caption"];
                NSString *topicTitle = dicCaption[@"Names"];
                return topicTitle;
            }
        }
        countDicF = countDicL;
    }
    return nil;
}

/**
 根据索引获取所对应的题目字典
 */
- (NSDictionary *)getTopicDictionary:(NSInteger)index{
    NSInteger countDicF = 0;
    NSInteger countDicL = 0;
    for (NSDictionary *dic in _arrayPaterData) {
        NSArray *array = dic[@"Questions"];
        countDicL = array.count + countDicF;
        if (index >= countDicF && index <= countDicL - 1) {
            NSDictionary *diccc = array[index - countDicF];
            return diccc;
        }
        countDicF = countDicL;
    }
    return nil;
}
//scrollView代理
//动画结束，控制不让‘上一题’，‘下一题’连续点击
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    _lastButton.userInteractionEnabled = YES;
    _nextButton.userInteractionEnabled =YES;
}

/**
 添加答题卡
 */
- (void)topicCardShow{
    [_buttonRight setTitle:@"隐藏答题卡" forState:UIControlStateNormal];
    [_collectionViewTopicCard setContentOffset:CGPointMake(0, 0) animated:YES];
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = _collectionViewTopicCard.frame;
        rect.origin.x = 0;
        _collectionViewTopicCard.frame = rect;
    }];
}
/**
 隐藏答题卡
 */
- (void)topicCardHiden{
    _isShowTopicCard = NO;
    [_buttonRight setTitle:@"试卷答题卡" forState:UIControlStateNormal];
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = _collectionViewTopicCard.frame;
        rect.origin.x = Scr_Width;
        _collectionViewTopicCard.frame = rect;
    }];
}
- (void)topicCollectonViewCellClick:(NSInteger)indexScroll{
    [_scrollViewPater setContentOffset:CGPointMake((indexScroll-1)*Scr_Width, 0) animated:YES];
    [self topicCardHiden];
}
////刷新设置答题信息，用于显示做过的题和未做题的信息
- (void)refreshTopicCard:(NSInteger)topicIndex selectString:(NSString *)selectString{
    NSString *indexString = [NSString stringWithFormat:@"%ld",topicIndex];
    if (![_collectionViewTopicCard.arrayisMakeTopic containsObject:indexString]) {
        [_collectionViewTopicCard.arrayisMakeTopic addObject:indexString];
    }
    
    if (_scrollViewPater.contentOffset.x < _scrollContentWidth*Scr_Width - Scr_Width) {
        _lastButton.userInteractionEnabled = NO;
        _nextButton.userInteractionEnabled =NO;
        [_scrollViewPater setContentOffset:CGPointMake(_scrollViewPater.contentOffset.x + Scr_Width, 0) animated:YES];
    }

    [_collectionViewTopicCard reloadData];
//    NSMutableDictionary *dicTopic = [self getTopicDictionary:topicIndex - 1];
    
}
//////////////////////
//
//////////////////////
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
//    NSDictionary *dicPater = _arrayPaterData[section];
//    NSArray *arrayTop = dicPater[@"Questions"];
//    return arrayTop.count;
//}
//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
//    return _arrayPaterData.count;
//}
//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
//    return UIEdgeInsetsMake(10, 10, 10, 10);
//}
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//    return CGSizeMake((Scr_Width-20-5*10)/6, (Scr_Width-20-5*10)/6);
//}
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
//    if (section == 0) {
//        return CGSizeMake(Scr_Width, 80);
//    }
//    return CGSizeMake(Scr_Width, 40);
//}
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
//    return 10;
//}
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
//    return 10;
//}
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
//    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
//        UICollectionReusableView *reView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"cellview" forIndexPath:indexPath];
//        for (id subView in reView.subviews) {
//            [subView removeFromSuperview];
//        }
//        reView.backgroundColor = ColorWithRGBWithAlpp(80, 200, 250, 0.8);
//        NSDictionary *dicCurr = _arrayPaterData[indexPath.section];
//        NSDictionary *dicCaption = dicCurr[@"Caption"];
//        UILabel *labCaptionTypeName = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, Scr_Width-10, reView.bounds.size.height)];
//        labCaptionTypeName.text = dicCaption[@"CaptionTypeName"];
//        labCaptionTypeName.font = [UIFont systemFontOfSize:16.0];
//        labCaptionTypeName.textColor = [UIColor blueColor];
//        if (indexPath.section == 0) {
//            labCaptionTypeName.frame = CGRectMake(10, 40, Scr_Width-10, 40);
//            UIView *viewTitle = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Scr_Width, 40)];
//            viewTitle.backgroundColor = [UIColor groupTableViewBackgroundColor];
//            [reView addSubview:viewTitle];
//            
//            UILabel *labDone = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, 70, 30)];
//            labDone.text = @"做过的题";
//            labDone.font = [UIFont systemFontOfSize:14.0];
//            [viewTitle addSubview:labDone];
//            
//            UIView *viewDone = [[UIView alloc]initWithFrame:CGRectMake(90, 15, 10, 10)];
//            viewDone.backgroundColor = ColorWithRGBWithAlpp(0, 233, 0, 0.5);
//            [viewTitle addSubview:viewDone];
//            
//            UIView *viewNo = [[UIView alloc]initWithFrame:CGRectMake(Scr_Width - 30, 15, 10, 10)];
//            viewNo.backgroundColor = ColorWithRGB(200, 200, 200);
//            [viewTitle addSubview:viewNo];
//            
//            UILabel *labNo = [[UILabel alloc]initWithFrame:CGRectMake(Scr_Width-100, 5, 70, 30)];
//            labNo.font = [UIFont systemFontOfSize:14.0];
//            labNo.text = @"未做的题";
//            [viewTitle addSubview:labNo];
//           
//        }
//        [reView addSubview:labCaptionTypeName];
//        return reView;
//    }
//    return nil;
//}
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
//    
//    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellcard" forIndexPath:indexPath];
//    for (id subView in cell.contentView.subviews) {
//        [subView removeFromSuperview];
//    }
//    UILabel *labNumber =[[UILabel alloc]initWithFrame:CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.width)];
//    labNumber.text = [NSString stringWithFormat:@"%ld",indexPath.row + 1];
//    labNumber.textAlignment = NSTextAlignmentCenter;
//    labNumber.font = [UIFont systemFontOfSize:15.0];
//    labNumber.backgroundColor = [UIColor clearColor];
//    [cell.contentView addSubview:labNumber];
//    if (indexPath.section != 0) {
//        NSInteger indexRow = 0;
//        for (int i = 0; i < indexPath.section; i++) {
//            NSDictionary *dicPater = _arrayPaterData[i];
//            NSArray *arrayTop = dicPater[@"Questions"];
//            indexRow = indexRow+arrayTop.count;
//        }
//        
//         labNumber.text = [NSString stringWithFormat:@"%ld",indexPath.row + 1+indexRow];
//    }
//    cell.backgroundColor = ColorWithRGB(200, 200, 200);
//    cell.layer.borderWidth = 1;
//    cell.layer.borderColor = [[UIColor lightGrayColor] CGColor];
//    return cell;
//}
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    NSLog(@"fsfd");
//}
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
