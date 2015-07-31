//
//  PopoversFactory.m
//  Talk2Me
//
//  Created by Quang Nguyen on 20/08/2014.
//

#import "PopoversFactory.h"
#import "ChatViewController.h"
#import "TMApi.h"

@implementation PopoversFactory


+ (ChatViewController *)chatControllerWithDialogID:(NSString *)dialogID
{
    QBChatDialog *dialog = [[TMApi instance] chatDialogWithID:dialogID];
    
    ChatViewController *chatVC = (ChatViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ChatViewController"];
    chatVC.dialog = dialog;
    return chatVC;
}

@end
