//
//  LCCKChatVoiceView.m
//  Pods
//
//  Created by 岳琛 on 2017/9/11.
//
//

#import "LCCKChatVoiceView.h"

@implementation LCCKChatVoiceView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

#pragma mark - Private Methods
- (void)setupConstraints {
    
}

- (void)setup {
    self.backgroundColor = [UIColor lightGrayColor];
    [self setupConstraints];
}

- (void)setupVoiceView {
    
}

@end
