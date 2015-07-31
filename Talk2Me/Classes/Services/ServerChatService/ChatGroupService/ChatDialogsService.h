//
//  ChatDialogsService.h
//  Talk2Me
//
//  Created by Quang Nguyen on 05/09/2014.
//

#import <Foundation/Foundation.h>
#import "BaseService.h"

@interface ChatDialogsService : BaseService

- (void)fetchAllDialogs:(QBDialogsPagedResultBlock)completion;
- (void)createChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResultBlock)completionl;
- (void)updateChatDialogWithID:(NSString *)dialogID extendedRequest:(NSMutableDictionary *)extendedRequest completion:(QBChatDialogResultBlock)completion;
//- (void)updateChatDialog:(QBChatDialog *)chatDialog;

- (NSArray *)dialogHistory;
- (void)addDialogToHistory:(QBChatDialog *)chatDialog;
- (void)addDialogs:(NSArray *)dialogs;
- (QBChatDialog *)privateDialogWithOpponentID:(NSUInteger)opponentID;
- (QBChatDialog *)chatDialogWithID:(NSString *)dialogID;
- (QBChatRoom *)chatRoomWithRoomJID:(NSString *)roomJID;

- (void)leaveFromRooms;
- (void)joinRooms;

@end
