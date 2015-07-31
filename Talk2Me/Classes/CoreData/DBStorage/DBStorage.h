//
//  DBStorage.h
//  Talk2Me
//
//  Created by Quang Nguyen on 12/09/2014.
//

#import <Foundation/Foundation.h>

#define CONTAINS(attrName, attrVal) [NSPredicate predicateWithFormat:@"self.%K CONTAINS %@", attrName, attrVal]
#define LIKE(attrName, attrVal) [NSPredicate predicateWithFormat:@"%K like %@", attrName, attrVal]
#define LIKE_C(attrName, attrVal) [NSPredicate predicateWithFormat:@"%K like[c] %@", attrName, attrVal]
#define IS(attrName, attrVal) [NSPredicate predicateWithFormat:@"%K == %@", attrName, attrVal]

#define START_LOG_TIME double startTime = CFAbsoluteTimeGetCurrent();
#define END_LOG_TIME NSLog(@"%s %f", __PRETTY_FUNCTION__, CFAbsoluteTimeGetCurrent()-startTime);

#define DO_AT_MAIN(x) dispatch_async(dispatch_get_main_queue(), ^{ x; });

typedef void(^DBCollectionBlock)(NSArray *collection);
typedef void(^DBContextBlock)(NSManagedObjectContext *context);
typedef void(^DBFinishBlock)(void);

@interface DBStorage : NSObject	

/**
 * @brief Load CoreData(Sqlite) file
 * @param name - filename
 */

+ (void)setupWithName:(NSString *)name;

/**
 * @brief Clean data base with store name
 */

+ (void)cleanDBWithName:(NSString *)name;

/**
 * @brief Perform operation in CoreData thread
 */

- (void)async:(DBContextBlock)block;
- (void)sync:(DBContextBlock)block;

/**
 * @brief Save to persistent store (async)
 */

- (void)save:(DBFinishBlock)completion;

@end

@interface NSObject (DBStorage)

@property (strong, nonatomic, readonly) DBStorage *dbStorage;

@end