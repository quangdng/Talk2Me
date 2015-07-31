//
//  FriendListCell.h
//  Talk2Me
//
//  Created by Quang Nguyen on 02/10/2014.
//

#import "TMTableViewCell.h"


@interface FriendListCell : TMTableViewCell

@property (strong, nonatomic) NSString *searchText;

@property (weak, nonatomic) id <QMUsersListCellDelegate>delegate;

@end
