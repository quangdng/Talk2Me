//
//  SoundManager.h
//  Talk2Me
//
//  Created by Quang Nguyen on 11/08/2014.
//

#import <Foundation/Foundation.h>

typedef void(^SoundManagerCompletionBlock)(void);

@interface SoundManager : NSObject

@property (assign, nonatomic, readonly) BOOL on;

+ (SoundManager *)shared;

- (void)toggleSoundPlayerOn:(BOOL)on;
- (void)playSoundWithName:(NSString *)filename extension:(NSString *)extension;
- (void)playSoundWithName:(NSString *)filename
                extension:(NSString *)extension
               completion:(SoundManagerCompletionBlock)completionBlock;
- (void)playAlertSoundWithName:(NSString *)filename extension:(NSString *)extension;
- (void)playAlertSoundWithName:(NSString *)filename
                     extension:(NSString *)extension
                    completion:(SoundManagerCompletionBlock)completionBlock;
- (void)playVibrateSound;
- (void)stopAllSounds;
- (void)stopSoundWithFilename:(NSString *)filename;
- (void)preloadSoundWithFilename:(NSString *)filename extension:(NSString *)extension;
/*Default sounds*/
+ (void)playMessageReceivedSound;
+ (void)playMessageSentSound;
+ (void)playCallingSound;
+ (void)playBusySound;
+ (void)playEndOfCallSound;
+ (void)playRingtoneSound;

@end
