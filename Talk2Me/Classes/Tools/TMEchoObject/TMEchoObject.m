//
//  TMEchoObject.m
//  TMEchoObject
//
//  Created by Quang Nguyen on 22/08/2014.
//

#import "TMEchoObject.h"
#import <Quickblox/Quickblox.h>

@implementation TMEchoObject

static TMEchoObject *instance = nil;

+ (TMEchoObject *)instance
{
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        instance = [self new];
    });
	
    return instance;
}

+ (void *)makeBlockForEchoObject:(id)originBlock
{
    return Block_copy((__bridge void*)originBlock);
}

- (void)completedWithResult:(Result *)result context:(void *)contextInfo
{
    ((__bridge void (^)(Result * result))(contextInfo))(result);
    Block_release(contextInfo);
}

- (void)completedWithResult:(Result *)result
{
	
}

@end
