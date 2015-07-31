//
//  MessagesService.h
//  Talk2Me
//
//  Created by Quang Nguyen on 05/09/2014.
//

#import <Foundation/Foundation.h>
#import "BaseService.h"

@interface MessagesService : BaseService

@property (strong, nonatomic) NSDictionary *pushNotification;
@property (strong, nonatomic) QBUUser *currentUser;

- (void)chat:(void(^)(QBChat *chat))chatBlock;
- (void)loginChat:(QBChatResultBlock)block;
- (void)logoutChat;

- (NSArray *)messageHistoryWithDialogID:(NSString *)dialogID;
- (void)addMessageToHistory:(QBChatMessage *)message withDialogID:(NSString *)dialogID;

/**
 Send message
 
 @param message QBChatMessage structure which contains message text and recipient id
 @return YES if the request was sent successfully. If not - see log.
 */
- (void)sendMessage:(QBChatMessage *)message withDialogID:(NSString *)dialogID saveToHistory:(BOOL)save completion:(void(^)(NSError *error))completion;

/**
 Send chat message to room
 
 @param message Message body
 @param room Room to send message
 @return YES if the request was sent successfully. If not - see log.
 */
- (void)sendChatMessage:(QBChatMessage *)message withDialogID:(NSString *)dialogID toRoom:(QBChatRoom *)chatRoom completion:(void(^)(void))completion ;

- (void)messagesWithDialogID:(NSString *)dialogID completion:(QBChatHistoryMessageResultBlock)completion;

@end
