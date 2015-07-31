//
//  ChatViewController.m
//  Talk2Me
//
//  Created by Quang Nguyen on 30/09/2014.
//

#import "ChatViewController.h"
#import "MainTabBarController.h"
#import "ChatDataSource.h"
#import "ChatButtonsFactory.h"
#import "GroupDetailsController.h"
#import "MessageBarStyleSheetFactory.h"
#import "TMApi.h"
#import "ChatReceiver.h"
#import "OnlineTitle.h"
#import "IDMPhotoBrowser.h"
#import "SoundManager.h"

@interface ChatViewController ()

<ChatDataSourceDelegate>

@property (strong, nonatomic) OnlineTitle *onlineTitle;

@end

@implementation ChatViewController

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
    [[ChatReceiver instance] unsubscribeForTarget:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = [[ChatDataSource alloc] initWithChatDialog:self.dialog forTableView:self.tableView];
    self.dataSource.delegate = self;
    self.dialog.type == QBChatDialogTypeGroup ? [self configureNavigationBarForGroupChat] : [self configureNavigationBarForPrivateChat];
    
    __weak __typeof(self)weakSelf = self;
    [[ChatReceiver instance] chatAfterDidReceiveMessageWithTarget:self block:^(QBChatMessage *message) {
        
        if (message.cParamNotificationType == MessageNotificationTypeUpdateDialog && [message.cParamDialogID isEqualToString:weakSelf.dialog.ID]) {
            weakSelf.title = message.cParamDialogName;
            weakSelf.dialog = [[TMApi instance] chatDialogWithID:message.cParamDialogID];
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setUpTabBarChatDelegate];
    
    if (self.dialog.type == QBChatDialogTypeGroup) {
        self.title = self.dialog.name;
    }
    else if (self.dialog.type == QBChatDialogTypePrivate) {
        
        [self updateTitleInfoForPrivateDialog];
    }
}

- (void)updateTitleInfoForPrivateDialog {
    
    NSUInteger oponentID = [[TMApi instance] occupantIDForPrivateChatDialog:self.dialog];
    QBUUser *opponent = [[TMApi instance] userWithID:oponentID];

    QBContactListItem *item = [[TMApi instance] contactItemWithUserID:opponent.ID];
    NSString *status = NSLocalizedString(item.online ? @"STR_ONLINE": @"STR_OFFLINE", nil);
    
    self.onlineTitle.titleLabel.text = opponent.fullName;
    self.onlineTitle.statusLabel.text = status;
}

- (void)viewWillDisappear:(BOOL)animated
{    
    [self removeTabBarChatDelegate];
    self.dialog.unreadMessagesCount = 0;
    
    [super viewWillDisappear:animated];
}

- (void)setUpTabBarChatDelegate
{
    if (self.tabBarController != nil && [self.tabBarController isKindOfClass:MainTabBarController.class]) {
        ((MainTabBarController *)self.tabBarController).chatDelegate = self;
    }
}

- (void)removeTabBarChatDelegate
{
     if (self.tabBarController != nil && [self.tabBarController isKindOfClass:MainTabBarController.class]) {
        ((MainTabBarController *)self.tabBarController).chatDelegate = nil;
     }
}

- (void)configureNavigationBarForPrivateChat {
    
    self.onlineTitle = [[OnlineTitle alloc] initWithFrame:CGRectMake(0,
                                                                       0,
                                                                       150,
                                                                       self.navigationController.navigationBar.frame.size.height)];
    self.navigationItem.titleView = self.onlineTitle;
    
    __weak __typeof(self)weakSelf = self;
    [[ChatReceiver instance] chatContactListUpdatedWithTarget:self block:^{
        [weakSelf updateTitleInfoForPrivateDialog];
    }];
    
#if AUDIO_VIDEO_ENABLED
    UIButton *audioButton = [ChatButtonsFactory audioCall];
    [audioButton addTarget:self action:@selector(audioCallAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *videoButton = [ChatButtonsFactory videoCall];
    [videoButton addTarget:self action:@selector(videoCallAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *videoCallBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:videoButton];
    UIBarButtonItem *audioCallBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:audioButton];
    
    [self.navigationItem setRightBarButtonItems:@[videoCallBarButtonItem,  audioCallBarButtonItem] animated:YES];
    
#else
    [self.navigationItem setRightBarButtonItem:nil];
#endif
}

- (void)configureNavigationBarForGroupChat {
    
    self.title = self.dialog.name;
    UIButton *groupInfoButton = [ChatButtonsFactory groupInfo];
    [groupInfoButton addTarget:self action:@selector(groupInfoNavButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *groupInfoBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:groupInfoButton];
    self.navigationItem.rightBarButtonItems = @[groupInfoBarButtonItem];
}

- (void)back:(id)sender {
    
	[self.navigationController popViewControllerAnimated:YES];
}




#pragma mark - TabBarChatDelegate

- (void)tabBarChatWithChatMessage:(QBChatMessage *)message chatDialog:(QBChatDialog *)dialog showTMessage:(BOOL)show
{
    if (!show) {
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    [SoundManager playMessageReceivedSound];
    [MessageBarStyleSheetFactory showMessageBarNotificationWithMessage:message chatDialog:dialog completionBlock:^(MPGNotification *notification, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            UINavigationController *navigationController = (UINavigationController *)[weakSelf.tabBarController selectedViewController];
            ChatViewController *chatController = [weakSelf.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
            chatController.dialog = dialog;
            [navigationController pushViewController:chatController animated:YES];
        }
    }];
}

#pragma mark - ChatDataSourceDelegate

- (void)chatDatasource:(ChatDataSource *)chatDatasource prepareImageURLAttachement:(NSURL *)imageUrl {
 
    IDMPhoto *photo = [IDMPhoto photoWithURL:imageUrl];
    IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:@[photo]];
    [self presentViewController:browser animated:YES completion:nil];
}

- (void)chatDatasource:(ChatDataSource *)chatDatasource prepareImageAttachement:(UIImage *)image fromView:(UIView *)fromView {
    
    IDMPhoto *photo = [IDMPhoto photoWithImage:image];
    IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:@[photo] animatedFromView:fromView];
    [self presentViewController:browser animated:YES completion:nil];
}

@end
