//
//  ChatMessage.m
//  Talk2Me
//
//  Created by Tian Long on 15/09/2014.
//

#import "ChatMessage.h"
#import "ChatLayoutConfigs.h"
#import "NSString+UsedSize.h"
#import "UIColor+Hex.h"
#import "SDImageCache.h"
#import "UIImage+TintColor.h"
#import "TMApi.h"

typedef NS_ENUM(NSUInteger, ChatNotificationsType) {
    
    ChatNotificationsTypeNone,
    ChatNotificationsTypeRoomCreated,
    ChatNotificationsTypeRoomUpdated,
};

NSString *const kNotificationTypeKey = @"notification_type";

@interface ChatMessage()

@property (assign, nonatomic) CGSize messageSize;
@property (assign, nonatomic) ChatMessageType type;
@property (strong, nonatomic) UIColor *balloonColor;
@property (weak, nonatomic) QBChatDialog *chatDialog;

@end

@implementation ChatMessage


- (instancetype)initWithChatHistoryMessage:(QBChatAbstractMessage *)historyMessage {
    
    self = [super init];
    if (self) {
        
        self.minWidth = -1;
        self.text = historyMessage.encodedText;
        self.ID = historyMessage.ID;
        self.recipientID = historyMessage.recipientID;
        self.senderID = historyMessage.senderID;
        self.datetime = historyMessage.datetime;
        self.customParameters = historyMessage.customParameters;
        self.attachments = historyMessage.attachments;
        
        self.chatDialog = [[TMApi instance] chatDialogWithID:historyMessage.cParamDialogID];
        
        NSNumber *notificationType = self.customParameters[kNotificationTypeKey];
        
        if (self.attachments.count > 0) {
            
            self.type = ChatMessageTypePhoto;
            self.layout = ChatMessageAttachmentLayout;
            
        } else if (notificationType) {
//            @throw [NSException exceptionWithName:NSInternalInconsistencyException
//                                           reason:@"Need update it"
//                                         userInfo:@{}];
            self.layout = ChatMessageBubbleLayout;
            self.type = ChatMessageTypeSystem;
            
        } else {
            
            self.type = ChatMessageTypeText;
            self.layout = ChatMessageTalk2MeLayout;
        }
        
    }
    return self;
}

- (CGSize)calculateMessageSize {
    
    ChatMessageLayout layout = self.layout;
    ChatBalloon balloon = self.balloonSettings;
    UIEdgeInsets insets = balloon.imageCapInsets;
    CGSize contentSize = CGSizeZero;
    /**
     Calculate content size
     */
    if (self.minWidth > 0) {
        layout.messageMinWidth = self.minWidth;
    }
    
    if (self.type == ChatMessageTypePhoto) {
        
        contentSize = CGSizeMake(200, 200);
        
    } else if (self.type == ChatMessageTypeText) {
        
        UIFont *font = UIFontFromChatMessageLayout(self.layout);
        
        CGFloat textWidth =
        layout.messageMaxWidth - layout.userImageSize.width - insets.left - insets.right - layout.messageMargin.right - layout.messageMargin.left;
        
        contentSize = [self.text usedSizeForWidth:textWidth
                                             font:font
                                   withAttributes:self.attributes];
        
    }
    
    layout.contentSize = contentSize;   //Set Content size
    self.layout = layout;               //Save Content size for reuse
    
    /**
     *Calculate message size
     */
    CGSize messageSize = contentSize;
    
    messageSize.height += layout.messageMargin.top + layout.messageMargin.bottom + insets.top + insets.bottom + layout.titleHeight;
    messageSize.width += layout.messageMargin.left + layout.messageMargin.right;
    
    if (!CGSizeEqualToSize(layout.userImageSize, CGSizeZero)) {
        if (messageSize.height - (layout.messageMargin.top + layout.messageMargin.bottom) < layout.userImageSize.height) {
            messageSize.height = layout.userImageSize.height + layout.messageMargin.top + layout.messageMargin.bottom;
        }
    }
    
    return messageSize;
}

- (CGSize)messageSize {
    
    if (CGSizeEqualToSize(_messageSize, CGSizeZero)) {
        
        _messageSize = [self calculateMessageSize];
    }
    
    return _messageSize;
}

- (UIImage *)balloonImage {
    
    ChatBalloon balloon = [self balloonSettings];
    
    UIImage *balloonImage = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:balloon.imageName];
    
    if (!balloonImage) {
        
        balloonImage = [UIImage imageNamed:balloon.imageName];
        balloonImage = [balloonImage tintImageWithColor:self.balloonColor];
        balloonImage = [balloonImage resizableImageWithCapInsets:balloon.imageCapInsets];
        [[SDImageCache sharedImageCache]  storeImage:balloonImage forKey:balloon.imageName toDisk:NO];
    }

    return balloonImage;
}

- (ChatBalloon)balloonSettings {
    
    if (self.align == ChatMessageContentAlignLeft) {
        return self.layout.leftBalloon;
    } else if (self.align == ChatMessageContentAlignRight) {
        return self.layout.rightBalloon;
    }
    
    return ChatBalloonNull;
}

- (UIColor *)textColor {
    
    ChatBalloon balloonSettings = [self balloonSettings];
    NSString *hexString = balloonSettings.textColor;
    
    if (hexString.length > 0) {
        
        UIColor *color = [UIColor colorWithHexString:hexString];
        NSAssert(color, @"Check it");
        return color;
    }
    
    return nil;
}

- (UIColor *)balloonColor {
    
    if (!_balloonColor) {
        
        ChatBalloon balloonSettings = [self balloonSettings];
        NSString *hexString = balloonSettings.hexTintColor;
        
        if (hexString.length > 0) {
            
            UIColor *color = [UIColor colorWithHexString:hexString];
            NSAssert(color, @"Check it");
            
            _balloonColor = color;
        }
    }
    
    return _balloonColor;
}

@end
