//
//  AddMembersToGroupController.m
//  Talk2Me
//
//  Created by Saranya Nagarajan on 29/09/2014.
//

#import "AddMembersToGroupController.h"
#import "TMApi.h"
#import "SVProgressHUD.h"

@implementation AddMembersToGroupController


- (void)viewDidLoad {
    
    NSArray *friends = [[TMApi instance] friends];
    NSArray *usersIDs = [[TMApi instance] idsWithUsers:friends];
    NSArray *friendsIDsToAdd = [self filteredIDs:usersIDs forChatDialog:self.chatDialog];
    
    NSArray *toAdd = [[TMApi instance] usersWithIDs:friendsIDsToAdd];
    self.friends = [UsersUtils sortUsersByFullname:toAdd];
    
    [super viewDidLoad];
}

#pragma mark - Overriden methods

- (IBAction)performAction:(id)sender {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    __weak __typeof(self)weakSelf = self;
    [[TMApi instance] joinOccupants:self.selectedFriends toChatDialog:self.chatDialog completion:^(QBChatDialogResult *result) {
        
        if (result.success) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
        
        [SVProgressHUD dismiss];
    }];
}

- (NSArray *)filteredIDs:(NSArray *)IDs forChatDialog:(QBChatDialog *)chatDialog
{
    NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:IDs];
    [newArray removeObjectsInArray:chatDialog.occupantIDs];
    return [newArray copy];
}

@end
