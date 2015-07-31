//
//  UploadContentOperation.h
//  Talk2Me
//
//  Created by Quang Nguyen on 26/08/2014.
//


#import "ContentOperation.h"

@interface UploadContentOperation : ContentOperation

- (instancetype)initWithUploadFile:(NSData *)data fileName:(NSString *)fileName contentType:(NSString *)contentType isPublic:(BOOL)isPublic;

@end
