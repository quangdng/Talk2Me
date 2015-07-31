//
//  InviteViewController.m
//  Talk2Me
//
//  Created by Tian Long on 09/10/2014.
//

#import "InviteViewController.h"
#import "InviteFriendsDataSource.h"
#import "TMApi.h"
#import "REMessageUI.h"
#import "SVProgressHUD.h"

@interface InviteViewController ()

<QBActionStatusDelegate, MFMailComposeViewControllerDelegate, CheckBoxStateDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) InviteFriendsDataSource *dataSource;

@end

@implementation InviteViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.dataSource = nil;
	self.dataSource = [[InviteFriendsDataSource alloc] initWithTableView:self.tableView];
    self.dataSource.checkBoxDelegate = self;
    
    [self changeSendButtonEnableForCheckedUsersCount:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (IBAction)sendButtonClicked:(id)sender {
    
    __weak __typeof(self)weakSelf = self;
    NSArray *abEmails = [weakSelf.dataSource emailsToInvite];
    if (abEmails.count > 0) {
        
        [REMailComposeViewController present:^(REMailComposeViewController *mailVC) {
            
            [mailVC setToRecipients:abEmails];
            [mailVC setSubject:kMailSubjectString];
            [mailVC setMessageBody:kMailBodyString isHTML:YES];
            [weakSelf presentViewController:mailVC animated:YES completion:nil];
            
        } finish:^(MFMailComposeResult result, NSError *error) {
            
            if (!error && result == MFMailComposeResultSent) {
                
                [weakSelf.dataSource clearABFriendsToInvite];
                [SVProgressHUD showSuccessWithStatus:@"Success!"];
            }
#warning Reachability case needed also!
            else if (result == MFMailComposeResultFailed && !error) {
                [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"STR_MAIL_COMPOSER_ERROR_DESCRIPTION_FOR_INVITE", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"STR_CANCEL", nil) otherButtonTitles:nil] show];
                
            } else if (result == MFMailComposeResultFailed && error) {
                [SVProgressHUD showErrorWithStatus:@"Error"];
            }
        }];
    }

}

- (void)changeSendButtonEnableForCheckedUsersCount:(NSInteger)checkedUsersCount
{
    self.sendButton.enabled = checkedUsersCount > 0;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self.dataSource heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.dataSource didSelectRowAtIndexPath:indexPath];
}


#pragma mark - CheckBoxStatusDelegate

- (void)checkListDidChangeCount:(NSInteger)checkedCount {
      [self changeSendButtonEnableForCheckedUsersCount:checkedCount];
}

- (IBAction)toContactView:(id)sender {
    // switch back
    
    int controllerIndex = 1;
    
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

- (IBAction)toSettingView:(id)sender {
    // switch back
    
    int controllerIndex = 3;
    
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
