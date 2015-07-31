//
//  InviteFriendsDataSource.h
//  Talk2Me
//
//  Created by Tian Long on 09/10/2014.
//


@protocol CheckBoxStateDelegate <NSObject>
@optional
- (void)checkListDidChangeCount:(NSInteger)checkedCount;
@end



@interface InviteFriendsDataSource : NSObject

@property (weak, nonatomic) id <CheckBoxStateDelegate> checkBoxDelegate;

- (instancetype)initWithTableView:(UITableView *)tableView;
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)emailsToInvite;
- (void)clearABFriendsToInvite;

@end
