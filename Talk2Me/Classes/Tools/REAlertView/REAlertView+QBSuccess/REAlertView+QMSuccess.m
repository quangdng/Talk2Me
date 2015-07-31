//
//  REAlertView+QMSuccess.m
//  Talk2Me
//
//  Created by Quang Nguyen on 11/08/2014.
//

#import "REAlertView+QMSuccess.h"

@implementation REAlertView (QMSuccess)

+ (void)showAlertWithMessage:(NSString *)messageString actionSuccess:(BOOL)success {
    
    [REAlertView presentAlertViewWithConfiguration:^(REAlertView *alertView) {
        alertView.title = success ? NSLocalizedString(@"STR_SUCCESS", nil) : NSLocalizedString(@"STR_ERROR", nil);
        alertView.message = messageString;
        [alertView addButtonWithTitle:NSLocalizedString(@"STR_OK", nil) andActionBlock:^{}];
    }];
}

@end
