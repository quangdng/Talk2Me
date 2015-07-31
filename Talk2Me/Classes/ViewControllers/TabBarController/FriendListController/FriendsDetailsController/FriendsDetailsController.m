//
//  FriendsDetailsController.m
//  Talk2Me
//
//  Created by He Gui on 04/10/2014.
//

#import "FriendsDetailsController.h"
#import "ChatViewController.h"
#import "ImageView.h"
#import "REAlertView.h"
#import "SVProgressHUD.h"
#import "TMApi.h"
#import "ChatReceiver.h"

typedef NS_ENUM(NSUInteger, CallType) {
    CallTypePhone,
    CallTypeVideo,
    CallTypeAudio,
    CallTypeChat
};

@interface FriendsDetailsController () <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *phoneCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *chatCell;

@property (weak, nonatomic) IBOutlet ImageView *userAvatar;
@property (weak, nonatomic) IBOutlet UILabel *fullName;
@property (weak, nonatomic) IBOutlet UILabel *userDetails;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UIImageView *onlineCircle;

@end

@implementation FriendsDetailsController

- (void)dealloc {
    [[ChatReceiver instance] unsubscribeForTarget:self];
    NSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationController.navigationItem.rightBarButtonItem = nil;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (self.selectedUser.phone.length == 0) {
        [self.phoneLabel setText:NSLocalizedString(@"STR_NONE", nil)];
    } else {
        self.phoneLabel.text = self.selectedUser.phone;
    }
    
    self.fullName.text = self.selectedUser.fullName;
    self.userDetails.text = self.selectedUser.customData;
    self.userAvatar.imageViewType = ImageViewTypeCircle;
    
    NSURL *url = [NSURL URLWithString:self.selectedUser.website];
    UIImage *placeholder = [UIImage imageNamed:@"upic-placeholder"];
    [self.userAvatar setImageWithURL:url
                         placeholder:placeholder
                             options:SDWebImageHighPriority
                            progress:
     ^(NSInteger receivedSize, NSInteger expectedSize) {
         
     }
     
                      completedBlock:
     ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
         
     }];
    
    __weak __typeof(self)weakSelf = self;
    [[ChatReceiver instance] chatContactListUpdatedWithTarget:self block:^{
        [weakSelf updateUserStatus];
    }];
    
    [self updateUserStatus];
    
}

- (void)updateUserStatus {
    
    QBContactListItem *item = [[TMApi instance] contactItemWithUserID:self.selectedUser.ID];
    
    if (item) { //friend if YES
        self.status.text = NSLocalizedString(item.online ? @"STR_ONLINE": @"STR_OFFLINE", nil);
        self.onlineCircle.hidden = item.online ? NO : YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kChatViewSegueIdentifier]) {
        
        ChatViewController *chatController = segue.destinationViewController;
        chatController.dialog = sender;
        
        NSAssert([sender isKindOfClass:QBChatDialog.class], @"Need update this case");
    }
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case CallTypePhone: break;
            
#if AUDIO_VIDEO_ENABLED
        case CallTypeVideo:[self performSegueWithIdentifier:kVideoCallSegueIdentifier sender:nil]; break;
        case CallTypeAudio: [self performSegueWithIdentifier:kAudioCallSegueIdentifier sender:nil]; break;
        case CallTypeChat: {
#else
        case CallTypeVideo: {
#endif
            __weak __typeof(self)weakSelf = self;
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
            [[TMApi instance] createPrivateChatDialogIfNeededWithOpponent:self.selectedUser completion:^(QBChatDialog *chatDialog) {
                
                if (chatDialog) {
                    [weakSelf performSegueWithIdentifier:kChatViewSegueIdentifier sender:chatDialog];
                }
                [SVProgressHUD dismiss];
            }];
            
        } break;
            
        default:break;
    }
}

#pragma mark - Actions

- (IBAction)removeFromFriends:(id)sender {
    
    __weak __typeof(self)weakSelf = self;
    [REAlertView presentAlertViewWithConfiguration:^(REAlertView *alertView) {
        
        alertView.message = [NSString stringWithFormat:NSLocalizedString(@"STR_CONFIRM_DELETE_CONTACT", @"{User Full Name}"), self.selectedUser.fullName];
        [alertView addButtonWithTitle:NSLocalizedString(@"STR_CANCEL", nil) andActionBlock:^{}];
        [alertView addButtonWithTitle:NSLocalizedString(@"STR_DELETE", nil) andActionBlock:^{
            
            [[TMApi instance] removeUserFromContactListWithUserID:weakSelf.selectedUser.ID completion:^(BOOL success) {}];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
    }];
}

@end
