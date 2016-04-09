//
//  TimerManager.m
//  Fifty-Five and Five
//
//  Created by Joel Ray Holveck on 4/5/16.
//  Copyright © 2016 Joel Ray Holveck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#import "TimerManager.h"

@implementation TimerManager {
    AVAudioPlayer * _Nullable playingAlarm;
}

NSString * kIdRunningTimer = @"runningTimer";
NSString * kIdNextAlarm = @"nextAlarm";
NSDictionary * defaultTimes;

+ (void)load
{
    defaultTimes = @{@"time55": @"55", @"time5": @"5", @"timeSnooze": @"5"};
}

+ (TimerManager*)sharedInstance
{
    static TimerManager * rv;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rv = [[TimerManager alloc] init];
    });
    return rv;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        [defaults registerDefaults:defaultTimes];
        [defaults synchronize];
        _runningTimer = (enum RunningTimer)[defaults integerForKey:kIdRunningTimer];
        _nextAlarm = [defaults objectForKey:kIdNextAlarm];
        // FIXME What if _nextAlarm has passed?
        
        [self setupNotification];
    }
    return self;
}

- (AVAudioPlayer*)newPlayingAlarm
{
    NSURL * alarmUrl = [[NSBundle mainBundle] URLForResource:@"alarm"
                                               withExtension:@"aif"];
    return [[AVAudioPlayer alloc] initWithContentsOfURL:alarmUrl
                                   fileTypeHint:AVFileTypeAIFF
                                          error:nil];
}

- (NSTimeInterval)definedInterval:(NSString * _Nonnull)key
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString * timeString = [defaults stringForKey:key];
    if (!timeString) {
        [defaults removeObjectForKey:key];
        [defaults synchronize];
        timeString = [defaultTimes objectForKey:key];
        assert(timeString);
    }
    NSInteger timeInt = [timeString integerValue];
    if (!timeInt) {
        [defaults removeObjectForKey:key];
        [defaults synchronize];
        timeInt = [[defaultTimes objectForKey:key] integerValue];
        assert(timeInt);
    }
    if ([defaults boolForKey:@"fastTimes"])
        return timeInt * 1.0;
    else
        return timeInt * 60.0;
}

#pragma mark - runningTimer and nextAlarm

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    if ([key isEqualToString:@"runningTimer"] || [key isEqualToString:@"nextAlarm"]) {
        return YES;
    } else {
        return [super automaticallyNotifiesObserversForKey:key];
    }
}

- (void)switchToTimer:(enum RunningTimer)timer
         forAlarmTime:(NSDate *)alarmTime
{
    // We do this here instead of in the view controller, since I'm not sure if the view controller can be freed while we're in the background.
    [[UIApplication sharedApplication] ignoreSnapshotOnNextApplicationLaunch];
    
    [self willChangeValueForKey:@"runningTimer"];
    [self willChangeValueForKey:@"nextAlarm"];
    _runningTimer = timer;
    _nextAlarm = alarmTime;
    [self didChangeValueForKey:@"nextAlarm"];
    [self didChangeValueForKey:@"runningTimer"];
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:_runningTimer forKey:kIdRunningTimer];
    [defaults setObject:_nextAlarm forKey:kIdNextAlarm];
    [defaults synchronize];
    
    [self setupNotification];
}

- (void)addInterval:(NSTimeInterval)interval
{
    [self willChangeValueForKey:@"nextAlarm"];
    _nextAlarm = [_nextAlarm dateByAddingTimeInterval:interval];
    [self didChangeValueForKey:@"nextAlarm"];
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_nextAlarm forKey:kIdNextAlarm];
    [defaults synchronize];
    
    [self setupNotification];
}

- (void)switchToTimer:(enum RunningTimer)timer
          forInterval:(NSTimeInterval)interval
{
    [self switchToTimer:timer
           forAlarmTime:[NSDate dateWithTimeIntervalSinceNow:interval]];
}

- (void)switchToTimer:(enum RunningTimer)timer
{
    switch (timer) {
        case TIMER_STOPPED:
            [self switchToTimer:timer forAlarmTime:nil];
            break;
        case TIMER_55:
            [self switchToTimer:timer forInterval:[self definedInterval:@"time55"]];
            break;
        case TIMER_5:
            [self switchToTimer:timer forInterval:[self definedInterval:@"time5"]];
            break;
        default:
            abort();
    }
}

- (void)switchToOtherTimerForInterval:(NSTimeInterval)interval
{
    [self switchToTimer:[self otherTimer] forInterval:interval];
}

- (void)switchToOtherTimer
{
    [self switchToTimer:[self otherTimer]];
}

- (enum RunningTimer)otherTimer
{
    switch (_runningTimer) {
        case TIMER_STOPPED:
            return TIMER_55;
        case TIMER_55:
            return TIMER_5;
        case TIMER_5:
            return TIMER_55;
        default:
            abort();
    }
}

#pragma mark - Notifications

- (NSString*)callToActionForTimer:(enum RunningTimer)timer
{
    switch (timer) {
        case TIMER_STOPPED: return NSLocalizedString(@"Time to stop", nil);
        case TIMER_55: return NSLocalizedString(@"Time to work", nil);
        case TIMER_5: return NSLocalizedString(@"Time to rest", nil);
        default: abort();
    }
}

- (void)setupNotification
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    if (_runningTimer == TIMER_STOPPED)
        return;
    assert(_nextAlarm);
    NSDate * now = [NSDate date];
    if ([now compare:_nextAlarm] != NSOrderedAscending)
        return;
    UILocalNotification * notification = [[UILocalNotification alloc] init];
    notification.fireDate = _nextAlarm;
    notification.alertBody = [self callToActionForTimer:[self otherTimer]];
    notification.category = @"alarm";
    notification.soundName = @"alarm.aif";
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    // FIXME Arrange an NSTimer to start the sound if we're in the foreground.
}

- (void)alarmFired
{
    if (playingAlarm) {
        [playingAlarm stop];
    } else {
        playingAlarm = [self newPlayingAlarm];
    }
    
    NSString * appName = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:appName
                                                                   message:[self callToActionForTimer:_runningTimer]
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* stopAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Stop", nil)
                                                         style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [playingAlarm stop];
                                                           playingAlarm = nil;
                                                           [self stopTimer];
                                                       }];
    [alert addAction:stopAction];
    UIAlertAction* snoozeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Snooze", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [playingAlarm stop];
                                                             playingAlarm = nil;
                                                             [self snooze];
                                                         }];
    [alert addAction:snoozeAction];
    UIAlertAction* closeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Close", nil)
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
                                                            [playingAlarm stop];
                                                            playingAlarm = nil;
                                                        }];
    [alert addAction:closeAction];

    AppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate.window.rootViewController presentViewController:alert
                                                        animated:YES
                                                      completion:^{
                                                          [self switchToOtherTimer];
                                                          [playingAlarm play];
                                                      }];
}

- (void)alarmAcknowledged
{
    if (playingAlarm && playingAlarm.playing) {
        [playingAlarm stop];
        playingAlarm = nil;
    }
}

#pragma mark - App state changes

- (void)resignActive
{
    if (playingAlarm)
        [playingAlarm stop];
}
- (void)becomeActive
{
    if (playingAlarm)
        [playingAlarm play];
}
- (void)enterForeground
{
    if (playingAlarm) {
        [playingAlarm stop];
        playingAlarm = nil;
    }
}
- (void)enterBackground
{
    if (playingAlarm) {
        [playingAlarm stop];
        playingAlarm = nil;
    }
}

#pragma mark - User inputs

- (void)startNextTimer
{
    [self switchToOtherTimer];
}

- (void)snooze
{
    [playingAlarm stop];
    playingAlarm = nil;
    [self switchToOtherTimerForInterval:[self definedInterval:@"timeSnooze"]];
}

- (void)fiveMoreMinutes
{
    NSTimeInterval timeSnooze = [self definedInterval:@"timeSnooze"];

    if (_runningTimer == TIMER_STOPPED) {
        [self switchToOtherTimerForInterval:timeSnooze];
        return;
    }
    
    if (playingAlarm) {
        // This shouldn't happen.
        [self snooze];
        return;
    }
    
    [self addInterval:timeSnooze];
}

- (void)stopTimer {
    [self switchToTimer:TIMER_STOPPED];
}

@end
