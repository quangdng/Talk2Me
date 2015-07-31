//
//  TMApi+Facebook.m
//  Talk2Me
//
//  Created by Quang Nguyen on 26/08/2014.
//

#import "TMApi.h"
#import "FacebookService.h"

@implementation TMApi (Facebook)

- (void)fbFriends:(void(^)(NSArray *fbFriends))completion {
    [FacebookService connectToFacebook:^(NSString *sessionToken) {
        [FacebookService fetchMyFriends:completion];
    }];
}

- (NSURL *)fbUserImageURLWithUserID:(NSString *)userID {
    return [FacebookService userImageUrlWithUserID:userID];
}

- (void)fbInviteUsersWithIDs:(NSArray *)ids copmpletion:(void(^)(NSError *error))completion {

    NSString *strIds = [ids componentsJoinedByString:@","];
    [FacebookService shareToUsers:strIds completion:completion];
}

- (void)fbLogout {
    [FacebookService logout];
}

- (void)fbIniviteDialogWithCompletion:(void(^)(BOOL success))completion {
    
   [FacebookService inviteFriendsWithCompletion:completion];
}

@end
