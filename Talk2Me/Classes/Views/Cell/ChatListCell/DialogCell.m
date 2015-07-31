//
//  DialogCell.m
//  Talk2Me
//
//  Created by Quang Nguyen on 02/10/2014.
//

#import "DialogCell.h"
#import "TMApi.h"
#import "ImageView.h"
#import "NSString+GTMNSStringHTMLAdditions.h"

@interface DialogCell()

@property (strong, nonatomic) IBOutlet UILabel *unreadMsgNumb;
@property (strong, nonatomic) IBOutlet UILabel *groupMembersNumb;

@property (strong, nonatomic) IBOutlet UIImageView *groupNumbBackground;
@property (strong, nonatomic) IBOutlet UIImageView *unreadMsgBackground;

@end

@implementation DialogCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setDialog:(QBChatDialog *)dialog {
    
    if (_dialog != dialog) {
        _dialog = dialog;
        
    }
    [self configureCellWithDialog:dialog];
}

- (void)configureCellWithDialog:(QBChatDialog *)chatDialog {
    
    BOOL isGroup = (chatDialog.type == QBChatDialogTypeGroup);
    self.descriptionLabel.text =  [chatDialog.lastMessageText gtm_stringByUnescapingFromHTML];
    self.groupMembersNumb.hidden = self.groupNumbBackground.hidden = !isGroup;
    self.unreadMsgBackground.hidden = self.unreadMsgNumb.hidden = (chatDialog.unreadMessagesCount == 0);
    self.unreadMsgNumb.text = [NSString stringWithFormat:@"%d", chatDialog.unreadMessagesCount];
    
    if (!isGroup) {
        
        NSUInteger opponentID = [[TMApi instance] occupantIDForPrivateChatDialog:self.dialog];
        QBUUser *opponent = [[TMApi instance] userWithID:opponentID];
        
        NSURL *url = [NSURL URLWithString:opponent.website];
        [self setUserImageWithUrl:url];
        
        self.titleLabel.text = opponent.fullName;
        
    } else {
        
        UIImage *img = [UIImage imageNamed:@"upic_placeholder_details_group"];
        [self setUserImage:img withKey:@"upic_placeholder_details_group"];
        self.titleLabel.text = chatDialog.name;
        self.groupMembersNumb.text = [NSString stringWithFormat:@"%d", chatDialog.occupantIDs.count];
    }
}

@end