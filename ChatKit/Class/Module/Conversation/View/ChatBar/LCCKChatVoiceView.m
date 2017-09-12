//
//  LCCKChatVoiceView.m
//  Pods
//
//  Created by 岳琛 on 2017/9/11.
//
//

#import "LCCKChatVoiceView.h"
#import "LCCKConstants.h"
#import "UIImage+LCCKExtension.h"

#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

#ifndef kLCCKHexRGB
#define kLCCKHexRGB(rgbValue) [UIColor colorWithRed: ((float)((rgbValue & 0xFF0000) >> 16))/255.0 green: ((float)((rgbValue & 0xFF00) >> 8))/255.0 blue: ((float)(rgbValue & 0xFF))/255.0 alpha: 1.0]
#endif

#define kLCCKTopLineBackgroundColor  [UIColor colorWithRed:219/255.0 green:219/255.0 blue:219/255.0 alpha:1.0f]

@interface LCCKChatVoiceView ()

@property (strong, nonatomic) UIView *recordView;//录音界面
@property (strong, nonatomic) UIButton *recordButton;
@property (strong, nonatomic) UILabel *recordLbl;


@property (strong, nonatomic) UIView *voiceView;//试听界面
@property (strong, nonatomic) UIButton *voiceButton;

@property (strong, nonatomic) UIView *bottomView;
@property (weak, nonatomic) UIButton *sendButton;
@property (weak, nonatomic) UIButton *cancleButton;

@end

@implementation LCCKChatVoiceView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

#pragma mark - Private Methods
- (void)setup {
    [self addLineView];
    [self recordView];
    [self.recordView addSubview:self.recordLbl];
    [self.recordView addSubview:self.recordButton];
    [self voiceView];
    [self.voiceView addSubview:self.bottomView];
    
    [self setupConstraints]; 
}

- (void)setupConstraints {
    [self.recordView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.and.left.and.right.mas_equalTo(self);
    }];
    
    [self.recordLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(16);
        make.left.and.right.mas_equalTo(self);
        make.height.mas_equalTo(16);
    }];
    
    [self.recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(12);
        make.width.and.height.mas_equalTo(110);
        make.centerX.mas_equalTo(self.mas_centerX);
//        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    
    [self.voiceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.and.left.and.right.mas_equalTo(self);
    }];
    
    [self.recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(16);
        make.bottom.mas_equalTo(self).offset(-60);
        make.centerX.mas_equalTo(self.mas_centerX);
    }];
}

#pragma mark - Setters


#pragma mark - Getters

- (void)addLineView
{
    UIImageView *topLine = [[UIImageView alloc] init];
    topLine.backgroundColor = kLCCKTopLineBackgroundColor;
    [self addSubview:topLine];
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.and.width.mas_equalTo(self);
        make.height.mas_equalTo(.5f);
    }];
}

// 录音界面
- (UIView *)recordView
{
    if (!_recordView) {
        UIView * recordView = [[UIView alloc] init];
        recordView.backgroundColor = [UIColor clearColor];
        recordView.hidden = NO;
        [self addSubview:(_recordView = recordView)];
    }
    return _recordView;
}

- (UILabel *)recordLbl
{
    if (!_recordLbl) {
        _recordLbl = [[UILabel alloc] init];
        _recordLbl.text = @"按住开始录制";
        _recordLbl.font = [UIFont systemFontOfSize:16.f];
        _recordLbl.textColor = kLCCKHexRGB(0xA5A5A5);
        _recordLbl.textAlignment = NSTextAlignmentCenter;
    }
    return _recordLbl;
}

- (UIButton *)recordButton
{
    if (!_recordButton) {
        _recordButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 44, 110, 110)];
        _recordButton.layer.masksToBounds = YES;
        _recordButton.layer.cornerRadius = _recordButton.frame.size.width/2;
        _recordButton.layer.borderColor = kLCCKHexRGB(0xDBDBDB).CGColor;
        _recordButton.layer.borderWidth = 5;
        [_recordButton setBackgroundImage:[UIImage lcck_imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_recordButton setBackgroundImage:[UIImage lcck_imageWithColor:kLCCKHexRGB(0x3EA0F3)] forState:UIControlStateHighlighted];
        [_recordButton setImage:[self imageInBundlePathForImageName:@"conversation_icon_start"] forState:UIControlStateNormal];
        [_recordButton setImage:[self imageInBundlePathForImageName:@"conversation_icon_starting"] forState:UIControlStateHighlighted];
        
        [_recordButton addTarget:self action:@selector(touchRecordVoice) forControlEvents:UIControlEventTouchDown];
        [_recordButton addTarget:self action:@selector(startRecordVoice) forControlEvents:UIControlEventTouchUpInside];
        [_recordButton addTarget:self action:@selector(stopRecordVoice) forControlEvents:UIControlEventTouchUpOutside];
        [_recordButton addTarget:self action:@selector(cancleRecordVoice) forControlEvents:UIControlEventTouchCancel];
    }
    return _recordButton;
}

// 播放界面
- (UIView *)voiceView
{
    if (!_voiceView) {
        UIView * voiceView = [[UIView alloc] init];
        voiceView.backgroundColor = [UIColor clearColor];
        voiceView.hidden = YES;
        [self addSubview:(_voiceView = voiceView)];
    }
    return _voiceView;
}

- (UIButton *)voiceButton
{
    if (!_voiceButton) {
        _voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _voiceButton.backgroundColor = [UIColor lightGrayColor];
    }
    return _voiceButton;
}

- (UIView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor blackColor];
    }
    return _bottomView;
}

#pragma mark - Action
//开始录音
- (void)startRecordVoice {
    // 判断权限
    if ([self judgeAVAudioSession]) {
        self.recordLbl.text = @"松开完成录制";
        //        [self.MP3 startRecord];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:LCCKNotificationRecordNoPower object:nil];
    }
}

//取消录音
- (void)stopRecordVoice {
    self.recordLbl.text = @"按住进行录制";
        self.recordButton.layer.borderWidth = 5;
    //    [self.MP3 stopRecord];
}

- (void)touchRecordVoice {
    self.recordButton.layer.borderWidth = 0;
}

- (void)cancleRecordVoice {
//    self.recordButton.layer.borderWidth = 5;
}

//进入后台 取消当前的录音
- (void)appBecomeBackgroundCancelRecordVoice {
    [self stopRecordVoice];
}

#pragma mark - Private Methods
- (BOOL)judgeAVAudioSession {
    __block BOOL bCanRecord = YES;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession requestRecordPermission:^(BOOL granted) {
        if (granted) {
            bCanRecord = YES;
        } else {
            bCanRecord = NO;
        }
    }];
    return bCanRecord;
}

- (UIImage *)imageInBundlePathForImageName:(NSString *)imageName {
    return   ({
        UIImage *image = [UIImage lcck_imageNamed:imageName bundleName:@"ChatKeyboard" bundleForClass:[self class]];
        image;});
}

@end
