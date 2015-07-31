//
//  REAlertView.h
//  Talk2Me
//
//  Created by Quang Nguyen on 11/08/2014.
//

#import <UIKit/UIKit.h>

@class REAlertView;

typedef void(^REAlertButtonAction)();
typedef void(^REAlertConfiguration)(REAlertView *alertView);

@interface REAlertView : UIAlertView

- (void)dissmis;
- (void)addButtonWithTitle:(NSString *)title andActionBlock:(REAlertButtonAction)block;
+ (void)presentAlertViewWithConfiguration:(REAlertConfiguration)configuration;

@end