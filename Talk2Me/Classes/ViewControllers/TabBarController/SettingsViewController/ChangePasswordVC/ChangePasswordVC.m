//
//  ChangePasswordVC.m
//  Talk2Me
//
//  Created by Yepeng Fan on 09/10/2014.
//

#import "ChangePasswordVC.h"
#import "SettingsManager.h"
#import "AuthService.h"
#import "UsersService.h"
#import "REAlertView+QMSuccess.h"
#import "UIImage+TintColor.h"
#import "SVProgressHUD.h"
#import "TMApi.h"

const NSUInteger kMinPasswordLenght = 7;

@interface ChangePasswordVC ()

<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *changeButton;
@property (strong, nonatomic) SettingsManager *settingsManager;

@end

@implementation ChangePasswordVC

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.settingsManager = [[SettingsManager alloc] init];
    
    [self configureChangePasswordVC];
}

- (void)configureChangePasswordVC {
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UIImage *buttonBG = [UIImage imageNamed:@"blue_conter"];
    UIColor *normalColor = [UIColor colorWithRed:0.091 green:0.674 blue:0.174 alpha:1.000];
    UIEdgeInsets imgInsets = UIEdgeInsetsMake(9, 9, 9, 9);
    [self.changeButton setBackgroundImage:[buttonBG tintImageWithColor:normalColor resizableImageWithCapInsets:imgInsets]
                                 forState:UIControlStateNormal];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.oldPasswordTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - actions

- (IBAction)pressChangeButton:(id)sender {
    
    NSString *oldPassword = self.settingsManager.password;
    NSString *confirmOldPassword = self.oldPasswordTextField.text;
    NSString *newPassword = self.passwordTextField.text;
    
    if (newPassword.length == 0 || confirmOldPassword.length == 0){
        
        [REAlertView showAlertWithMessage:NSLocalizedString(@"STR_FILL_IN_ALL_THE_FIELDS", nil) actionSuccess:NO];
    }
    else if (newPassword.length < kMinPasswordLenght) {
        
        [REAlertView showAlertWithMessage:NSLocalizedString(@"STR_PASSWORD_IS_TOO_SHORT", nil) actionSuccess:NO];
    }
    else if (![oldPassword isEqualToString:confirmOldPassword]) {
        
        [REAlertView showAlertWithMessage:NSLocalizedString(@"STR_WRONG_OLD_PASSWORD", nil) actionSuccess:NO];
    }
    else {
        
        [self updatePassword:oldPassword newPassword:newPassword];
    }
}

- (void)updatePassword:(NSString *)oldPassword newPassword:(NSString *)newPassword {

    QBUUser *myProfile = [TMApi instance].currentUser;
    myProfile.password = newPassword;
    myProfile.oldPassword = oldPassword;
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];

    __weak __typeof(self)weakSelf = self;
    [[TMApi instance] changePasswordForCurrentUser:myProfile completion:^(BOOL success) {
        
        if (success) {
            
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"STR_PASSWORD_CHANGED", nil)];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
        
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.oldPasswordTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        [self pressChangeButton:nil];
    }
    
    return YES;
}

@end
