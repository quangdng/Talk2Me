//
//  GroupDetailsDataSource.m
//  Talk2Me
//
//  Created by Quang Nguyen on 06/10/2014.
//
#import "GroupDetailsDataSource.h"
#import "FriendListCell.h"
#import "ChatReceiver.h"
#import "TMApi.h"

NSString * const kFriendsListCellIdentifier = @"FriendListCell";

@interface GroupDetailsDataSource ()

<QMUsersListCellDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray *participants;

@property (nonatomic, strong) QBChatDialog *chatDialog;

@end

@implementation GroupDetailsDataSource

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
    [[ChatReceiver instance] unsubscribeForTarget:self];
}

- (id)initWithTableView:(UITableView *)tableView {

    if (self = [super init]) {
        
        _tableView = tableView;
        
        
        self.tableView.dataSource = nil;
        self.tableView.dataSource = self;
        
        __weak __typeof(self)weakSelf = self;
        
        [[ChatReceiver instance] usersHistoryUpdatedWithTarget:self block:^{
            [weakSelf reloadUserData];
        }];
        
        [[ChatReceiver instance] chatContactListUpdatedWithTarget:self block:^{
            [weakSelf reloadUserData];
        }];
        
        [[ChatReceiver instance] chatAfterDidReceiveMessageWithTarget:self block:^(QBChatMessage *message) {
            
            if (message.cParamNotificationType == MessageNotificationTypeUpdateDialog &&
                [message.cParamDialogID isEqualToString:weakSelf.chatDialog.ID])
            {
                [weakSelf reloadUserData];
            }
        }];
    }
    
    return self;
}

- (void)reloadDataWithChatDialog:(QBChatDialog *)chatDialog  {
    
    self.chatDialog = chatDialog;
    [self reloadUserData];
}

- (void)reloadUserData {
    
    NSArray *unsortedParticipants = [[TMApi instance] usersWithIDs:self.chatDialog.occupantIDs];
    self.participants = [UsersUtils sortUsersByFullname:unsortedParticipants];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.participants.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:kFriendsListCellIdentifier];

    QBUUser *user = self.participants[indexPath.row];
    
    cell.userData = user;
    cell.contactlistItem = [[TMApi instance] contactItemWithUserID:user.ID];
    cell.delegate = self;
    
    return cell;
}

#pragma mark - FriendListCellDelegate

- (void)usersListCell:(FriendListCell *)cell pressAddBtn:(UIButton *)sender {

    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    QBUUser *user = self.participants[indexPath.row];
    [[TMApi instance] addUserToContactListRequest:user completion:^(BOOL success) {
        
    }];
}

@end
