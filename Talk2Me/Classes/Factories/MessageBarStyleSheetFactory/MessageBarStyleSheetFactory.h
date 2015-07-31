//
//  MessageBarStyleSheetFactory.h
//  Talk2Me
//
//  Created by Quang Nguyen on 20/08/2014.
//

#import <Foundation/Foundation.h>
#import "MPGNotification.h"

@interface MessageBarStyleSheetFactory : NSObject

+ (void)showMessageBarNotificationWithMessage:(QBChatAbstractMessage *)chatMessage chatDialog:(QBChatDialog *)chatDialog completionBlock:(MPGNotificationButtonHandler)block;

@end
