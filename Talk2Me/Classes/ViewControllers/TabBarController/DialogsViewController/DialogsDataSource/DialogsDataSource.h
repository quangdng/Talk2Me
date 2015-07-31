//
//  DialogsDataSource.h
//  Talk2Me
//
//  Created by Tian Long on 09/09/2014.
//

#import <Foundation/Foundation.h>

@protocol DialogsDataSourceDelegate <NSObject>

- (void)didChangeUnreadDialogCount:(NSUInteger)unreadDialogsCount;

@end

@interface DialogsDataSource : NSObject

@property(weak, nonatomic) id <DialogsDataSourceDelegate> delegate;

- (instancetype)initWithTableView:(UITableView *)tableView;
- (QBChatDialog *)dialogAtIndexPath:(NSIndexPath *)indexPath;
- (void)fetchUnreadDialogsCount;

@end
