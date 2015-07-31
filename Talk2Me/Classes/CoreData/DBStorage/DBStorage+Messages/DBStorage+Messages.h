//
//  DBStorage.h+Messages.h
//  Talk2Me
//
//  Created by Quang Nguyen on 12/09/2014.
//

#import "DBStorage.h"

@interface DBStorage (Messages)

- (void)cacheQBChatMessages:(NSArray *)messages withDialogId:(NSString *)dialogId finish:(DBFinishBlock)finish;
- (void)cachedQBChatMessagesWithDialogId:(NSString *)dialogId qbMessages:(DBCollectionBlock)qbMessages;

@end
