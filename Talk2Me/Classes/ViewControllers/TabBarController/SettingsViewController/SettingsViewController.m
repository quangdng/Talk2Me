//
//  SettingsViewController.m
//  Talk2Me
//
//  Created by Yepeng Fan on 09/10/2014.
//

#import "SettingsViewController.h"
#import "REAlertView+QMSuccess.h"
#import "SVProgressHUD.h"
#import "SDWebImageManager.h"
#import "TMApi.h"
#import "SettingsManager.h"


@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UITableViewCell *logoutCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *changePasswordCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *profileCell;
@property (weak, nonatomic) IBOutlet UISwitch *pushNotificationSwitch;
@property (weak, nonatomic) IBOutlet UILabel *cacheSize;

@end

@implementation SettingsViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pushNotificationSwitch.on = [TMApi instance].settingsManager.pushNotificationsEnabled;
    if ([TMApi instance].settingsManager.accountType == QMAccountTypeFacebook) {
        [self cell:self.changePasswordCell setHidden:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    __weak __typeof(self)weakSelf = self;
    [[[SDWebImageManager sharedManager] imageCache] calculateSizeWithCompletionBlock:^(NSUInteger fileCount, NSUInteger totalSize) {
        weakSelf.cacheSize.text = [NSString stringWithFormat:@"Cache Size: %.2f mb", (float)totalSize / 1024.f / 1024.f];
    }];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == self.logoutCell) {
        
        FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"Logout" message:NSLocalizedString(@"STR_ARE_YOU_SURE", nil) delegate:self
 cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Logout", nil];
        
        alertView.titleLabel.textColor = [UIColor cloudsColor];
        alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
        alertView.messageLabel.textColor = [UIColor cloudsColor];
        alertView.messageLabel.font = [UIFont flatFontOfSize:14];
        alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.9];
        alertView.alertContainer.backgroundColor = [UIColor pomegranateColor];
        alertView.defaultButtonColor = [UIColor cloudsColor];
        alertView.defaultButtonShadowColor = [UIColor concreteColor];
        alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
        alertView.defaultButtonTitleColor = [UIColor asbestosColor];
        [alertView show];
        
       
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [alertView cancelButtonIndex]) {
        [self pressClearCache:nil];
        [SVProgressHUD  showWithMaskType:SVProgressHUDMaskTypeClear];
        [[TMApi instance] logout:^(BOOL success) {
            [SVProgressHUD dismiss];
            [self performSegueWithIdentifier:kSplashSegueIdentifier sender:nil];
        }];
    }
}

#pragma mark - Actions

- (IBAction)changePushNotificationValue:(UISwitch *)sender {

    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    if (sender.on) {
        [[TMApi instance] subscribeToPushNotificationsForceSettings:YES complete:^(BOOL success) {
            [SVProgressHUD dismiss];
        }];
    }
    else {
        [[TMApi instance] unSubscribeToPushNotifications:^(BOOL success) {
            [SVProgressHUD dismiss];
        }];
    }
    
}

- (IBAction)pressClearCache:(id)sender {
    
    __weak __typeof(self)weakSelf = self;
    [[[SDWebImageManager sharedManager] imageCache] clearMemory];
    [[[SDWebImageManager sharedManager] imageCache] clearDiskOnCompletion:^{
        
        [[[SDWebImageManager sharedManager] imageCache] calculateSizeWithCompletionBlock:^(NSUInteger fileCount, NSUInteger totalSize) {
            weakSelf.cacheSize.text = [NSString stringWithFormat:@"Cache Size: %.2f mb", (float)totalSize / 1024.f / 1024.f];
        }];
    }];
}

- (IBAction)toInviteView:(id)sender {
    // switch back
    
    int controllerIndex = 2;
    
    UITabBarController *tabBarController = self.tabBarController;
    UIView * fromView = tabBarController.selectedViewController.view;
    UIView * toView = [[tabBarController.viewControllers objectAtIndex:controllerIndex] view];
    
    // Transition using a page curl.
    [UIView transitionFromView:fromView
                        toView:toView
                      duration:0.5
                       options:(UIViewAnimationOptionTransitionCrossDissolve )
                    completion:^(BOOL finished) {
                        if (finished) {
                            tabBarController.selectedIndex = controllerIndex;
                        }
                    }];
    
    
}

@end