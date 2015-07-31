//
//  Protocols.h
//  Talk2Me
//
//  Created by Quang Nguyen on 20/08/2014.
//


@class TMTableViewCell;


@protocol TabBarChatDelegate <NSObject>
@optional
- (void)tabBarChatWithChatMessage:(QBChatMessage *)message chatDialog:(QBChatDialog *)dialog showTMessage:(BOOL)show;
@end

@protocol QMUsersListCellDelegate <NSObject>
@optional
- (void)usersListCell:(TMTableViewCell *)cell pressAddBtn:(UIButton *)sender;
- (void)usersListCell:(TMTableViewCell *)cell requestWasAccepted:(BOOL)accepted;

@end
