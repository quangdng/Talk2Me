//
//  ContactRequestCell.h
//  Talk2Me
//
//  Created by Quang Nguyen on 02/10/2014.
//

#import "TMTableViewCell.h"

@interface ContactRequestCell : TMTableViewCell

@property (nonatomic, weak) id <QMUsersListCellDelegate> delegate;

@end
