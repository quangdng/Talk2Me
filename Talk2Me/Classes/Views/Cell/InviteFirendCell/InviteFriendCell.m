//
//  InviteFriendsCell.m
//  Talk2Me
//
//  Created by Quang Nguyen on 02/10/2014.
//

#import "InviteFriendCell.h"
#import "ABPerson.h"
#import "TMApi.h"

@interface InviteFriendCell()

@property (weak, nonatomic) IBOutlet UIImageView *activeCheckbox;

@end

@implementation InviteFriendCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.activeCheckbox.hidden = YES;
}

- (void)setUserData:(id)userData {
    
    [super setUserData:userData];
    
    if ([userData isKindOfClass:ABPerson.class]) {
        [self configureWithAdressaddressBookUser:userData];
    } else if ([userData conformsToProtocol:@protocol(FBGraphUser)]) {
        [self configureWithFBGraphUser:userData];
    } else if ([userData isKindOfClass:[QBUUser class]]) {

        QBUUser *user = userData;
        self.titleLabel.text = (user.fullName.length == 0) ? @"" : user.fullName;
        NSURL *avatarUrl = [NSURL URLWithString:user.website];
        [self setUserImageWithUrl:avatarUrl];
    }
}

- (void)setContactlistItem:(QBContactListItem *)contactlistItem {
    
    if (contactlistItem) {
        self.descriptionLabel.text = NSLocalizedString(contactlistItem.online ? @"STR_ONLINE": @"STR_OFFLINE", nil);
    }
}

- (void)configureWithFBGraphUser:(NSDictionary<FBGraphUser> *)user {
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@ %@", user.first_name, user.last_name];
    NSURL *url = [[TMApi instance] fbUserImageURLWithUserID:user.id];
    [self setUserImageWithUrl:url];
    self.descriptionLabel.text = NSLocalizedString(@"STR_FACEBOOK", nil);
}

- (void)configureWithAdressaddressBookUser:(ABPerson *)addressBookUser {
    
    self.titleLabel.text = addressBookUser.fullName;
    self.descriptionLabel.text = NSLocalizedString(@"STR_CONTACT_LIST", nil);
    
    UIImage *image = addressBookUser.image;
    [self setUserImage:image withKey:addressBookUser.fullName];
}

- (void)setCheck:(BOOL)check {
    
    if (_check != check) {
        _check = check;
        self.activeCheckbox.hidden = !check;
    }
}

#pragma mark - Actions

- (IBAction)pressCheckBox:(id)sender {

    self.check ^= 1;
    [self.delegate containerView:self didChangeState:sender];
}

@end
