//
//  TMImagePicker.h
//  Talk2Me
//
//  Created by Quang Nguyen on 20/08/2014.
//

#import <Foundation/Foundation.h>

typedef void(^TMImagePickerResult)(UIImage *image);

@interface TMImagePicker : UIImagePickerController

+ (void)presentIn:(UIViewController *)vc
        configure:(void (^)(UIImagePickerController *picker))configure
           result:(TMImagePickerResult)result;

+ (void)chooseSourceTypeInVC:(id)vc allowsEditing:(BOOL)allowsEditing result:(TMImagePickerResult)result;

@end
