//
//  PopoversFactory.h
//  Talk2Me
//
//  Created by Quang Nguyen on 20/08/2014.
//

#import <Foundation/Foundation.h>
@class ChatViewController;

@interface PopoversFactory : NSObject

+ (ChatViewController *)chatControllerWithDialogID:(NSString *)dialogID;

@end
