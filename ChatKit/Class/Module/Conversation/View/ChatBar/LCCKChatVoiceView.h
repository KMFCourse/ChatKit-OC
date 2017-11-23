//
//  LCCKChatVoiceView.h
//  Pods
//
//  Created by 岳琛 on 2017/9/11.
//
//

#import <UIKit/UIKit.h>

@protocol LCCKChatVoiceViewDelegate <NSObject>

- (void)voiceViewSendVoiceMessage:(NSString *)mp3Path seconds:(NSTimeInterval )second;

@end

@interface LCCKChatVoiceView : UIView

@property (weak, nonatomic) id<LCCKChatVoiceViewDelegate> delegate;

- (void)userWillHideVoiceRecordView;

@end
