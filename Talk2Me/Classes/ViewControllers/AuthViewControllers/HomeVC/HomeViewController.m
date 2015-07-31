//
//  HomeViewController.m
//  Talk2Me
//
//  Created by Saranya Nagarajan on 01/09/2014.
//

#import "HomeViewController.h"
#import "LoadingViewController.h"
#import "TMApi.h"
#import "SettingsManager.h"
#import "SVProgressHUD.h"
#import "REAlertView.h"
#import "UIFont+FlatUI.h"
#import "FUIButton.h"
#import "UIColor+FlatUI.h"


@interface HomeViewController ()

@property (weak, nonatomic) IBOutlet FUIButton *fbBtn;
@property (weak, nonatomic) IBOutlet FUIButton *signUpBtn;
@property (weak, nonatomic) IBOutlet FUIButton *loginBtn;

- (IBAction)connectWithFacebook:(id)sender;

@end

@implementation HomeViewController

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [[TMApi instance].settingsManager defaultSettings];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    // Customize Flat Button
    self.signUpBtn.buttonColor = [UIColor emerlandColor];
    self.signUpBtn.shadowColor = [UIColor nephritisColor];
    self.signUpBtn.shadowHeight = 3.0f;
    self.signUpBtn.cornerRadius = 6.0f;
    self.signUpBtn.titleLabel.font = [UIFont boldFlatFontOfSize:20];
    [self.signUpBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.signUpBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
}

#pragma mark - Actions

- (IBAction)connectWithFacebook:(id)sender {
    
    __weak __typeof(self)weakSelf = self;

    [weakSelf signInWithFacebook];
}

- (IBAction)signUpWithEmail:(id)sender
{
    [self performSegueWithIdentifier:kSignUpSegueIdentifier sender:nil];
}

- (IBAction)pressAlreadyBtn:(id)sender
{
    [self performSegueWithIdentifier:kLogInSegueSegueIdentifier sender:nil];
}

- (void)signInWithFacebook {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    __weak __typeof(self)weakSelf = self;
    [[TMApi instance] singUpAndLoginWithFacebook:^(BOOL success) {
        
        [SVProgressHUD dismiss];
        if (success) {
            [weakSelf performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
        }
    }];
}

@end
