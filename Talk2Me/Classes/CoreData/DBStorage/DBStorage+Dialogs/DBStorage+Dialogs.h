//
//  DBStorage.h+Dialogs.h
//  Talk2Me
//
//  Created by Quang Nguyen on 12/09/2014.
//

#import "DBStorage.h"

@interface DBStorage (Dialogs)

- (void)cachedQBChatDialogs:(DBCollectionBlock)qbDialogs;
- (void)cacheQBDialogs:(NSArray *)dialogs finish:(DBFinishBlock)finish;

@end
