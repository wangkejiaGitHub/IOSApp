//
//  StartDoTopicViewController.m
//  TyDtk
//
//  Created by 天一文化 on 16/4/11.
//  Copyright © 2016年 天一文化.王可佳. All rights reserved.
//

#import "StartDoTopicViewController.h"

@interface StartDoTopicViewController ()
//所有展示试题的容器
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewPater;

//本地信息存储
@property (nonatomic,strong) NSUserDefaults *tyUser;
//令牌
@property (nonatomic,strong) NSString *accessToken;
//试卷信息数组
@property (nonatomic,strong) NSArray *arrayPaterData;
//scrollview 的宽度，单位是以屏宽的个数去计算
@property (nonatomic,assign) NSInteger scrollContentWidth;
@end

@implementation StartDoTopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tyUser = [NSUserDefaults standardUserDefaults];
    _accessToken = [_tyUser objectForKey:tyUserAccessToken];
    // Do any additional setup after loading the view.
    [self getPaterDatas];
}
- (IBAction)tewtwew:(UIBarButtonItem *)sender {
    NSLog(@"datas");
}

/**
 获取试卷试题
 */
- (void)getPaterDatas{
     NSString *urlString = [NSString stringWithFormat:@"%@api/Paper/GetPaperQuestions/%ld?access_token=%@",systemHttps,_paterId,_accessToken];
    [HttpTools getHttpRequestURL:urlString RequestSuccess:^(id repoes, NSURLSessionDataTask *task) {
        NSDictionary *dicPater = [NSJSONSerialization JSONObjectWithData:repoes options:NSJSONReadingMutableLeaves error:nil];
        _arrayPaterData = dicPater[@"datas"];
        NSLog(@"%ld == %@",_paterId,_accessToken);
        NSLog(@"%@",dicPater);
        _scrollContentWidth = 0;
        for (NSDictionary *dicNum in _arrayPaterData) {
            NSArray *arrayDic = dicNum[@"Questions"];
            _scrollContentWidth = _scrollContentWidth + arrayDic.count;
        }
        NSLog(@"%ld",_scrollContentWidth);
        
        _scrollViewPater.contentSize = CGSizeMake(_scrollContentWidth*Scr_Width, _scrollViewPater.bounds.size.height);
        [self testScrollView];
        
        
    } RequestFaile:^(NSError *error) {
        
    }];
}
- (void)testScrollView{
    for (int i = 0; i<_scrollContentWidth; i++) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(Scr_Width*i, 0, Scr_Width, Scr_Height - 50)];
        view.backgroundColor = colorSuiJi;
        [_scrollViewPater addSubview:view];
    }
}
/**
 http://api.diantiku.cn/api/Paper/GetPaperInfo/25?access_token=1Ak0ePXnVNoeh7MfuxD3yW41Nrjz86sLXXslGj8tumdL9Fa%2BJj3AjccnwL9wUCr%2BvpQKrgrWaeoDHvcro%2B1VS1WsDgKULZw2fQEYBOfxmKVoRxU2nuYQnuBrnRTPpZrPkfjRQkQvPAqU0t03l/9LyjM5MjZv1Vl6x6WBPcPUd2/zeZfW8IHJFq/bqEoe2V0v
 
 http://api.diantiku.cn/api/Paper/GetCaptions/25?access_token=1Ak0ePXnVNoeh7MfuxD3yW41Nrjz86sLXXslGj8tumdL9Fa%2BJj3AjccnwL9wUCr%2BvpQKrgrWaeoDHvcro%2B1VS1WsDgKULZw2fQEYBOfxmKVoRxU2nuYQnuBrnRTPpZrPkfjRQkQvPAqU0t03l/9LyjM5MjZv1Vl6x6WBPcPUd2/zeZfW8IHJFq/bqEoe2V0v
*/
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
