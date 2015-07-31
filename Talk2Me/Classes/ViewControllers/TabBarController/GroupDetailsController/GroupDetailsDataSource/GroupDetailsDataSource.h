//
//  GroupDetailsDataSource.h
//  Talk2Me
//
//  Created by Quang Nguyen on 06/10/2014.
//

#import <Foundation/Foundation.h>

@interface GroupDetailsDataSource : NSObject <UITableViewDataSource>

- (id)initWithTableView:(UITableView *)tableView;
- (void)reloadDataWithChatDialog:(QBChatDialog *)chatDialog;

@end
