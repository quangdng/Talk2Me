//
//  MessageBarStyleSheetFactory.m
//  Talk2Me
//
//  Created by Quang Nguyen on 20/08/2014.
//

#import "MessageBarStyleSheetFactory.h"
#import "TMApi.h"


@implementation MessageBarStyleSheetFactory

+ (void)showMessageBarNotificationWithMessage:(QBChatAbstractMessage *)chatMessage chatDialog:(QBChatDialog *)chatDialog completionBlock:(MPGNotificationButtonHandler)block
{
    UIImage *img = nil;
    NSString *title = nil;
    
    if (chatDialog.type ==  QBChatDialogTypeGroup) {
        
        img = [UIImage imageNamed:@"upic_placeholder_details_group"];
        title = chatDialog.name;
    }
    else if (chatDialog.type == QBChatDialogTypePrivate) {
        
        NSUInteger occupantID = [[TMApi instance] occupantIDForPrivateChatDialog:chatDialog];
        QBUUser *user = [[TMApi instance] userWithID:occupantID];
        title = user.fullName;
    }

    MPGNotification *newNotification = [MPGNotification notificationWithTitle:title subtitle:chatMessage.encodedText backgroundColor:[UIColor colorWithRed:0.32 green:0.33 blue:0.34 alpha:0.86] iconImage:img];
    [newNotification setButtonConfiguration:MPGNotificationButtonConfigrationOneButton withButtonTitles:@[@"Reply"]];
    newNotification.duration = 2.0;
    
    newNotification.buttonHandler = block;
    [newNotification show];
}



@end
