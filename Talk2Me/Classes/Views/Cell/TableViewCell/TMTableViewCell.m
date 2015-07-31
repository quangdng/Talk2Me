//
//  TMTableViewCell.m
//  Talk2Me
//
//  Created by Quang Nguyen on 02/10/2014.
//

#import "TMTableViewCell.h"
#import "ImageView.h"

@interface TMTableViewCell()

@end

@implementation TMTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.ImageView.imageViewType = ImageViewTypeCircle;
}

- (void)setUserImageWithUrl:(NSURL *)userImageUrl {
    
    UIImage *placeholder = [UIImage imageNamed:@"upic-placeholder"];
    
    [self.ImageView setImageWithURL:userImageUrl
                          placeholder:placeholder
                              options:SDWebImageHighPriority
                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {}
                       completedBlock:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {}];
}

- (void)setUserImage:(UIImage *)image withKey:(NSString *)key {
    
    if (!image) {
        image = [UIImage imageNamed:@"upic-placeholder"];
    }
    
    [self.ImageView sd_setImage:image withKey:key];
}

@end
