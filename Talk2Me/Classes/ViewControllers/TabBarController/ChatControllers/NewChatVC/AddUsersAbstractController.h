//
//  AddUsersAbstractController.h
//  Talk2Me
//
//  Created by Saranya Nagarajan on 29/09/2014.
//

#import <UIKit/UIKit.h>


@interface AddUsersAbstractController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *selectedFriends;
@property (strong, nonatomic) NSArray *friends;

/** Actions */
- (IBAction)performAction:(UIButton *)sender;

@end
