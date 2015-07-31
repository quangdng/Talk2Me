//
//  FriendsListDataSource.h
//  Talk2Me
//
//  Created by He Gui on 04/10/2014.
//

static NSString *const kFriendsListCellIdentifier = @"FriendListCell";
static NSString *const kDontHaveAnyFriendsCellIdentifier = @"QMDontHaveAnyFriendsCell";
static NSString *const kContactRequestCellIdentifier = @"ContactRequestCell";

@protocol FriendsListDataSourceDelegate <NSObject>

- (void)didChangeContactRequestsCount:(NSUInteger)contactRequestsCount;

@end

@interface FriendsListDataSource : NSObject <UITableViewDataSource, UISearchDisplayDelegate, QMUsersListCellDelegate>

@property (nonatomic, assign) BOOL viewIsShowed;
@property (assign, nonatomic, readonly) BOOL searchIsActive;
@property (weak, nonatomic) id <FriendsListDataSourceDelegate> delegate;

- (instancetype)initWithTableView:(UITableView *)tableView searchDisplayController:(UISearchDisplayController *)searchDisplayController;
- (NSArray *)usersAtSections:(NSInteger)section;
- (QBUUser *)userAtIndexPath:(NSIndexPath *)indexPath;

@end
