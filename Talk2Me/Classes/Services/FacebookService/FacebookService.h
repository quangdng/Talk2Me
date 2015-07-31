//
//  FacebookService.h
//  Talk2Me
//
//  Created by Quang Nguyen on 09/09/2014.
//


#import <Foundation/Foundation.h>

@interface FacebookService : NSObject
/**
 */
+ (void)connectToFacebook:(void(^)(NSString *sessionToken))completion;

/**
 */
+ (void)inviteFriendsWithCompletion:(void(^)(BOOL success))completion;

/**
 */
+ (void)fetchMyFriends:(void(^)(NSArray *facebookFriends))completion;

/**
 */
+ (void)fetchMyFriendsIDs:(void(^)(NSArray *facebookFriendsIDs))completion;

/**
 */
+ (NSURL *)userImageUrlWithUserID:(NSString *)userID;

/**
 */
+ (void)shareToUsers:(NSString *)usersIDs completion:(void(^)(NSError *error))completion;

/**
 */
+ (void)loadMe:(void(^)(NSDictionary<FBGraphUser> *user))completion;

/**
 */
+ (void)logout;

@end
