//
//  ProgressView.h
//  Talk2Me
//
//  Created by Quang Nguyen on 13/10/2014.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, QMProgressType) {
    QMProgressTypeNone,
    QMProgressTypeVertical,
    QMProgressTypeHorizontal
};

@interface ProgressView : UIView <UIAppearance>

@property (assign, nonatomic) QMProgressType progressType;
@property (assign, nonatomic, getter = currentProgress) CGFloat progress;

@property (strong, nonatomic) UIColor *trackTintColor UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor *progressTintColor UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) CALayer *mask;

- (id)initWithFrame:(CGRect)frame gravity:(BOOL)gravity;

// Gravity Motion
- (BOOL)isGravityActive;
- (void)startGravity;
- (void)stopGravity;

@end
