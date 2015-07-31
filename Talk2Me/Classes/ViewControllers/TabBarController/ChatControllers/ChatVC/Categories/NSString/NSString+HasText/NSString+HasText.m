//
//  NSString+HasText.m
//  Talk2Me
//
//  Created by He Gui on 12/09/2014.
//

#import "NSString+HasText.h"

@implementation NSString (HasText)

- (NSString *)stringByTrimingWhitespace {
    
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL)hasText {
    
    NSString *trimingStr = [self stringByTrimingWhitespace];
    BOOL hasText = trimingStr.length > 0;
    
    return hasText;
}

@end
