//
//  LCCKGradientProgressView.m
//  AVOSCloud
//
//  Created by 岳琛 on 2017/11/7.
//

#import "LCCKGradientProgressView.h"

@interface LCCKGradientProgressView ()

@property (nonatomic, strong) CALayer *bgLayer;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation LCCKGradientProgressView

#pragma mark - Lazy Load

- (CALayer *)bgLayer
{
    if (!_bgLayer) {
        _bgLayer = [CALayer layer];
        //一般不用frame，因为不支持隐式动画
        _bgLayer.bounds = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _bgLayer.anchorPoint = CGPointMake(0, 0);
        _bgLayer.backgroundColor = self.bgProgressColor.CGColor;
        _bgLayer.cornerRadius = self.frame.size.height / 2.;
        [self.layer addSublayer:_bgLayer];
    }
    return _bgLayer;
}

- (CAGradientLayer *)gradientLayer
{
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.bounds = CGRectMake(0, 0, self.frame.size.width * self.progress, self.frame.size.height);
        _gradientLayer.startPoint = CGPointMake(0, 0);
        _gradientLayer.endPoint = CGPointMake(1, 0);
        _gradientLayer.anchorPoint = CGPointMake(0, 0);
        NSArray *colorArr = self.colorArr;
        _gradientLayer.colors = colorArr;
        _gradientLayer.cornerRadius = self.frame.size.height / 2.;
        [self.layer addSublayer:_gradientLayer];
    }
    return _gradientLayer;
}

#pragma mark - Set Methods
- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    [self updateView];
}

- (void)setColorArr:(NSArray *)colorArr
{
    if (colorArr.count >= 2) {
        _colorArr = colorArr;
        [self updateView];
    } else {
        NSLog(@"EHGPV >>>>> 颜色数组个数小于2，显示默认颜色");
    }
}

- (void)setBgProgressColor:(UIColor *)bgProgressColor
{
    _bgProgressColor = bgProgressColor;
    _bgLayer.backgroundColor = self.bgProgressColor.CGColor;
}

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSLog(@"%f",frame.size.height);
        [self config];
        [self simulateViewDidLoad];
    }
    return self;
}

- (void)config
{
    self.colorArr = @[(id)GPV_RGBColor(252, 244, 77).CGColor,(id)GPV_RGBColor(252, 93, 59).CGColor];
    self.bgProgressColor = GPV_RGBColor(230., 244., 245.);
    self.progress = 0.65;
}

- (void)simulateViewDidLoad
{
    [self bgLayer];
    [self gradientLayer];
}

- (void)updateView
{
    self.gradientLayer.bounds = CGRectMake(0, 0, self.frame.size.width * self.progress, self.frame.size.height);
    self.gradientLayer.colors = self.colorArr;
}

@end
