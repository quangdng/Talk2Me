//
//  CustomSegue.m
//  Talk2Me
//
//  Created by Quang Nguyen on 20/08/2014.

#import "CustomSegue.h"
#import "AppDelegate.h"

@implementation CustomSegue

- (void)perform {
    
    AppDelegate *delegate =  (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIWindow *window = delegate.window;
    window.rootViewController = self.destinationViewController;
}

@end
