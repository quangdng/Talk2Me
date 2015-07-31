//
//  ChatVC.h
//  Talk2Me
//
//  Created by Quang Nguyen on 13/09/2014.
//

#import <UIKit/UIKit.h>
#import <SpeechKit/SpeechKit.h>


@class ChatDataSource;
@class ChatInputToolbar;

@interface ChatVC : UIViewController <SpeechKitDelegate, SKRecognizerDelegate> {
    enum {
        TS_IDLE,
        TS_INITIAL,
        TS_RECORDING,
        TS_PROCESSING,
    } transactionState;
}

@property (strong, nonatomic, readonly) UITableView *tableView;
@property(strong, nonatomic)         SKRecognizer* voiceSearch;

@property (strong, nonatomic) ChatDataSource *dataSource;
/**
 *  Returns the input toolbar view object managed by this view controller.
 *  This view controller is the toolbar's delegate.
 */
@property (strong, nonatomic, readonly) ChatInputToolbar *inputToolBar;
/**
 *  Scrolls the collection view such that the bottom most cell is completely visible, above the `inputView`.
 *
 *  @param animated Pass `YES` if you want to animate scrolling, `NO` if it should be immediate.
 */

@property (strong, nonatomic) QBChatDialog *dialog;

@end
