//
//  UIColor+Hex.h
//  Talk2Me
//
//  Created by Yepeng Fan on 12/09/2014.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

/**
 takes @"#123456"
 */
+ (UIColor *)colorWithHex:(UInt32)col;

/**
 takes 0x123456
 */
+ (UIColor *)colorWithHexString:(NSString *)str;

@end
