//
//  ChatLayoutConfigs.m
//  Talk2Me
//
//  Created by Quang Nguyen on 13/09/2014.
//

#import "ChatLayoutConfigs.h"

const CGFloat kMessageMaxWidth = 310;
const CGFloat kMessageMinWidth = 150;

struct ChatBalloon ChatBalloonNull = {
    
    .imageName = @"",
    .hexTintColor = @"",
    .imageCapInsets= (UIEdgeInsets){0, 0, 0, 0},
};

struct ChatMessageLayout ChatMessageTalk2MeLayout = {
    
    .messageMargin = {
        .top = 15,
        .left = 5,
        .bottom = 5,
        .right = 5,
    },
    .titleHeight = 13,
    .messageMaxWidth = kMessageMaxWidth,
    .messageMinWidth = kMessageMinWidth,
    .userImageSize = (CGSize){50, 50},
    
    .fontName = @"HelveticaNeue",
    .fontSize = 16,

    .leftBalloon = {
        .imageName = @"_balloon_left",
        .imageCapInsets= (UIEdgeInsets){7, 13, 8, 7},
        .hexTintColor = @"#e2ebf2",
        .textColor = @"#000"
    },
    
    .rightBalloon = {
        .imageName = @"_balloon_right",
        .imageCapInsets = (UIEdgeInsets){7, 7, 8, 13},
        .hexTintColor = @"#17d14b",
        .textColor = @"#FFFFFF"
    },
};

struct ChatMessageLayout ChatMessageBubbleLayout = {
    .messageMargin = {
        .top = 5,
        .left = 5,
        .bottom = 5,
        .right = 5,
    },
    .titleHeight = 13,
    .messageMaxWidth = kMessageMaxWidth,
    .messageMinWidth = kMessageMinWidth,
    .userImageSize = (CGSize){50, 50},
    
    .fontName = @"HelveticaNeue",
    .fontSize = 16,
    
    .leftBalloon = {
        .imageName = @"_balloon_left",
        .imageCapInsets= (UIEdgeInsets){7, 13, 8, 7},
        .hexTintColor = @"#e2ebf2",
        .textColor = @"#000"
    },
    
    .rightBalloon = {
        .imageName = @"_balloon_right",
        .imageCapInsets = (UIEdgeInsets){7, 7, 8, 13},
        .hexTintColor = @"#17d14b",
        .textColor = @"#FFFFFF"
    },
};

struct ChatMessageLayout ChatMessageAttachmentLayout = {
    
    .messageMargin = {
        .top = 15,
        .left = 5,
        .bottom = 5,
        .right = 5,
    },
    
    .messageMaxWidth = kMessageMaxWidth,

    .userImageSize = (CGSize){50,50},
    
    .fontName = @"HelveticaNeue-Light",
    .fontSize = 16,
    
    .leftBalloon = {
        .imageName = @"_balloon_left",
        .imageCapInsets= (UIEdgeInsets){7, 13, 8, 7},
        .hexTintColor = @"#e2ebf2",
        .textColor = @"#000"
    },
    
    .rightBalloon = {
        .imageName = @"_balloon_right",
        .imageCapInsets = (UIEdgeInsets){7, 7, 8, 13},
        .hexTintColor = @"#17d14b",
        .textColor = @"#FFFFFF"
    },
};

UIFont * UIFontFromChatMessageLayout(ChatMessageLayout layout) {
    
    return [UIFont fontWithName:layout.fontName size:layout.fontSize];
}