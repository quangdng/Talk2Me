//
//  ChatDialogsService.m
//  Talk2Me
//
//  Created by Quang Nguyen on 05/09/2014.
//

#import "ChatDialogsService.h"
#import "TMEchoObject.h"
#import "ChatReceiver.h"
//#import "NSString+occupantsIDsFromMessage.h"

@interface ChatDialogsService()

@property (strong, nonatomic) NSMutableDictionary *dialogs;
@property (strong, nonatomic) NSMutableDictionary *rooms;

@end

@implementation ChatDialogsService

- (void)start {
    [super start];
    
    self.dialogs = [NSMutableDictionary dictionary];
    self.rooms = [NSMutableDictionary dictionary];
    
    __weak __typeof(self)weakSelf = self;
    [[ChatReceiver instance] chatRoomDidReceiveMessageWithTarget:self block:^(QBChatMessage *message, NSString *roomJID) {
        [weakSelf updateOrCreateDialogWithMessage:message];
    }];
    
    [[ChatReceiver instance] chatDidReceiveMessageWithTarget:self block:^(QBChatMessage *message) {
        [weakSelf updateOrCreateDialogWithMessage:message];
    }];
}

- (void)stop {
    [super stop];
    
    [[ChatReceiver instance] unsubscribeForTarget:self];
    
    [self.rooms removeAllObjects];
    [self.dialogs removeAllObjects];
}

- (void)fetchAllDialogs:(QBDialogsPagedResultBlock)completion {
    
    QBDialogsPagedResultBlock resultBlock = ^(QBDialogsPagedResult *result) {
        completion(result);
        [[ChatReceiver instance] postDialogsHistoryUpdated];
    };
    
    [QBChat dialogsWithDelegate:[TMEchoObject instance] context:[TMEchoObject makeBlockForEchoObject:resultBlock]];
}

- (void)createChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResultBlock)completion {
    
	[QBChat createDialog:chatDialog delegate:[TMEchoObject instance] context:[TMEchoObject makeBlockForEchoObject:completion]];
}

- (void)updateChatDialogWithID:(NSString *)dialogID extendedRequest:(NSMutableDictionary *)extendedRequest completion:(QBChatDialogResultBlock)completion {
    
    [QBChat updateDialogWithID:dialogID
               extendedRequest:extendedRequest
                      delegate:[TMEchoObject instance]
                       context:[TMEchoObject makeBlockForEchoObject:completion]];
}

- (void)addDialogs:(NSArray *)dialogs {
    
    for (QBChatDialog *chatDialog in dialogs) {
        [self addDialogToHistory:chatDialog];
    }
}

- (QBChatDialog *)chatDialogWithRoomJID:(NSString *)roomJID {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.roomJID == %@", roomJID];
    NSArray *allDialogs = [self dialogHistory];
    
    QBChatDialog *dialog = [allDialogs filteredArrayUsingPredicate:predicate].firstObject;
    return dialog;
}

//- (void)updateChatDialog:(QBChatDialog *)chatDialog
//{
//    self.dialogs[chatDialog.ID] = chatDialog;
//}

- (QBChatDialog *)chatDialogWithID:(NSString *)dialogID {
    return self.dialogs[dialogID];
}

- (void)addDialogToHistory:(QBChatDialog *)chatDialog {
    
    //If dialog type is equal group then need join room
    if (chatDialog.type == QBChatDialogTypeGroup) {
        
       __unused NSString *roomJID = chatDialog.roomJID;
        if (!self.rooms[roomJID]) {
            
            NSAssert(roomJID, @"Need update this case");
            
            QBChatRoom *room = chatDialog.chatRoom;
            [room joinRoomWithHistoryAttribute:@{@"maxstanzas": @"0"}];
            self.rooms[chatDialog.roomJID] = room;
        }
        
    } else if (chatDialog.type == QBChatDialogTypePrivate) {
        
    }
    
    self.dialogs[chatDialog.ID] = chatDialog;
}

- (NSArray *)dialogHistory {
    
    NSArray *dialogs = [self.dialogs allValues];
    return dialogs;
}

- (QBChatDialog *)privateDialogWithOpponentID:(NSUInteger)opponentID {
    
    NSArray *allDialogs = [self dialogHistory];
    
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"SELF.type == %d AND SUBQUERY(SELF.occupantIDs, $userID, $userID == %@).@count > 0", QBChatDialogTypePrivate, @(opponentID)];
    
    NSArray *result = [allDialogs filteredArrayUsingPredicate:predicate];
    QBChatDialog *dialog = result.firstObject;
    
    return dialog;
}


- (void)updateChatDialogWithChatMessage:(QBChatMessage *)chatMessage {
    
    QBChatDialog *dialog = self.dialogs[chatMessage.cParamDialogID];
    if (dialog == nil) {
        NSAssert(!dialog, @"Dialog you are looking for not found.");
        return;
    }
    
    dialog.name = chatMessage.cParamDialogName;
//    dialog.occupantIDs = [chatMessage.cParamDialogOccupantsIDs occupantsIDs];
}

- (void)updateOrCreateDialogWithMessage:(QBChatMessage *)message {
    
    if (message.cParamNotificationType == 3) {
        return;
    }
    NSAssert(message.cParamDialogID, @"Need update this case");
    
    if (message.cParamNotificationType == MessageNotificationTypeCreateDialog) {
        
        QBChatDialog *chatDialog = [message chatDialogFromCustomParameters];
        [self addDialogToHistory:chatDialog];
    }
    else if (message.cParamNotificationType == MessageNotificationTypeUpdateDialog) {
        
        [self updateChatDialogWithChatMessage:message];
    }
    else {
        
        QBChatDialog *dialog = [self chatDialogWithID:message.cParamDialogID];
        dialog.lastMessageText = message.encodedText;
        dialog.lastMessageDate = [NSDate dateWithTimeIntervalSince1970:message.cParamDateSent.doubleValue];
        dialog.unreadMessagesCount++;
    }
}

#pragma mark - Chat Room

- (QBChatRoom *)chatRoomWithRoomJID:(NSString *)roomJID {
    
    QBChatRoom *room = self.rooms[roomJID];
    NSAssert(room, @"Need update this case");

    return room;
}

- (void)leaveFromRooms {
    
    NSArray *allRooms = [self.rooms allValues];
    for (QBChatRoom *room in allRooms) {
       
        if (room.isJoined) {
            [room leaveRoom];
            [self.rooms removeObjectForKey:room.JID];
        }
    }
}

- (void)joinRooms {
    
    NSArray *allDialogs = [self dialogHistory];
    for (QBChatDialog *dialog in allDialogs) {
        
        if (dialog.roomJID) {
            
            QBChatRoom *room = dialog.chatRoom;
            [room joinRoomWithHistoryAttribute:@{@"maxstanzas": @"0"}];

            self.rooms[dialog.roomJID] = room;
        }
    }
}

@end
