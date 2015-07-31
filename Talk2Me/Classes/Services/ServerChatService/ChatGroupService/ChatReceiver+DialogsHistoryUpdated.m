//
//  ChatReceiver+DialogsHistoryUpdated.m
//  Talk2Me
//
//  Created by Quang Nguyen on 05/09/2014.
//

#import "ChatReceiver.h"

@implementation ChatReceiver (DialogsHistoryUpdated)

- (void)postDialogsHistoryUpdated {
    
    [self executeBloksWithSelector:_cmd enumerateBloks:^(DialogsHistoryUpdated block) {
        block();
    }];
    
}

- (void)dialogsHisotryUpdatedWithTarget:(id)target block:(DialogsHistoryUpdated)block {
    [self subsribeWithTarget:target selector:@selector(postDialogsHistoryUpdated) block:block];
}

@end
