//
//  LCCKChatFaceView.h
//  LCCKChatBarExample
//
//  v0.8.5 Created by ElonChan ( https://github.com/leancloud/ChatKit-OC ) on 15/8/21.
//  Copyright (c) 2015年 https://LeanCloud.cn . All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LCCKShowFaceViewType) {
    LCCKShowEmojiFace = 0,
    LCCKShowRecentFace,
    LCCKShowGifFace,
};

#define kLCCKTopLineBackgroundColor  [UIColor colorWithRed:219/255.0 green:219/255.0 blue:219/255.0 alpha:1.0f]

@protocol LCCKChatFaceViewDelegate <NSObject>

- (void)faceViewSendFace:(NSString *)faceName;

@end

@interface LCCKChatFaceView : UIView

@property (weak, nonatomic) id<LCCKChatFaceViewDelegate> delegate;
@property (assign, nonatomic) LCCKShowFaceViewType faceViewType;

@end
