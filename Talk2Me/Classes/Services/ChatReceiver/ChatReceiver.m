//
//  ChatReceiver.m
//  Talk2Me
//
//  Created by Quang Nguyen on 02/09/2014.
//

#import "ChatReceiver.h"
#import "NSString+GTMNSStringHTMLAdditions.h"
#import "TMApi.h"

@interface ChatHandlerObject : NSObject

@property (weak, nonatomic) id target;
@property (strong, nonatomic) id callback;
@property (assign, nonatomic) NSUInteger identifier;
@property (strong, nonatomic) NSString *className;
@property (strong, nonatomic) NSString *tcmd;

@end

@implementation ChatHandlerObject

- (void)dealloc {
    ILog(@"%@ %@", self.description, NSStringFromSelector(_cmd));
}

- (NSString *)description {
    
    return [NSString stringWithFormat:
            @"cmd - %@, callback - %@, identfier - %d, targetClass - %@",
            self.tcmd, self.callback, self.identifier, self.className];
}

- (BOOL)isEqual:(ChatHandlerObject *)other {
    
    if(other == self || [super isEqual:other] || [self.target isEqual:other.target] || self.identifier == other.identifier){
        return YES;
    }
    return NO;
}

- (NSUInteger)hash {
    return self.identifier;
}

@end

@interface ChatReceiver()

@property (strong, nonatomic) NSMutableDictionary *handlerList;

@end

@implementation ChatReceiver

+ (instancetype)instance {
    
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.handlerList = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)unsubscribeForTarget:(id)target {
    
    NSArray *allHendlers = [self.handlerList allValues];
    
    NSUInteger identifier = [target hash];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SUBQUERY(self, $x, $x.identifier == %d).@count != 0", identifier];
    NSArray *result = [allHendlers filteredArrayUsingPredicate:predicate];
    
    for (NSMutableSet *handlers in result) {
    
        NSMutableSet *minusSet = [NSMutableSet set];
        
        for (ChatHandlerObject *handler in handlers) {
            
            if (handler.identifier == identifier) {
                [minusSet addObject:handler];
            }
        }
        
        [handlers minusSet:minusSet];
    }
}

- (void)subsribeWithTarget:(id)target selector:(SEL)selector block:(id)block {
    
    NSString *key = NSStringFromSelector(selector);
    NSMutableSet *handlers = self.handlerList[key];
    
    if (!handlers) {
        handlers = [NSMutableSet set];
    }
    
    ChatHandlerObject *handler = [[ChatHandlerObject alloc] init];
    handler.callback = [block copy];
    handler.target = target;
    handler.identifier = [target hash];
    handler.className = NSStringFromClass([target class]);
    handler.tcmd = key;
    
#if _TEST
    if (handlers.count > 0)
    for (ChatHandlerObject * test_handler in handlers) {
        NSAssert(![test_handler isEqual:handler], @"Check this case");
    }
#endif
    
    ILog(@"Subscribe:%@", [handler description]);
    [handlers addObject:handler];
    self.handlerList[key] = handlers;
}

- (void)executeBloksWithSelector:(SEL)selector enumerateBloks:(void(^)(id block))enumerateBloks {
    
    NSString *key = NSStringFromSelector(selector);

    NSMutableSet *toExecute = self.handlerList[key];
    
    for (ChatHandlerObject *handler in toExecute) {
        if (handler.callback) {
            ILog(@"Send %@ notification to %@", key, handler.target);
            enumerateBloks(handler.callback);
        }
    }
}

#pragma mark - ChatService

/**
 didLogin fired by QBChat when connection to service established and login is successfull
 */
- (void)chatDidLoginWithTarget:(id)target block:(ChatDidLogin)block {
    [self subsribeWithTarget:target selector:@selector(chatDidLogin) block:block];
}

- (void)chatDidLogin {
    ILog(@"Chat Did login");
    [self executeBloksWithSelector:_cmd enumerateBloks:^(ChatDidLogin block) {
        block(YES);
    }];
}

/**
 didNotLogin fired when login process did not finished successfully
 */

- (void)chatDidNotLoginWithTarget:(id)target block:(ChatDidLogin)block {
    [self subsribeWithTarget:target selector:@selector(chatDidNotLogin) block:block];
}

- (void)chatDidNotLogin {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(ChatDidLogin block) {
        block(NO);
    }];
}

/**
 didNotSendMessage fired when message cannot be send to user
 
 @param message Message passed to sendMessage method into QBChat
 */

- (void)chatDidNotSendMessageWithTarget:(id)target block:(ChatMessageBlock)block {
    [self subsribeWithTarget:target selector:@selector(chatDidNotSendMessage:) block:block];
}

- (void)chatDidNotSendMessage:(QBChatMessage *)message {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(ChatMessageBlock block) {
        block(message);
    }];
}

/**
 didReceiveMessage fired when new message was received from QBChat
 
 @param message Message received from Chat
 */

- (void)chatDidReceiveMessageWithTarget:(id)target block:(ChatMessageBlock)block {
    [self subsribeWithTarget:target selector:@selector(chatDidReceiveMessage:) block:block];
}

- (void)chatDidReceiveMessage:(QBChatMessage *)message {
    message.text = [message.text gtm_stringByUnescapingFromHTML];
    
    [self executeBloksWithSelector:_cmd enumerateBloks:^(ChatMessageBlock block) {
        block(message);
    }];
    [self chatAfterDidReceiveMessage:message];
}

- (void)chatDidDeliverMessageWithPacketID:(NSString *)packetID
{
    ILog(@"Message was delivered to user. Message package ID: %@", packetID);
}

- (void)chatAfterDidReceiveMessageWithTarget:(id)target block:(ChatMessageBlock)block {
    [self subsribeWithTarget:target selector:@selector(chatAfterDidReceiveMessage:) block:block];
}

- (void)chatAfterDidReceiveMessage:(QBChatMessage *)message {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(ChatMessageBlock block) {
        block(message);
    }];
}

/**
 didFailWithError fired when connection error occurs
 
 @param error Error code from QBChatServiceError enum
 */
- (void)chatDidFailWithTarget:(id)target block:(ChatDidFailLogin)block {
    [self subsribeWithTarget:target selector:@selector(chatDidFailWithError:) block:block];
}

- (void)chatDidFailWithError:(NSInteger)code {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(ChatDidFailLogin block) {
        block(code);
    }];
}

/**
 Called in case receiving presence
 
 @param userID User ID from which received presence
 @param type Presence type
 */

- (void)chatDidReceivePresenceOfUserWithTarget:(id)target block:(ChatDidReceivePresenceOfUser)block {
    [self subsribeWithTarget:target selector:@selector(chatDidReceivePresenceOfUser:type:) block:block];
}

- (void)chatDidReceivePresenceOfUser:(NSUInteger)userID type:(NSString *)type {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(ChatDidReceivePresenceOfUser block) {
        block(userID, type);
    }];
}

#pragma mark -
#pragma mark Contact list

/**
 Called in case receiving contact request
 
 @param userID User ID from which received contact request
 */

- (void)chatDidReceiveContactAddRequestWithTarget:(id)target block:(ChatDidReceiveContactAddRequest)block {
    [self subsribeWithTarget:target selector:@selector(chatDidReceiveContactAddRequestFromUser:) block:block];
}

- (void)chatDidReceiveContactAddRequestFromUser:(NSUInteger)userID {
    NSLog(@"User %d", userID);
    [self executeBloksWithSelector:_cmd enumerateBloks:^(ChatDidReceiveContactAddRequest block) {
        block(userID);
    }];
}

/**
 Called in case changing contact list
 */
- (void)chatContactListDidChangeWithTarget:(id)target block:(ChatContactListDidChange)block {
    [self subsribeWithTarget:target selector:@selector(chatContactListDidChange:) block:block];
}

- (void)chatContactListDidChange:(QBContactList *)contactList {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(ChatContactListDidChange block) {
        block(contactList);
    }];
    [self chatContactListUpdated];

}

- (void)chatContactListUpdatedWithTarget:(id)target block:(ChatContactListWillChange)block {
    [self subsribeWithTarget:target selector:@selector(chatContactListUpdated) block:block];
}

- (void)chatContactListUpdated {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(ChatContactListWillChange block) {
        block();
    }];
}

/**
 Called in case changing contact's online status
 
 @param userID User which online status has changed
 @param isOnline New user status (online or offline)
 @param status Custom user status
 */
- (void)chatDidReceiveContactItemActivityWithTarget:(id)target block:(ChathatDidReceiveContactItemActivity)block {
    [self subsribeWithTarget:target selector:@selector(chatDidReceiveContactItemActivity:isOnline:status:) block:block];
}

- (void)chatDidReceiveContactItemActivity:(NSUInteger)userID isOnline:(BOOL)isOnline status:(NSString *)status {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(ChathatDidReceiveContactItemActivity block) {
        block(userID, isOnline, status);
    }];
}

#pragma mark -
#pragma mark Rooms

/**
 Called in case received list of available to join rooms.
 
 @rooms Array of rooms
 */
- (void)chatDidReceiveListOfRoomsWithTarget:(id)target block:(ChatDidReceiveListOfRooms)block {
    [self subsribeWithTarget:target selector:@selector(chatDidReceiveListOfRooms:) block:block];
}

- (void)chatDidReceiveListOfRooms:(NSArray *)rooms {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(ChatDidReceiveListOfRooms block) {
        block(rooms);
    }];
}
/**
 Called when room receives a message.
 
 @param message Received message
 @param roomJID Room JID
 */

- (void)chatRoomDidReceiveMessageWithTarget:(id)target block:(ChatRoomDidReceiveMessage)block {
    [self subsribeWithTarget:target selector:@selector(chatRoomDidReceiveMessage:fromRoomJID:) block:block];
}

- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromRoomJID:(NSString *)roomJID {
    message.text = [message.text gtm_stringByUnescapingFromHTML];
    [self executeBloksWithSelector:_cmd enumerateBloks:^(ChatRoomDidReceiveMessage block) {
        block(message, roomJID);
    }];
    
    [self chatAfterDidReceiveMessage:message];
}

/**
 Called when received room information.
 
 @param information Room information
 @param roomJID JID of room
 @param roomName Name of room
 */

- (void)chatRoomDidReceiveInformationWithTarget:(id)target block:(ChatRoomDidReceiveInformation)block {
    [self subsribeWithTarget:target selector:@selector(chatRoomDidReceiveInformation:roomJID:roomName:) block:block];
}

- (void)chatRoomDidReceiveInformation:(NSDictionary *)information roomJID:(NSString *)roomJID roomName:(NSString *)roomName {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(ChatRoomDidReceiveInformation block) {
        block(information, roomJID, roomName);
    }];
}

/**
 Fired when room was successfully created
 */

- (void)chatRoomDidCreateWithTarget:(id)target block:(ChatRoomDidCreate)block {
    [self subsribeWithTarget:target selector:@selector(chatRoomDidCreate:) block:block];
}

- (void)chatRoomDidCreate:(NSString*)roomName {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(ChatRoomDidCreate block) {
        block(roomName);
    }];
}

/**
 Fired when you did enter to room
 
 @param room which you have joined
 */

- (void)chatRoomDidEnterWithTarget:(id)target block:(ChatRoomDidEnter)block {
    [self subsribeWithTarget:target selector:@selector(chatRoomDidEnter:) block:block];
}

- (void)chatRoomDidEnter:(QBChatRoom *)room {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(ChatRoomDidEnter block) {
        block(room);
    }];
}

/**
 Called when you didn't enter to room
 
 @param room which you haven't joined
 @param error Error
 */

- (void)chatRoomDidNotEnterWithTarget:(id)target block:(ChatRoomDidNotEnter)block {
    [self subsribeWithTarget:target selector:@selector(chatRoomDidNotEnter:error:) block:block];
}

- (void)chatRoomDidNotEnter:(NSString *)roomName error:(NSError *)error {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(ChatRoomDidNotEnter block) {
        block(roomName, error);
    }];
}

/**
 Fired when you did leave room
 
 @param Name of room which you have leaved
 */
- (void)chatRoomDidLeaveWithTarget:(id)target block:(ChatRoomDidLeave)block {
    [self subsribeWithTarget:target selector:@selector(chatRoomDidLeave:) block:block];
}

- (void)chatRoomDidLeave:(NSString *)roomName {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(ChatRoomDidLeave block) {
        block(roomName);
    }];
}

/**
 Fired when you did destroy room
 
 @param Name of room which you have destroyed
 */
- (void)chatRoomDidDestroyWithTarget:(id)target block:(ChatRoomDidDestroy)block {
    [self subsribeWithTarget:target selector:@selector(chatRoomDidDestroy:) block:block];
}

- (void)chatRoomDidDestroy:(NSString *)roomName {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(ChatRoomDidDestroy block) {
        block(roomName);
    }];
}

/**
 Called in case changing online users
 
 @param onlineUsers Array of online users
 @param roomName Name of room in which have changed online users
 */
- (void)chatRoomDidChangeOnlineUsersWithTarget:(id)target block:(ChatRoomDidChangeOnlineUsers)block {
    [self subsribeWithTarget:target selector:@selector(chatRoomDidChangeOnlineUsers:room:) block:block];
}

- (void)chatRoomDidChangeOnlineUsers:(NSArray *)onlineUsers room:(NSString *)roomName {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(ChatRoomDidChangeOnlineUsers block) {
        block(onlineUsers, roomName);
    }];
}

/**
 Called in case receiving list of users who can join room
 
 @param users Array of users which are able to join room
 @param roomName Name of room which provides access to join
 */
- (void)chatRoomDidReceiveListOfUsersWithTarget:(id)target block:(ChatRoomDidReceiveListOfUsers)block {
    [self subsribeWithTarget:target selector:@selector(chatRoomDidReceiveListOfUsers:room:) block:block];
}

- (void)chatRoomDidReceiveListOfUsers:(NSArray *)users room:(NSString *)roomName {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(ChatRoomDidReceiveListOfUsers block) {
        block(users, roomName);
    }];
}

/**
 Called in case receiving list of active users (joined)
 
 @param users Array of joined users
 @param roomName Name of room
 */
- (void)chatRoomDidReceiveListOfOnlineUsersWithTarget:(id)target block:(ChatRoomDidReceiveListOfOnlineUsers)block {
    [self subsribeWithTarget:target selector:@selector(chatRoomDidReceiveListOfOnlineUsers:room:) block:block];
}

- (void)chatRoomDidReceiveListOfOnlineUsers:(NSArray *)users room:(NSString *)roomName {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(ChatRoomDidReceiveListOfOnlineUsers block) {
        block(users, roomName);
    }];
}


@end
