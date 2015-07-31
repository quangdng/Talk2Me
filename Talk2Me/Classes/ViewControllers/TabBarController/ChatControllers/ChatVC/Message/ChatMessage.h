//
//  ChatMessage.h
//  Talk2Me
//
//  Created by Tian Long on 15/09/2014.
//

#import <Foundation/Foundation.h>
#import "ChatLayoutConfigs.h"
#import "ChatMessageType.h"

@interface ChatMessage : QBChatHistoryMessage
/**
 * Attributes for attributed message text
 */
@property (strong, nonatomic) NSDictionary *attributes;
/**
 QBChatDialog
 */
@property (weak, nonatomic, readonly) QBChatDialog *chatDialog;
/**
 * Balloon image
 */
@property (strong, nonatomic, readonly) UIImage *balloonImage;
/**
 Ballon color (Load from layout property)
 */
@property (strong, nonatomic, readonly) UIColor *balloonColor;

- (UIColor *)textColor ;
/**
 This is important property
 */
@property (nonatomic) struct ChatMessageLayout layout;
/**
 */
@property (nonatomic, readonly) ChatBalloon balloonSettings;
/**
 Calculate and cached message size
 */
@property (nonatomic, readonly) CGSize messageSize;
/**
 * Type of message.
 * Available values:
 * ChatMessageTypeText, ChatMessageTypePhoto
 */
@property (nonatomic, readonly) ChatMessageType type;
/**
 * Align message container
 * Available values:
 * ChatMessageContentAlignLeft, ChatMessageContentAlignRight, ChatMessageContentAlignCenter
 * This is important property and will be used to decide in which side show message.
 */
@property (nonatomic) ChatMessageContentAlign align;
/**
 if -1 then minWidht getting from layout property
 */
@property (nonatomic) CGFloat minWidth;

@property (nonatomic, readonly) NSString *encodingText;

- (instancetype)initWithChatHistoryMessage:(QBChatAbstractMessage *)historyMessage;

@end
