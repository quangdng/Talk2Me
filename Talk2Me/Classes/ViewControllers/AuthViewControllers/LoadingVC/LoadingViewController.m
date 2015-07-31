//
//  LoadingViewController.m
//  Talk2Me
//
//  Created by Tian Long on 01/09/2014.
//

#import "LoadingViewController.h"
#import "HomeViewController.h"
#import "SettingsManager.h"
#import "REAlertView+QMSuccess.h"
#import "TMApi.h"

@interface LoadingViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *splashLogoView;
@property (weak, nonatomic) IBOutlet UIButton *reconnectBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation LoadingViewController

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self createSession];
}

- (void)createSession {
    
    self.reconnectBtn.alpha = 0;
    [self.activityIndicator startAnimating];

    __weak __typeof(self)weakSelf = self;
    [[TMApi instance] createSessionWithBlock:^(BOOL success) {

        if (!success) {
            [weakSelf reconnect];
        }
        else {
            
            SettingsManager *settingsManager = [[SettingsManager alloc] init];
            BOOL rememberMe = settingsManager.rememberMe;
            
            if (rememberMe) {
                [weakSelf performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
            } else {
                [weakSelf performSegueWithIdentifier:kWelcomeScreenSegueIdentifier sender:nil];
            }
        }
    }];
}

- (void)reconnect {
    
    self.reconnectBtn.alpha = 1;
    [self.activityIndicator stopAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)pressReconnectBtn:(id)sender {
    [self createSession];
}

@end
