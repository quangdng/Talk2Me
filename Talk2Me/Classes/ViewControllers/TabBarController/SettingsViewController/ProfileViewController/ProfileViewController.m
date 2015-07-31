//
//  ProfileViewController.m
//  Talk2Me
//
//  Created by Yepeng Fan on 09/10/2014.
//

#import "ProfileViewController.h"
#import "PlaceholderTextView.h"
#import "TMApi.h"
#import "REAlertView+QMSuccess.h"
#import "ImageView.h"
#import "SVProgressHUD.h"
#import "ContentService.h"
#import "UIImage+Cropper.h"
#import "REActionSheet.h"
#import "TMImagePicker.h"
#import "FUIButton.h"
#import "UIColor+FlatUI.h"
#import "UIFont+FlatUI.h"

@interface ProfileViewController ()

<UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet ImageView *avatarView;
@property (weak, nonatomic) IBOutlet UITextField *fullNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet UITextField *statusField;
@property (weak, nonatomic) IBOutlet FUIButton *updateProfileBtn;

@property (strong, nonatomic) NSString *fullNameFieldCache;
@property (copy, nonatomic) NSString *phoneFieldCache;
@property (copy, nonatomic) NSString *statusTextCache;


@property (nonatomic, strong) UIImage *avatarImage;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.avatarView.imageViewType = ImageViewTypeCircle;
    
    [self updateProfileView];
    [self setUpdateButtonActivity];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // Customize Flat Button
    self.updateProfileBtn.buttonColor = [UIColor peterRiverColor];
    self.updateProfileBtn.shadowColor = [UIColor belizeHoleColor];
    self.updateProfileBtn.shadowHeight = 3.0f;
    self.updateProfileBtn.cornerRadius = 6.0f;
    self.updateProfileBtn.titleLabel.font = [UIFont boldFlatFontOfSize:20];
    [self.updateProfileBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.updateProfileBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)updateProfileView {
    
    
    self.fullNameFieldCache = self.currentUser.fullName;
    self.phoneFieldCache = self.currentUser.phone ?: @"";
    self.statusTextCache = self.currentUser.customData ?: @"";
    
    UIImage *placeholder = [UIImage imageNamed:@"upic-placeholder"];
    NSURL *url = [NSURL URLWithString:self.currentUser.website];
    
    
    [self.avatarView setImageWithURL:url
                         placeholder:placeholder
                             options:SDWebImageHighPriority
                            progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                ILog(@"r - %d; e - %d", receivedSize, expectedSize);
                            } completedBlock:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                
                            }];
    
    self.fullNameField.text = self.currentUser.fullName;
    self.emailField.text = self.currentUser.email;
    self.phoneNumberField.text = self.currentUser.phone;
    self.statusField.text = self.currentUser.customData;
}

- (IBAction)changeAvatar:(id)sender {
    
    __weak __typeof(self)weakSelf = self;
    [TMImagePicker chooseSourceTypeInVC:self allowsEditing:YES result:^(UIImage *image) {
        
        weakSelf.avatarImage = image;
        weakSelf.avatarView.image = [image imageByCircularScaleAndCrop:weakSelf.avatarView.frame.size];
        [weakSelf setUpdateButtonActivity];
    }];
}

- (void)setUpdateButtonActivity {
    
    BOOL activity = [self fieldsWereChanged];
    self.updateProfileBtn.enabled = activity;
}

- (IBAction)hideKeyboard:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)saveChanges:(id)sender {
    
    [self.view endEditing:YES];
    
    __weak __typeof(self)weakSelf = self;
    
    QBUUser *user = weakSelf.currentUser;
    user.fullName = weakSelf.fullNameFieldCache;
    user.phone = weakSelf.phoneFieldCache;
    user.customData = weakSelf.statusTextCache;
    
    [SVProgressHUD showWithStatus:@"Processing" maskType:SVProgressHUDMaskTypeGradient];
    [[TMApi instance] updateUser:user image:self.avatarImage progress:^(float progress) {
    } completion:^(BOOL success) {
        
        if (success) {
            weakSelf.avatarImage = nil;
            [weakSelf updateProfileView];
            [weakSelf setUpdateButtonActivity];
        }
        [SVProgressHUD dismiss];
    }];
}

- (BOOL)fieldsWereChanged {
    
    if (self.avatarImage) return YES;
    if (![self.fullNameFieldCache isEqualToString:self.currentUser.fullName]) return YES;
    if (![self.phoneFieldCache isEqualToString:self.currentUser.phone ?: @""]) return YES;
    if (![self.statusTextCache isEqualToString:self.currentUser.customData ?: @""]) return YES;
    
    return NO;
}

#pragma mark - UITextFieldDelegate & UITextViewDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField == self.fullNameField) {
        self.fullNameFieldCache = str;
    } else if (textField == self.phoneNumberField) {
        self.phoneFieldCache = str;
    }
    else if (textField == self.statusField){
        self.statusTextCache = str;
    }
    [self setUpdateButtonActivity];
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    
    [self setUpdateButtonActivity];
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
    
    self.statusTextCache = [self langagueReturn:chosenCountry.countryCode];
    self.statusField.text = self.statusTextCache;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self setUpdateButtonActivity];
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
