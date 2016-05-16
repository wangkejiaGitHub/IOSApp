//
//  ZFPieChart.m
//  ZFChartView
//
//  Created by apple on 16/2/16.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "ZFPieChart.h"
#import "ZFConst.h"
#import "NSObject+Zirkfied.h"
#import "NSString+Zirkfied.h"
#import "UIColor+Zirkfied.h"
#import "UIView+Zirkfied.h"
#import "ZFTranslucencePath.h"

#define PercentLabelTag 100
#define DetailBackgroundTag 500

@interface ZFPieChart()

/** 总数 */
@property (nonatomic, assign) CGFloat totalValue;
/** 半径 */
@property (nonatomic, assign) CGFloat radius;
/** 半径最大上限 */
@property (nonatomic, assign) CGFloat maxRadius;
/** 记录每个圆弧开始的角度 */
@property (nonatomic, assign) CGFloat startAngle;
/** 动画总时长 */
@property (nonatomic, assign) CFTimeInterval totalDuration;
/** 圆环线宽 */
@property (nonatomic, assign) CGFloat lineWidth;
/** 记录valueArray当前元素的下标 */
@property (nonatomic, assign) NSInteger index;
/** 记录当前path的中心点 */
@property (nonatomic, assign) CGPoint centerPoint;
/** 半透明Path延伸长度 */
@property (nonatomic, assign) CGFloat extendLength;
/** 记录圆环中心 */
@property (nonatomic, assign) CGPoint pieCenter;
/** 记录初始高度 */
@property (nonatomic, assign) CGFloat originHeight;
/** 存储每个圆弧动画开始的时间 */
@property (nonatomic, strong) NSMutableArray * startTimeArray;
/** 记录每个path startAngle 和 endAngle, 数组里存的是NSDictionary */
@property (nonatomic, strong) NSMutableArray * angelArray;
/** 标题Label */
@property (nonatomic, strong) UILabel * titleLabel;
/** 数值Label */
@property (nonatomic, strong) UILabel * valueLabel;

@end

@implementation ZFPieChart

- (NSMutableArray *)startTimeArray{
    if (!_startTimeArray) {
        _startTimeArray = [NSMutableArray array];
    }
    return _startTimeArray;
}

- (NSMutableArray *)angelArray{
    if (!_angelArray) {
        _angelArray = [NSMutableArray array];
    }
    return _angelArray;
}

/**
 *  初始化变量
 */
- (void)commonInit{
    _maxRadius = self.frame.size.width > self.frame.size.height ? self.frame.size.height : self.frame.size.width;
    _radius = _maxRadius * 0.25;
    _lineWidth = _radius;
    _totalDuration = 0.75f;
    _startAngle = ZFRadian(-90);
    _extendLength = 10.f;
    _originHeight = self.frame.size.height;
    _pieCenter = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    _isShowDetail = YES;
    _isShowPercent = YES;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
        
        //标题Label
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.frame.size.width, 30)];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = [UIColor redColor];
        [self addSubview:self.titleLabel];
        
        //数值Label
        self.valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _radius, _radius * 0.5)];
        self.valueLabel.font = [UIFont boldSystemFontOfSize:11.f];
        self.valueLabel.textAlignment = NSTextAlignmentCenter;
        self.valueLabel.textColor = [UIColor blueColor];
        self.valueLabel.center = self.pieCenter;
        [self addSubview:self.valueLabel];
    }
    return self;
}

/**
 *  添加详情
 */
- (void)addUI{
    for (NSInteger i = 0; i < self.valueArray.count; i++) {
        //装载容器
        UIView * background = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height / 8.f * 7 + 30 + 25 * i, self.frame.size.width, 25)];
        background.tag = DetailBackgroundTag + i;
        [self addSubview:background];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showTranslucencePathAction:)];
        [background addGestureRecognizer:tap];
        
        //颜色View
        UIView * color = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width * 0.05, 5, 10, 10)];
        [color setBorderCornerRadius:color.frame.size.width * 0.5 andBorderWidth:0 andBorderColor:nil];
        color.backgroundColor = _colorArray[i];
        [background addSubview:color];
        
        //名称
        CGFloat width = (self.frame.size.width * (1 - 0.1) - 40) / 3.f;
        UILabel * name = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(color.frame) + 10, 0, width, 20)];
        name.text = _nameArray[i];
        name.font = [UIFont boldSystemFontOfSize:16.f];
        [background addSubview:name];
        
        //数值
        UILabel * value = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(name.frame) + 10, 0, width, 20)];
        value.text = [NSString stringWithFormat:@"%@题",_valueArray[i]];

        value.font = [UIFont boldSystemFontOfSize:16.f];
        [background addSubview:value];
        
        //百分比
        UILabel * percent = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(value.frame) + 10, 0, width, 20)];
        percent.adjustsFontSizeToFitWidth = YES;
        percent.text = [self getPercent:i];
        percent.font = [UIFont boldSystemFontOfSize:16.f];
        [background addSubview:percent];
    }
    
    //重设self.frame的值
    UILabel * lastLabel = (UILabel *)[self viewWithTag:DetailBackgroundTag + self.valueArray.count - 1];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, CGRectGetMaxY(lastLabel.frame) + 20);
}

#pragma mark - Arc(圆弧)

/**
 *  填充
 *
 *  @return UIBezierPath
 */
- (UIBezierPath *)fill{
    //需要多少度的圆弧
    CGFloat angle = [self countAngle:[_valueArray[_index] floatValue]];
    
    UIBezierPath * bezier = [UIBezierPath bezierPathWithArcCenter:_pieCenter radius:_radius startAngle:_startAngle endAngle:_startAngle + angle clockwise:YES];
    self.centerPoint = [self getBezierPathCenterPointWithStartAngle:_startAngle endAngle:_startAngle + angle];
    //记录开始角度和结束角度
    NSDictionary * dict = @{@"startAngle":@(_startAngle), @"endAngle":@(_startAngle + angle)};
    [self.angelArray addObject:dict];
    
    _startAngle += angle;
    
    return bezier;
}

/**
 *  CAShapeLayer
 *
 *  @return CAShapeLayer
 */
- (CAShapeLayer *)shapeLayer{
    CAShapeLayer * layer = [CAShapeLayer layer];
    layer.fillColor = nil;
    layer.strokeColor = [_colorArray[_index] CGColor];
    layer.lineWidth = _lineWidth;
    layer.path = [self fill].CGPath;

    CABasicAnimation * animation = [self animation];
    [layer addAnimation:animation forKey:nil];

    return layer;
}

#pragma mark - 动画

/**
 *  填充动画过程
 *
 *  @return CABasicAnimation
 */
- (CABasicAnimation *)animation{
    CABasicAnimation * fillAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    fillAnimation.duration = [self countDuration:_index];
    fillAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    fillAnimation.fillMode = kCAFillModeForwards;
    fillAnimation.removedOnCompletion = NO;
    fillAnimation.fromValue = @(0.f);
    fillAnimation.toValue = @(1.f);
    
    return fillAnimation;
}

#pragma mark - 清除控件

/**
 *  清除之前所有子控件
 */
- (void)removeAllSubLayers{
    [self.angelArray removeAllObjects];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, _originHeight);
    
    NSArray * subLayers = [NSArray arrayWithArray:self.layer.sublayers];
    for (CALayer * layer in subLayers) {
        if (layer != self.titleLabel.layer && layer != self.valueLabel.layer) {
            [layer removeAllAnimations];
            [layer removeFromSuperlayer];
        }
    }
    
    for (UIView * view in self.subviews) {
        if (view != self.titleLabel && view != self.valueLabel) {
            [view removeFromSuperview];
        }
    }
}

/**
 *  移除半透明Path
 */
- (void)removeZFTranslucencePath{
    NSMutableArray * sublayers = [NSMutableArray arrayWithArray:self.layer.sublayers];
    for (CALayer * layer in sublayers) {
        if ([layer isKindOfClass:[ZFTranslucencePath class]]) {
            [layer removeFromSuperlayer];
        }
    }
}

#pragma mark - 半透明Path

/**
 *  半透明Path
 *
 *  @param startAngle 开始角度
 *  @param endAngle   结束角度
 *  @param index      下标
 *
 *  @return ZFTranslucencePath
 */
- (ZFTranslucencePath *)translucencePathShapeLayerWithStartAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle index:(NSInteger)index{
    ZFTranslucencePath * layer = [ZFTranslucencePath layerWithArcCenter:_pieCenter radius:_radius + _extendLength startAngle:startAngle endAngle:endAngle clockwise:YES];
    layer.strokeColor = [_colorArray[index] CGColor];
    layer.lineWidth = _lineWidth + _extendLength;
    return layer;
}

#pragma mark - public method

/**
 *  重绘
 */
- (void)strokePath{
    self.userInteractionEnabled = NO;
    [self removeAllSubLayers];
    _startAngle = ZFRadian(-90);
    
    for (NSInteger i = 0; i < _valueArray.count; i++) {
        [self dispatch_after_withSeconds:[self.startTimeArray[i] floatValue] actions:^{
            _index = i;
            CAShapeLayer * shapeLayer = [self shapeLayer];
            [self.layer addSublayer:shapeLayer];
            _isShowPercent == YES?[self creatPercentLabel]:nil;
        }];
    }
    
    [self dispatch_after_withSeconds:_totalDuration actions:^{
        self.userInteractionEnabled = YES;
    }];
    
    _isShowDetail == YES?[self addUI]:nil;
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (point.y > _originHeight / 8.f * 7 + 30) {
        return;
    }
    
    //求弧度
    CGFloat x = (point.x - _pieCenter.x);
    CGFloat y = (point.y - _pieCenter.y);
    CGFloat radian = atan2(y, x);
    //当超过180度时，要加2π
    if (y < 0 && x < 0) {
        radian = radian + ZFRadian(360);
    }
    
    //判断点击位置的角度在哪个path范围上
    for (NSInteger i = 0; i < self.angelArray.count; i++) {
        NSDictionary * dict = self.angelArray[i];
        CGFloat startAngle = [dict[@"startAngle"] floatValue];
        CGFloat endAngle = [dict[@"endAngle"] floatValue];
        
        if (radian >= startAngle && radian < endAngle) {
            [self removeZFTranslucencePath];
            [self.layer addSublayer:[self translucencePathShapeLayerWithStartAngle:startAngle endAngle:endAngle index:i]];
            UILabel * percentLabel = [self viewWithTag:PercentLabelTag + i];
            [self bringSubviewToFront:percentLabel];
            self.valueLabel.text = [NSString stringWithFormat:@"[%@]题", _valueArray[i]];
            return;
        }
    }
}

/**
 *  显示半透明Path Action
 *
 *  @param sender UITapGestureRecognizer
 */
- (void)showTranslucencePathAction:(UITapGestureRecognizer *)sender{
    NSInteger index = sender.view.tag - DetailBackgroundTag;
    NSDictionary * dict = self.angelArray[index];
    CGFloat startAngle = [dict[@"startAngle"] floatValue];
    CGFloat endAngle = [dict[@"endAngle"] floatValue];
    
    [self removeZFTranslucencePath];
    [self.layer addSublayer:[self translucencePathShapeLayerWithStartAngle:startAngle endAngle:endAngle index:index]];
    UILabel * percentLabel = [self viewWithTag:PercentLabelTag + index];
    [self bringSubviewToFront:percentLabel];
    self.valueLabel.text = [NSString stringWithFormat:@"[%@]题",_valueArray[index]];
}

#pragma mark - 获取每个item所占百分比

/**
 *  计算每个item所占角度大小
 *
 *  @param value 每个item的value
 *
 *  @return 返回角度大小
 */
- (CGFloat)countAngle:(CGFloat)value{
    //计算百分比
    CGFloat percent = value / _totalValue;
    //需要多少度的圆弧
    CGFloat angle = M_PI * 2 * percent;
    return angle;
}

#pragma mark - 计算每个圆弧执行动画持续时间

/**
 *  计算每个圆弧执行动画持续时间
 *
 *  @param index 下标
 *
 *  @return CFTimeInterval
 */
- (CFTimeInterval)countDuration:(NSInteger)index{
    if (_totalDuration < 0.1f) {
        _totalDuration = 0.1f;
    }
    float count = _totalDuration / 0.1f;
    CGFloat averageAngle =  M_PI * 2 / count;
    CGFloat time = [self countAngle:[_valueArray[index] floatValue]] / averageAngle * 0.1;
    
    return time;
}

#pragma mark - 获取每个path的中心点

/**
 *  获取每个path的中心点
 *
 *  @return CGFloat
 */
- (CGPoint)getBezierPathCenterPointWithStartAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle{
    //一半角度(弧度)
    CGFloat halfAngle = (endAngle - startAngle) / 2;
    //中心角度(弧度)
    CGFloat centerAngle = halfAngle + startAngle;
    //中心角度(角度)
    CGFloat realAngle = ZFAngle(centerAngle);
    
    CGFloat center_xPos = ZFCos(realAngle) * _radius + _pieCenter.x;
    CGFloat center_yPos = ZFSin(realAngle) * _radius + _pieCenter.y;

    return CGPointMake(center_xPos, center_yPos);
}

#pragma mark - 添加百分比Label

/**
 *  添加百分比Label
 */
- (void)creatPercentLabel{
    NSString * string = [self getPercent:_index];
    CGRect rect = [string stringWidthRectWithSize:CGSizeMake(0, 0) fontOfSize:9.f];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    label.text = string;
    label.alpha = 0.f;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:9.f];
    label.center = self.centerPoint;
    label.tag = PercentLabelTag + _index;
    [self addSubview:label];
    
    [UIView animateWithDuration:[self countDuration:_index] animations:^{
        label.alpha = 1.f;
    }];
    
    //获取r,g,b三色值
    CGFloat red = [_colorArray[_index] red];
    CGFloat green = [_colorArray[_index] green];
    //path颜色为深色时，更改文字颜色
    if ((red < 180.f && green < 180.f)) {
        label.textColor = [UIColor whiteColor];
    }
}

/**
 *  计算百分比
 *
 *  @return NSString
 */
- (NSString *)getPercent:(NSInteger)index{
    CGFloat percent = [_valueArray[index] floatValue] / _totalValue * 100;
    NSString * string;
    if (self.percentType == kPercentTypeDecimal) {
        string = [NSString stringWithFormat:@"%.2f%%",percent];
    }else if (self.percentType == kPercentTypeInteger){
        string = [NSString stringWithFormat:@"%d%%",(int)roundf(percent)];
    }
    return string;
}

#pragma mark - 重写setter,getter方法

- (void)setValueArray:(NSMutableArray *)valueArray{
    _valueArray = valueArray;
    _totalValue = 0;
    [self.startTimeArray removeAllObjects];
    CFTimeInterval startTime = 0.f;
    //计算总数
    for (NSInteger i = 0; i < valueArray.count; i++) {
        _totalValue += [valueArray[i] floatValue];
    }
    
    //计算每个path的开始时间
    for (NSInteger i = 0; i < valueArray.count; i++) {
        [self.startTimeArray addObject:[NSNumber numberWithDouble:startTime]];
        CFTimeInterval duration = [self countDuration:i];
        startTime += duration;
    }
}

- (void)setTitle:(NSString *)title{
    _title = title;
    self.titleLabel.text = _title;
}

@end
