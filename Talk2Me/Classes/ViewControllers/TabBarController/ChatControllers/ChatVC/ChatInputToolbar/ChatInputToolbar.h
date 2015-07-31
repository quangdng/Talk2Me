//
//  ChatInputToolbar.h
//  Talk2Me
//
//  Created by Saranya Nagarajan on 12/09/2014.
//

#import <UIKit/UIKit.h>

@class ChatInputToolbar;
@class ChatToolbarContentView;
/**
 *  A constant the specifies the default height for a `ChatInputToolbar`.
 */
FOUNDATION_EXPORT const CGFloat kChatInputToolbarHeightDefault;
/**
 *  The `ChatInputToolbarDelegate` protocol defines methods for interacting with
 *  a `ChatInputToolbar` object.
 */
@protocol ChatInputToolbarDelegate <UIToolbarDelegate>

@required
/**
 *  Tells the delegate that the toolbar's `rightBarButtonItem` has been pressed.
 *
 *  @param toolbar The object representing the toolbar sending this information.
 *  @param sender  The button that received the touch event.
 */
- (void)chatInputToolbar:(ChatInputToolbar *)toolbar didPressRightBarButton:(UIButton *)sender;
/**
 *  Tells the delegate that the toolbar's `leftBarButtonItem` has been pressed.
 *
 *  @param toolbar The object representing the toolbar sending this information.
 *  @param sender  The button that received the touch event.
 */
- (void)chatInputToolbar:(ChatInputToolbar *)toolbar didPressLeftBarButton:(UIButton *)sender;

@end

@interface ChatInputToolbar : UIToolbar
/**
 *  The object that acts as the delegate of the toolbar.
 */
@property (weak, nonatomic) id<ChatInputToolbarDelegate> delegate;
/**
 *  Returns the content view of the toolbar. This view contains all subviews of the toolbar.
 */
@property (weak, nonatomic, readonly) ChatToolbarContentView *contentView;
/**
 *  A boolean value indicating whether the send button is on the right side of the toolbar or not.
 *
 *  @discussion The default value is `YES`, which indicates that the send button is the right-most subview of
 *  the toolbar's `contentView`. Set to `NO` to specify that the send button is on the left. This
 *  property is used to determine which touch events correspond to which actions.
 *
 *  @warning Note, this property *does not* change the positions of buttons in the toolbar's content view.
 *  It only specifies whether the `rightBarButtonItem `or the `leftBarButtonItem` is the send button.
 *  The other button then acts as the accessory button.
 */
@property (assign, nonatomic) BOOL sendButtonOnRight;
/**
 *  Enables or disables the send button based on whether or not its `textView` has text.
 *  That is, the send button will be enabled if there is text in the `textView`, and disabled otherwise.
 */
- (void)toggleSendButtonEnabled;

@end
