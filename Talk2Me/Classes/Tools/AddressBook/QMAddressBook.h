//
//  QMAddressBook.h
//  Talk2Me
//
//  Created by Quang Nguyen on 20/08/2014.
//

#import <Foundation/Foundation.h>

typedef void(^AddressBookResult)(NSArray *contacts, BOOL success, NSError *error);

@interface QMAddressBook : NSObject

+ (void)getAllContactsFromAddressBook:(AddressBookResult)block;
+ (void)getContactsWithEmailsWithCompletionBlock:(void(^)(NSArray *contactsWithEmails))block;

@end
