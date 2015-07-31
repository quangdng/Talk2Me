//
//  DBStorage.h+Users.h
//  Talk2Me
//
//  Created by Quang Nguyen on 12/09/2014.
//

#import "DBStorage.h"

@interface DBStorage (Users)

- (void)cacheUsers:(NSArray *)users finish:(DBFinishBlock)finish;
- (void)cachedQbUsers:(DBCollectionBlock)qbUsers;

@end
