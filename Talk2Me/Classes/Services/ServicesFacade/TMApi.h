//
//  TMApi.h
//  Talk2Me
//
//  Created by Quang Nguyen on 26/08/2014.
//

#import <Foundation/Foundation.h>
#import "UsersUtils.h"

@class AuthService;
@class SettingsManager;
@class FacebookService;
@class UsersService;
@class ChatDialogsService;
@class QMAVCallService;
@class MessagesService;
@class ChatReceiver;
@class ContentService;

typedef NS_ENUM(NSUInteger, QMAccountType);

@interface TMApi : NSObject

@property (strong, nonatomic, readonly) AuthService *authService;
@property (strong, nonatomic, readonly) SettingsManager *settingsManager;
@property (strong, nonatomic, readonly) UsersService *usersService;
@property (strong, nonatomic, readonly) QMAVCallService *avCallService;
@property (strong, nonatomic, readonly) ChatDialogsService *chatDialogsService;
@property (strong, nonatomic, readonly) MessagesService *messagesService;
@property (strong, nonatomic, readonly) ChatReceiver *responceService;
@property (strong, nonatomic, readonly) ContentService *contentService;


@property (strong, nonatomic, readonly) QBUUser *currentUser;

+ (instancetype)instance;

- (BOOL)checkResult:(Result *)result;

- (void)startServices;
- (void)stopServices;

- (void)applicationDidBecomeActive:(void(^)(BOOL success))completion;
- (void)applicationWillResignActive;
- (void)openChatPageForPushNotification:(NSDictionary *)notification;

- (void)fetchAllHistory:(void(^)(void))completion;

@end

@interface TMApi (Auth)

- (void)autoLogin:(void(^)(BOOL success))completion;

- (void)createSessionWithBlock:(void(^)(BOOL success))completion;
- (void)setAutoLogin:(BOOL)autologin withAccountType:(QMAccountType)accountType;

- (void)signUpAndLoginWithUser:(QBUUser *)user rememberMe:(BOOL)rememberMe completion:(void(^)(BOOL success))completion;
- (void)singUpAndLoginWithFacebook:(void(^)(BOOL success))completion;
/**
 User LogIn with email and password
 
 Type of Result - QBUUserLogInResult
 @return completion stastus
 */

- (void)loginWithEmail:(NSString *)email password:(NSString *)password rememberMe:(BOOL)rememberMe completion:(void(^)(BOOL success))completion;

/**
 User LogIn with facebook
 
 Type of Result - QBUUserLogInResult
 @return completion stastus
 */
- (void)loginWithFacebook:(void(^)(BOOL success))completion;
- (void)logout:(void(^)(BOOL success))completion;

/**
 Reset user password wiht email
 */
- (void)resetUserPassordWithEmail:(NSString *)email completion:(void(^)(BOOL success))completion;
- (void)subscribeToPushNotificationsForceSettings:(BOOL)force complete:(void(^)(BOOL success))complete;
- (void)unSubscribeToPushNotifications:(void(^)(BOOL success))complete;

@end

@interface TMApi (Messages)

@property (nonatomic, strong) NSDictionary *pushNotification;

- (void)loginChat:(QBChatResultBlock)block;
- (void)logoutFromChat;
/**
 */
- (void)fetchMessageWithDialog:(QBChatDialog *)chatDialog complete:(void(^)(BOOL success))complete;
/**
 */
- (NSArray *)messagesHistoryWithDialog:(QBChatDialog *)chatDialog;
/**
 if ok return QBChatMessage , else nil
 */

- (void)sendText:(NSString *)text toDialog:(QBChatDialog *)dialog completion:(void(^)(QBChatMessage * message))completion;
- (void)sendAttachment:(NSString *)attachmentUrl toDialog:(QBChatDialog *)dialog completion:(void(^)(QBChatMessage * message))completion;

@end

@interface TMApi (ChatDialogs)

/**
 return cached dialogs
 
 @result array QBChatDialg's
 */
- (NSArray *)dialogHistory;
/**/
- (NSArray *)allOccupantIDsFromDialogsHistory;
- (QBChatDialog *)chatDialogWithID:(NSString *)dialogID;

/**
 Get all dialogs for current user
 */
- (void)fetchAllDialogs:(void(^)(void))completion;

/**
 Create group chat dialog
 
 @param name - Group chat name.
 @param ocupants - Array of QBUUser in chat.
 @result QBChatDialogResult
 */
- (void)createGroupChatDialogWithName:(NSString *)name occupants:(NSArray *)occupants completion:(QBChatDialogResultBlock)completion;

/**
 Create private chat dialog
 
 @param opponent - oponent.
 @result QBChatDialogResult
 */
- (void)createPrivateChatDialogIfNeededWithOpponent:(QBUUser *)opponent completion:(void(^)(QBChatDialog *chatDialog))completion;
/**
 Leave user from chat dialog
 
 @param userID - user identifier
 @param chatDialog - chat dialog
 @result QBChatDialogResult
 */
- (void)leaveWithUserId:(NSUInteger)userID fromChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResultBlock)completion;

/**
 Join users to chat dialog
 
 @param occupantsIDs - Array of QBUUser in chat.
 @result QBChatDialogResult
 */
- (void)joinOccupants:(NSArray *)occupants toChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResultBlock)completion;

/**
 Join new users to chat
 
 @param dialogName
 @result QBChatDialogResult
 */
- (void)changeChatName:(NSString *)dialogName forChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResultBlock)completion;

- (NSUInteger)occupantIDForPrivateChatDialog:(QBChatDialog *)chatDialog;

/**
 QBChatRoom with roomJID
 
 @param roomJID
 @result QBChatDialogResult
 */

- (QBChatRoom *)chatRoomWithRoomJID:(NSString *)roomJID;

@end


@interface TMApi (Users)

@property (strong, nonatomic, readonly) NSArray *friends;
@property (strong, nonatomic, readonly) NSArray *contactRequestUsers;

- (NSArray *)usersWithIDs:(NSArray *)ids;
- (NSArray *)idsWithUsers:(NSArray *)users;
- (QBUUser *)userWithID:(NSUInteger)userID;
- (QBContactListItem *)contactItemWithUserID:(NSUInteger)userID;
//- (NSArray *)idsFromContactListItems;

/** 
 Import facebook friends from quickblox database.
 */
- (void)importFriendsFromFacebook;

/**
 Import friends from Address book which exists in quickblox database.
 */
- (void)importFriendsFromAddressBook;

/**
 Add user to contact list request
 
 @param user of user which you would like to add to contact list
 @return*/
- (void)addUserToContactListRequest:(QBUUser *)user completion:(void(^)(BOOL success))completion;

/**
 Remove user from contact list
 
 @param userID ID of user which you would like to remove from contact list
 @return YES if the request was sent successfully. If not - see log.
 */
- (void)removeUserFromContactListWithUserID:(NSUInteger)userID completion:(void(^)(BOOL success))completion;

/**
 Confirm add to contact list request
 
 @param userID ID of user from which you would like to confirm add to contact request
 @return YES if the request was sent successfully. If not - see log.
 */
- (void)confirmAddContactRequest:(NSUInteger)userID completion:(void(^)(BOOL success))completion;

/**
 Reject add to contact list request
 
 @param userID ID of user from which you would like to reject add to contact request
 @return YES if the request was sent successfully. If not - see log.
 */
- (void)rejectAddContactRequest:(NSUInteger)userID completion:(void(^)(BOOL success))completion;

/**
 */
- (void)updateUser:(QBUUser *)user image:(UIImage *)image progress:(ContentProgressBlock)progress completion:(void (^)(BOOL success))completion;
/**
 
 */
- (void)updateUser:(QBUUser *)user imageUrl:(NSURL *)imageUrl progress:(ContentProgressBlock)progress completion:(void (^)(BOOL success))completion;

/**
 */
- (void)changePasswordForCurrentUser:(QBUUser *)currentUser completion:(void(^)(BOOL success))completion;

@end

/**
 Facebook interface
 */
@interface TMApi (Facebook)

- (void)fbLogout;
- (void)fbIniviteDialogWithCompletion:(void(^)(BOOL success))completion;
- (NSURL *)fbUserImageURLWithUserID:(NSString *)userID;
- (void)fbFriends:(void(^)(NSArray *fbFriends))completion;
- (void)fbInviteUsersWithIDs:(NSArray *)ids copmpletion:(void(^)(NSError *error))completion;

@end


@interface NSObject(CurrentUser)

@property (strong, nonatomic) QBUUser *currentUser;

@end