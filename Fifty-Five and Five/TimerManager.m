//
//  TimerManager.m
//  Fifty-Five and Five
//
//  Created by Joel Ray Holveck on 4/5/16.
//  Copyright © 2016 Joel Ray Holveck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimerManager.h"

@implementation TimerManager

#define TIME_55 ((NSTimeInterval)55)
#define TIME_5 ((NSTimeInterval)5)
#define TIME_SNOOZE ((NSTimeInterval)5)

NSString * kIdRunningMode = @"runningMode";
NSString * kIdNextAlarm = @"nextAlarm";

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
        [defaults synchronize];
        _runningMode = (enum RunningMode)[defaults integerForKey:kIdRunningMode];
        _nextAlarm = [defaults objectForKey:kIdNextAlarm];
        // FIXME What if _nextAlarm has passed?
        
        [self addObserver:self
               forKeyPath:@"runningMode"
                  options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                  context:nil];
        [self addObserver:self
               forKeyPath:@"nextAlarm"
                  options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                  context:nil];
        [self setupNotification];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"runningMode"]) {
        switch (_runningMode) {
            case RUNNING_MODE_STOPPED:
                self.nextAlarm = nil;
                break;
            case RUNNING_MODE_55:
                self.nextAlarm = [NSDate dateWithTimeIntervalSinceNow:TIME_55];
                break;
            case RUNNING_MODE_5:
                self.nextAlarm = [NSDate dateWithTimeIntervalSinceNow:TIME_5];
                break;
            default:
                abort();
        }
        // Don't bother saving the user defaults; we'll save them on the nextAlarm change observation.
        return;
        
    } else if ([keyPath isEqualToString:@"nextAlarm"]) {
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:_runningMode forKey:kIdRunningMode];
        [defaults setObject:_nextAlarm forKey:kIdNextAlarm];
        [defaults synchronize];
        [self setupNotification];
        return;
        
    } else {
        abort();
    }
}

- (void)setupNotification
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    if (_runningMode == RUNNING_MODE_STOPPED)
        return;
    assert(_nextAlarm);
    NSDate * now = [NSDate date];
    if ([now compare:_nextAlarm] != NSOrderedAscending)
        return;
    UILocalNotification * notification = [[UILocalNotification alloc] init];
    notification.fireDate = _nextAlarm;
    notification.alertBody = (_runningMode == RUNNING_MODE_5 ? NSLocalizedString(@"Time to work", nil) :
                              _runningMode == RUNNING_MODE_55 ? NSLocalizedString(@"Time to rest", nil) :
                              @"missingNo");
    // FIXME This overlaps with the actions in the category.  What up?
    notification.alertAction = NSLocalizedString(@"Proceed", nil);
    notification.category = @"alarm";
    notification.soundName = @"alarm.aif";
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    // FIXME Arrange an NSTimer to start the sound if we're in the foreground.
}

- (void)resignActive
{
}
- (void)becomeActive
{
}
- (void)enterForeground
{
}
- (void)enterBackground
{
}

- (void)startNextTimer
{
    switch (self.runningMode) {
        case RUNNING_MODE_STOPPED:
            self.runningMode = RUNNING_MODE_55;
            break;
        case RUNNING_MODE_55:
            self.runningMode = RUNNING_MODE_5;
            break;
        case RUNNING_MODE_5:
            self.runningMode = RUNNING_MODE_55;
            break;
        default:
            abort();
    }
}

- (void)fiveMoreMinutes
{
    if (_runningMode == RUNNING_MODE_STOPPED)
        return;
    assert(_nextAlarm);
    NSDate * now = [NSDate date];
    if ([now compare:_nextAlarm] == NSOrderedDescending) {
        self.nextAlarm = [NSDate dateWithTimeIntervalSinceNow:TIME_SNOOZE];
        [self setupNotification];
        return;
    }
    self.nextAlarm = [NSDate dateWithTimeInterval:TIME_SNOOZE
                                        sinceDate:self.nextAlarm];
}

- (void)stopTimer {
    self.runningMode = RUNNING_MODE_STOPPED;
}

@end
