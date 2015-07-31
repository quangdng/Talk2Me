//
//  UIImage+Cropper.h
//  ChattAR
//
//  Created by Quang Nguyen on 20/08/2014.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Cropper)

- (UIImage *)imageByScaleAndCrop:(CGSize)targetSize;
- (UIImage *)imageByCircularScaleAndCrop:(CGSize)targetSize;

@end
