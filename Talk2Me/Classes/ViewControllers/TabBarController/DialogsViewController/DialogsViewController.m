//
//  DialogsViewController.m
//  Talk2Me
//
//  Created by Tian Long on 09/09/2014.
//

#import "DialogsViewController.h"
#import "ChatViewController.h"
#import "CreateNewChatController.h"
#import "DialogsDataSource.h"
#import "ChatReceiver.h"
#import "TMApi.h"

static NSString *const ChatListCellIdentifier = @"ChatListCell";

@interface DialogsViewController ()

<UITableViewDelegate, DialogsDataSourceDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) DialogsDataSource *dataSource;

@end

@implementation DialogsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.dataSource = [[DialogsDataSource alloc] initWithTableView:self.tableView];
    self.dataSource.delegate = self;
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.dataSource fetchUnreadDialogsCount];
    [self.tableView reloadData];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 59;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QBChatDialog *dialog = [self.dataSource dialogAtIndexPath:indexPath];
    if (dialog) {
        [self performSegueWithIdentifier:kChatViewSegueIdentifier sender:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kChatViewSegueIdentifier]) {
        
        ChatViewController *chatController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        QBChatDialog *dialog = [self.dataSource dialogAtIndexPath:indexPath];
        chatController.dialog = dialog;
        
    } else if ([segue.destinationViewController isKindOfClass:[CreateNewChatController class]]) {
        
    }
}

#pragma mark - Actions

- (IBAction)createNewDialog:(id)sender {
    if ([[TMApi instance].friends count] == 0) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"You don't have any friends for creating new chat." delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil] show];
        return;
    }
    [self performSegueWithIdentifier:kCreateNewChatSegueIdentifier sender:nil];
}

#pragma mark - DialogsDataSourceDelegate

- (void)didChangeUnreadDialogCount:(NSUInteger)unreadDialogsCount {
    
    NSUInteger idx = [self.tabBarController.viewControllers indexOfObject:self.navigationController];
    if (idx != NSNotFound) {
        UITabBarItem *item = self.tabBarController.tabBar.items[idx];
        item.badgeValue = unreadDialogsCount > 0 ? [NSString stringWithFormat:@"%d", unreadDialogsCount] : nil;
    }
}

- (IBAction)toContactView:(id)sender {
    // switch back
    
    int controllerIndex = 1;
    
    UITabBarController *tabBarController = self.tabBarController;
    UIView * fromView = tabBarController.selectedViewController.view;
    UIView * toView = [[tabBarController.viewControllers objectAtIndex:controllerIndex] view];
    
    // Transition using a page curl.
    [UIView transitionFromView:fromView
                        toView:toView
                      duration:0.5
                       options:(UIViewAnimationOptionTransitionCrossDissolve )
                    completion:^(BOOL finished) {
                        if (finished) {
                            tabBarController.selectedIndex = controllerIndex;
                        }
                    }];
                    
   
}



@end
