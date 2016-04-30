//
//  AlarmSoundManager.m
//  Fifty-Five and Five
//  Copyright © 2016 Joel Ray Holveck
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "AlarmSoundManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@implementation AlarmSound {
    AVAudioPlayer * player;
}

- (id)initWithIdentifier:(NSString * _Nonnull)identifier
                    name:(NSString * _Nonnull)name
                filename:(NSString * _Nonnull)filename
{
    self = [super init];
    if (!self)
        return self;
    self.identifier = identifier;
    self.localizedName = NSLocalizedString(name, nil);
    self.urlToSoundFile = [[NSBundle mainBundle] URLForResource:filename withExtension:@"caf"];
    return self;
}

- (NSString*)filename
{
    return [_urlToSoundFile lastPathComponent];
}

- (void)play
{
    if (!player) {
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:_urlToSoundFile
                                                 fileTypeHint:AVFileTypeCoreAudioFormat
                                                        error:nil];
        player.delegate = self;
    }
    player.currentTime = 0;

    NSError *activationError = nil;
    BOOL activationSuccess = [[AVAudioSession sharedInstance] setActive: YES error: &activationError];
    if (!activationSuccess)
        NSLog(@"Could not activate audio session: %@", activationError);

    [player play];
}

- (void)alarm
{
    [self play];
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

- (void)stop
{
    if (player)
        [player stop];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player
                       successfully:(BOOL)flag
{
    NSLog(@"Finished playing");
    NSError *activationError = nil;
    BOOL activationSuccess = [[AVAudioSession sharedInstance]
                              setActive: NO
                              withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                              error: &activationError];
    if (!activationSuccess)
        NSLog(@"Could not deactivate audio session: %@", activationError);
}

@end

@implementation AlarmSoundManager {
    NSUInteger _currentAlarmSoundIdx;
}

static NSString * kAlarmSound = @"alarmSound";

+ (AlarmSoundManager * _Nonnull)sharedInstance
{
    static AlarmSoundManager * rv;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rv = [[self alloc] init];
        
        // FIXME I'm using AVAudioSessionCategoryPlayback, since that's the only way I can request
        // it to duck other audio.  Unfortunately, that means that I don't honor the silent switch
        // when the app is in the foreground.  I don't see a way to have the same characteristics
        // as system notifications, i.e.:
        // * Duck other audio
        // * Honor silent switch
        // * Stop playback when the alert is dismissed
        NSError *setCategoryError = nil;
        BOOL categorySuccess = [[AVAudioSession sharedInstance]
                                setCategory:AVAudioSessionCategoryPlayback
                                withOptions:(AVAudioSessionCategoryOptionMixWithOthers |
                                             AVAudioSessionCategoryOptionDuckOthers |
                                             AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers)
                                      error:&setCategoryError];
        if (!categorySuccess) {
            NSLog(@"Error setting audio session category: %@", setCategoryError);
        }
        
        
    });
    return rv;
}

- (id)init
{
    self = [super init];
    if (!self)
        return self;
    
    _alarmSounds = [NSArray arrayWithObjects:
                    [[AlarmSound alloc] initWithIdentifier:@"song" name:@"Song" filename:@"Alarm Song"],
                    [[AlarmSound alloc] initWithIdentifier:@"ding" name:@"Ding" filename:@"Alarm Ding"],
                    nil];
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString * alarmId = [defaults stringForKey:kAlarmSound];
    NSUInteger alarmIdx = [_alarmSounds indexOfObjectPassingTest:^BOOL(AlarmSound* obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj.identifier isEqualToString:alarmId];
    }];
    _currentAlarmSoundIdx = alarmIdx == NSNotFound ? 0 : alarmIdx;
    
    return self;
}

- (NSUInteger)currentAlarmSoundIdx
{
    @synchronized (self) {
        return _currentAlarmSoundIdx;
    }
}

- (void)setCurrentAlarmSoundIdx:(NSUInteger)newIdx
{
    @synchronized (self) {
        _currentAlarmSoundIdx = newIdx;
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[self currentAlarm].identifier
                     forKey:kAlarmSound];
    }
}

- (AlarmSound*)currentAlarm
{
    return [_alarmSounds objectAtIndex:_currentAlarmSoundIdx];
}

- (void)stopAll
{
    [_alarmSounds makeObjectsPerformSelector:@selector(stop)];
    
    NSError *activationError = nil;
    BOOL activationSuccess = [[AVAudioSession sharedInstance]
                              setActive:NO
                              withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                              error:&activationError];
    if (!activationSuccess)
        NSLog(@"Could not deactivate audio session: %@", activationError);
}

@end
