//
//  TimerManager.h
//  Fifty-Five and Five
//
//  Created by Joel Ray Holveck on 4/5/16.
//  Copyright © 2016 Joel Ray Holveck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Timer.h"

@interface TimerManager : NSObject <NSCoding, UITableViewDataSource>

// FIXME Make timers non-mutable publicly, but mutable privately.
@property (readonly) NSMutableOrderedSet<Timer*> * _Nonnull timers;
@property (readonly) Timer * _Nullable runningTimer;
@property (readonly) NSDate * _Nullable nextAlarm;
@property (readonly) NSTimeInterval snoozeInterval;

+ (TimerManager * _Nonnull)sharedInstance;
- (void)save;

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

- (Timer * _Nullable)timerForIndexPath:(NSIndexPath * _Nonnull)indexPath;
- (NSString * _Nonnull)stringForTimerInterval:(Timer * _Nonnull)timer;

// These are usually implemented as part of UITableViewDelegate, but SettingsController will
// defer them to us just like it does the UITableViewDataSource methods.
- (UITableViewCellEditingStyle)tableView:(UITableView * _Nonnull)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath * _Nonnull)indexPath;
- (NSIndexPath * _Nonnull)tableView:(UITableView * _Nonnull)tableView
targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath * _Nonnull)sourceIndexPath
       toProposedIndexPath:(NSIndexPath * _Nonnull)proposedDestinationIndexPath;
- (NSIndexPath * _Nonnull)highestMoveDestinationIndexPathForTableView:(UITableView * _Nonnull)tableView;

@end
