//
//  ChatAbstractMessage+TextEncoding.m
//  Talk2Me
//
//  Created by Quang Nguyen on 20/08/2014.

#import "QBChatAbstractMessage+TextEncoding.h"
#import "NSString+GTMNSStringHTMLAdditions.h"
#import <objc/runtime.h>

static const char encodedTextKey;

@implementation QBChatAbstractMessage (TextEncoding)

-(NSString *)encodedText {

    NSString *text = objc_getAssociatedObject(self, &encodedTextKey);
    
    if (!text){
        text = [self.text gtm_stringByUnescapingFromHTML];
        objc_setAssociatedObject(self, &encodedTextKey, text, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    }
    
    return text;
}


@end
