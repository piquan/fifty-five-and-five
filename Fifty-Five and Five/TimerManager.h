//
//  TimerManager.h
//  Fifty-Five and Five
//
//  Created by Joel Ray Holveck on 4/5/16.
//  Copyright © 2016 Joel Ray Holveck. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimerManager : NSObject

enum RunningMode {
    RUNNING_MODE_STOPPED,
    RUNNING_MODE_55,
    RUNNING_MODE_5
};

@property enum RunningMode runningMode;
@property NSDate * _Nullable nextAlarm;

+ (TimerManager * _Nonnull)sharedInstance;

- (void)resignActive;
- (void)becomeActive;
- (void)enterForeground;
- (void)enterBackground;

- (void)startNextTimer;
- (void)fiveMoreMinutes;
- (void)stopTimer;

@end
