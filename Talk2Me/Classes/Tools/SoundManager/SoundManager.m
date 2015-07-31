//
//  SoundManager.m
//  Talk2Me
//
//  Created by Quang Nguyen on 11/08/2014.
//

#import "SoundManager.h"
#import "NSUserDefaultsHelper.h"

NSString * const kSystemSoundTypeCAF = @"caf";
NSString * const kSystemSoundTypeAIF = @"aif";
NSString * const kSystemSoundTypeAIFF = @"aiff";
NSString * const kystemSoundTypeWAV = @"wav";

static NSString * const kSoundManagerSettingKey = @"kSoundManagerSettingKey";


@interface SoundManager()

@property (strong, nonatomic) NSMutableDictionary *sounds;
@property (strong, nonatomic) NSMutableDictionary *completionBlocks;

@end

@implementation SoundManager

void systemServicesSoundCompletion(SystemSoundID  soundID, void *data) {
    
    SoundManager *soundManager = [SoundManager shared];
    
    SoundManagerCompletionBlock completion = [soundManager completionBlockForSoundID:soundID];
    if (completion) {
        completion();
        [soundManager removeCompletionBlockForSoundID:soundID];
    }
}

+ (SoundManager *)shared {
    static SoundManager *sharedPlayer;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPlayer = [[SoundManager alloc] init];
    });
    
    return sharedPlayer;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        _on = [self readSoundPlayerOnFromUserDefaults];
        _sounds = [[NSMutableDictionary alloc] init];
        _completionBlocks = [[NSMutableDictionary alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveMemoryWarningNotification:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}

- (BOOL)readSoundPlayerOnFromUserDefaults {

    BOOL setting = defBool(kSoundManagerSettingKey);
    
    if (!setting) {
        [self toggleSoundPlayerOn:YES];
        return YES;
    }
    
    return setting;
}

- (void)toggleSoundPlayerOn:(BOOL)on {
    
    _on = on;
    
    defSetBool(kSoundManagerSettingKey, on);
    
    if (!on) {
        [self stopAllSounds];
    }
}

#pragma mark - Playing sounds

- (void)playSoundWithName:(NSString *)filename
                extension:(NSString *)extension
                  isAlert:(BOOL)isAlert
          completionBlock:(SoundManagerCompletionBlock)completionBlock
{
    if (!self.on) {
        return;
    }
    
    if (!filename || !extension) {
        return;
    }
    
    if (![self.sounds objectForKey:filename]) {
        [self addSoundIDForAudioFileWithName:filename extension:extension];
    }
    
    SystemSoundID soundID = [self soundIDForFilename:filename];
    if (soundID) {
        if (completionBlock) {
            OSStatus error = AudioServicesAddSystemSoundCompletion(soundID,
                                                                   NULL,
                                                                   NULL,
                                                                   systemServicesSoundCompletion,
                                                                   NULL);
            
            if (error) {
                [self logError:error withMessage:@"Warning! Completion block could not be added to SystemSoundID."];
            }
            else {
                [self addCompletionBlock:completionBlock toSoundID:soundID];
            }
        }
        
        if (isAlert) {
            AudioServicesPlayAlertSound(soundID);
        }
        else {
            AudioServicesPlaySystemSound(soundID);
        }
        
    }
}



- (void)playSoundWithName:(NSString *)filename extension:(NSString *)extension {
    [self playSoundWithName:filename
                  extension:extension
                 completion:nil];
}

- (void)playSoundWithName:(NSString *)filename
                extension:(NSString *)extension
               completion:(SoundManagerCompletionBlock)completionBlock {
    
    [self playSoundWithName:filename
                  extension:extension
                    isAlert:NO
            completionBlock:completionBlock];
}

- (void)playAlertSoundWithName:(NSString *)filename
                     extension:(NSString *)extension
                    completion:(SoundManagerCompletionBlock)completionBlock {
    
    [self playSoundWithName:filename
                  extension:extension
                    isAlert:YES
            completionBlock:completionBlock];
}

- (void)playAlertSoundWithName:(NSString *)filename extension:(NSString *)extension {
    
    [self playAlertSoundWithName:filename
                       extension:extension
                      completion:nil];
}

- (void)playVibrateSound {
    
    if (self.on) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

- (void)stopAllSounds {
    
    [self unloadSoundIDs];
}

- (void)stopSoundWithFilename:(NSString *)filename {
    
    SystemSoundID soundID = [self soundIDForFilename:filename];
    NSData *data = [self dataWithSoundID:soundID];
    
    [self unloadSoundIDForFileNamed:filename];
    
    [self.sounds removeObjectForKey:filename];
    [self.completionBlocks removeObjectForKey:data];
}

- (void)preloadSoundWithFilename:(NSString *)filename extension:(NSString *)extension {
    
    if (![self.sounds objectForKey:filename]) {
        [self addSoundIDForAudioFileWithName:filename extension:extension];
    }
}

#pragma mark - Sound data

- (NSData *)dataWithSoundID:(SystemSoundID)soundID {
    
    return [NSData dataWithBytes:&soundID length:sizeof(SystemSoundID)];
}

- (SystemSoundID)soundIDFromData:(NSData *)data {

    if (data) {
        SystemSoundID soundID;
        [data getBytes:&soundID length:sizeof(SystemSoundID)];
        return soundID;
    }
    return 0;
}

#pragma mark - Sound files

- (SystemSoundID)soundIDForFilename:(NSString *)filenameKey {
    
    NSData *soundData = [self.sounds objectForKey:filenameKey];
    return [self soundIDFromData:soundData];
}

- (void)addSoundIDForAudioFileWithName:(NSString *)filename
                             extension:(NSString *)extension {
    
    SystemSoundID soundID = [self createSoundIDWithName:filename
                                              extension:extension];
    if (soundID) {
        NSData *data = [self dataWithSoundID:soundID];
        [self.sounds setObject:data forKey:filename];
    }
}

#pragma mark - Sound completion blocks

- (SoundManagerCompletionBlock)completionBlockForSoundID:(SystemSoundID)soundID
{
    NSData *data = [self dataWithSoundID:soundID];
    return [self.completionBlocks objectForKey:data];
}

- (void)addCompletionBlock:(SoundManagerCompletionBlock)block
                 toSoundID:(SystemSoundID)soundID {
    
    NSData *data = [self dataWithSoundID:soundID];
    [self.completionBlocks setObject:block forKey:data];
}

- (void)removeCompletionBlockForSoundID:(SystemSoundID)soundID {
    
    NSData *key = [self dataWithSoundID:soundID];
    [self.completionBlocks removeObjectForKey:key];
    AudioServicesRemoveSystemSoundCompletion(soundID);
}

#pragma mark - Managing sounds

- (SystemSoundID)createSoundIDWithName:(NSString *)filename
                             extension:(NSString *)extension {
    
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:filename
                                             withExtension:extension];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]]) {
        SystemSoundID soundID;
        OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &soundID);
        
        if (error) {
            [self logError:error withMessage:@"Warning! SystemSoundID could not be created."];
            return 0;
        }
        else {
            return soundID;
        }
    }
    
    ILog(@"Error: audio file not found at URL: %@", fileURL);
    return 0;
}

- (void)unloadSoundIDs {
    
    for(NSString *eachFilename in [_sounds allKeys]) {
        [self unloadSoundIDForFileNamed:eachFilename];
    }
    
    [self.sounds removeAllObjects];
    [self.completionBlocks removeAllObjects];
}

- (void)unloadSoundIDForFileNamed:(NSString *)filename {
    
    SystemSoundID soundID = [self soundIDForFilename:filename];
    
    if(soundID) {
        AudioServicesRemoveSystemSoundCompletion(soundID);
        
        OSStatus error = AudioServicesDisposeSystemSoundID(soundID);
        if(error) {
            [self logError:error withMessage:@"Warning! SystemSoundID could not be disposed."];
        }
    }
}

- (void)logError:(OSStatus)error withMessage:(NSString *)message {
    
    NSString *errorMessage = nil;
    
    switch (error) {
        case kAudioServicesUnsupportedPropertyError:
            errorMessage = @"The property is not supported.";
            break;
        case kAudioServicesBadPropertySizeError:
            errorMessage = @"The size of the property data was not correct.";
            break;
        case kAudioServicesBadSpecifierSizeError:
            errorMessage = @"The size of the specifier data was not correct.";
            break;
        case kAudioServicesSystemSoundUnspecifiedError:
            errorMessage = @"An unspecified error has occurred.";
            break;
        case kAudioServicesSystemSoundClientTimedOutError:
            errorMessage = @"System sound client message timed out.";
            break;
    }
    
    ILog(@"%@ Error: (code %d) %@", message, (int)error, errorMessage);
}

#pragma mark - Did Receive Memory Warning Notification

- (void)didReceiveMemoryWarningNotification:(NSNotification *)notification {
    
    ILog(@"%@ received memory warning!", [self class]);
    [self unloadSoundIDs];
}

#pragma mark - Default sounds

NSString *const kReceivedSoundName = @"received";
NSString *const kSendSoundName = @"sent";
NSString *const kCallingSoundName = @"calling";
NSString *const kBusySoundName = @"busy";
NSString *const kEndOfCallSoundName = @"end_of_call";
NSString *const kRingtoneSoundName = @"ringtone";

+ (void)playMessageReceivedSound {
    
    [[SoundManager shared] playSoundWithName:kReceivedSoundName extension:kystemSoundTypeWAV];
}

+ (void)playMessageSentSound {
    
    [[SoundManager shared] playSoundWithName:kSendSoundName extension:kystemSoundTypeWAV];
}

+ (void)playCallingSound {
    
    [[SoundManager shared] playSoundWithName:kCallingSoundName extension:kystemSoundTypeWAV completion:^{
        
    }];
}

+ (void)playBusySound {
    
    [[SoundManager shared] playSoundWithName:kBusySoundName extension:kystemSoundTypeWAV];
}

+ (void)playEndOfCallSound {
    
    [[SoundManager shared] playSoundWithName:kEndOfCallSoundName extension:kystemSoundTypeWAV];
}

+ (void)playRingtoneSound {
    
    [[SoundManager shared] playSoundWithName:kRingtoneSoundName extension:kystemSoundTypeWAV];
}

@end
