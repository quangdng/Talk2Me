//
//  TMApi.m
//  Talk2Me
//
//  Created by Quang Nguyen on 26/08/2014.
//

#import "TMApi.h"

#import "SettingsManager.h"
#import "FacebookService.h"
#import "AuthService.h"
#import "UsersService.h"
#import "ChatDialogsService.h"
#import "ContentService.h"
#import "MessagesService.h"
#import "REAlertView+QMSuccess.h"
#import "ChatReceiver.h"
#import "PopoversFactory.h"
#import "MainTabBarController.h"

const NSTimeInterval kPresenceTime = 30;

@interface TMApi()

@property (strong, nonatomic) AuthService *authService;
@property (strong, nonatomic) SettingsManager *settingsManager;
@property (strong, nonatomic) UsersService *usersService;
@property (strong, nonatomic) QMAVCallService *avCallService;
@property (strong, nonatomic) ChatDialogsService *chatDialogsService;
@property (strong, nonatomic) MessagesService *messagesService;
@property (strong, nonatomic) ChatReceiver *responceService;
@property (strong, nonatomic) ContentService *contentService;
@property (strong, nonatomic) NSTimer *presenceTimer;


@end

@implementation TMApi

@dynamic currentUser;

+ (instancetype)instance {
    
    static TMApi *servicesFacade = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        servicesFacade = [[self alloc] init];
        [QBChat instance].useMutualSubscriptionForContactList = YES;
//        [QBChat instance].autoReconnectEnabled = YES;
        [QBChat instance].streamManagementEnabled = YES;
        
        [QBChat instance].delegate = [ChatReceiver instance];
        servicesFacade.presenceTimer = [NSTimer scheduledTimerWithTimeInterval:kPresenceTime
                                                                        target:servicesFacade
                                                                      selector:@selector(sendPresence)
                                                                      userInfo:nil
                                                                       repeats:YES];
    });
    
    return servicesFacade;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.messagesService = [[MessagesService alloc] init];
        self.authService = [[AuthService alloc] init];
        self.usersService = [[UsersService alloc] init];
        self.chatDialogsService = [[ChatDialogsService alloc] init];
        self.settingsManager = [[SettingsManager alloc] init];
        self.contentService = [[ContentService alloc] init];
        
    }
    
    return self;
}

- (void)setCurrentUser:(QBUUser *)currentUser {
    self.messagesService.currentUser = currentUser;
}

- (QBUUser *)currentUser {
    return self.messagesService.currentUser;
}

- (void)startServices {
    
    [self.authService start];
    [self.messagesService start];
    [self.usersService start];
    [self.chatDialogsService start];
}

- (void)stopServices {
    
    [self.authService stop];
    [self.usersService stop];
    [self.chatDialogsService stop];
    [self.messagesService stop];
}

- (void)fetchAllHistory:(void(^)(void))completion {
    /**
     Feach Dialogs
     */
    __weak __typeof(self)weakSelf = self;
    [self fetchAllDialogs:^{
        
        NSArray *allOccupantIDs = [weakSelf allOccupantIDsFromDialogsHistory];
        
        [weakSelf.usersService retrieveUsersWithIDs:allOccupantIDs completion:^(BOOL updated) {
            completion();
        }];
    }];
}

- (BOOL)checkResult:(Result *)result {
    
    if (!result.success) {
        [REAlertView showAlertWithMessage:result.errors.lastObject actionSuccess:NO];
    }
    
    return result.success;
}

#pragma mark - STATUS

- (void)sendPresence {
    
    if ([[QBChat instance] isLoggedIn]) {
        [[QBChat instance] sendPresence];
    }
}

- (void)applicationDidBecomeActive:(void(^)(BOOL success))completion {
    [self loginChat:completion];
}

- (void)applicationWillResignActive {
    [self logoutFromChat];
}

- (void)openChatPageForPushNotification:(NSDictionary *)notification
{
    NSString *dialogID = notification[@"dialog_id"];
    QBChatDialog *dialog = [self chatDialogWithID:dialogID];
    if (dialog == nil) {
        return;
    }
    
    ChatViewController *chatController = [PopoversFactory chatControllerWithDialogID:dialogID];
    UIWindow *window = [[UIApplication sharedApplication].windows firstObject];
    MainTabBarController *tabBar = (MainTabBarController *)window.rootViewController;
    UINavigationController *navigationController = (UINavigationController *)[tabBar selectedViewController];
    [navigationController pushViewController:(UIViewController *)chatController animated:YES];
}

@end

@implementation NSObject(CurrentUser)

@dynamic currentUser;

- (QBUUser *)currentUser {
   return [[TMApi instance] currentUser];
}

@end
