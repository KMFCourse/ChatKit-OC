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
#import "LCCKAVAudioPlayer.h"
#import "Mp3Recorder.h"
#import "LCCKGradientProgressView.h"

#if __has_include(<DACircularProgressView.h>)
#import <DACircularProgressView.h>
#else
#import "DACircularProgressView.h"
#endif

#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

#ifndef kLCCKHexRGB
#define kLCCKHexRGB(rgbValue) [UIColor colorWithRed: ((float)((rgbValue & 0xFF0000) >> 16))/255.0 green: ((float)((rgbValue & 0xFF00) >> 8))/255.0 blue: ((float)(rgbValue & 0xFF))/255.0 alpha: 1.0]
#endif

#define kLCCKTopLineBackgroundColor  [UIColor colorWithRed:219/255.0 green:219/255.0 blue:219/255.0 alpha:1.0f]

static NSInteger const kVoiceRecordTimerCount = 60;

@interface LCCKChatVoiceView ()<Mp3RecorderDelegate>
{
    dispatch_source_t _timer;
    dispatch_source_t _recordTimer;
}

@property (strong, nonatomic) Mp3Recorder *MP3;
@property (copy, nonatomic) NSString *mp3Path;
@property (assign, nonatomic) NSInteger secondCount;//记录录音时长
@property (assign, nonatomic) CGFloat secondNumber;//记录播放时长

@property (strong, nonatomic) UIView *recordView;//录音界面
@property (strong, nonatomic) UIButton *recordButton;
@property (strong, nonatomic) UILabel *recordLbl;
@property (strong, nonatomic) UILabel *recordProgressLbl;
@property (strong, nonatomic) UIView *recordBtnBaseView;

@property (strong, nonatomic) UIView *voiceView;//试听界面
@property (strong, nonatomic) UIButton *voiceButton;
@property (strong, nonatomic) UILabel *voiceLbl;
@property (strong, nonatomic) DACircularProgressView *progressView;

@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) UIButton *cancleButton;

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
    self.mp3Path = @"";
    self.secondCount = 0;
    self.secondNumber = 0.0;
    self.MP3 = [[Mp3Recorder alloc] initWithDelegate:self];
    
    [self addLineView];
    
    [self.recordView addSubview:self.recordProgressLbl];
    [self.recordView addSubview:self.recordButton];
    [self.recordView addSubview:self.recordLbl];
    
    [self.voiceView addSubview:self.voiceLbl];
    [self.voiceView addSubview:self.voiceButton];
    [self.voiceView addSubview:self.progressView];
    [self.voiceView sendSubviewToBack:self.progressView];
    
    [self.bottomView addSubview:self.cancleButton];
    [self.bottomView addSubview:self.sendButton];
    [self addVoiceBtmLine];
    [self setupConstraints]; 
}

- (void)setupConstraints {
    [self.recordView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.and.left.and.right.mas_equalTo(self);
    }];
    
    [self.recordProgressLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.recordView).offset(16);
        make.left.and.right.mas_equalTo(self.recordView);
        make.height.mas_equalTo(16);
    }];
    
    [self.recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.recordProgressLbl.mas_bottom).offset(12);
        make.width.and.height.mas_equalTo(108);
        make.centerX.mas_equalTo(self.recordView.mas_centerX);
    }];
    
    [self.recordLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.recordButton.mas_bottom).offset(12);
        make.left.and.right.mas_equalTo(self.recordView);
        make.height.mas_equalTo(16);
    }];
    
    [self.voiceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.and.left.and.right.mas_equalTo(self);
    }];
    
    [self.voiceLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(16);
        make.left.and.right.mas_equalTo(self);
        make.height.mas_equalTo(16);
    }];
    
    [self.voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.voiceLbl.mas_bottom).offset(16);
        make.width.and.height.mas_equalTo(100);
        make.centerX.mas_equalTo(self.mas_centerX);
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.and.centerY.mas_equalTo(self.voiceButton);
        make.width.height.mas_equalTo(self.voiceButton).offset(10);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.and.left.and.right.mas_equalTo(self);
        make.height.mas_equalTo(48);
    }];
    
    [self.cancleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView);
        make.height.equalTo(@(48));
        make.centerY.equalTo(self.bottomView);
    }];
    
    [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.cancleButton.mas_right);
        make.right.equalTo(self.bottomView.mas_right);
        make.height.equalTo(self.cancleButton);
        make.width.equalTo(self.cancleButton);
        make.centerY.equalTo(self.cancleButton);
    }];
}

#pragma mark - Setters

- (void)addLineView {
    UIImageView *topLine = [[UIImageView alloc] init];
    topLine.backgroundColor = kLCCKTopLineBackgroundColor;
    [self addSubview:topLine];
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.and.width.mas_equalTo(self);
        make.height.mas_equalTo(.5f);
    }];
}

- (void)addVoiceBtmLine {
    UIImageView *topLine = [[UIImageView alloc] init];
    topLine.backgroundColor = kLCCKTopLineBackgroundColor;
    [self.bottomView addSubview:topLine];
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.and.width.mas_equalTo(self.bottomView);
        make.height.mas_equalTo(.5f);
    }];
    
    UIImageView *centerLine = [[UIImageView alloc] init];
    centerLine.backgroundColor = kLCCKTopLineBackgroundColor;
    [self.bottomView addSubview:centerLine];
    [centerLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bottomView).offset(11);
        make.bottom.mas_equalTo(self.bottomView).offset(-11);
        make.width.mas_equalTo(.5f);
        make.centerX.mas_equalTo(self.bottomView.mas_centerX);
    }];
}

#pragma mark - Getters

// 录音界面
- (UIView *)recordView {
    if (!_recordView) {
        UIView * recordView = [[UIView alloc] init];
        recordView.backgroundColor = [UIColor clearColor];
        recordView.hidden = NO;
        [self addSubview:(_recordView = recordView)];
    }
    return _recordView;
}

- (UILabel *)recordLbl {
    if (!_recordLbl) {
        _recordLbl = [[UILabel alloc] init];
        _recordLbl.text = @"点击开始录音";
        _recordLbl.font = [UIFont systemFontOfSize:16.f];
        _recordLbl.textColor = kLCCKHexRGB(0xA5A5A5);
        _recordLbl.textAlignment = NSTextAlignmentCenter;
    }
    return _recordLbl;
}

- (UILabel *)recordProgressLbl {
    if (!_recordProgressLbl) {
        _recordProgressLbl = [[UILabel alloc] init];
        _recordProgressLbl.text = @"00:00";
        _recordProgressLbl.font = [UIFont systemFontOfSize:16.f];
        _recordProgressLbl.textColor = kLCCKHexRGB(0xA5A5A5);
        _recordProgressLbl.textAlignment = NSTextAlignmentCenter;
    }
    return _recordProgressLbl;
}

- (UIButton *)recordButton {
    if (!_recordButton) {
        _recordButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _recordButton.layer.masksToBounds = YES;
        _recordButton.layer.cornerRadius = _recordButton.frame.size.width/2;
        _recordButton.layer.borderColor = kLCCKHexRGB(0xDBDBDB).CGColor;
        _recordButton.layer.borderWidth = 5;
        
        [_recordButton setBackgroundImage:[UIImage lcck_imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_recordButton setBackgroundImage:[UIImage lcck_imageWithColor:kLCCKHexRGB(0x3EA0F3)] forState:UIControlStateSelected];
        [_recordButton setBackgroundImage:[UIImage lcck_imageWithColor:kLCCKHexRGB(0x3EA0F3)] forState:UIControlStateHighlighted];
        [_recordButton setImage:[self imageInBundlePathForImageName:@"conversation_icon_start"] forState:UIControlStateNormal];
        [_recordButton setImage:[self imageInBundlePathForImageName:@"conversation_icon_starting"] forState:UIControlStateSelected];
        [_recordButton setImage:[self imageInBundlePathForImageName:@"conversation_icon_starting"] forState:UIControlStateHighlighted];
        [_recordButton addTarget:self action:@selector(recordVoicerBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _recordButton;
}

- (UIView *)recordBtnBaseView {
    if (!_recordBtnBaseView) {
        _recordBtnBaseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
        _recordBtnBaseView.center = self.recordButton.center;
        _recordBtnBaseView.backgroundColor = [UIColor whiteColor];
        [self.recordView addSubview:_recordBtnBaseView];
        [self.recordView sendSubviewToBack:_recordBtnBaseView];
    }
    return _recordBtnBaseView;
}

// 播放界面
- (UIView *)voiceView {
    if (!_voiceView) {
        UIView * voiceView = [[UIView alloc] init];
        voiceView.backgroundColor = [UIColor clearColor];
        voiceView.hidden = YES;
        [self addSubview:(_voiceView = voiceView)];
    }
    return _voiceView;
}

- (UILabel *)voiceLbl {
    if (!_voiceLbl) {
        _voiceLbl = [[UILabel alloc] init];
        _voiceLbl.text = @"00:00";
        _voiceLbl.font = [UIFont systemFontOfSize:16.f];
        _voiceLbl.textColor = kLCCKHexRGB(0xA5A5A5);
        _voiceLbl.textAlignment = NSTextAlignmentCenter;
    }
    return _voiceLbl;
}

- (UIButton *)voiceButton {
    if (!_voiceButton) {
        _voiceButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _voiceButton.layer.masksToBounds = YES;
        _voiceButton.layer.cornerRadius = _voiceButton.frame.size.width/2;
        [_voiceButton setBackgroundImage:[UIImage lcck_imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_voiceButton setBackgroundImage:[UIImage lcck_imageWithColor:kLCCKHexRGB(0x3EA0F3)] forState:UIControlStateHighlighted];
        [_voiceButton setImage:[self imageInBundlePathForImageName:@"conversation_icon_play"] forState:UIControlStateNormal];
        [_voiceButton setImage:[self imageInBundlePathForImageName:@"conversation_icon_stop"] forState:UIControlStateSelected];
        [_voiceButton addTarget:self action:@selector(userTouchVoiceButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _voiceButton;
}

- (DACircularProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[DACircularProgressView alloc] initWithFrame:CGRectZero];
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;
        _progressView.trackTintColor = kLCCKHexRGB(0xDBDBDB);
        _progressView.progressTintColor = kLCCKHexRGB(0x3EA0F3);
        _progressView.innerTintColor = [UIColor clearColor];
        _progressView.thicknessRatio = 0.1;
    }
    return _progressView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        [self.voiceView addSubview:_bottomView];
    }
    return _bottomView;
}

- (UIButton *)cancleButton {
    if (!_cancleButton) {
        _cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancleButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancleButton setTitleColor:kLCCKHexRGB(0x3EA0F3) forState:UIControlStateNormal];
        _cancleButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_cancleButton addTarget:self action:@selector(userTouchCancleAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancleButton;
}

- (UIButton *)sendButton {
    if (!_sendButton) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [_sendButton setTitleColor:kLCCKHexRGB(0x3EA0F3) forState:UIControlStateNormal];
        _sendButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_sendButton addTarget:self action:@selector(userTouchSendAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}

#pragma mark - Mp3RecorderDelegate

- (void)endConvertWithMP3FileName:(NSString *)fileName {
    if (fileName) {
        self.mp3Path = fileName;
        [self.progressView setProgress:0.0];
        [self reloadRecordAndVoiceTitle:self.secondCount isRecordType:NO];
        [self switchToVoiceVoice:YES];
    }
}

- (void)failRecord {
    //    NSLog(@"出现错误");
}

- (void)beginConvert {
    //    NSLog(@"正在转换");
}


#pragma mark - Action
- (void)recordVoicerBtnAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected)
        [self startRecordVoice];
    else
        [self stopRecordVoice];
}

//开始录音
- (void)startRecordVoice {
    // 判断权限
    if ([self checkAVAudioSession]) {
        [self startRecordTimer];
        self.recordLbl.text = @"再次点击结束录音";
        self.recordButton.layer.borderWidth = 0;
        self.recordButton.highlighted = YES;
        [self.MP3 startRecord];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:LCCKNotificationRecordNoPower object:nil];
    }
}

//录音结束
- (void)stopRecordVoice {
    [self endRecordTimer];
    self.recordLbl.text = @"点击开始录音";
    self.recordButton.layer.borderWidth = 5;
    [self.MP3 stopRecord];
}

//语音播放-取消按钮
- (void)userTouchCancleAction:(UIButton *)sender {
    [self userWillCancleMethod];
}

//语音播放-取消方法
- (void)userWillCancleMethod {
    if (_voiceButton.selected == YES) {
        [self userTouchVoiceButton:_voiceButton];
    }
    if (_voiceButton.selected == NO && _secondNumber > 0 && _progressView.progress < 1) {
        [self resumeVoiceTimer];
    }
    [self endVoiceTimer];
    [self switchToVoiceVoice:NO];
}

//语音播放-发送按钮
- (void)userTouchSendAction:(UIButton *)sender {
    [self userWillSendMethod];
}

//语音播放-发送方法
- (void)userWillSendMethod {
    if (_mp3Path.length > 0 && _secondCount > 0) {
        if (_voiceButton.selected == YES) {
            [self userTouchVoiceButton:_voiceButton];
        }
        if (_voiceButton.selected == NO && _secondNumber > 0 && _progressView.progress < 1) {
            [self resumeVoiceTimer];
        }
        [self endVoiceTimer];
        [self switchToVoiceVoice:NO];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(voiceViewSendVoiceMessage:seconds:)]) {
            [self.delegate voiceViewSendVoiceMessage:_mp3Path seconds:_secondCount];
        }
    }
}

//语音播放-播放按钮
- (void)userTouchVoiceButton:(UIButton *)sender {
    if (_mp3Path.length > 0 && _secondCount > 0) {
        if (sender.selected == NO) {
            if (_secondNumber > 0 && _progressView.progress > 0) {
                [[LCCKAVAudioPlayer sharePlayer] resumeAudioPlayer];
                [self resumeVoiceTimer];
            } else {
                [[LCCKAVAudioPlayer sharePlayer] playAudioWithURLString:self.mp3Path identifier:@"EHVoiceRecordView"];
                [self startVoiceTimer];
            }
        } else {
            [self pauseVoiceTimer];
            [[LCCKAVAudioPlayer sharePlayer] pauseAudioPlayer];
        }
        self.voiceButton.selected = !self.voiceButton.selected;
    }
}

// 收起
- (void)userWillHideVoiceRecordView {
    self.recordView.hidden == NO ? [self dismissCurrentViewWhenRecord] : [self dismissCurrentViewWhenVoice];
}

#pragma mark - Private Methods
- (BOOL)checkAVAudioSession {
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

- (void)reloadRecordAndVoiceTitle:(NSInteger)time isRecordType:(BOOL)type {
    NSInteger m = time/60;
    NSInteger s = time-m*60;
    NSString * temp = [NSString stringWithFormat:@"%02zd:%02zd",m,s];
    if (type) {
        self.recordProgressLbl.text = temp;
        self.voiceLbl.text = @"00:00";
    } else {
        self.recordProgressLbl.text = @"00:00";
        self.voiceLbl.text = temp;
    }
}

- (UIImage *)imageInBundlePathForImageName:(NSString *)imageName {
    return   ({
        UIImage *image = [UIImage lcck_imageNamed:imageName bundleName:@"ChatKeyboard" bundleForClass:[self class]];
        image;});
}

// 视图切换
- (void)switchToVoiceVoice:(BOOL)isShow {
    [_progressView setProgress:0.0];
    
    self.recordProgressLbl.text = @"00:00";
    
    self.recordView.hidden = isShow;
    self.voiceView.hidden = !isShow;
}

// 当前界面为录音时 消失
- (void)dismissCurrentViewWhenRecord
{
    if (self.recordButton.selected == YES) {
        [self endRecordTimer];
        [self recordVoicerBtnAction:self.recordButton];
    }
}

// 当前界面为播放时 消失
- (void)dismissCurrentViewWhenVoice
{
    if (_voiceButton.selected == YES) {
        [self userTouchVoiceButton:_voiceButton];
    }
}

#pragma mark -
#pragma mark 录音倒计时
// 录音倒计时开始
- (void)startRecordTimer
{
    __block NSInteger count = 0;
    
    _recordTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(_recordTimer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_recordTimer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (count < kVoiceRecordTimerCount) {
                self.secondCount = count;
                [self reloadRecordAndVoiceTitle:count isRecordType:YES];
                count++;
            } else {
                [self endRecordTimer];
                [self recordVoicerBtnAction:self.recordButton];
            }
        });
    });
    dispatch_resume(_recordTimer);
}

// 录音倒计时结束
- (void)endRecordTimer
{
    if (_recordTimer) {
        dispatch_source_cancel(_recordTimer);
        _recordTimer = nil;
    }
}

#pragma mark 语音播放倒计时
// 环形进度开始
- (void)startVoiceTimer
{
    if (!_timer) {
        //使用全局队列创建计时器
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
        dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, 0.02 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(_timer, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.secondNumber < self.secondCount) {
                    self.secondNumber += 0.02;
                    CGFloat duration = self.secondNumber / self.secondCount;
                    [self.progressView setProgress:duration];
                    [self reloadRecordAndVoiceTitle:self.secondNumber isRecordType:NO];
                } else {
                    [self endVoiceTimer];
                    [self userTouchVoiceButton:self.voiceButton];
                }
            });
        });
    }
    
    dispatch_resume(_timer);
}

// 环形进度结束
- (void)endVoiceTimer
{
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
        _secondNumber = 0;
        [self.progressView setProgress:0];
    }
}

// 环形进度暂停
- (void)pauseVoiceTimer
{
    if (_timer) {
        dispatch_suspend(_timer);
    }
}

// 环形进度继续
- (void)resumeVoiceTimer
{
    if (_timer) {
        dispatch_resume(_timer);
    }
}

@end
