//
//  ContentService.h
//  Talk2Me
//
//  Created by Quang Nguyen on 26/08/2014.
//

#import <Foundation/Foundation.h>
#import "ContentOperation.h"

@interface ContentService : NSObject

- (void)uploadJPEGImage:(UIImage *)image progress:(ContentProgressBlock)progress completion:(FileUploadTaskResultBlockBlock)completion;
- (void)uploadPNGImage:(UIImage *)image progress:(ContentProgressBlock)progress completion:(FileUploadTaskResultBlockBlock)completion;

- (void)downloadFileWithUrl:(NSURL *)url completion:(void(^)(NSData *data))completion;
- (void)downloadFileWithBlobID:(NSUInteger )blobID progress:(ContentProgressBlock)progress completion:(FileDownloadTaskResultBlockBlock)completion;

@end
