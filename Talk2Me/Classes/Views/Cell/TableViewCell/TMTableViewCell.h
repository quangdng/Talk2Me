//
//  TMTableViewCell.h
//  Talk2Me
//
//  Created by Quang Nguyen on 02/10/2014.
//

#import <UIKit/UIKit.h>
@class ImageView;

@interface TMTableViewCell : UITableViewCell 

@property (strong, nonatomic) id userData;
@property (strong, nonatomic) QBContactListItem *contactlistItem;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet ImageView *ImageView;

- (void)setUserImageWithUrl:(NSURL *)userImageUrl;
- (void)setUserImage:(UIImage *)image withKey:(NSString *)key;

@end
