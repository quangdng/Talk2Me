//
//  NSString+UsedSize.h
//  Talk2Me
//
//  Created by He Gui on 12/09/2014.
//

#import <Foundation/Foundation.h>

@interface NSString (UsedSize)

- (CGSize)usedSizeForWidth:(CGFloat)width font:(UIFont *)font withAttributes:(NSDictionary *)attributes;

@end
