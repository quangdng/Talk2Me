//
//  ChatDataSource.h
//  Talk2Me
//
//  Created by Quang Nguyen on 12/09/2014.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "FGTranslator.h"
#import <SpeechKit/SpeechKit.h>

@class ChatDataSource;

@protocol ChatDataSourceDelegate <NSObject>

- (void)chatDatasource:(ChatDataSource *)chatDatasource prepareImageURLAttachement:(NSURL *)imageUrl;
- (void)chatDatasource:(ChatDataSource *)chatDatasource prepareImageAttachement:(UIImage *)image fromView:(UIView *)fromView;

@end

@interface ChatDataSource : NSObject <SKVocalizerDelegate> {
    BOOL isSpeaking;
    SKVocalizer* vocalizer;
}

@property (strong, nonatomic) QBChatDialog *chatDialog;
@property (strong, nonatomic, readonly) NSMutableArray *chatSections;

@property (weak, nonatomic) id <ChatDataSourceDelegate> delegate;

- (id)init __attribute__((unavailable("init is not a supported initializer for this class.")));

- (instancetype)initWithChatDialog:(QBChatDialog *)dialog forTableView:(UITableView *)tableView;
- (void)scrollToBottomAnimated:(BOOL)animated;
- (void)sendImage:(UIImage *)image;
- (void)sendMessage:(NSString *)text;

@end
