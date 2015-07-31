//
//  ChatAbstractMessage+CustomParameters.m
//  Talk2Me
//
//  Created by Quang Nguyen on 30/08/2014.
//

#import "QBChatAbstractMessage+CustomParameters.h"

/*Message keys*/
NSString const *kCustomParameterSaveToHistory = @"save_to_history";
NSString const *kCustomParameterNotificationType = @"notification_type";
NSString const *kCustomParameterChatMessageID = @"chat_message_id";
NSString const *kCustomParameterDateSent = @"date_sent";
NSString const *kCustomParameterChatMessageDeliveryStatus = @"message_delivery_status_read";
/*Dialogs keys*/
NSString const *kCustomParameterDialogID = @"dialog_id";
NSString const *kCustomParameterRoomJID = @"room_jid";
NSString const *kCustomParameterDialogName = @"name";
NSString const *kCustomParameterDialogType = @"type";
NSString const *kCustomParameterDialogOccupantsIDs = @"occupants_ids";

@interface QBChatAbstractMessage (Context)

@property (strong, nonatomic) NSMutableDictionary *context;

@end

@implementation QBChatAbstractMessage (CustomParameters)

/*Message params*/
@dynamic cParamSaveToHistory;
@dynamic cParamNotificationType;
@dynamic cParamChatMessageID;
@dynamic cParamDateSent;
@dynamic cParamMessageDeliveryStatus;

/*dialog info params*/
@dynamic cParamDialogID;
@dynamic cParamRoomJID;
@dynamic cParamDialogName;
@dynamic cParamDialogType;
@dynamic cParamDialogOccupantsIDs;

- (NSMutableDictionary *)context {
    
    if (!self.customParameters) {
        self.customParameters = [NSMutableDictionary dictionary];
    }
    return self.customParameters;
}

#pragma mark - cParamChatMessageID

- (void)setCParamChatMessageID:(NSString *)cParamChatMessageID {
    self.context[kCustomParameterChatMessageID] = cParamChatMessageID;
}

- (NSString *)cParamChatMessageID {
    
    return self.context[kCustomParameterChatMessageID];
}

#pragma mark - cParamDateSent

- (void)setCParamDateSent:(NSNumber *)cParamDateSent {
    self.context[kCustomParameterDateSent] = cParamDateSent;
}

- (NSNumber *)cParamDateSent {
    return self.context[kCustomParameterDateSent];
}

#pragma mark - cParamDialogID

- (void)setCParamDialogID:(NSString *)cParamDialogID {
    self.context[kCustomParameterDialogID] = cParamDialogID;
}

- (NSString *)cParamDialogID {
    return self.context[kCustomParameterDialogID];
}

#pragma mark - cParamSaveToHistory

- (void)setCParamSaveToHistory:(NSString *)cParamSaveToHistory {
    self.context[kCustomParameterSaveToHistory] = cParamSaveToHistory;
}

- (NSString *)cParamSaveToHistory {
    return self.context[kCustomParameterSaveToHistory];
}

#pragma mark - cParamRoomJID

- (void)setCParamRoomJID:(NSString *)cParamRoomJID {
    self.context[kCustomParameterRoomJID] = cParamRoomJID;
}

- (NSString *)cParamRoomJID {
    return self.context[kCustomParameterRoomJID];
}

#pragma mark - cParamDialogType

- (void)setCParamDialogType:(NSNumber *)cParamDialogType {
    self.context[kCustomParameterDialogType] = cParamDialogType;
}

- (NSNumber *)cParamDialogType {
    return self.context[kCustomParameterDialogType];
}

#pragma mark - cParamDialogName

- (void)setCParamDialogName:(NSString *)cParamDialogName {
    self.context[kCustomParameterDialogName] = cParamDialogName;
}

- (NSString *)cParamDialogName {
    return self.context[kCustomParameterDialogName];
}

#pragma mark - cParamDialogOccupantsIDs

- (void)setCParamDialogOccupantsIDs:(NSArray *)cParamDialogOccupantsIDs {
    
    NSString *strIDs = [cParamDialogOccupantsIDs componentsJoinedByString:@","];
    self.context[kCustomParameterDialogOccupantsIDs] = strIDs;
}

- (NSArray *)cParamDialogOccupantsIDs {
    
    NSString * strIDs = self.context[kCustomParameterDialogOccupantsIDs];
    
    NSArray *componets = [strIDs componentsSeparatedByString:@","];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:componets.count];

    for (NSString *occupantID in componets) {
        [result addObject:@(occupantID.integerValue)];
    }
    
    return result;
}

#pragma mark - cParamNotificationType

- (void)setCParamNotificationType:(MessageNotificationType)cParamNotificationType {

    self.context[kCustomParameterNotificationType] = @(cParamNotificationType);
}

- (MessageNotificationType)cParamNotificationType {
    return [self.context[kCustomParameterNotificationType] integerValue];
}

#pragma mark - cParamMessageDeliveryStatus

- (void)setCParamMessageDeliveryStatus:(BOOL)cParamMessageDeliveryStatus {
    self.context[kCustomParameterChatMessageDeliveryStatus] = @(cParamMessageDeliveryStatus);
}

- (BOOL)cParamMessageDeliveryStatus {
    return [self.context[kCustomParameterChatMessageDeliveryStatus] boolValue];
}

#pragma mark - QBChatDialog

- (void)setCustomParametersWithChatDialog:(QBChatDialog *)chatDialog {
    
    self.cParamDialogID = chatDialog.ID;
    
    if (chatDialog.type == QBChatDialogTypeGroup) {
        self.cParamRoomJID = chatDialog.roomJID;
        self.cParamDialogName = chatDialog.name;
    }
    
    self.cParamDialogType = @(chatDialog.type);
    self.cParamDialogOccupantsIDs = chatDialog.occupantIDs;
}

- (QBChatDialog *)chatDialogFromCustomParameters {

    QBChatDialog *chatDialog = [[QBChatDialog alloc] init];
    chatDialog.ID = self.cParamDialogID;
    chatDialog.roomJID = self.cParamRoomJID;
    chatDialog.name = self.cParamDialogName;
    chatDialog.occupantIDs = self.cParamDialogOccupantsIDs;
    chatDialog.type = self.cParamDialogType.integerValue;
    chatDialog.lastMessageDate = [NSDate dateWithTimeIntervalSince1970:self.cParamDateSent.doubleValue];
    
    return chatDialog;
}

@end
