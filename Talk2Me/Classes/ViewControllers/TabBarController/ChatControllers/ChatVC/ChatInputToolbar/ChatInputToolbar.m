//
//  ChatInputToolbar.m
//  Talk2Me
//
//  Created by Saranya Nagarajan on 12/09/2014.
//

#import "ChatInputToolbar.h"
#import "ChatToolbarContentView.h"
#import "ChatButtonsFactory.h"
#import "PlaceholderTextView.h"
#import "Parus.h"

const CGFloat kChatInputToolbarHeightDefault = 44.0f;

static void * kInputToolbarKeyValueObservingContext = &kInputToolbarKeyValueObservingContext;

@interface ChatInputToolbar()

@end

@implementation ChatInputToolbar

- (void)dealloc {
    [self removeObservers];
    _contentView = nil;
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self configureChatToolbarContentView];
        
    }
    
    return self;
}

- (void)configureChatToolbarContentView {
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    ChatToolbarContentView *contentView = [[ChatToolbarContentView alloc] init];
    [self addSubview:contentView];
    
    [self addConstraints:PVGroup(@[
                                   PVTopOf(contentView).equalTo.topOf(self).asConstraint,
                                   PVLeftOf(contentView).equalTo.leftOf(self).asConstraint,
                                   PVBottomOf(contentView).equalTo.bottomOf(self).asConstraint,
                                   PVRightOf(contentView).equalTo.rightOf(self).asConstraint,
                                   ]).asArray];
    
    [self updateConstraintsIfNeeded];
    
    _contentView = contentView;
    
     [self addObservers];
    
    [self toggleSendButtonEnabled];
}

#pragma mark - Actions

- (void)layoutSubviews {
    [super layoutSubviews];
    
}

- (void)leftBarButtonPressed:(UIButton *)sender {
    
    [self.delegate chatInputToolbar:self didPressLeftBarButton:sender];
}

- (void)rightBarButtonPressed:(UIButton *)sender {
    
    [self.delegate chatInputToolbar:self didPressRightBarButton:sender];
}

#pragma mark - Input toolbar

- (void)toggleSendButtonEnabled {
    
    BOOL hasText = [self.contentView.textView hasText];
    
    if (self.sendButtonOnRight) {
        self.contentView.rightBarButtonItem.enabled = hasText;
    }
    else {
        self.contentView.leftBarButtonItem.enabled = hasText;
    }
}

#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kInputToolbarKeyValueObservingContext) {
        if (object == self.contentView) {
            
            if ([keyPath isEqualToString:NSStringFromSelector(@selector(leftBarButtonItem))]) {
                
                [self.contentView.leftBarButtonItem removeTarget:self
                                                          action:NULL
                                                forControlEvents:UIControlEventTouchUpInside];
                
                [self.contentView.leftBarButtonItem addTarget:self
                                                       action:@selector(leftBarButtonPressed:)
                                             forControlEvents:UIControlEventTouchUpInside];
            }
            else if ([keyPath isEqualToString:NSStringFromSelector(@selector(rightBarButtonItem))]) {
                
                [self.contentView.rightBarButtonItem removeTarget:self
                                                           action:NULL
                                                 forControlEvents:UIControlEventTouchUpInside];
                
                [self.contentView.rightBarButtonItem addTarget:self
                                                        action:@selector(rightBarButtonPressed:)
                                              forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
}

- (void)addObservers {
    
    [self.contentView addObserver:self
                       forKeyPath:NSStringFromSelector(@selector(leftBarButtonItem))
                          options:0
                          context:kInputToolbarKeyValueObservingContext];
    
    [self.contentView addObserver:self
                       forKeyPath:NSStringFromSelector(@selector(rightBarButtonItem))
                          options:0
                          context:kInputToolbarKeyValueObservingContext];
}

- (void)removeObservers {
    
    @try {
        [self.contentView removeObserver:self
                              forKeyPath:NSStringFromSelector(@selector(leftBarButtonItem))
                                 context:kInputToolbarKeyValueObservingContext];
        
        [self.contentView removeObserver:self
                              forKeyPath:NSStringFromSelector(@selector(rightBarButtonItem))
                                 context:kInputToolbarKeyValueObservingContext];
        
    } @catch (NSException *__unused exception) {
        ILog(@"%@", exception);
    }
}

@end
