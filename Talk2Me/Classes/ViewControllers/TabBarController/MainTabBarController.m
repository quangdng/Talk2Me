//
//  MainTabBarController.m
//  Talk2Me
//
//  Created by He Gui on 05/09/2014.
//

#import "MainTabBarController.h"
#import "SVProgressHUD.h"
#import "TMApi.h"
#import "ImageView.h"
#import "MPGNotification.h"
#import "MessageBarStyleSheetFactory.h"
#import "ChatViewController.h"
#import "SoundManager.h"
#import "ChatDataSource.h"
#import "SettingsManager.h"
#import "ChatReceiver.h"


@interface MainTabBarController ()

@end


@implementation MainTabBarController


- (void)dealloc
{
    [[ChatReceiver instance] unsubscribeForTarget:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.chatDelegate = self;
    
//    [self customizeTabBar];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [self subscribeToNotifications];
    __weak __typeof(self)weakSelf = self;
    
    [[TMApi instance] autoLogin:^(BOOL success) {
        if (!success) {
            
            [[TMApi instance] logout:^(BOOL logoutSuccess) {
                [weakSelf performSegueWithIdentifier:@"SplashSegue" sender:nil];
            }];
            
        }else {
            NSDictionary *push = [[TMApi instance] pushNotification];
            if (push != nil) {
                [SVProgressHUD show];
            }
            [[TMApi instance] loginChat:^(BOOL loginSuccess) {
                [[TMApi instance] subscribeToPushNotificationsForceSettings:NO complete:^(BOOL subscribeToPushNotificationsSuccess) {
                
                    if (!subscribeToPushNotificationsSuccess) {
                        [TMApi instance].settingsManager.pushNotificationsEnabled = NO;
                    }
                }];
                
                SettingsManager *settings = [TMApi instance].settingsManager;
                
                [[TMApi instance] fetchAllHistory:^{
                    
                    if (push != nil) {
                        [SVProgressHUD dismiss];
                        [[TMApi instance] openChatPageForPushNotification:push];
                        [[TMApi instance] setPushNotification:nil];
                    }
                }];
                
                if (![settings isFirstFacebookLogin]) {
                    
                    [settings setFirstFacebookLogin:YES];
                    [[TMApi instance] importFriendsFromFacebook];
                    [[TMApi instance] importFriendsFromAddressBook];
                }
                
            }];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setChatDelegate:(id)chatDelegate
{
    if (chatDelegate == nil) {
        _chatDelegate = self;
        return;
    }
    _chatDelegate = chatDelegate;
}

- (void)subscribeToNotifications
{
    __weak typeof(self)weakSelf = self;
    [[ChatReceiver instance] chatAfterDidReceiveMessageWithTarget:self block:^(QBChatMessage *message) {
        if (message.delayed) {
            return;
        }
        QBChatDialog *dialog = [[TMApi instance] chatDialogWithID:message.cParamDialogID];
        [weakSelf message:message forOtherDialog:dialog];
    }];
}

- (void)customizeTabBar {
    
    UIColor *white = [UIColor whiteColor];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : white} forState:UIControlStateNormal];
    self.tabBarController.tabBar.tintColor = white;
    
    UIImage *chatImg = [[UIImage imageNamed:@"tb_chat"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *firstTab = self.tabBar.items[0];
    firstTab.image = chatImg;
    firstTab.selectedImage = chatImg;
    
    UIImage *friendsImg = [[UIImage imageNamed:@"tb_friends"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *chatTab = self.tabBar.items[1];
    chatTab.image = friendsImg;
    chatTab.selectedImage = friendsImg;
    
    UIImage *inviteImg = [[UIImage imageNamed:@"tb_invite"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *inviteTab = self.tabBar.items[2];
    inviteTab.image = inviteImg;
    inviteTab.selectedImage = inviteImg;
    
    UIImage *settingsImg = [[UIImage imageNamed:@"tb_settings"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *fourthTab = self.tabBar.items[3];
    fourthTab.image = settingsImg;
    fourthTab.selectedImage = settingsImg;
    
    for (UINavigationController *navViewController in self.viewControllers ) {
        NSAssert([navViewController isKindOfClass:[UINavigationController class]], @"is not UINavigationController");
        [navViewController.viewControllers makeObjectsPerformSelector:@selector(view)];
    }
}

#pragma mark - ChatDataSourceDelegate

- (void)message:(QBChatMessage *)message forOtherDialog:(QBChatDialog *)otherDialog {
    
    if (message.cParamNotificationType > 0) {
        [self.chatDelegate tabBarChatWithChatMessage:message chatDialog:otherDialog showTMessage:NO];
    }
    else if ([self.chatDelegate isKindOfClass:ChatViewController.class] && [otherDialog.ID isEqual:((ChatViewController *)self.chatDelegate).dialog.ID]) {
        [self.chatDelegate tabBarChatWithChatMessage:message chatDialog:otherDialog showTMessage:NO];
    }
    else {
        [self.chatDelegate tabBarChatWithChatMessage:message chatDialog:otherDialog showTMessage:YES];
    }
}


#pragma mark - TabBarChatDelegate

- (void)tabBarChatWithChatMessage:(QBChatMessage *)message chatDialog:(QBChatDialog *)dialog showTMessage:(BOOL)show
{
    if (!show) {
        return;
    }
    [SoundManager playMessageReceivedSound];
    
    __weak typeof(self) weakSelf = self;
    [MessageBarStyleSheetFactory showMessageBarNotificationWithMessage:message chatDialog:dialog completionBlock:^(MPGNotification *notification, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            UINavigationController *navigationController = (UINavigationController *)[weakSelf selectedViewController];
            ChatViewController *chatController = [weakSelf.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
            chatController.dialog = dialog;
            [navigationController pushViewController:chatController animated:YES];
        }
    }];
    
}


#pragma mark - TabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    UITabBarItem *neededTab = tabBar.items[1];
    if ([item isEqual:neededTab]) {
        if ([self.tabDelegate respondsToSelector:@selector(friendsListTabWasTapped:)]) {
            [self.tabDelegate friendsListTabWasTapped:item];
        }
    }
}

@end
