//
//  LogInViewController.m
//  Talk2Me
//
//  Created by Yepeng Fan on 02/09/2014.
//

#import "LogInViewController.h"
#import "HomeViewController.h"
#import "SettingsManager.h"
#import "REAlertView+QMSuccess.h"
#import "TMApi.h"
#import "SettingsManager.h"
#import "SVProgressHUD.h"

@interface LogInViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UISwitch *rememberMeSwitch;
@property (strong, nonatomic) SettingsManager *settingsManager;

@end

@implementation LogInViewController

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.rememberMeSwitch.on = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

#pragma mark - Actions

- (IBAction)hideKeyboard:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)logIn:(id)sender
{
    NSString *email = self.emailField.text;
    NSString *password = self.passwordField.text;
    
    if (email.length == 0 || password.length == 0) {
        [REAlertView showAlertWithMessage:NSLocalizedString(@"STR_FILL_IN_ALL_THE_FIELDS", nil)
                            actionSuccess:NO];
    }
    else {
        
        __weak __typeof(self)weakSelf = self;
        
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        
        [[TMApi instance] loginWithEmail:email
                                password:password
                              rememberMe:weakSelf.rememberMeSwitch.on
                              completion:^(BOOL success)
         {
             [SVProgressHUD dismiss];
             
             if (success) {
                 [[TMApi instance] setAutoLogin:weakSelf.rememberMeSwitch.on
                                withAccountType:QMAccountTypeEmail];
                 [weakSelf performSegueWithIdentifier:kTabBarSegueIdnetifier
                                               sender:nil];
             }
         }];
    }
}

- (IBAction)connectWithFacebook:(id)sender
{
    __weak __typeof(self)weakSelf = self;
    [weakSelf fireConnectWithFacebook];
}

- (void)fireConnectWithFacebook
{
    __weak __typeof(self)weakSelf = self;
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[TMApi instance] singUpAndLoginWithFacebook:^(BOOL success) {
        
        [SVProgressHUD dismiss];
        if (success) {
            [weakSelf performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
        }
    }];
}

@end
