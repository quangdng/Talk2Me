//
//  ChatButtonsFactory.m
//  Talk2Me
//
//  Created by Tian Long on 12/09/2014.
//

#import "ChatButtonsFactory.h"
#import "UIImage+TintColor.h"


@implementation ChatButtonsFactory

+ (UIButton *)sendButton {
    
    NSString *sendTitle = @"Send";
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [sendButton setTitle:sendTitle forState:UIControlStateNormal];
    
    [sendButton setTitleColor:[UIColor colorWithWhite:0.340 alpha:1.000] forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor colorWithWhite:0.604 alpha:1.000] forState:UIControlStateHighlighted];
    [sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    
    sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    sendButton.contentMode = UIViewContentModeCenter;
    sendButton.backgroundColor = [UIColor clearColor];
    sendButton.tintColor = [UIColor grayColor];
    
    return sendButton;
}

+ (UIButton *)groupInfo {
    
    UIButton *groupInfoButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [groupInfoButton setFrame:CGRectMake(0, 0, 30, 40)];
    [groupInfoButton setImage:[UIImage imageNamed:@"ic_info_top"] forState:UIControlStateNormal];
    
    return groupInfoButton;
}

+ (UIButton *)dictationBtn {
    
    UIButton *dictationBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [dictationBtn setImage:[UIImage imageNamed:@"dictation"] forState:UIControlStateNormal];
    [dictationBtn setImage:[UIImage imageNamed:@"dictation_highlight"] forState:UIControlStateHighlighted];
    [dictationBtn setTintColor:[UIColor lightGrayColor]];
    
    return dictationBtn;
}

+ (UIButton *)cameraButton {
    
    UIImage *cameraImage = [UIImage imageNamed:@"ic_camera"];
    UIImage *cameraNormal = [cameraImage tintImageWithColor:[UIColor lightGrayColor]];
    UIImage *cameraHighlighted = [cameraImage tintImageWithColor:[UIColor darkGrayColor]];
    
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [cameraButton setImage:cameraNormal forState:UIControlStateNormal];
    [cameraButton setImage:cameraHighlighted forState:UIControlStateHighlighted];
    
    cameraButton.contentMode = UIViewContentModeScaleAspectFit;
    cameraButton.backgroundColor = [UIColor clearColor];
    cameraButton.tintColor = [UIColor lightGrayColor];
    
    return cameraButton;
}



@end
