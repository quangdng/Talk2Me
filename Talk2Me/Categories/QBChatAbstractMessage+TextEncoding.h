//
//  ChatAbstractMessage+TextEncoding.h
//  Talk2Me
//
//  Created by Quang Nguyen on 20/08/2014.

#import <Quickblox/Quickblox.h>

@interface QBChatAbstractMessage (TextEncoding)

@property (strong, nonatomic, readonly) NSString *encodedText;

@end
