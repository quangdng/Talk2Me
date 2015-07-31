//
//  ChatAbstractMessage+CustomParameters.h
//  Talk2Me
//
//  Created by Quang Nguyen on 30/08/2014.
//

#import <Quickblox/Quickblox.h>

typedef NS_ENUM(NSUInteger, MessageNotificationType) {
    MessageNotificationTypeNone,
    MessageNotificationTypeCreateDialog,
    MessageNotificationTypeUpdateDialog,
    MessageNotificationTypeDeliveryMessage
    
};

@interface QBChatAbstractMessage (CustomParameters)

@property (strong, nonatomic) NSString *cParamSaveToHistory;
@property (assign, nonatomic) MessageNotificationType cParamNotificationType;
@property (strong, nonatomic) NSString *cParamChatMessageID;
@property (strong, nonatomic) NSNumber *cParamDateSent;
@property (assign, nonatomic) BOOL cParamMessageDeliveryStatus;

@property (strong, nonatomic) NSString *cParamDialogID;
@property (strong, nonatomic) NSString *cParamRoomJID;
@property (strong, nonatomic) NSString *cParamDialogName;
@property (strong, nonatomic) NSNumber *cParamDialogType;
@property (strong, nonatomic) NSArray *cParamDialogOccupantsIDs;

- (void)setCustomParametersWithChatDialog:(QBChatDialog *)chatDialog;
- (QBChatDialog *)chatDialogFromCustomParameters;

@end
