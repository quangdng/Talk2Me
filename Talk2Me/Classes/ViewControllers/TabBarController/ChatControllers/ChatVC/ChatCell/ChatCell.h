//
//  ChatCell.h
//  Talk2Me
//
//  Created by Yepeng Fan on 12/09/2014.
//

#import <UIKit/UIKit.h>
#import "ChatMessage.h"

@class ChatMessage;
@class ImageView;

@protocol ChatCellDelegate <NSObject>

- (void)chatCell:(id)cell didSelectMessage:(ChatMessage *)message;

@end

@interface ChatCell : UITableViewCell

@property (strong, nonatomic, readonly) UIView *containerView;
@property (strong, nonatomic, readonly) UIView *headerView;
@property (strong, nonatomic, readonly) ImageView *balloonImageView;
@property (strong, nonatomic, readonly) ImageView *userImageView;
@property (strong, nonatomic, readonly) UILabel *title;
@property (strong, nonatomic, readonly) UIImageView *deliveryStatusView;
@property (strong, nonatomic, readonly) UILabel *timeLabel;

@property (weak, nonatomic) id <ChatCellDelegate> delegate;

- (void)setMessage:(ChatMessage *)message user:(QBUUser *)user isMe:(BOOL)isMe;
- (void)setBalloonImage:(UIImage *)balloonImage;
- (void)setDeliveryStatus:(NSUInteger)deliveryStatus;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)createContainerSubviews;
- (NSDateFormatter *)formatter;

@end