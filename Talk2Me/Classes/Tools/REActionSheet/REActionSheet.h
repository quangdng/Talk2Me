//
//  REActionSheet.h
//  Talk2Me
//
//  Created by Quang Nguyen on 20/08/2014.
//

#import <UIKit/UIKit.h>

@class REActionSheet;

typedef void(^REActionSheetButtonAction)();
typedef void(^REActionSheetBlock)(REActionSheet *actionSheet);

@interface REActionSheet : UIActionSheet

+ (void)presentActionSheetInView:(UIView *)view configuration:(REActionSheetBlock)configuration;
- (void)addButtonWithTitle:(NSString *)title andActionBlock:(REActionSheetButtonAction)block;
- (void)addDestructiveButtonWithTitle:(NSString *)title andActionBlock:(REActionSheetButtonAction)block;
- (void)addCancelButtonWihtTitle:(NSString *)title andActionBlock:(REActionSheetButtonAction)block;

@end