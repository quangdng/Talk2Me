//
//  FriendListCell.m
//  Talk2Me
//
//  Created by Quang Nguyen on 02/10/2014.
//

#import "FriendListCell.h"
#import "ImageView.h"
#import "TMApi.h"

@interface FriendListCell()

@property (weak, nonatomic) IBOutlet UIImageView *onlineCircle;
@property (weak, nonatomic) IBOutlet UIButton *addToFriendsButton;

@property (assign, nonatomic) BOOL isFriend;
@property (assign, nonatomic) BOOL online;

@end

@implementation FriendListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    /*isFriend - YES*/
    _isFriend = YES;
    self.addToFriendsButton.hidden = self.isFriend;
    /*isOnlien - NO*/
    self.onlineCircle.hidden = YES;
    self.descriptionLabel.text = NSLocalizedString(@"STR_OFFLINE", nil);
}

- (void)setUserData:(id)userData {
    [super setUserData:userData];

    QBUUser *user = userData;
    self.titleLabel.text = (user.fullName.length == 0) ? @"" : user.fullName;
    NSURL *avatarUrl = [NSURL URLWithString:user.website];
    [self setUserImageWithUrl:avatarUrl];
}

- (void)setOnline:(BOOL)online {
    
    QBUUser *user = self.userData;
    online = (user.ID == [TMApi instance].currentUser.ID) ? YES : online;
    
    if (_online != online) {
        _online = online;
    }
    self.onlineCircle.hidden = !online;
}

- (void)setContactlistItem:(QBContactListItem *)contactlistItem {

    [super setContactlistItem:contactlistItem];
    self.online = contactlistItem.online;
    self.isFriend = contactlistItem ?  YES : NO;
    
    NSString *status = nil;
    
    if (!contactlistItem) {
        status = @"";
    } else if (contactlistItem.subscriptionState == QBPresenseSubscriptionStateBoth) {
        status = NSLocalizedString(contactlistItem.online ? @"STR_ONLINE": @"STR_OFFLINE", nil);
    } else {
        status = NSLocalizedString(@"STR_PENDING", nil);
    }
    self.descriptionLabel.text = status;
}

- (void)setIsFriend:(BOOL)isFriend {
    
    QBUUser *user = self.userData;
    isFriend = (user.ID == [TMApi instance].currentUser.ID) ? YES : isFriend;
    
    _isFriend = isFriend;
    
    self.addToFriendsButton.hidden = isFriend;
    if (!_isFriend) {
        self.descriptionLabel.text = @"";
    }
}

- (void)setSearchText:(NSString *)searchText {
    
    _searchText = searchText;
    if (_searchText.length > 0) {
        
        QBUUser *user = self.userData;
        NSString *fullName = user.fullName;
        
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:fullName];
        [text addAttribute: NSForegroundColorAttributeName
                     value:[UIColor redColor]
                     range:[fullName.lowercaseString rangeOfString:searchText.lowercaseString]];
        
        self.titleLabel.attributedText = text;
    }
}

#pragma mark - Actions

- (IBAction)pressAddBtn:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(usersListCell:pressAddBtn:)]) {
        [self.delegate usersListCell:self pressAddBtn:sender];
    }
}

@end
