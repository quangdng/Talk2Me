//
//  ChatInputTextView.h
//  Talk2Me
//
//  Created by Saranya Nagarajan on 12/09/2014.
//

#import <UIKit/UIKit.h>

@interface PlaceholderTextView : UITextView
/**
 *  The text to be displayed when the text view is empty. The default value is `nil`.
 */
@property (copy, nonatomic) NSString *placeHolder;
/**
 *  The color of the place holder text. The default value is `[UIColor lightGrayColor]`.
 */
@property (strong, nonatomic) UIColor *placeHolderTextColor;

@end
