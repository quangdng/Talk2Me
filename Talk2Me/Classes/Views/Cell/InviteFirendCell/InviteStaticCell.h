//
//  InviteFriendsStaticCell.h
//  Talk2Me
//
//  Created by Quang Nguyen on 02/10/2014.
//

#import <UIKit/UIKit.h>
#import "CheckBoxProtocol.h"

@interface InviteStaticCell : UITableViewCell

@property (assign, nonatomic) NSUInteger badgeCount;
@property (assign, nonatomic, getter = isChecked) BOOL check;
@property (weak, nonatomic) id <CheckBoxProtocol> delegate;

@end
