//
//  CreateNewChatController.m
//  Talk2Me
//
//  Created by Saranya Nagarajan on 29/09/2014.
//

#import "CreateNewChatController.h"
#import "ChatViewController.h"
#import "SVProgressHUD.h"
#import "TMApi.h"

NSString *const ChatViewControllerID = @"ChatViewController";

@implementation CreateNewChatController

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    
    NSArray *unsortedFriends = [[TMApi instance] friends];
    self.friends = [UsersUtils sortUsersByFullname:unsortedFriends];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Overriden Actions

- (IBAction)performAction:(id)sender {
    
	NSMutableArray *selectedUsersMArray = self.selectedFriends;
    NSString *chatName = [self chatNameFromUserNames:selectedUsersMArray];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];

    __weak __typeof(self)weakSelf = self;
    [[TMApi instance] createGroupChatDialogWithName:chatName occupants:self.selectedFriends completion:^(QBChatDialogResult *result) {
        
        if (result.success) {
            
            ChatViewController *chatVC = [weakSelf.storyboard instantiateViewControllerWithIdentifier:ChatViewControllerID];
            chatVC.dialog = result.dialog;
            
            NSMutableArray *controllers = weakSelf.navigationController.viewControllers.mutableCopy;
            [controllers removeLastObject];
            [controllers addObject:chatVC];
            
            [weakSelf.navigationController setViewControllers:controllers animated:YES];
        }
        
        [SVProgressHUD dismiss];
    }];
}

- (NSString *)chatNameFromUserNames:(NSMutableArray *)users {
    
    NSMutableArray *names = [NSMutableArray arrayWithCapacity:users.count];
    
    for (QBUUser *user in users) {
        [names addObject:user.fullName];
    }
    
    [names addObject:[TMApi instance].currentUser.fullName];
    return [names componentsJoinedByString:@", "];
}

@end
