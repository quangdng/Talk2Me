//
//  InviteFriendsCell.h
//  Talk2Me
//
//  Created by Quang Nguyen on 02/10/2014.
//

#import "CheckBoxProtocol.h"
#import "TMTableViewCell.h"

@class InviteFriendCell;

@interface InviteFriendCell : TMTableViewCell

@property (assign, nonatomic, getter = isChecked) BOOL check;
@property (weak, nonatomic) id <CheckBoxProtocol> delegate;

@end
