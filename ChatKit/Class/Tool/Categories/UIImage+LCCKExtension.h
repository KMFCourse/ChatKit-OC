//
//  UIImage+LCCKExtension.h
//  LeanCloudChatKit-iOS
//
//  v0.8.5 Created by ElonChan on 16/5/7.
//  Copyright © 2016年 LeanCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSBundle+LCCKExtension.h"

@interface UIImage (LCCKExtension)

- (UIImage *)lcck_imageByScalingAspectFill;

- (UIImage *)lcck_imageByScalingAspectFillWithOriginSize:(CGSize)originSize;

- (UIImage *)lcck_imageByScalingAspectFillWithOriginSize:(CGSize)originSize
                                               limitSize:(CGSize)limitSize;

+ (UIImage *)lcck_imageNamed:(NSString *)imageName bundleName:(NSString *)bundleName bundleForClass:(Class)aClass;
+ (UIImage *)lcck_imageNamed:(NSString *)name;

- (UIImage *)lcck_scalingPatternImageToSize:(CGSize)size;

+ (instancetype)lcck_imageWithColor:(UIColor *)color;//从颜色返回图像
@end
