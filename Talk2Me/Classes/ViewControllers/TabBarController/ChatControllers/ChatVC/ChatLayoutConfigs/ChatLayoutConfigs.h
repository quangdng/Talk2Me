//
//  ChatLayoutConfigs.h
//  Talk2Me
//
//  Created by Quang Nguyen on 13/09/2014.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ChatMessageContentAlign) {
    
    ChatMessageContentAlignLeft,
    ChatMessageContentAlignRight,
    ChatMessageContentAlignCenter
};

typedef struct ChatBalloon {
    
    __unsafe_unretained NSString *imageName;
    __unsafe_unretained NSString *hexTintColor;
    __unsafe_unretained NSString *textColor;
    UIEdgeInsets imageCapInsets;
    
} ChatBalloon ;

ChatBalloon ChatBalloonNull;

/**
 Message layout stucture
 */
typedef struct ChatMessageLayout {
    
    UIEdgeInsets messageMargin;
    
    CGFloat messageMaxWidth;
    CGFloat messageMinWidth;
    CGFloat titleHeight;
    
    CGSize contentSize;
    
    CGSize userImageSize;
    
    CGFloat fontSize;
    __unsafe_unretained NSString *fontName;
    
    ChatBalloon leftBalloon;
    ChatBalloon rightBalloon;
    
    
} ChatMessageLayout;

/**
 Examples Of Themes
 ChatMessageTalk2MeLayout - default theme
 ChatMessageBubbleLayout - bubble thme
 */

ChatMessageLayout ChatMessageTalk2MeLayout;
ChatMessageLayout ChatMessageBubbleLayout;
ChatMessageLayout ChatMessageAttachmentLayout;

UIFont * UIFontFromChatMessageLayout(ChatMessageLayout layout);
