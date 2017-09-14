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

#if __has_include(<EHCircularProgressView.h>)
#import <EHCircularProgressView.h>
#else
#import "EHCircularProgressView.h"
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

@interface LCCKChatVoiceView ()<Mp3RecorderDelegate>
{
    dispatch_source_t _timer;
}

@property (strong, nonatomic) Mp3Recorder *MP3;
@property (copy, nonatomic) NSString *mp3Path;
@property (assign, nonatomic) NSInteger secondCount;

@property (strong, nonatomic) UIView *recordView;//录音界面
@property (strong, nonatomic) UIButton *recordButton;
@property (strong, nonatomic) UILabel *recordLbl;

@property (strong, nonatomic) UIView *voiceView;//试听界面
@property (strong, nonatomic) UIButton *voiceButton;
@property (strong, nonatomic) UILabel *voiceLbl;
@property (strong, nonatomic) EHCircularProgressView *progressView;

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
    self.MP3 = [[Mp3Recorder alloc] initWithDelegate:self];
    
    [self addLineView];
    
    [self.recordView addSubview:self.recordLbl];
    [self.recordView addSubview:self.recordButton];
    
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
    
    [self.recordLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(16);
        make.left.and.right.mas_equalTo(self);
        make.height.mas_equalTo(16);
    }];
    
    [self.recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.recordLbl.mas_bottom).offset(16);
        make.width.and.height.mas_equalTo(100);
        make.centerX.mas_equalTo(self.mas_centerX);
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
        make.width.height.mas_equalTo(self.voiceButton).offset(5);
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


#pragma mark - Getters

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
        _recordLbl.text = @"按住开始录制";
        _recordLbl.font = [UIFont systemFontOfSize:16.f];
        _recordLbl.textColor = kLCCKHexRGB(0xA5A5A5);
        _recordLbl.textAlignment = NSTextAlignmentCenter;
    }
    return _recordLbl;
}

- (UIButton *)recordButton {
    if (!_recordButton) {
        _recordButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _recordButton.layer.masksToBounds = YES;
        _recordButton.layer.cornerRadius = _recordButton.frame.size.width/2;
        _recordButton.layer.borderColor = kLCCKHexRGB(0xDBDBDB).CGColor;
        _recordButton.layer.borderWidth = 5;
        [_recordButton setBackgroundImage:[UIImage lcck_imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_recordButton setBackgroundImage:[UIImage lcck_imageWithColor:kLCCKHexRGB(0x3EA0F3)] forState:UIControlStateHighlighted];
        [_recordButton setImage:[self imageInBundlePathForImageName:@"conversation_icon_start"] forState:UIControlStateNormal];
        [_recordButton setImage:[self imageInBundlePathForImageName:@"conversation_icon_starting"] forState:UIControlStateHighlighted];
        
        [_recordButton addTarget:self action:@selector(startRecordVoice) forControlEvents:UIControlEventTouchDown];
        [_recordButton addTarget:self action:@selector(cancelRecordVoice) forControlEvents:UIControlEventTouchUpOutside];
        [_recordButton addTarget:self action:@selector(confirmRecordVoice) forControlEvents:UIControlEventTouchUpInside];
    }
    return _recordButton;
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

- (EHCircularProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[EHCircularProgressView alloc] initWithFrame:CGRectZero];
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;
        _progressView.trackTintColor = kLCCKHexRGB(0xd4d4d4);
        _progressView.progressTintColor = [UIColor colorWithRed:0.612 green:0.604 blue:0.745 alpha:1.000];
        _progressView.innerTintColor = [UIColor clearColor];
        _progressView.thicknessRatio = 0.05;
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
        [self reloadVoiceTitle:fileName];
        [self switchToVoiceVoice:YES];
    }
}

- (void)reloadVoiceTitle:(NSString *)fileName {
    AVURLAsset * audioAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:fileName] options:nil];
    CMTime audioDuration = audioAsset.duration;
    int audioDurationSeconds = (int)CMTimeGetSeconds(audioDuration);
    
    self.secondCount = audioDurationSeconds;
    self.mp3Path = fileName;
    
    int m = audioDurationSeconds/60;
    int s = audioDurationSeconds-m*60;
    if (m >0) {
        self.voiceLbl.text = [NSString stringWithFormat:@"%02d:%02d",m,s];
    } else {
        self.voiceLbl.text = [NSString stringWithFormat:@"00:%02d",s];
    }
}

- (void)failRecord {
    NSLog(@"出现错误");
}

- (void)beginConvert {
    NSLog(@"正在转换");
}

#pragma mark - Action
//开始录音
- (void)startRecordVoice {
    // 判断权限
    if ([self judgeAVAudioSession]) {
        self.recordLbl.text = @"松开完成录制";
        self.recordButton.layer.borderWidth = 0;
        self.recordButton.highlighted = YES;
        [self.MP3 startRecord];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:LCCKNotificationRecordNoPower object:nil];
    }
}

//取消录音
- (void)cancelRecordVoice {
    self.recordButton.highlighted = NO;
    [self.MP3 cancelRecord];
}

//录音结束
- (void)confirmRecordVoice {
    self.recordLbl.text = @"按住进行录制";
    self.recordButton.layer.borderWidth = 5;
    [self.MP3 stopRecord];
}

- (void)switchToVoiceVoice:(BOOL)isShow {
    self.recordView.hidden = isShow;
    self.voiceView.hidden = !isShow;
}

- (void)userTouchCancleAction:(UIButton *)sender {
    [self switchToVoiceVoice:NO];
    [self endHeartbeatPacket];
}

- (void)userTouchSendAction:(UIButton *)sender {
    
    if (_mp3Path.length > 0 && _secondCount > 0) {
        [self endHeartbeatPacket];
        if (self.delegate && [self.delegate respondsToSelector:@selector(voiceViewSendVoiceMessage:seconds:)]) {
            [self.delegate voiceViewSendVoiceMessage:_mp3Path seconds:_secondCount];
        }
    }
}

- (void)userTouchVoiceButton:(UIButton *)sender {
    if (self.mp3Path.length > 0 && self.secondCount > 0) {
        
        if (sender.selected == NO) {
            [[LCCKAVAudioPlayer sharePlayer] playAudioWithURLString:self.mp3Path identifier:@"LCCKVoiceView"];
            self.voiceLbl.text = @"00:00";
            [self startHeartbeatPacket];
        } else {
            [[LCCKAVAudioPlayer sharePlayer] stopAudioPlayer];
            [self endHeartbeatPacket];
            [self reloadVoiceTitle:self.mp3Path];
        }
        self.progressView.progress = 0;
        self.voiceButton.selected = !self.voiceButton.selected;
    }
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

#pragma mark - Heartbeat Packet
// 开始
- (void)startHeartbeatPacket
{
    __block float finishNum = 0;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 0.2 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (finishNum > _secondCount) {
                [[LCCKAVAudioPlayer sharePlayer] stopAudioPlayer];
                [self endHeartbeatPacket];
                
                self.progressView.progress = 0;
                self.voiceButton.selected = NO;
            } else {
                finishNum = finishNum + 0.2;
                
                CGFloat duration = finishNum / _secondCount;
                [_progressView setProgress:duration animated:YES];
                
                int m = finishNum/60;
                int s = finishNum-m*60;
                if (m >0) {
                    self.voiceLbl.text = [NSString stringWithFormat:@"%02d:%02d",m,s];
                } else {
                    self.voiceLbl.text = [NSString stringWithFormat:@"00:%02d",s];
                }
            }
        });
    });
    dispatch_resume(_timer);
}

// 结束
- (void)endHeartbeatPacket
{
    if (_timer) {
        dispatch_source_cancel(_timer);
    }
}

@end
