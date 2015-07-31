//
//  ContentOperation.m
//  Talk2Me
//
//  Created by Quang Nguyen on 26/08/2014.
//

#import "ContentOperation.h"
#import "TMEchoObject.h"

@interface ContentOperation()

@property (strong, nonatomic) dispatch_semaphore_t sem;

@end

@implementation ContentOperation

- (void)setProgress:(float)progress {
    
    if(self.progressHandler)
        self.progressHandler(progress);
}

- (void)completedWithResult:(Result *)result {
    
    if (self.completionHandler) {
        
        TaskResultBlock block = (TaskResultBlock)self.completionHandler;
        block(result);
    }
    
    dispatch_semaphore_signal(self.sem);
}

- (void)setCancelableOperation:(NSObject<Cancelable> *)cancelableOperation {
    
    _cancelableOperation = cancelableOperation;
    
    self.sem = dispatch_semaphore_create(0);
    dispatch_semaphore_wait(self.sem, DISPATCH_TIME_FOREVER);
}

- (void)cancel {
    
    [self.cancelableOperation cancel];
}

@end
