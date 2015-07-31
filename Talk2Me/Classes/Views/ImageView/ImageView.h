//
//  ImageView.h
//  Talk2Me
//
//  Created by Tian Long on 13/10/2014.
//

#import <UIKit/UIKit.h>
#import "SDWebImageManager.h"

typedef NS_ENUM(NSUInteger, ImageViewType) {
    ImageViewTypeNone,
    ImageViewTypeCircle,
    ImageViewTypeSquare
};

@interface ImageView : UIImageView
/**
 Default UserImageViewType UserImageViewTypeNone
 */
@property (assign, nonatomic) ImageViewType imageViewType;

- (void)sd_setImage:(UIImage *)image withKey:(NSString *)key;
- (void)setImageWithURL:(NSURL *)url
            placeholder:(UIImage *)placehoder
                options:(SDWebImageOptions)options
               progress:(SDWebImageDownloaderProgressBlock)progress
         completedBlock:(SDWebImageCompletionBlock)completedBlock;
@end
