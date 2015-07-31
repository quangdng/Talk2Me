//
//  TMEchoObject.h
//  TMEchoObject
//
//  Created by Quang Nguyen on 24/08/2014.
//

#import <Foundation/Foundation.h>

@class Result;

typedef void (^TMResultBlock)(Result *);

@interface TMEchoObject : NSObject<QBActionStatusDelegate>

// Singleton instance
+ (TMEchoObject *)instance;

// Helper
+ (void *)makeBlockForEchoObject:(id)originBlock;

@end
