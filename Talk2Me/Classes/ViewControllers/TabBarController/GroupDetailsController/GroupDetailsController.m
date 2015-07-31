//
//  GroupDetailsController.m
//  Talk2Me
//
//  Created by Quang Nguyen on 06/10/2014.
//

#import "GroupDetailsController.h"
#import "AddMembersToGroupController.h"
#import "GroupDetailsDataSource.h"
#import "SVProgressHUD.h"
#import "TMApi.h"
#import "ChatReceiver.h"

@interface GroupDetailsController ()

<UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *groupAvatarView;
@property (weak, nonatomic) IBOutlet UITextField *groupNameField;
@property (weak, nonatomic) IBOutlet UILabel *occupantsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *onlineOccupantsCountLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) GroupDetailsDataSource *dataSource;

@end

@implementation GroupDetailsController

- (void)dealloc {
    
    [[ChatReceiver instance] unsubscribeForTarget:self];
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateGUIWithChatDialog:self.chatDialog];
    
    self.dataSource = [[GroupDetailsDataSource alloc] initWithTableView:self.tableView];
    [self.dataSource reloadDataWithChatDialog:self.chatDialog];
    
    __weak __typeof(self)weakSelf = self;
    [[ChatReceiver instance] chatRoomDidReceiveListOfOnlineUsersWithTarget:self block:^(NSArray *users, NSString *roomName) {
        
        QBChatRoom *chatRoom = [[TMApi instance] chatRoomWithRoomJID:weakSelf.chatDialog.roomJID];
        if ([roomName isEqualToString:chatRoom.name]) {
            [weakSelf updateOnlineStatus:users.count];
        }
    }];
    
    [[ChatReceiver instance] chatRoomDidChangeOnlineUsersWithTarget:self block:^(NSArray *onlineUsers, NSString *roomName) {
        
        QBChatRoom *chatRoom = [[TMApi instance] chatRoomWithRoomJID:weakSelf.chatDialog.roomJID];
        if ([roomName isEqualToString:chatRoom.name]) {
            [weakSelf updateOnlineStatus:onlineUsers.count];
        }
    }];

    [[ChatReceiver instance] chatAfterDidReceiveMessageWithTarget:self block:^(QBChatMessage *message) {
        
        if (message.cParamNotificationType == MessageNotificationTypeUpdateDialog &&
            [message.cParamDialogID isEqualToString:weakSelf.chatDialog.ID]) {
            
            weakSelf.chatDialog = [[TMApi instance] chatDialogWithID:message.cParamDialogID];
            [weakSelf updateGUIWithChatDialog:weakSelf.chatDialog];
        }
    }];
}

- (void)updateOnlineStatus:(NSUInteger)online {
    
    NSString *onlineUsersCountText = [NSString stringWithFormat:@"%d/%d online", online, self.chatDialog.occupantIDs.count];
    self.onlineOccupantsCountLabel.text = onlineUsersCountText;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self.view endEditing:YES];
    [super viewWillDisappear:animated];
}

- (IBAction)changeDialogName:(id)sender {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[TMApi instance] changeChatName:self.groupNameField.text forChatDialog:self.chatDialog completion:^(QBChatDialogResult *result) {
        [SVProgressHUD dismiss];
    }];
}
- (IBAction)addFriendsToChat:(id)sender
{
    // check for friends:
    NSArray *friends = [[TMApi instance] friends];
    NSArray *usersIDs = [[TMApi instance] idsWithUsers:friends];
    NSArray *friendsIDsToAdd = [self filteredIDs:usersIDs forChatDialog:self.chatDialog];
    
    if ([friendsIDsToAdd count] == 0) {
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:NSLocalizedString(@"STR_CANT_ADD_NEW_FRIEND", nil)
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"STR_CANCEL", nil)
                          otherButtonTitles:nil] show];
        return;
    }
    
    [self performSegueWithIdentifier:kAddMembersToGroupControllerSegue sender:nil];
}

- (void)updateGUIWithChatDialog:(QBChatDialog *)chatDialog {
    
    NSAssert(self.chatDialog && chatDialog.type == QBChatDialogTypeGroup , @"Need update this case");

    self.groupNameField.text = chatDialog.name;
    self.occupantsCountLabel.text = [NSString stringWithFormat:@"%d participants", self.chatDialog.occupantIDs.count];
    self.onlineOccupantsCountLabel.text = [NSString stringWithFormat:@"0/%d online", self.chatDialog.occupantIDs.count];

    [self.dataSource reloadDataWithChatDialog:self.chatDialog];
    
    QBChatRoom *chatRoom = [[TMApi instance] chatRoomWithRoomJID:self.chatDialog.roomJID];
    [chatRoom requestOnlineUsers];
}

- (NSArray *)filteredIDs:(NSArray *)IDs forChatDialog:(QBChatDialog *)chatDialog
{
    NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:IDs];
    [newArray removeObjectsInArray:chatDialog.occupantIDs];
    return [newArray copy];
}


#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kAddMembersToGroupControllerSegue]) {
        AddMembersToGroupController *addMembersVC = segue.destinationViewController;
        addMembersVC.chatDialog = self.chatDialog;
    }
}

@end
