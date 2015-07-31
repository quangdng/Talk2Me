//
//  MessagesService.m
//  Talk2Me
//
//  Created by Quang Nguyen on 05/09/2014.
//


#import "MessagesService.h"
#import "TMEchoObject.h"
#import "ChatReceiver.h"
#import "NSString+GTMNSStringHTMLAdditions.h"

@interface MessagesService()

@property (strong, nonatomic) NSMutableDictionary *history;

@end

@implementation MessagesService

- (void)chat:(void(^)(QBChat *chat))chatBlock {
    
    if ([[QBChat instance] isLoggedIn]) {
        chatBlock([QBChat instance]);
    }
    else {
        [self loginChat:^(BOOL success) {
            chatBlock([QBChat instance]);
        }];
    }
}

- (void)loginChat:(QBChatResultBlock)block {
    
    if (!self.currentUser) {
        block(NO);
        return;
    }
    
    if (([[QBChat instance] isLoggedIn])) {
        block(YES);
        return;
    }
    
    [[ChatReceiver instance] chatDidLoginWithTarget:self block:block];
    [[ChatReceiver instance] chatDidNotLoginWithTarget:self block:block];

    NSAssert(self.currentUser, @"update this case");
    [[QBChat instance] loginWithUser:self.currentUser];
}

- (void)logoutChat {
    
    if ([[QBChat instance] isLoggedIn]) {
        [[QBChat instance] logout];
        [[ChatReceiver instance] unsubscribeForTarget:self];
    }
}

- (void)start {
    [super start];
    
    self.history = [NSMutableDictionary dictionary];

    __weak __typeof(self)weakSelf = self;
    void (^updateHistory)(QBChatMessage *) = ^(QBChatMessage *message) {

        if (message.recipientID != message.senderID && message.cParamNotificationType == MessageNotificationTypeNone) {
            [weakSelf addMessageToHistory:message withDialogID:message.cParamDialogID];
        }
    };
    
    [[ChatReceiver instance] chatDidReceiveMessageWithTarget:self block:^(QBChatMessage *message) {
        updateHistory(message);
    }];
    
    [[ChatReceiver instance] chatRoomDidReceiveMessageWithTarget:self block:^(QBChatMessage *message, NSString *roomJID) {
        updateHistory(message);
    }];
}

- (void)stop {
    [super stop];
    
    [[ChatReceiver instance] unsubscribeForTarget:self];
    [self.history removeAllObjects];
}

- (void)setMessages:(NSArray *)messages withDialogID:(NSString *)dialogID {
    
    self.history[dialogID] = messages;
}

- (void)addMessageToHistory:(QBChatMessage *)message withDialogID:(NSString *)dialogID {
    
    NSMutableArray *history = self.history[dialogID];
    [history addObject:message];
}

- (NSArray *)messageHistoryWithDialogID:(NSString *)dialogID {
    
    NSArray *messages = self.history[dialogID];
    return messages;
}

- (void)sendMessage:(QBChatMessage *)message withDialogID:(NSString *)dialogID saveToHistory:(BOOL)save completion:(void(^)(NSError *error))completion {
    
    message.cParamDialogID = dialogID;
    message.cParamDateSent = @((NSInteger)CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970);
    message.text = [message.text gtm_stringByEscapingForHTML];
    
    if (save) {
        message.cParamSaveToHistory = @"1";
        message.markable = YES;
    }
    
    [self chat:^(QBChat *chat) {
//        [chat sendMessage:message sentBlock:^(NSError *error) {
//            completion(error);
//        }];
       if ( [chat sendMessage:message]) {
           completion(nil);
       };
    }];
}

- (void)sendChatMessage:(QBChatMessage *)message withDialogID:(NSString *)dialogID toRoom:(QBChatRoom *)chatRoom completion:(void(^)(void))completion {
    
    message.cParamDialogID = dialogID;
    message.cParamSaveToHistory = @"1";
    message.cParamDateSent = @((NSInteger)CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970);
    message.text = [message.text gtm_stringByEscapingForHTML];
    
    [self chat:^(QBChat *chat) {
        if ([chat sendChatMessage:message toRoom:chatRoom]) {
            completion();
        }
    }];
}

- (void)messagesWithDialogID:(NSString *)dialogID completion:(QBChatHistoryMessageResultBlock)completion {
    
    __weak __typeof(self)weakSelf = self;
    QBChatHistoryMessageResultBlock echoObject = ^(QBChatHistoryMessageResult *result) {
        [weakSelf setMessages:result.messages.count ? result.messages.mutableCopy : @[].mutableCopy withDialogID:dialogID];
        completion(result);
    };
    
    [QBChat messagesWithDialogID:dialogID delegate:[TMEchoObject instance] context:[TMEchoObject makeBlockForEchoObject:echoObject]];
}

- (void)messagesWithDialogID:(NSString *)dialogID time:(NSUInteger)time completion:(QBChatHistoryMessageResultBlock)completion {
    
    __weak __typeof(self)weakSelf = self;
    QBChatHistoryMessageResultBlock echoObject = ^(QBChatHistoryMessageResult *result) {
        [weakSelf setMessages:result.messages.count ? result.messages.mutableCopy : @[].mutableCopy withDialogID:dialogID];
        completion(result);
    };
    
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    
    [getRequest setObject:@(time)
                   forKey:@"date_send[gt]"];
    
    [QBChat messagesWithDialogID:dialogID extendedRequest:getRequest delegate:[TMEchoObject instance] context:[TMEchoObject makeBlockForEchoObject:echoObject]];
}

@end
