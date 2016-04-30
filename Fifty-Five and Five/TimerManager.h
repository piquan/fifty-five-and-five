//
//  TimerManager.h
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

- (Timer * _Nonnull)nextTimer;
- (void)updateColors; // FIXME This shouldn't be called; it should be updated automatically with KVO.

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
- (NSTimeInterval)timerIntervalForString:(NSString * _Nonnull)string;

// These are usually implemented as part of UITableViewDelegate, but SettingsController will
// defer them to us just like it does the UITableViewDataSource methods.
- (UITableViewCellEditingStyle)tableView:(UITableView * _Nonnull)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath * _Nonnull)indexPath;
- (NSIndexPath * _Nonnull)tableView:(UITableView * _Nonnull)tableView
targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath * _Nonnull)sourceIndexPath
       toProposedIndexPath:(NSIndexPath * _Nonnull)proposedDestinationIndexPath;
- (NSIndexPath * _Nonnull)highestMoveDestinationIndexPathForTableView:(UITableView * _Nonnull)tableView;

@end
