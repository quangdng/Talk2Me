//
//  AppDelegate.m
//  Talk2Me
//
//  Created by Quang Nguyen on 20/08/2014.

#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "PopoversFactory.h"
#import "TMApi.h"
#import "UIColor+FlatUI.h"
#import "SpeechKit/SpeechKit.h"

#define IS_DEVELOPMENT 0

#if IS_DEVELOPMENT

// IS_DEVELOPMENT
const NSUInteger kApplicationID = 15415;
NSString *const kAuthorizationKey = @"mrCms5szdaTuw9A";
NSString *const kAuthorizationSecret = @"Sx3NFjRbLpufJWO";
NSString *const kAcconuntKey = @"XUxWgcizKgq2PWz3Fqge";

#else

// IS_DEVELOPMENT
const NSUInteger kApplicationID = 15415;
NSString *const kAuthorizationKey = @"mrCms5szdaTuw9A";
NSString *const kAuthorizationSecret = @"Sx3NFjRbLpufJWO";
NSString *const kAcconuntKey = @"XUxWgcizKgq2PWz3Fqge";

#endif

const unsigned char SpeechKitApplicationKey[] = {0x0d, 0xcb, 0xf9, 0xa3, 0x45, 0x69, 0xdc, 0xf9, 0x73, 0xfc, 0x4d, 0xc0, 0xa7, 0xc4, 0x0a, 0x30, 0x51, 0x21, 0x5d, 0x45, 0xce, 0x44, 0xf1, 0xb3, 0x74, 0x0b, 0x30, 0x51, 0x95, 0x2f, 0xe1, 0xa2, 0xfa, 0xdb, 0x45, 0x3f, 0x44, 0x22, 0x39, 0xb7, 0x1e, 0x86, 0x78, 0xc5, 0x4a, 0x82, 0xf5, 0x9b, 0xa3, 0x53, 0xe1, 0x72, 0x97, 0xd2, 0x25, 0x0b, 0xdd, 0x55, 0x5d, 0x72, 0x84, 0x3e, 0x14, 0x7f};

/* ==================================================================== */

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleDefault;
    self.window.backgroundColor = [UIColor whiteColor];
    
    UIApplication.sharedApplication.applicationIconBadgeNumber = 0;
    
    [QBApplication sharedApplication].applicationId = kApplicationID;
    [QBConnection registerServiceKey:kAuthorizationKey];
    [QBConnection registerServiceSecret:kAuthorizationSecret];
    [QBSettings setAccountKey:kAcconuntKey];
    [QBSettings setLogLevel:QBLogLevelDebug];
    
    
#ifndef DEBUG
    [QBSettings useProductionEnvironmentForPushNotifications:NO];
#endif
    
    
#if STAGE_SERVER_IS_ACTIVE == 1
    [QBSettings setServerApiDomain:@"https://api.quickblox.com];
    [QBSettings setServerChatDomain:@"chat.quickblox.com"];
#endif
    
    NSDictionary *normalAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithWhite:1.000 alpha:0.750]};
    NSDictionary *disabledAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.935 alpha:0.260]};
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:normalAttributes forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:disabledAttributes forState:UIControlStateDisabled];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil] setTitleTextAttributes:nil forState:UIControlStateNormal];
    [[UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil] setTitleTextAttributes:nil forState:UIControlStateDisabled];
    
    if (launchOptions != nil) {
        NSDictionary *notification = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        [[TMApi instance] setPushNotification:notification];
    }
     
     [SpeechKit setupWithID:@"NMDPTRIAL_thienphong20140809121353"
                       host:@"sandbox.nmdp.nuancemobility.net"
                       port:443
                     useSSL:NO
                   delegate:nil];
     
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {


    [[TMApi instance] openChatPageForPushNotification:userInfo];
    NSLog(@"didReceiveRemoteNotification userInfo=%@", userInfo);
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[TMApi instance] applicationWillResignActive];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[TMApi instance] applicationDidBecomeActive:^(BOOL success) {
        [SVProgressHUD dismiss];
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

     

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {

}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {

    BOOL urlWasIntendedForFacebook = [FBSession.activeSession handleOpenURL:url];
    return urlWasIntendedForFacebook;
}

@end
