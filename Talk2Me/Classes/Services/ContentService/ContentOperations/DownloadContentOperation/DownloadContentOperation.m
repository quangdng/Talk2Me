//
//  DownloadContentOperation.m
//  Talk2Me
//
//  Created by Quang Nguyen on 26/08/2014.
//


#import "DownloadContentOperation.h"

@interface DownloadContentOperation()

@property (assign, nonatomic) NSUInteger blobID;

@end

@implementation DownloadContentOperation

- (instancetype)initWithBlobID:(NSUInteger )blobID {
    
    self = [super init];
    if (self) {
        self.blobID = blobID;
    }
    return self;
}

- (void)main {
    self.cancelableOperation = [QBContent TDownloadFileWithBlobID:self.blobID delegate:self];
}

@end
