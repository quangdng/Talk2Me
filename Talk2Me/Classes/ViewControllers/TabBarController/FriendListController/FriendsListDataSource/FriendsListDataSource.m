//
//  FriendsListDataSource.m
//  Talk2Me
//
//  Created by He Gui on 04/10/2014.
//

#import "FriendsListDataSource.h"
#import "FriendListViewController.h"
#import "UsersService.h"
#import "FriendListCell.h"
#import "ContactRequestCell.h"
#import "TMApi.h"
#import "UsersService.h"
#import "SVProgressHud.h"
#import "ChatReceiver.h"
#import "REAlertView.h"


@interface FriendsListDataSource()


@property (strong, nonatomic) NSArray *searchResult;
@property (strong, nonatomic) NSArray *friendList;
@property (strong, nonatomic) NSArray *contactRequests;

@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) UISearchDisplayController *searchDisplayController;
@property (strong, nonatomic) NSObject<Cancelable> *searchOperation;

@property (strong, nonatomic) id tUser;

@property (assign, nonatomic) BOOL searchIsActive;

@property (assign, nonatomic) NSUInteger contactRequestsCount;

@end

@implementation FriendsListDataSource

@synthesize friendList = _friendList;


- (instancetype)initWithTableView:(UITableView *)tableView searchDisplayController:(UISearchDisplayController *)searchDisplayController
{
    
    self = [super init];
    if (self) {
        
        self.tableView = tableView;
        self.tableView.dataSource = self;
        self.searchResult = [NSArray array];
        
        self.searchDisplayController = searchDisplayController;
        __weak __typeof(self)weakSelf = self;
        
        void (^reloadDatasource)(void) = ^(void) {
            
            if (weakSelf.searchOperation) {
                return;
            }
            
            if (weakSelf.searchIsActive) {
                
                CGPoint point = weakSelf.searchDisplayController.searchResultsTableView.contentOffset;
                
                weakSelf.friendList = [TMApi instance].friends;
                [weakSelf.searchDisplayController.searchResultsTableView reloadData];
                NSUInteger idx = [weakSelf.friendList indexOfObject:weakSelf.tUser];
                NSUInteger idx2 = [weakSelf.searchResult indexOfObject:weakSelf.tUser];
               
                if (idx != NSNotFound && idx2 != NSNotFound) {
                    
                    point .y += 59;
                    weakSelf.searchDisplayController.searchResultsTableView.contentOffset = point;
                    
                    weakSelf.tUser = nil;
                    [SVProgressHUD dismiss];
                }
            }
            else {
                [weakSelf reloadDataSource];
            }
        };
        
        [[ChatReceiver instance] contactRequestUsersListChangedWithTarget:self block:^{
            weakSelf.contactRequests = [TMApi instance].contactRequestUsers;
            weakSelf.contactRequestsCount = weakSelf.contactRequests.count;
            if (weakSelf.viewIsShowed && !self.searchIsActive) {
                [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationFade];
            }
        }];
        
        [[ChatReceiver instance] usersHistoryUpdatedWithTarget:self block:reloadDatasource];
        [[ChatReceiver instance] chatContactListUpdatedWithTarget:self block:reloadDatasource];
        
        UINib *friendsCellNib = [UINib nibWithNibName:@"FriendListCell" bundle:nil];
        UINib *contactRequestCellNib = [UINib nibWithNibName:@"ContactRequestCell" bundle:nil];
        UINib *noResultsCellNib = [UINib nibWithNibName:@"NoResultsCell" bundle:nil];
        
        [searchDisplayController.searchResultsTableView registerNib:friendsCellNib forCellReuseIdentifier:kFriendsListCellIdentifier];
        [searchDisplayController.searchResultsTableView registerNib:contactRequestCellNib forCellReuseIdentifier:kContactRequestCellIdentifier];
        [searchDisplayController.searchResultsTableView registerNib:noResultsCellNib forCellReuseIdentifier:kDontHaveAnyFriendsCellIdentifier];
        
        
    }
    
    return self;
}

- (void)setFriendList:(NSArray *)friendList {
    _friendList = [UsersUtils sortUsersByFullname:friendList];
}

- (NSArray *)friendList {
    
    if (self.searchIsActive && self.searchDisplayController.searchBar.text.length > 0) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.fullName CONTAINS[cd] %@", self.searchDisplayController.searchBar.text];
        NSArray *filtered = [_friendList filteredArrayUsingPredicate:predicate];
        
        return filtered;
    }
    return _friendList;
}

- (void)reloadDataSource {
    
    self.friendList = [TMApi instance].friends;
    if (self.viewIsShowed) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    }
} 

- (void)globalSearch:(NSString *)searchText {
    
    if (searchText.length == 0) {
        self.searchResult = @[];
        [self.searchDisplayController.searchResultsTableView reloadData];
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    QBUUserPagedResultBlock userPagedBlock = ^(QBUUserPagedResult *pagedResult) {
        
        NSArray *users = [UsersUtils sortUsersByFullname:pagedResult.users];
        //Remove current user from search result
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.ID != %d", [TMApi instance].currentUser.ID];
        weakSelf.searchResult = [users filteredArrayUsingPredicate:predicate];
        [weakSelf.searchDisplayController.searchResultsTableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
        weakSelf.searchOperation = nil;
        [SVProgressHUD dismiss];
    };
    
    [self.searchDisplayController.searchResultsTableView reloadData];
    
    __block NSString *tsearch = [searchText copy];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if ([weakSelf.searchDisplayController.searchBar.text isEqualToString:tsearch]) {
            
            if (weakSelf.searchOperation) {
                [weakSelf.searchOperation cancel];
                weakSelf.searchOperation = nil;
            }
            
            PagedRequest *request = [[PagedRequest alloc] init];
            request.page = 1;
            request.perPage = 100;
            
            
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
            weakSelf.searchOperation = [[TMApi instance].usersService retrieveUsersWithFullName:searchText pagedRequest:request completion:userPagedBlock];
        }
    });
}

- (void)setContactRequestsCount:(NSUInteger)contactRequestsCount
{
    if (_contactRequestsCount != contactRequestsCount) {
        _contactRequestsCount = contactRequestsCount;
        if ([self.delegate respondsToSelector:@selector(didChangeContactRequestsCount:)]) {
            [self.delegate didChangeContactRequestsCount:_contactRequestsCount];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSArray *users = [self usersAtSections:section];
    
    if (section == 0) {
        return (!self.searchIsActive && users.count > 0) ? NSLocalizedString(@"STR_REQUESTS", nil) : nil;
    } else if (section == 1) {
        return (users.count > 0) ? NSLocalizedString(@"STR_CONTACTS", nil) : nil;
    }
    return (self.searchIsActive) ? NSLocalizedString(@"STR_ALL_USERS", nil) : nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (self.searchIsActive) {
        return 3;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *users = [self usersAtSections:section];
    
    if (section == 0) {
        return (!self.searchIsActive && [users count] > 0) ? users.count : 0;
    } else if (section == 1) {
        if (self.searchIsActive) {
            return ([users count] > 0) ? users.count : 0;
        }
        else if ([self.contactRequests count] > 0) {
            return ([users count] > 0) ? users.count : 0;
        }
        return ([users count] > 0) ? users.count : 1;
    }
    return (self.searchIsActive && users.count > 0) ? users.count : 0;
}

- (NSArray *)usersAtSections:(NSInteger)section
{
    if (section == 0 ) {
        return self.contactRequests;
    } else if (section == 1) {
        return self.friendList;
    }
    return self.searchResult;
}

- (QBUUser *)userAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *users = [self usersAtSections:indexPath.section];
    QBUUser *user = users[indexPath.row];
    
    return user;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *users = [self usersAtSections:indexPath.section];
    
    if (!self.searchIsActive) {
        if (users.count == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDontHaveAnyFriendsCellIdentifier];
            return cell;
        }
    }
    TMTableViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:kContactRequestCellIdentifier];
        ((ContactRequestCell *)cell).delegate = self;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:kFriendsListCellIdentifier];
        ((FriendListCell *)cell).delegate = self;
    }
    QBUUser *user = users[indexPath.row];
    
    QBContactListItem *item = [[TMApi instance] contactItemWithUserID:user.ID];
    cell.contactlistItem = item;
    cell.userData = user;
    
    if(self.searchIsActive && [cell isKindOfClass:FriendListCell.class]) {
        ((FriendListCell *)cell).searchText = self.searchDisplayController.searchBar.text;
    }
    
    return cell;
}


#pragma mark - UsersListCellDelegate

- (void)usersListCell:(FriendListCell *)cell pressAddBtn:(UIButton *)sender {
    
    NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForCell:cell];
    NSArray *datasource = [self usersAtSections:indexPath.section];
    QBUUser *user = datasource[indexPath.row];
    
    __weak __typeof(self)weakSelf = self;
    [[TMApi instance] addUserToContactListRequest:user completion:^(BOOL success) {
        if (success) {
            weakSelf.tUser = user;
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        }
    }];
}

- (void)usersListCell:(TMTableViewCell *)cell requestWasAccepted:(BOOL)accepted
{
    QBUUser *user = cell.userData;    
    __weak __typeof(self)weakSelf = self;

    if (accepted) {
        [[TMApi instance] confirmAddContactRequest:user.ID completion:^(BOOL success) {
            [weakSelf reloadContactListSectionIfNeeded];
        }];
    } else {
        
        [REAlertView presentAlertViewWithConfiguration:^(REAlertView *alertView) {
            alertView.message = [NSString stringWithFormat:NSLocalizedString(@"STR_CONFIRM_REJECT_FRIENDS_REQUEST", @"{User's full name}"),  user.fullName];
            [alertView addButtonWithTitle:NSLocalizedString(@"STR_CANCEL", nil) andActionBlock:^{}];
            [alertView addButtonWithTitle:NSLocalizedString(@"STR_OK", nil) andActionBlock:^{
                //
                [[TMApi instance] rejectAddContactRequest:user.ID completion:^(BOOL success) {
                   [weakSelf reloadContactListSectionIfNeeded];
                }];
            }];
        }];
    }
}

- (void)reloadContactListSectionIfNeeded
{
    self.contactRequests = [TMApi instance].contactRequestUsers;
    self.contactRequestsCount = self.contactRequests.count;
    if (self.viewIsShowed) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationTop];
    }
}


#pragma mark - UISearchDisplayController

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    if (!self.searchIsActive) {
        if (searchString.length > 0) {
            [self.tableView setDataSource:nil];
        } else {
            [self.tableView setDataSource:self];
        }
        self.searchIsActive = YES;
    }
    [self globalSearch:searchString];
    return NO;
}

-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    if (self.searchIsActive) {
        self.searchIsActive = NO;
    }
    [self.tableView setDataSource:self];
    [self.tableView reloadData];
}

@end
