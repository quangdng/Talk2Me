//
//  ChatSection.h
//  Talk2Me
//
//  Created by Yepeng Fan on 15/09/2014.
//

#import <Foundation/Foundation.h>

@class ChatMessage;

@interface ChatSection : NSObject

@property (nonatomic, assign, readonly) NSInteger identifier;
@property (nonatomic,strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSMutableArray *messages;

- (id)initWithDate:(NSDate *)date;
+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;
- (void)addMessage:(ChatMessage *)message;

@end
