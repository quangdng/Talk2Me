//
//  ChatReceiver+UsersHistoryUpdated.m
//  Talk2Me
//
//  Created by Quang Nguyen on 09/09/2014.
//

#import "ChatReceiver.h"

@implementation ChatReceiver (UsersHistoryUpdated)

- (void)postUsersHistoryUpdated {
    
    [self executeBloksWithSelector:_cmd enumerateBloks:^(UsersHistoryUpdated block) {
        block();
    }];
}

- (void)usersHistoryUpdatedWithTarget:(id)target block:(UsersHistoryUpdated)block {
    [self subsribeWithTarget:target selector:@selector(postUsersHistoryUpdated) block:block];
}

- (void)contactRequestUsersListChanged
{
    [self executeBloksWithSelector:_cmd enumerateBloks:^(UsersHistoryUpdated block) {
        block();
    }];
}

- (void)contactRequestUsersListChangedWithTarget:(id)target block:(UsersHistoryUpdated)block {
    [self subsribeWithTarget:target selector:@selector(contactRequestUsersListChanged) block:block];
}


@end
