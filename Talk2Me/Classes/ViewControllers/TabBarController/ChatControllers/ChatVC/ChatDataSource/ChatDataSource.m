//
//  ChatDataSource.m
//  Talk2Me
//
//  Created by Quang Nguyen on 12/09/2014.
//

#import "ChatDataSource.h"
#import "DBStorage+Messages.h"
#import "ChatMessage.h"
#import "TMApi.h"
#import "SVProgressHUD.h"
#import "ChatReceiver.h"
#import "ContentService.h"
#import "TextMessageCell.h"
#import "SystemMessageCell.h"
#import "AttachmentMessageCell.h"
#import "SoundManager.h"
#import "ChatSection.h"
#import "AppDelegate.h"
#import "FUIAlertView.h"
#import "UIColor+FlatUI.h"
#import "UIFont+FlatUI.h"

@interface ChatDataSource()

<UITableViewDataSource, ChatCellDelegate>

@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *chatSections;

/**
 *  Specifies whether or not the view controller should automatically scroll to the most recent message
 *  when the view appears and when sending, receiving, and composing a new message.
 *
 *  @discussion The default value is `YES`, which allows the view controller to scroll automatically to the most recent message.
 *  Set to `NO` if you want to manage scrolling yourself.
 */
@property (assign, nonatomic) BOOL automaticallyScrollsToMostRecentMessage;

@end

@implementation ChatDataSource

- (void)dealloc {
    [[ChatReceiver instance] unsubscribeForTarget:self];
    ILog(@"%@ - %@", NSStringFromSelector(_cmd), self);
}

- (instancetype)initWithChatDialog:(QBChatDialog *)dialog forTableView:(UITableView *)tableView {
    
    self = [super init];
    
    if (self) {
        
        self.chatDialog = dialog;
        self.tableView = tableView;
        self.chatSections = [NSMutableArray array];
        
        self.automaticallyScrollsToMostRecentMessage = YES;
        
        tableView.dataSource = self;
        [tableView registerClass:[TextMessageCell class] forCellReuseIdentifier:TextMessageCellID];
        [tableView registerClass:[AttachmentMessageCell class] forCellReuseIdentifier:AttachmentMessageCellID];
        [tableView registerClass:[SystemMessageCell class] forCellReuseIdentifier:SystemMessageCellID];
        
        __weak __typeof(self)weakSelf = self;
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [[TMApi instance] fetchMessageWithDialog:self.chatDialog complete:^(BOOL success) {
            
            [weakSelf reloadCachedMessages:NO];
            [SVProgressHUD dismiss];
            
        }];
        
        [[ChatReceiver instance] chatAfterDidReceiveMessageWithTarget:self block:^(QBChatMessage *message) {
            
            QBChatDialog *dialogForReceiverMessage = [[TMApi instance] chatDialogWithID:message.cParamDialogID];
            
            if ([weakSelf.chatDialog isEqual:dialogForReceiverMessage] && message.cParamNotificationType == MessageNotificationTypeNone) {
                
                if (message.senderID != [TMApi instance].currentUser.ID) {
                    
                    [SoundManager playMessageReceivedSound];
                    [weakSelf insertNewMessage:message];
                    
                    
                    
                }
                
            }
            else if (message.cParamNotificationType == MessageNotificationTypeDeliveryMessage ){
            }
            
        }];
    }
    
    return self;
}

- (ChatSection *)chatSectionForDate:(NSDate *)date
{
    NSInteger identifer = [ChatSection daysBetweenDate:date andDate:[NSDate date]];
    for (ChatSection *section in self.chatSections) {
        if (identifer == section.identifier) {
            return section;
        }
    }
    ChatSection *newSection = [[ChatSection alloc] initWithDate:date];
    [self.chatSections addObject:newSection];
    return newSection;
}

- (void)insertNewMessage:(QBChatMessage *)message {
    
    ChatMessage *ChatMessage = [self ChatMessageWithQbChatHistoryMessage:message];
    
    ChatSection *chatSection = [self chatSectionForDate:ChatMessage.datetime];
    [chatSection addMessage:ChatMessage];
    
    [self.tableView beginUpdates];
    if (chatSection.messages.count > 1) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:chatSection.messages.count-1 inSection:self.chatSections.count-1];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:self.chatSections.count-1] withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.tableView endUpdates];
    
    [self scrollToBottomAnimated:YES];
}

- (void)reloadCachedMessages:(BOOL)animated {
    
    NSArray *history = [[TMApi instance] messagesHistoryWithDialog:self.chatDialog];
    
    [self.chatSections removeAllObjects];
    self.chatSections = [self sortedChatSectionsFromMessageArray:history];
    
    [self.tableView reloadData];
    [self scrollToBottomAnimated:animated];
}

// ******************************************************************************
- (NSMutableArray *)sortedChatSectionsFromMessageArray:(NSArray *)messagesArray
{
    NSMutableArray *arrayOfSections = [[NSMutableArray alloc] init];
    NSMutableDictionary *sectionsDictionary = [NSMutableDictionary new];
    NSDate *dateNow = [NSDate date];
    
    for (QBChatHistoryMessage *historyMessage in messagesArray) {
        ChatMessage *ChatMessage = [self ChatMessageWithQbChatHistoryMessage:historyMessage];
        NSNumber *key = @([ChatSection daysBetweenDate:historyMessage.datetime andDate:dateNow]);
        ChatSection *section = sectionsDictionary[key];
        if (!section) {
            section = [[ChatSection alloc] initWithDate:ChatMessage.datetime];
            sectionsDictionary[key] = section;
            [arrayOfSections addObject:section];
            
        }
        [section addMessage:ChatMessage];
        
    }
    return arrayOfSections;
}
// *******************************************************************************

- (void)scrollToBottomAnimated:(BOOL)animated {
    
    if (self.chatSections.count > 0) {
        ChatSection *chatSection = [self.chatSections lastObject];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:chatSection.messages.count-1 inSection:self.chatSections.count-1];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:animated];
    }
}

- (NSString *)cellIDAtChatMessage:(ChatMessage *)message {
    
    switch (message.type) {
            
        case ChatMessageTypeSystem: return SystemMessageCellID; break;
        case ChatMessageTypePhoto: return AttachmentMessageCellID; break;
        case ChatMessageTypeText: return TextMessageCellID; break;
        default: NSAssert(nil, @"Need update this case"); break;
    }
}

- (ChatMessage *)ChatMessageWithQbChatHistoryMessage:(QBChatAbstractMessage *)historyMessage {
    
    ChatMessage *message = [[ChatMessage alloc] initWithChatHistoryMessage:historyMessage];
    BOOL fromMe = ([TMApi instance].currentUser.ID == historyMessage.senderID);
    
    message.minWidth = fromMe || (message.chatDialog.type == QBChatDialogTypePrivate) ? 78 : -1;
    message.align =  fromMe ? ChatMessageContentAlignRight : ChatMessageContentAlignLeft;
    
    return message;
}

#pragma mark - Abstract methods

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    ChatSection *chatSection = self.chatSections[section];
    NSAssert(chatSection, @"Section not found. Check this case");
    return ([chatSection.messages count] > 0) ? chatSection.name : nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.chatSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    ChatSection *chatSection = self.chatSections[section];
    return chatSection.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ChatSection *chatSection = self.chatSections[indexPath.section];
    ChatMessage *message = chatSection.messages[indexPath.row];
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:[self cellIDAtChatMessage:message]];
    
    cell.delegate = self;
    
    BOOL isMe = [TMApi instance].currentUser.ID == message.senderID;
    QBUUser *user = [[TMApi instance] userWithID:message.senderID];
    [cell setMessage:message user:user isMe:isMe];
    
    return cell;
}

#pragma mark - Send actions

- (void)sendImage:(UIImage *)image {
    
    __weak __typeof(self)weakSelf = self;
    
    [SVProgressHUD showProgress:0 status:nil maskType:SVProgressHUDMaskTypeClear];
    [[TMApi instance].contentService uploadJPEGImage:image progress:^(float progress) {
        
        [SVProgressHUD showProgress:progress status:nil maskType:SVProgressHUDMaskTypeClear];
        
    } completion:^(QBCFileUploadTaskResult *result) {
        
        if (result.success) {
            
            [[TMApi instance] sendAttachment:result.uploadedBlob.publicUrl toDialog:weakSelf.chatDialog completion:^(QBChatMessage *message) {
                [weakSelf insertNewMessage:message];
            }];
        }
        
        [SVProgressHUD dismiss];
    }];
}

- (void)sendMessage:(NSString *)text {
    
    __weak __typeof(self)weakSelf = self;
    
    [[TMApi instance] sendText:text  toDialog:self.chatDialog completion:^(QBChatMessage *message) {
        
        
        [SoundManager playMessageSentSound];
        [weakSelf insertNewMessage:message];
        
    }];
    


    
    
}

- (NSString *) localeReturn: (NSString *) language {
    NSString *locale = @"";
    
    if ([language isEqual:@"Vietnamese"]) {
        locale = @"vi";
    }
    else if ([language isEqual:@"German"]) {
        locale = @"de";
    }
    else if ([language isEqual:@"Mandarin Chinese"]) {
        locale = @"zh";
    }
    else if ([language isEqual:@"Japanese"]) {
        locale = @"ja";
    }
    else if ([language isEqual:@"Spanish"]) {
        locale = @"es";
    }
    else {
        locale = @"en";
    }
    
    
    return locale;
}

- (NSString *) langReturn: (NSString *) language {
    NSString *locale = @"";
    
    if ([language isEqual:@"Vietnamese"]) {
        locale = @"vi_VN";
    }
    else if ([language isEqual:@"German"]) {
        locale = @"de_DE";
    }
    else if ([language isEqual:@"Mandarin Chinese"]) {
        locale = @"zh_CN";
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
    
    
    return locale;
}



#pragma mark - ChatCellDelegate

#define USE_ATTACHMENT_FROM_CACHE 1

- (void)chatCell:(id)cell didSelectMessage:(ChatMessage *)message {
    
    if ([cell isKindOfClass:[AttachmentMessageCell class]]) {
#if USE_ATTACHMENT_FROM_CACHE
        AttachmentMessageCell *imageCell = cell;
        
        if ([self.delegate respondsToSelector:@selector(chatDatasource:prepareImageAttachement:fromView:)]) {
            
            UIImageView *imageView = (UIImageView *)imageCell.balloonImageView;
            UIImage *image  = imageView.image;
            
            [self.delegate chatDatasource:self prepareImageAttachement:image fromView:imageView];
        }
#else
        if ([self.delegate respondsToSelector:@selector(chatDatasource:prepareImageURLAttachement:)]) {
            
            QBChatAttachment *attachment = [message.attachments firstObject];
            NSURL *url = [NSURL URLWithString:attachment.url];
            [self.delegate chatDatasource:self prepareImageURLAttachement:url];
        }
#endif
    }
    else {
        
        // also need an instance variable like so:
//        NSLog(@"%@", ((QBUUser *)[[[TMApi instance] usersWithIDs:self.chatDialog.occupantIDs] objectAtIndex:0]).fullName);
        
        if (isSpeaking) {
            [vocalizer cancel];
            isSpeaking = NO;
        }
        else {
            isSpeaking = YES;
            
            NSString *currentLang = [self localeReturn:self.currentUser.customData];
            NSString *targetLang = [self localeReturn:[[TMApi instance] userWithID:message.senderID].customData];
            
            FGTranslator *tranlator = [[FGTranslator alloc] initWithGoogleAPIKey:@"AIzaSyB41zQEDWZ7zjUXOyPBRZuS7bbSVjW_0DM"];
            
            [tranlator translateText:message.encodedText withSource:targetLang target:currentLang completion:^(NSError *error, NSString *translated, NSString *sourceLanguage) {
                if (error)
                {
                    FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"Error" message:
                                               NSLocalizedString(@"Can't translate", nil)  delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
                    
                    alertView.titleLabel.textColor = [UIColor cloudsColor];
                    alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
                    alertView.messageLabel.textColor = [UIColor cloudsColor];
                    alertView.messageLabel.font = [UIFont flatFontOfSize:14];
                    alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.9];
                    alertView.alertContainer.backgroundColor = [UIColor belizeHoleColor];
                    alertView.defaultButtonColor = [UIColor cloudsColor];
                    alertView.defaultButtonShadowColor = [UIColor concreteColor];
                    alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
                    alertView.defaultButtonTitleColor = [UIColor asbestosColor];
                    [alertView show];
                }
                else
                {
                    [SVProgressHUD showWithStatus:@"Speaking..." maskType:SVProgressHUDMaskTypeGradient];
                    vocalizer = [[SKVocalizer alloc] initWithLanguage:[self langReturn:self.currentUser.customData] delegate:self];
                    [vocalizer speakString:translated];
                }
                
            }];
            
            
            
        }
    }
    
}

#pragma mark -
#pragma mark SKVocalizerDelegate methods

- (void)vocalizer:(SKVocalizer *)vocalizer willBeginSpeakingString:(NSString *)text {
    isSpeaking = YES;
    
}

- (void)vocalizer:(SKVocalizer *)vocalizer willSpeakTextAtCharacter:(NSUInteger)index ofString:(NSString *)text {
    NSLog(@"Session id [%@].", [SpeechKit sessionID]); // for debugging purpose: printing out the speechkit session id
}

- (void)vocalizer:(SKVocalizer *)vocalizer didFinishSpeakingString:(NSString *)text withError:(NSError *)error {
    NSLog(@"Session id [%@].", [SpeechKit sessionID]); // for debugging purpose: printing out the speechkit session id
    isSpeaking = NO;
    if (error !=nil)
    {
    }
    
    [SVProgressHUD dismiss];
}



@end