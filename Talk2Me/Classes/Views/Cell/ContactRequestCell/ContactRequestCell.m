//
//  ContactRequestCell.m
//  Talk2Me
//
//  Created by Quang Nguyen on 02/10/2014.
//

#import "ContactRequestCell.h"

@implementation ContactRequestCell


- (void)setUserData:(id)userData {
    [super setUserData:userData];
    
    QBUUser *user = userData;
    self.titleLabel.text = (user.fullName.length == 0) ? @"" : user.fullName;
    NSURL *avatarUrl = [NSURL URLWithString:user.website];
    [self setUserImageWithUrl:avatarUrl];
}

- (IBAction)rejectButtonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(usersListCell:requestWasAccepted:)]) {
        [self.delegate usersListCell:self requestWasAccepted:NO];
    }
}

- (IBAction)acceptButtonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(usersListCell:requestWasAccepted:)]) {
        [self.delegate usersListCell:self requestWasAccepted:YES];
    }
}

@end
