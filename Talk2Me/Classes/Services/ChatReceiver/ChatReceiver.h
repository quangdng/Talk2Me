//
//  ChatReceiver.h
//  Talk2Me
//
//  Created by Quang Nguyen on 02/09/2014.
//

#import <Foundation/Foundation.h>
#import "ServiceProtocol.h"

typedef void(^DialogsHistoryUpdated)(void);
typedef void(^UsersHistoryUpdated)(void);

typedef void(^ChatDidLogin)(BOOL success);
typedef void(^ChatDidFailLogin)(NSInteger errorCode);
typedef void(^ChatMessageBlock)(QBChatMessage *message);
typedef void(^ChatDidReceivePresenceOfUser)(NSUInteger userID, NSString *type);
typedef void(^ChatDidReceiveListOfRooms)(NSArray *rooms);
typedef void(^ChatRoomDidReceiveMessage)(QBChatMessage *message, NSString *roomJID);
typedef void(^ChatRoomDidReceiveInformation)(NSDictionary *information, NSString *roomJID, NSString *roomName);
typedef void(^ChatRoomDidCreate)(NSString *roomName);
typedef void(^ChatRoomDidEnter)(QBChatRoom *room);
typedef void(^ChatRoomDidNotEnter)(NSString *roomName, NSError *error);
typedef void(^ChatRoomDidLeave)(NSString *roomName);
typedef void(^ChatRoomDidDestroy)(NSString *roomName);
typedef void(^ChatRoomDidChangeOnlineUsers)(NSArray *onlineUsers, NSString *roomName);
typedef void(^ChatRoomDidReceiveListOfUsers)(NSArray *users, NSString *roomName);
typedef void(^ChatRoomDidReceiveListOfOnlineUsers)(NSArray *users, NSString *roomName);
typedef void(^ChatDidReceiveCallRequest)(NSUInteger userID, NSString *sessionID, enum QBVideoChatConferenceType conferenceType);
typedef void(^ChatDidReceiveCallRequestCustomParams)(NSUInteger userID, NSString *sessionID, enum QBVideoChatConferenceType conferenceType, NSDictionary *customParameters);
typedef void(^ChatCallUserDidNotAnswer)(NSUInteger userID);
typedef void(^ChatCallDidAcceptByUser)(NSUInteger userID);
typedef void(^ChatCallDidAcceptByUserCustomParams)(NSUInteger userID, NSDictionary *customParameters);
typedef void(^ChatCallDidRejectByUser)(NSUInteger userID);
typedef void(^ChatCallDidStopByUser)(NSUInteger userID, NSString *status);
typedef void(^ChatCallDidStopByUserCustomParams)(NSUInteger userID, NSString *status, NSDictionary *customParameters);
typedef void(^ChathatCallDidStartWithUser)(NSUInteger userID, NSString *sessionID);
typedef void(^DidStartUseTURNForVideoChat)(void);
typedef void(^ChatDidReceiveContactAddRequest)(NSUInteger userID);
typedef void(^ChatContactListDidChange)(QBContactList * contactList);
typedef void(^ChatContactListWillChange)(void);
typedef void(^ChathatDidReceiveContactItemActivity)(NSUInteger userID, BOOL isOnline, NSString *status);

@interface ChatReceiver : NSObject <QBChatDelegate>

+ (instancetype)instance;

- (void)unsubscribeForTarget:(id)target;
- (void)subsribeWithTarget:(id)target selector:(SEL)selector block:(id)block;
- (void)executeBloksWithSelector:(SEL)selector enumerateBloks:(void(^)(id block))enumerateBloks;

/**
 ChatService
 */
- (void)chatDidLoginWithTarget:(id)target block:(ChatDidLogin)block;
- (void)chatDidNotLoginWithTarget:(id)target block:(ChatDidLogin)block;
- (void)chatDidFailWithTarget:(id)target block:(ChatDidFailLogin)block;
- (void)chatDidReceiveMessageWithTarget:(id)target block:(ChatMessageBlock)block;
- (void)chatAfterDidReceiveMessageWithTarget:(id)target block:(ChatMessageBlock)block;
- (void)chatDidNotSendMessageWithTarget:(id)target block:(ChatMessageBlock)block;
- (void)chatDidReceivePresenceOfUserWithTarget:(id)target block:(ChatDidReceivePresenceOfUser)block;
/**
 ContactList
 */
- (void)chatDidReceiveContactAddRequestWithTarget:(id)target block:(ChatDidReceiveContactAddRequest)block;
- (void)chatContactListDidChangeWithTarget:(id)target block:(ChatContactListDidChange)block;
- (void)chatContactListDidChange:(QBContactList *)contactList;
- (void)chatContactListUpdatedWithTarget:(id)target block:(ChatContactListWillChange)block;
- (void)chatDidReceiveContactItemActivityWithTarget:(id)target block:(ChathatDidReceiveContactItemActivity)block;
/**
 ChatRoom
 */
- (void)chatDidReceiveListOfRoomsWithTarget:(id)target block:(ChatDidReceiveListOfRooms)block;
- (void)chatRoomDidReceiveMessageWithTarget:(id)target block:(ChatRoomDidReceiveMessage)block;
- (void)chatRoomDidReceiveInformationWithTarget:(id)target block:(ChatRoomDidReceiveInformation)block;
- (void)chatRoomDidCreateWithTarget:(id)target block:(ChatRoomDidCreate)block;
- (void)chatRoomDidEnterWithTarget:(id)target block:(ChatRoomDidEnter)block;
- (void)chatRoomDidNotEnterWithTarget:(id)target block:(ChatRoomDidNotEnter)block;
- (void)chatRoomDidLeaveWithTarget:(id)target block:(ChatRoomDidLeave)block;
- (void)chatRoomDidDestroyWithTarget:(id)target block:(ChatRoomDidDestroy)block;
- (void)chatRoomDidChangeOnlineUsersWithTarget:(id)target block:(ChatRoomDidChangeOnlineUsers)block;
- (void)chatRoomDidReceiveListOfUsersWithTarget:(id)target block:(ChatRoomDidReceiveListOfUsers)block;
- (void)chatRoomDidReceiveListOfOnlineUsersWithTarget:(id)target block:(ChatRoomDidReceiveListOfOnlineUsers)block;

@end

@interface ChatReceiver (DialogsHistoryUpdated)

- (void)postDialogsHistoryUpdated;
- (void)dialogsHisotryUpdatedWithTarget:(id)target block:(DialogsHistoryUpdated)block;

@end


@interface ChatReceiver (UsersHistoryUpdated)

- (void)postUsersHistoryUpdated;
- (void)usersHistoryUpdatedWithTarget:(id)target block:(UsersHistoryUpdated)block;
- (void)contactRequestUsersListChanged;
- (void)contactRequestUsersListChangedWithTarget:(id)target block:(UsersHistoryUpdated)block;

@end
