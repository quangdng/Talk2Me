//
//  UIImage+TintColor.h
//  Talk2Me
//
//  Created by Saranya Nagarajan on 12/09/2014.
//

#import <UIKit/UIKit.h>

@interface UIImage (TintColor)

- (UIImage *)tintImageWithColor:(UIColor *)maskColor;
- (UIImage *)tintImageWithColor:(UIColor *)maskColor resizableImageWithCapInsets:(UIEdgeInsets)capInsets NS_AVAILABLE_IOS(5_0);

@end
