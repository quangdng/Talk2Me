//
//  InviteFriendsDataSource.m
//  Talk2Me
//
//  Created by Tian Long on 09/10/2014.
//

#import "InviteFriendsDataSource.h"
#import "InviteFriendCell.h"
#import "InviteStaticCell.h"
#import "ABPerson.h"
#import "TMApi.h"
#import "FacebookService.h"
#import "QMAddressBook.h"
#import "SVProgressHUD.h"

typedef NS_ENUM(NSUInteger, QMCollectionGroup) {
    
    QMStaticCellsSection = 0,
    QMFriendsListSection = 1,
    QMABFriendsToInviteSection = 3
};

NSString *const kInviteFriendCellID = @"InviteFriendCell";
NSString *const kStaticFBCellID = @"QMStaticFBCell";
NSString *const kStaticABCellID = @"QMStaticABCell";

const CGFloat kInviteFriendCellHeight = 60;
const CGFloat kStaticCellHeihgt = 44;
const NSUInteger kNumberOfSection = 2;

@interface InviteFriendsDataSource()

<UITableViewDataSource, CheckBoxProtocol, CheckBoxStateDelegate>

@property (weak, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSMutableDictionary *collections;
@property (strong, nonatomic) InviteStaticCell *abStaticCell;
@property (strong, nonatomic) InviteStaticCell *fbStaticCell;

@property (strong, nonatomic) NSArray *abUsers;

@end

@implementation InviteFriendsDataSource

- (instancetype)initWithTableView:(UITableView *)tableView {
    
    self = [super init];
    if (self) {
        
        _collections = [NSMutableDictionary dictionary];
        _abUsers = @[];
        
        self.tableView = tableView;
        self.tableView.dataSource = self;
        self.checkBoxDelegate = self;
        
        self.abStaticCell = [self.tableView dequeueReusableCellWithIdentifier:kStaticABCellID];
        self.abStaticCell.delegate = self;
        
        self.fbStaticCell = [self.tableView dequeueReusableCellWithIdentifier:kStaticFBCellID];
        
        NSArray *staticCells = @[self.fbStaticCell, self.abStaticCell];

        [self setCollection:staticCells toSection:QMStaticCellsSection];
        [self setCollection:@[].mutableCopy toSection:QMABFriendsToInviteSection];
    }
    
    return self;
}

#pragma mark - fetch user 

- (void)fetchFacebookFriends:(void(^)(void))completion {
    
    [[TMApi instance] fbIniviteDialogWithCompletion:^(BOOL success) {
        if (success) {
            [SVProgressHUD showSuccessWithStatus:@"Success"];
            return;
        }
    }];

}

- (void)fetchAdressbookFriends:(void(^)(void))completion {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    __weak __typeof(self)weakSelf = self;
    [QMAddressBook getContactsWithEmailsWithCompletionBlock:^(NSArray *contactsWithEmails) {
        weakSelf.abUsers = contactsWithEmails;
        [SVProgressHUD dismiss];
        
        if (completion) completion();
        
    }];
}

#pragma mark - setters

- (void)setAbUsers:(NSArray *)abUsers {
    
    abUsers = [self sortUsersByKey:@"fullName" users:abUsers];
    if (![_abUsers isEqualToArray:abUsers]) {
        _abUsers = abUsers;
        [self updateDatasource];
    }
}

- (NSArray *)sortUsersByKey:(NSString *)key users:(NSArray *)users {
    
    NSSortDescriptor *fullNameDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:YES];
    NSArray *sortedUsers = [users sortedArrayUsingDescriptors:@[fullNameDescriptor]];
    
    return sortedUsers;
}

- (void)reloadFriendSectionWithRowAnimation:(UITableViewRowAnimation)animation {
    
    [self.tableView beginUpdates];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:QMFriendsListSection];
    [self.tableView reloadSections:indexSet withRowAnimation:animation];
    [self.tableView endUpdates];
}

- (void)reloadRowPathAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation {
   
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
    [self.tableView endUpdates];
}

- (void)updateDatasource {
    
    NSArray * friendsCollection = self.abUsers;
    [self setCollection:friendsCollection toSection:QMFriendsListSection];
    [self reloadFriendSectionWithRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kNumberOfSection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray *collection = [self collectionAtSection:section];
    return collection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == QMStaticCellsSection) {

        InviteStaticCell *staticCell = [self itemAtIndexPath:indexPath];
        NSArray *array = [self collectionAtSection:QMABFriendsToInviteSection];
        staticCell.badgeCount = array.count;
        
        return staticCell;
    }
    
    InviteFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:kInviteFriendCellID];

    id userData = [self itemAtIndexPath:indexPath];

    if ([userData isKindOfClass:[QBUUser class]]) {
        QBUUser *user = userData;
        cell.contactlistItem = [[TMApi instance] contactItemWithUserID:user.ID];
    }
    
    cell.userData = userData;
    cell.check = [self checkedAtIndexPath:indexPath];
    cell.delegate = self;
    
    return cell;
}

#pragma mark - keys
/**
 Access key for collection At section
 */
- (NSString *)keyAtSection:(NSUInteger)section {
    
    NSString *sectionKey = [NSString stringWithFormat:@"section - %d", section];
    return sectionKey;
}

#pragma mark - collections

- (NSMutableArray *)collectionAtSection:(NSUInteger)section {
    
    NSString *key = [self keyAtSection:section];
    NSMutableArray *collection = self.collections[key];
    
    return collection;
}

- (void)setCollection:(NSArray *)collection toSection:(NSUInteger)section {
    
    NSString *key = [self keyAtSection:section];
    self.collections[key] = collection;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *collection = [self collectionAtSection:indexPath.section];
    id item = collection[indexPath.row];
    
    return item;
}

- (NSUInteger)sectionToInviteWihtUserData:(id)data {
    
    if ([data isKindOfClass:ABPerson.class]) {
        return QMABFriendsToInviteSection;
    }
    
    NSAssert(nil, @"Need update this case");
    return 0;
}

- (BOOL)checkedAtIndexPath:(NSIndexPath *)indexPath {
    
    id item = [self itemAtIndexPath:indexPath];
    NSInteger sectionToInvite = [self sectionToInviteWihtUserData:item];
    NSArray *toInvite = [self collectionAtSection:sectionToInvite];
    BOOL checked = [toInvite containsObject:item];
    
    return checked;
}

#pragma mark - CheckBoxProtocol

- (void)containerView:(UIView *)containerView didChangeState:(id)sender {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(id)containerView];
   __weak __typeof(self)weakSelf = self;
    void (^update)(NSUInteger, NSArray*) = ^(NSUInteger collectionSection, NSArray *collection){
        
        InviteStaticCell *cell = (InviteStaticCell *)containerView;
        
        [weakSelf setCollection:cell.isChecked ? collection.mutableCopy : @[].mutableCopy toSection:collectionSection];
        [weakSelf reloadRowPathAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
        [weakSelf reloadFriendSectionWithRowAnimation:UITableViewRowAnimationNone];
    };
    
    if (containerView == self.abStaticCell) {
        
        if (self.abUsers.count == 0) {
            [self fetchAdressbookFriends:^{
                update(QMABFriendsToInviteSection, weakSelf.abUsers);
            }];
        }
        else {
            update(QMABFriendsToInviteSection, self.abUsers);
        }
        
    }
    else  {
        
        InviteFriendCell *cell = (InviteFriendCell *)containerView;
        
        id item = [self itemAtIndexPath:indexPath];
        
        NSUInteger section = [self sectionToInviteWihtUserData:item];
        NSMutableArray *toInvite = [self collectionAtSection:section];
        cell.isChecked ? [toInvite addObject:item] : [toInvite removeObject:item];
    
        NSIndexPath *indexPathToReload = [NSIndexPath indexPathForRow:1 inSection:QMStaticCellsSection];
        
        [self reloadRowPathAtIndexPath:indexPathToReload withRowAnimation:UITableViewRowAnimationNone];
    }
    
    [self checkListDidChange];
}

- (void)clearABFriendsToInvite  {
    
    [self setCollection:@[].mutableCopy toSection:QMABFriendsToInviteSection];
    [self.tableView reloadData];
    [self checkListDidChange];
}


- (void)checkListDidChange {
    
    NSArray *addressBookFriendsToInvite = self.collections [[self keyAtSection:QMABFriendsToInviteSection]];
    [self.checkBoxDelegate checkListDidChangeCount:(addressBookFriendsToInvite.count)];
}

#pragma mark - Public methods
#pragma mark Invite Data

- (NSArray *)emailsToInvite {
    
    NSMutableArray *result = [NSMutableArray array];
    
    NSArray *addressBookUsersToInvite = [self collectionAtSection:QMABFriendsToInviteSection];
    for (ABPerson *user in addressBookUsersToInvite) {
        [result addObject:user.emails.firstObject];
    }
    
    return result;
}

#pragma mark -

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == QMStaticCellsSection ) {
        return kStaticCellHeihgt;
    } else if (indexPath.section == QMFriendsListSection) {
        return kInviteFriendCellHeight;
    }
    
    NSAssert(nil, @"Need Update this case");
    return 0;
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == QMStaticCellsSection) {
        
        switch (indexPath.row) {
            case 0: [self fetchFacebookFriends:nil]; break;
            case 1:[self fetchAdressbookFriends:nil]; break;
            default:NSAssert(nil, @"Need Update this case"); break;
        }
    }
}

@end