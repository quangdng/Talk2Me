//
//  ForgotPasswordVC.m
//  Talk2Me
//
//  Created by Yepeng Fan on 02/09/2014.
//

#import "ForgotPasswordVC.h"
#import "TMApi.h"
#import "SVProgressHUD.h"

@interface ForgotPasswordVC ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *resetPasswordBtn;

@end

@implementation ForgotPasswordVC

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

#pragma mark - actions

- (IBAction)pressResetPasswordBtn:(id)sender {
    
    NSString *email = self.emailTextField.text;
    
    if (email.length > 0) {
        [self resetPasswordForMail:email];
    }
}

- (void)resetPasswordForMail:(NSString *)emailString {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];

    __weak __typeof(self)weakSelf = self;
    [[TMApi instance] resetUserPassordWithEmail:emailString completion:^(BOOL success) {

        if (success) {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"STR_MESSAGE_WAS_SENT_TO_YOUR_EMAIL", nil)];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }else {
            [SVProgressHUD dismiss];
        }
    }];
}

@end
