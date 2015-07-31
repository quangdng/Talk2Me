//
//  SettingsManager.m
//  Talk2Me
//
//  Created by Quang Nguyen on 09/09/2014.
//

#import "SettingsManager.h"
#import <Security/Security.h>
#import "NSUserDefaultsHelper.h"
#import "SSKeychain.h"

NSString *const kSettingsLoginKey = @"loginKey";
NSString *const kSettingsRememberMeKey = @"rememberMeKey";
NSString *const kFirstFacebookLoginKey = @"first_facebook_login";
NSString *const kSettingsPushNotificationEnabled = @"pushNotificationEnabledKey";
NSString *const kSettingsUserStatusKey = @"userStatusKey";
NSString *const kAuthServiceKey = @"QMAuthServiceKey";
NSString *const kLicenceAcceptedKey = @"licence_accepted";
NSString *const kAccountTypeKey = @"accountType";
NSString *const kApplicationEnteredFromPushKey = @"app_entered_from_push";


@implementation SettingsManager

@dynamic login;
@dynamic password;
@dynamic userStatus;
@dynamic pushNotificationsEnabled;
@dynamic rememberMe;
@dynamic userAgreementAccepted;
@dynamic accountType;

#pragma mark - accountType

- (void)setAccountType:(QMAccountType)accountType {
    defSetInt(kAccountTypeKey, accountType);
}

- (QMAccountType)accountType {
    
    NSUInteger accountType = defInt(kAccountTypeKey);
    return accountType;
}

#pragma mark - userAgreementAccepted

- (void)setUserAgreementAccepted:(BOOL)userAgreementAccepted {
    
    defSetBool(kLicenceAcceptedKey, userAgreementAccepted);
}

- (BOOL)userAgreementAccepted {
    BOOL accepted = defBool(kLicenceAcceptedKey);
    return accepted;
}

#pragma mark - Login

- (void)setLogin:(NSString *)login andPassword:(NSString *)password {

    [self setLogin:login];
    [SSKeychain setPassword:password forService:kAuthServiceKey account:login];
}

- (NSString *)login {
    
    NSString *login = defObject(kSettingsLoginKey);
    return login;
}

- (void)setLogin:(NSString *)login {
    
    defSetObject(kSettingsLoginKey, login);
}

#pragma mark - Password

- (NSString *)password {
    
    NSString *password = [SSKeychain passwordForService:kAuthServiceKey account:self.login];
    return password;
}

#pragma mark - Push notifications enabled

- (BOOL)pushNotificationsEnabled {
    
    BOOL pushNotificationEnabled = defBool(kSettingsPushNotificationEnabled);
    return pushNotificationEnabled;
}

- (void)setPushNotificationsEnabled:(BOOL)pushNotificationsEnabled {
    
    defSetBool(kSettingsPushNotificationEnabled, pushNotificationsEnabled);
}

#pragma mark - remember login

- (BOOL)rememberMe {
    
    BOOL rememberMe = defBool(kSettingsRememberMeKey);
    return rememberMe;
}

- (void)setRememberMe:(BOOL)rememberMe {
    
    defSetBool(kSettingsRememberMeKey, rememberMe);
}

#pragma mark - User Status

- (NSString *)userStatus {
    
    NSString *userStatus = defObject(kSettingsUserStatusKey);
    return userStatus;
}

- (void)setUserStatus:(NSString *)userStatus {
    
    defSetObject(kSettingsUserStatusKey, userStatus);
}

#pragma mark - First facebook login

- (void)setFirstFacebookLogin:(BOOL)firstFacebookLogin
{
    defSetBool(kFirstFacebookLoginKey, firstFacebookLogin);
}

- (BOOL)isFirstFacebookLogin
{
    return defBool(kFirstFacebookLoginKey);
}


#pragma mark - Default Settings

- (void)defaultSettings {
    self.pushNotificationsEnabled = YES;
}

- (void)clearSettings {
    [self defaultSettings];
    self.rememberMe = NO;
    [self setLogin:nil andPassword:nil];
    self.userAgreementAccepted = NO;
    self.firstFacebookLogin = NO;
    self.accountType = QMAccountTypeNone;
    self.userStatus = nil;
    self.login = nil;
}

@end
