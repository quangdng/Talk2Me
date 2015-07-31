//
//  UsersUtils.m
//  Talk2Me
//
//  Created by Quang Nguyen on 20/08/2014.
//

#import "UsersUtils.h"

@implementation UsersUtils

+ (NSArray *)sortUsersByFullname:(NSArray *)users
{    
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc]
                                initWithKey:@"fullName"
                                ascending:YES
                                selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortedUsers = [users sortedArrayUsingDescriptors:@[sorter]];
    
    return sortedUsers;
}

@end
