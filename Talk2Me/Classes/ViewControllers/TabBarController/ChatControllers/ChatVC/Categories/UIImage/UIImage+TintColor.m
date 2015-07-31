//
//  UIImage+TintColor.m
//  Talk2Me
//
//  Created by Saranya Nagarajan on 12/09/2014.
//

#import "UIImage+TintColor.h"

@implementation UIImage (TintColor)

- (UIImage *)tintImageWithColor:(UIColor *)maskColor resizableImageWithCapInsets:(UIEdgeInsets)capInsets {
    
    UIImage *tintImg = [self tintImageWithColor:maskColor];
    return [tintImg resizableImageWithCapInsets:capInsets];
}

- (UIImage *)tintImageWithColor:(UIColor *)maskColor {
    
    NSParameterAssert(maskColor != nil);
    
    CGRect imageRect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);
    
    UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGContextTranslateCTM(context, 0.0f, -(imageRect.size.height));
    
    CGContextClipToMask(context, imageRect, self.CGImage);
    CGContextSetFillColorWithColor(context, maskColor.CGColor);
    CGContextFillRect(context, imageRect);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
