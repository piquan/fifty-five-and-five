//
//  TimerManager.h
//  Fifty-Five and Five
//
//  Created by Joel Ray Holveck on 4/5/16.
//  Copyright © 2016 Joel Ray Holveck. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimerManager : NSObject

enum RunningTimer {
    TIMER_STOPPED,
    TIMER_55,
    TIMER_5
};

@property (readonly) enum RunningTimer runningTimer;
@property (readonly) NSDate * _Nullable nextAlarm;

+ (TimerManager * _Nonnull)sharedInstance;

- (void)resignActive;
- (void)becomeActive;
- (void)enterForeground;
- (void)enterBackground;

- (void)alarmFired;
- (void)alarmAcknowledged;

- (void)startNextTimer;
- (void)snooze;
- (void)fiveMoreMinutes;
- (void)stopTimer;

@end
