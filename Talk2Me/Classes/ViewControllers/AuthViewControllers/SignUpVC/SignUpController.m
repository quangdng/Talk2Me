//
//  SignUpController.m
//  Talk2Me
//
//  Created by He Gui on 01/09/2014.
//

#import "SignUpController.h"
#import "HomeViewController.h"
#import "UIImage+Cropper.h"
#import "REAlertView+QMSuccess.h"
#import "SVProgressHUD.h"
#import "TMApi.h"
#import "TMImagePicker.h"
#import "REActionSheet.h"
#import "UIColor+FlatUI.h"
#import "UISlider+FlatUI.h"
#import "UIStepper+FlatUI.h"
#import "UITabBar+FlatUI.h"
#import "UINavigationBar+FlatUI.h"
#import "FUIButton.h"
#import "FUISwitch.h"
#import "UIFont+FlatUI.h"
#import "FUIAlertView.h"
#import "UIBarButtonItem+FlatUI.h"
#import "UIProgressView+FlatUI.h"
#import "FUISegmentedControl.h"
#import "UIPopoverController+FlatUI.h"

@interface SignUpController ()

@property (weak, nonatomic) IBOutlet UITextField *fullNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UITextField *language;
@property (weak, nonatomic) IBOutlet FUIButton *signUpBtn;


@property (strong, nonatomic) UIImage *cachedPicture;

- (IBAction)chooseUserPicture:(id)sender;
- (IBAction)signUp:(id)sender;

@end

@implementation SignUpController

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userImage.layer.cornerRadius = self.userImage.frame.size.width / 2;
    self.userImage.layer.masksToBounds = YES;
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Customize Flat Button
    self.signUpBtn.buttonColor = [UIColor peterRiverColor];
    self.signUpBtn.shadowColor = [UIColor belizeHoleColor];
    self.signUpBtn.shadowHeight = 3.0f;
    self.signUpBtn.cornerRadius = 6.0f;
    self.signUpBtn.titleLabel.font = [UIFont boldFlatFontOfSize:20];
    [self.signUpBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.signUpBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    
    
}

#pragma mark - Actions

- (IBAction)hideKeyboard:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)chooseUserPicture:(id)sender {
    
    __weak __typeof(self)weakSelf = self;
    
    [TMImagePicker chooseSourceTypeInVC:self allowsEditing:YES result:^(UIImage *image) {
        
        [weakSelf.userImage setImage:image];
        weakSelf.cachedPicture = image;
    }];
}


- (IBAction)signUp:(id)sender {
    [self fireSignUp];
}

- (void)fireSignUp
{
    NSString *fullName = self.fullNameField.text;
    NSString *email = self.emailField.text;
    NSString *password = self.passwordField.text;
    NSString *language = self.language.text;
    
    if (fullName.length == 0 || password.length == 0 || email.length == 0 || language.length == 0) {
        FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"Error" message:
                                   NSLocalizedString(@"STR_FILL_IN_ALL_THE_FIELDS", nil)  delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        
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

        return;
    }
    
    __weak __typeof(self)weakSelf = self;
        

            
    QBUUser *newUser = [QBUUser user];
    
    newUser.fullName = fullName;
    newUser.email = email;
    newUser.password = password;
    newUser.customData = language;
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    void (^presentTabBar)(void) = ^(void) {
        
        [SVProgressHUD dismiss];
        [weakSelf performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
    };
    
    [[TMApi instance] signUpAndLoginWithUser:newUser rememberMe:YES completion:^(BOOL success) {
        
        if (success) {
            
            if (weakSelf.cachedPicture) {
                
                [SVProgressHUD showProgress:0.f status:nil maskType:SVProgressHUDMaskTypeGradient];
                [[TMApi instance] updateUser:nil image:weakSelf.cachedPicture progress:^(float progress) {
                    [SVProgressHUD showProgress:progress status:nil maskType:SVProgressHUDMaskTypeGradient];
                } completion:^(BOOL updateUserSuccess) {
                    presentTabBar();
                }];
            }
            else {
                presentTabBar();
            }
        }
        else {
            [SVProgressHUD dismiss];
        }
    }];

    
}

- (NSString *) langagueReturn: (NSString*) countryCode {
    
    NSString *language = countryCode;
    
    if ([countryCode  isEqual: @"AU"]) {
        language = @"English";
    }
    else if ([countryCode  isEqual: @"ES"]) {
        language = @"Spanish";
    }
    else if ([countryCode  isEqual: @"JP"]) {
        language = @"Japanese";
    }
    else if ([countryCode  isEqual: @"DE"]) {
        language = @"German";
    }
    else if ([countryCode  isEqual: @"CN"]) {
        language = @"Mandarin Chinese";
    }
    else {
        language = @"Vietnamese";
    }
    
    return language;
}

- (void) countryController:(id)sender didSelectCountry:(EMCCountry *)chosenCountry {

    self.language.text = [self langagueReturn:chosenCountry.countryCode];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kCountryPicker])
    {
        EMCCountryPickerController *countryPicker = segue.destinationViewController;
        
        // default values
        countryPicker.showFlags = true;
        countryPicker.countryDelegate = self;
        countryPicker.drawFlagBorder = true;
        countryPicker.flagBorderColor = [UIColor grayColor];
        countryPicker.flagBorderWidth = 0.5f;
        countryPicker.availableCountryCodes = [NSSet setWithObjects:@"AU", @"ES", @"JP", @"VN", @"DE", @"CN", nil];
    }
}

@end
