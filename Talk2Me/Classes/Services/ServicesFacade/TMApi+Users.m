//
//  TMApi+Users.m
//  Talk2Me
//
//  Created by Quang Nguyen on 26/08/2014.
//

#import "TMApi.h"
#import "UsersService.h"
#import "ContentService.h"
#import "FacebookService.h"
#import "MessagesService.h"
#import "ChatReceiver.h"
#import "SettingsManager.h"
#import "QMAddressBook.h"
#import "ABPerson.h"


@implementation TMApi (Users)

- (void)addUserToContactListRequest:(QBUUser *)user completion:(void(^)(BOOL success))completion {

    [self.messagesService chat:^(QBChat *chat) {
        BOOL success = [chat addUserToContactListRequest:user.ID];
        if (success) {
            [self.usersService addUser:user];
        }
        if (completion) completion(success);
    }];
}

- (void)removeUserFromContactListWithUserID:(NSUInteger)userID completion:(void(^)(BOOL success))completion {
    
    [self.messagesService chat:^(QBChat *chat) {
        BOOL success = [chat removeUserFromContactList:userID];
        completion(success);
    }];
}

- (void)confirmAddContactRequest:(NSUInteger)userID completion:(void(^)(BOOL success))completion {
    
    [self.messagesService chat:^(QBChat *chat) {
        BOOL success = [chat confirmAddContactRequest:userID];
        [self.usersService.confirmRequestUsersIDs removeObject:@(userID)];
        completion(success);
    }];
}

- (void)rejectAddContactRequest:(NSUInteger)userID completion:(void(^)(BOOL success))completion {
    [self.messagesService chat:^(QBChat *chat) {
        BOOL success = [chat rejectAddContactRequest:userID];
        [self.usersService.confirmRequestUsersIDs removeObject:@(userID)];
        completion(success);
    }];
}

/**
 @param QBUUser ID
 @return QBContactListItem from chaced contactList
 */

- (QBContactListItem *)contactItemWithUserID:(NSUInteger)userID {
    
    NSArray *contacts = self.usersService.contactList;
    for (QBContactListItem *item in contacts) {
        
        if (item.userID == userID) {
            return item;
        }
    }
    
    return nil;
}

- (NSArray *)idsWithUsers:(NSArray *)users {

    NSMutableSet *ids = [NSMutableSet set];
    for (QBUUser *user in users) {
        [ids addObject:@(user.ID)];
    }
    return [ids allObjects];
}

- (QBUUser *)userWithID:(NSUInteger)userID {
    return [self.usersService userWithID:userID];
}

- (NSArray *)usersWithIDs:(NSArray *)ids {

    NSMutableArray *allFriends = [NSMutableArray array];
    for (NSNumber * friendID in ids) {
        QBUUser *user = [self userWithID:friendID.integerValue];
        if (user) {
            [allFriends addObject:user];
        }
    }
    
    return allFriends;
}

- (NSArray *)friends {
    
    NSArray *ids = [self.usersService idsFromContactListItems];
    NSArray *allFriends = [self usersWithIDs:ids];
    
    return allFriends;
}

- (NSArray *)contactRequestUsers
{
    NSArray *ids = [self.usersService.confirmRequestUsersIDs allObjects];
    NSArray *users = [self usersWithIDs:ids];
    return users;
}


#pragma mark - Update current User

- (void)changePasswordForCurrentUser:(QBUUser *)currentUser completion:(void(^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    [self.usersService updateUser:currentUser withCompletion:^(QBUUserResult *result) {
        
        if ([weakSelf checkResult:result]) {
            
            weakSelf.currentUser = result.user;
            weakSelf.currentUser.password = currentUser.password;
            [weakSelf.settingsManager setLogin:currentUser.email andPassword:currentUser.password];
        }
        
        completion(result.success);
    }];
}

- (void)updateUser:(QBUUser *)user image:(UIImage *)image progress:(ContentProgressBlock)progress completion:(void (^)(BOOL success))completion {
    
    __block QBUUser *userInfo = user;
    __weak __typeof(self)weakSelf = self;
    
    void (^updateUserProfile)(NSString *) =^(NSString *publicUrl) {

        if (!userInfo) {
            userInfo = weakSelf.currentUser;
        }
        
        if (publicUrl.length > 0) {
            userInfo.website = publicUrl;
        }
        NSString *password = userInfo.password;
        userInfo.password = nil;
        
        [weakSelf.usersService updateUser:userInfo withCompletion:^(QBUUserResult *result) {
            
            if ([weakSelf checkResult:result]) {
                
                weakSelf.currentUser = result.user;
                weakSelf.currentUser.password = password;
            }
            
            completion(result.success);
        }];
    };
    
    if (image) {
        [self.contentService uploadJPEGImage:image progress:progress completion:^(QBCFileUploadTaskResult *result) {
            if ([weakSelf checkResult:result]) {
                updateUserProfile(result.uploadedBlob.publicUrl);
            }
            else {
                updateUserProfile(nil);                
            }
        }];
    }
    else {
        updateUserProfile(nil);
    }
}

- (void)updateUser:(QBUUser *)user imageUrl:(NSURL *)imageUrl progress:(ContentProgressBlock)progress completion:(void (^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    [self.contentService downloadFileWithUrl:imageUrl completion:^(NSData *data) {
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            [weakSelf updateUser:user image:image progress:progress completion:completion];
        }
    }];
}


#pragma mark - Import friends

- (void)importFriendsFromFacebook
{
    __weak __typeof(self)weakSelf = self;
    [FacebookService fetchMyFriendsIDs:^(NSArray *facebookFriendsIDs) {
        
        if ([facebookFriendsIDs count] == 0) {
            return;
        }
        [weakSelf.usersService retrieveUsersWithFacebookIDs:facebookFriendsIDs completion:^(QBUUserPagedResult *pagedResult) {

            if (!pagedResult.success) {
                return;
            }
            if ([pagedResult.users count] == 0) {
                return;
            }
            
            // sending contact requests:
            for (QBUUser *user in pagedResult.users) {
                [weakSelf addUserToContactListRequest:user completion:nil];
            }
        }];
    }];
}

- (void)importFriendsFromAddressBook
{
    __weak __typeof(self)weakSelf = self;
    [QMAddressBook getContactsWithEmailsWithCompletionBlock:^(NSArray *contactsWithEmails) {
        
        if ([contactsWithEmails count] == 0) {
            return;
        }
        NSMutableArray *emails = [NSMutableArray array];
        for (ABPerson *person in contactsWithEmails) {
            [emails addObjectsFromArray:person.emails];
        }
        
        // post request for emails to QB server:
        [weakSelf.usersService retrieveUsersWithEmails:emails completion:^(QBUUserPagedResult *pagedResult) {
            if (!pagedResult.success) {
                return;
            }
            
            if ([pagedResult.users count] == 0) {
                return;
            }
            
            // sending contact requests:
            for (QBUUser *user in pagedResult.users) {
                [weakSelf addUserToContactListRequest:user completion:^(BOOL success) {}];
            }
        }];
    }];
}

@end
