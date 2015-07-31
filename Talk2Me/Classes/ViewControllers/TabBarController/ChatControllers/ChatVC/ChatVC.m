//
//  ChatVC.m
//  Talk2Me
//
//  Created by Quang Nguyen on 13/09/2014.
//

#import "ChatVC.h"
#import "ChatInputToolbar.h"
#import "ChatMessage.h"
#import "ChatDataSource.h"
#import "KeyboardController.h"
#import "ChatToolbarContentView.h"
#import "PlaceholderTextView.h"
#import "ChatButtonsFactory.h"
#import "SoundManager.h"
#import "NSString+HasText.h"
#import "TMApi.h"
#import "Parus.h"
#import "Helpers.h"
#import "TMImagePicker.h"
#import "REActionSheet.h"
#import "ChatSection.h"
#import "SVProgressHUD.h"
#import "FUIAlertView.h"
#import "UIColor+FlatUI.h"
#import "UIFont+FlatUI.h"

static void * kKeyValueObservingContext = &kKeyValueObservingContext;

@interface ChatVC () 

<UITableViewDelegate, KeyboardControllerDelegate, ChatInputToolbarDelegate, UITextViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) ChatInputToolbar *inputToolBar;
@property (strong, nonatomic) KeyboardController *keyboardController;

@property (weak, nonatomic) NSLayoutConstraint *toolbarHeightConstraint;
@property (weak, nonatomic) NSLayoutConstraint *toolbarBottomLayoutGuide;

@property (assign, nonatomic) CGFloat statusBarChangeInHeight;

@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIButton *dictationBtn;

@property (assign, nonatomic) BOOL showCameraButton;

@end

@implementation ChatVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configureChatVC];
    [self registerForNotifications:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.keyboardController = [[KeyboardController alloc] initWithTextView:self.inputToolBar.contentView.textView
                                                                 contextView:self.navigationController.view
                                                        panGestureRecognizer:self.tableView.panGestureRecognizer
                                                                    delegate:self];
    _showCameraButton = YES;
    
    // Remove notification badge when enter chat view
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    // Set earcons to play
    SKEarcon* earconStart	= [SKEarcon earconWithName:@"earcon_listening.wav"];
    SKEarcon* earconStop	= [SKEarcon earconWithName:@"earcon_done_listening.wav"];
    SKEarcon* earconCancel	= [SKEarcon earconWithName:@"earcon_cancel.wav"];
    
    [SpeechKit setEarcon:earconStart forType:SKStartRecordingEarconType];
    [SpeechKit setEarcon:earconStop forType:SKStopRecordingEarconType];
    [SpeechKit setEarcon:earconCancel forType:SKCancelRecordingEarconType];

    

    
    
}

- (NSString *) localeReturn: (NSString *) language {
    NSString *locale = @"";
    
    if ([language isEqual:@"Vietnamese"]) {
        locale = @"vi_VN";
    }
    else if ([language isEqual:@"German"]) {
        locale = @"de_DE";
    }
    else if ([language isEqual:@"Mandarin Chinese"]) {
        locale = @"cn_MA";
    }
    else if ([language isEqual:@"Japanese"]) {
        locale = @"ja_JP";
    }
    else if ([language isEqual:@"Spanish"]) {
        locale = @"es_ES";
    }
    else {
        locale = @"en_AU";
    }
    
    NSLog(@"Current language %@:", locale);
    
    return locale;
}

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
    [self registerForNotifications:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self addObservers];
    [self addActionToInteractivePopGestureRecognizer:YES];
    [self.keyboardController beginListeningForKeyboard];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [self addActionToInteractivePopGestureRecognizer:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    [self removeObservers];
    [self.keyboardController endListeningForKeyboard];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self updateKeyboardTriggerPoint];
}

- (void)updateKeyboardTriggerPoint {
    
    self.keyboardController.keyboardTriggerPoint = CGPointMake(0.0f, CGRectGetHeight(self.inputToolBar.bounds));
}

#pragma mark - Configure ChatVC

- (void)configureInputView {
    
    self.cameraButton = [ChatButtonsFactory cameraButton];
    self.sendButton = [ChatButtonsFactory sendButton];
    self.dictationBtn = [ChatButtonsFactory dictationBtn];
    
    self.inputToolBar.contentView.leftBarButtonItem = self.dictationBtn;
    self.inputToolBar.contentView.rightBarButtonItem = self.cameraButton;
    
    self.inputToolBar.contentView.rightBarButtonItemWidth = 26;
    self.inputToolBar.contentView.leftBarButtonItemWidth = 26;
}

- (void)configureChatVC {
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.inputToolBar = [[ChatInputToolbar alloc] init];
    
    [self configureInputView];
    
    self.inputToolBar.delegate = self;
    self.inputToolBar.contentView.textView.delegate =self;
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.inputToolBar];
    
    [self configureChatContstraints];
}

- (void)configureChatContstraints {
    
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.toolbarHeightConstraint = PVHeightOf(self.inputToolBar).equalTo.constant(kChatInputToolbarHeightDefault).asConstraint;
    self.toolbarBottomLayoutGuide = PVBottomOf(self.inputToolBar).equalTo.bottomOf(self.view).asConstraint;
    
    [self.view addConstraints:PVGroup(@[
                                        PVTopOf(self.view).equalTo.topOf(self.tableView),
                                        PVLeadingOf(self.view).equalTo.leadingOf(self.tableView),
                                        PVTrailingOf(self.view).equalTo.trailingOf(self.tableView),
                                        PVTrailingOf(self.view).equalTo.trailingOf(self.inputToolBar),
                                        PVLeadingOf(self.view).equalTo.leadingOf(self.inputToolBar),
                                        self.toolbarBottomLayoutGuide,
                                        self.toolbarHeightConstraint,
                                        PVTopOf(self.inputToolBar).equalTo.bottomOf(self.tableView),
                                        ]).asArray];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ChatSection *chatSection = self.dataSource.chatSections[indexPath.section];
    ChatMessage *message = chatSection.messages[indexPath.row];
    return message.messageSize.height;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    ChatSection *chatSection = self.dataSource.chatSections[section];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, tableView.frame.size.width, 15)];
    [label setFont:[UIFont boldSystemFontOfSize:13]];
    [label setTextColor:[UIColor grayColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setText:chatSection.name];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:0.95]]; //your background color...
    return view;
}

#pragma mark - KeyboardControllerDelegate

- (void)keyboardDidChangeFrame:(CGRect)keyboardFrame {
    
    CGFloat heightFromBottom = keyboardFrame.origin.y - CGRectGetMaxY(self.view.frame);
    [self setToolbarBottomLayoutGuideConstant:heightFromBottom];
}

- (void)setToolbarBottomLayoutGuideConstant:(CGFloat)constant {
    
    self.toolbarBottomLayoutGuide.constant = constant;
    [self.view setNeedsUpdateConstraints];
    [self.view layoutIfNeeded];
}

- (void)removeObservers {
    
    @try {
        [self.inputToolBar.contentView.textView removeObserver:self
                                                    forKeyPath:NSStringFromSelector(@selector(contentSize))
                                                       context:kKeyValueObservingContext];
    }
    @catch (NSException * __unused exception) { }
}

- (void)addObservers {
    
    [self.inputToolBar.contentView.textView addObserver:self
                                             forKeyPath:NSStringFromSelector(@selector(contentSize))
                                                options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                                                context:kKeyValueObservingContext];
}

- (void)registerForNotifications:(BOOL)registerForNotifications {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    if (registerForNotifications) {
        [notificationCenter addObserver:self
                               selector:@selector(handleDidChangeStatusBarFrameNotification:)
                                   name:UIApplicationDidChangeStatusBarFrameNotification
                                 object:nil];
    }
    else {
        [notificationCenter removeObserver:self
                                      name:UIApplicationDidChangeStatusBarFrameNotification
                                    object:nil];
    }
}

- (void)addActionToInteractivePopGestureRecognizer:(BOOL)addAction {
    
    if (self.navigationController.interactivePopGestureRecognizer) {
        [self.navigationController.interactivePopGestureRecognizer removeTarget:nil
                                                                         action:@selector(handleInteractivePopGestureRecognizer:)];
        
        if (addAction) {
            [self.navigationController.interactivePopGestureRecognizer addTarget:self
                                                                          action:@selector(handleInteractivePopGestureRecognizer:)];
        }
    }
}

- (void)handleDidChangeStatusBarFrameNotification:(NSNotification *)notification {
    
    CGRect previousStatusBarFrame = [[[notification userInfo] objectForKey:UIApplicationStatusBarFrameUserInfoKey] CGRectValue];
    CGRect currentStatusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    CGFloat statusBarHeightDelta = CGRectGetHeight(currentStatusBarFrame) - CGRectGetHeight(previousStatusBarFrame);
    self.statusBarChangeInHeight = MAX(statusBarHeightDelta, 0.0f);
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        self.statusBarChangeInHeight = 0.0f;
    }
}

#pragma mark - Gesture recognizers

- (void)handleInteractivePopGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self.keyboardController endListeningForKeyboard];
            [self.inputToolBar.contentView.textView resignFirstResponder];
            [UIView animateWithDuration:0.0
                             animations:^{
                                 [self setToolbarBottomLayoutGuideConstant:0.0f];
                             }];
        }
            break;
        case UIGestureRecognizerStateChanged:
            //  TODO: handle this animation better
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
            [self.keyboardController beginListeningForKeyboard];
            break;
        default:
            break;
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    [textView becomeFirstResponder];
    
    [self.dataSource scrollToBottomAnimated:NO];
}

- (void)setShowCameraButton:(BOOL)showCameraButton {
    
    if (_showCameraButton != showCameraButton) {
        _showCameraButton = showCameraButton;
        if (_showCameraButton) {
            self.inputToolBar.contentView.rightBarButtonItem = self.cameraButton;
            self.inputToolBar.contentView.rightBarButtonItemWidth = 26.0f;
        }else {
            self.inputToolBar.contentView.rightBarButtonItem = self.sendButton;
            self.inputToolBar.contentView.rightBarButtonItemWidth = 44.0f;
        }
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    
    self.showCameraButton = textView.text.length == 0;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    [textView resignFirstResponder];
}

#pragma mark - Key-value observing for content size

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (context == kKeyValueObservingContext) {
        
        if (object == self.inputToolBar.contentView.textView && [keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))]) {
            
            CGSize oldContentSize = [[change objectForKey:NSKeyValueChangeOldKey] CGSizeValue];
            CGSize newContentSize = [[change objectForKey:NSKeyValueChangeNewKey] CGSizeValue];
            
            CGFloat dy = newContentSize.height - oldContentSize.height;
            
            [self adjustInputToolbarForComposerTextViewContentSizeChange:dy];
            [self.dataSource scrollToBottomAnimated:NO];
        }
    }
}

- (void)adjustInputToolbarForComposerTextViewContentSizeChange:(CGFloat)dy {
    
    BOOL contentSizeIsIncreasing = (dy > 0);
    
    UITextView *textView = self.inputToolBar.contentView.textView;
    int numLines = textView.contentSize.height / textView.font.leading;
    
    if ([self inputToolbarHasReachedMaximumHeight] || numLines >= 4) {
        
        BOOL contentOffsetIsPositive = (self.inputToolBar.contentView.textView.contentOffset.y > 0);
        if (contentSizeIsIncreasing || contentOffsetIsPositive) {
            [self scrollComposerTextViewToBottomAnimated:YES];
            return;
        }
    }
    
    CGFloat toolbarOriginY = CGRectGetMinY(self.inputToolBar.frame);
    CGFloat newToolbarOriginY = toolbarOriginY - dy;
    
    if (newToolbarOriginY <= self.topLayoutGuide.length) {
        dy = toolbarOriginY - self.topLayoutGuide.length;
        [self scrollComposerTextViewToBottomAnimated:YES];
    }
    
    [self adjustInputToolbarHeightConstraintByDelta:dy];
    [self updateKeyboardTriggerPoint];
    if (dy < 0) {
        [self scrollComposerTextViewToBottomAnimated:NO];
    }
}

- (void)adjustInputToolbarHeightConstraintByDelta:(CGFloat)dy {
    
    float h = self.toolbarHeightConstraint.constant + dy;
    
    if (h < kChatInputToolbarHeightDefault) {
        self.toolbarHeightConstraint.constant = kChatInputToolbarHeightDefault;
    }else {
        self.toolbarHeightConstraint.constant = h;
    }
    
    [self.view setNeedsUpdateConstraints];
    [self.view layoutIfNeeded];
}

- (void)scrollComposerTextViewToBottomAnimated:(BOOL)animated {
    
    UITextView *textView = self.inputToolBar.contentView.textView;
    CGPoint contentOffsetToShowLastLine = CGPointMake(0.0f, textView.contentSize.height - CGRectGetHeight(textView.bounds));
    
    if (!animated) {
        textView.contentOffset = contentOffsetToShowLastLine;
        return;
    }
    
    [UIView animateWithDuration:0.01
                          delay:0.01
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         textView.contentOffset = contentOffsetToShowLastLine;
                     }
                     completion:nil];
}

- (BOOL)inputToolbarHasReachedMaximumHeight {
    
    return FloatAlmostEqual(CGRectGetMinY(self.inputToolBar.frame), self.topLayoutGuide.length, 0.00001);
}

#pragma mark - ChatInputToolbarDelegate

- (void)chatInputToolbar:(ChatInputToolbar *)toolbar didPressRightBarButton:(UIButton *)sender {
    
    if (sender == self.sendButton) {
        
        NSString *text = self.inputToolBar.contentView.textView.text;
        if ([text hasText]) {
            self.inputToolBar.contentView.textView.text = [text stringByTrimingWhitespace];
            [self.dataSource sendMessage:text];
            self.showCameraButton = YES;
        }
        self.inputToolBar.contentView.textView.text = @"";
    }
    else {
        
        __weak __typeof(self)weakSelf = self;
        [self.view endEditing:YES];
        
        
        [TMImagePicker chooseSourceTypeInVC:self allowsEditing:NO result:^(UIImage *image) {
            [weakSelf.dataSource sendImage:image];
        }];
    }
}

- (void)chatInputToolbar:(ChatInputToolbar *)toolbar didPressLeftBarButton:(UIButton *)sender {
    
    
    
    if (transactionState == TS_RECORDING) {
        [self.voiceSearch stopRecording];
    }
    else if (transactionState == TS_IDLE) {
        
        transactionState = TS_INITIAL;
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
        self.voiceSearch = [[SKRecognizer alloc] initWithType:SKDictationRecognizerType
                                                    detection:SKShortEndOfSpeechDetection
                                                     language:[self localeReturn:self.currentUser.customData]
                                                     delegate:self];
    }
    
}


#pragma mark -
#pragma mark SKRecognizerDelegate methods

- (void)recognizerDidBeginRecording:(SKRecognizer *)recognizer
{
    NSLog(@"Recording started.");
    
    transactionState = TS_RECORDING;
    [SVProgressHUD showWithStatus:@"Listening.." maskType:SVProgressHUDMaskTypeGradient];
//    [self performSelector:@selector(updateVUMeter) withObject:nil afterDelay:0.05];
    
    
}

- (void)recognizerDidFinishRecording:(SKRecognizer *)recognizer
{
    NSLog(@"Recording finished.");
    
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateVUMeter) object:nil];
//    [self setVUMeterWidth:0.];
    transactionState = TS_PROCESSING;
    [SVProgressHUD showWithStatus:@"Processing..." maskType:SVProgressHUDMaskTypeGradient];
}

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithResults:(SKRecognition *)results
{
    NSLog(@"Got results.");
    NSLog(@"Session id [%@].", [SpeechKit sessionID]); // for debugging purpose: printing out the speechkit session id
    
    long numOfResults = [results.results count];
    
    transactionState = TS_IDLE;
    [SVProgressHUD dismiss];
    
    if (numOfResults > 0)
        self.inputToolBar.contentView.textView.text = [results firstResult];
    
    self.voiceSearch = nil;
    
    [self setShowCameraButton:NO];
    [self.inputToolBar.contentView.textView becomeFirstResponder];
    
}

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithError:(NSError *)error suggestion:(NSString *)suggestion
{
    NSLog(@"Got error.");
    NSLog(@"Session id [%@].", [SpeechKit sessionID]); // for debugging purpose: printing out the speechkit session id
    
    transactionState = TS_IDLE;
    
    FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"Error" message:
                               NSLocalizedString(@"Does not recognize voice input", nil)  delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
    
    alertView.titleLabel.textColor = [UIColor cloudsColor];
    alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    alertView.messageLabel.textColor = [UIColor cloudsColor];
    alertView.messageLabel.font = [UIFont flatFontOfSize:14];
    alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.9];
    alertView.alertContainer.backgroundColor = [UIColor pomegranateColor];
    alertView.defaultButtonColor = [UIColor cloudsColor];
    alertView.defaultButtonShadowColor = [UIColor concreteColor];
    alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    alertView.defaultButtonTitleColor = [UIColor asbestosColor];
    [alertView show];
    
    self.voiceSearch = nil;
}





@end
