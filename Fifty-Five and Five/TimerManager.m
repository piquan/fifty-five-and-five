//
//  TimerManager.m
//  Fifty-Five and Five
//
//  Created by Joel Ray Holveck on 4/5/16.
//  Copyright © 2016 Joel Ray Holveck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlarmSoundManager.h"
#import "AppDelegate.h"
#import "TimerManager.h"

@implementation TimerManager {
    NSDateComponentsFormatter * _Nonnull timerFormatter;
    UIAlertController * _Nullable presentingAlert;
}

static NSString * kTimers = @"timers";
static NSString * kRunningTimer = @"runningTimer";
static NSString * kNextAlarm = @"nextAlarm";
static NSString * kSnoozeInterval = @"snoozeInterval";

+ (NSString*)modelPath
{
    NSURL * applicationSupport = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory
                                                                        inDomain:NSUserDomainMask
                                                               appropriateForURL:nil
                                                                          create:YES
                                                                           error:nil];
    NSURL * url = [NSURL URLWithString:@"Timers.plist" relativeToURL:applicationSupport];
    return [url path];
}

+ (TimerManager*)sharedInstance
{
    static TimerManager * rv;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rv = nil;
#if TARGET_OS_SIMULATOR
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"resetDataStore"])
#endif
        {
            rv = [NSKeyedUnarchiver unarchiveObjectWithFile:[self modelPath]];
        }
        if (!rv)
            rv = [[TimerManager alloc] init];
    });
    return rv;
}

- (id)initWithTimers:(NSOrderedSet<Timer*> * _Nonnull)timers
        runningTimer:(Timer * _Nullable)runningTimer
           nextAlarm:(NSDate * _Nullable)nextAlarm
      snoozeInterval:(NSTimeInterval)snoozeInterval
{
    self = [super init];
    if (self) {
        
        // If you change this, consider changing the one in ViewController.
        timerFormatter = [[NSDateComponentsFormatter alloc] init];
        timerFormatter.unitsStyle = NSDateComponentsFormatterUnitsStylePositional;
        timerFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorDefault;
        
        _timers = [NSMutableOrderedSet orderedSetWithOrderedSet:timers];
        _snoozeInterval = snoozeInterval;
        _runningTimer = runningTimer;
        _nextAlarm = nextAlarm;
        [self updateColors];
        [self normalizeNextAlarm];
        
        [self setupNotifications];
    }
    return self;
}

- (id)init
{
    NSLog(@"Initializing data store");
    
#if TARGET_OS_SIMULATOR
    NSString *demoTimerSet = [[NSUserDefaults standardUserDefaults] stringForKey:@"demoTimerSet"];
    if ([demoTimerSet isEqualToString:@"intervalTraining"]) {
        Timer *run =    [[Timer alloc] initWithName:NSLocalizedString(@"Run", nil)
                                           interval:20];
        Timer *sprint = [[Timer alloc] initWithName:NSLocalizedString(@"Sprint", nil)
                                           interval:10];
        Timer *recover =[[Timer alloc] initWithName:NSLocalizedString(@"Recover", nil)
                                           interval:30];
        
        return [self initWithTimers:[NSOrderedSet orderedSetWithObjects:run, sprint, recover, nil]
                       runningTimer:nil
                          nextAlarm:nil
                     snoozeInterval:5 * 60];
        
    } else if ([demoTimerSet isEqualToString:@"shortWork"]) {
        Timer *timer55 = [[Timer alloc] initWithName:NSLocalizedString(@"Work", nil)
                                            interval:5];
        Timer *timer5 =  [[Timer alloc] initWithName:NSLocalizedString(@"Rest", nil)
                                            interval:5 * 60];
        
        return [self initWithTimers:[NSOrderedSet orderedSetWithObjects:timer55, timer5, nil]
                       runningTimer:nil
                          nextAlarm:nil
                     snoozeInterval:5 * 60];
        
    } else
#endif
    {
        Timer *timer55 = [[Timer alloc] initWithName:NSLocalizedString(@"Work", nil)
                                            interval:55 * 60];
        Timer *timer5 =  [[Timer alloc] initWithName:NSLocalizedString(@"Rest", nil)
                                            interval:5 * 60];
        
        return [self initWithTimers:[NSOrderedSet orderedSetWithObjects:timer55, timer5, nil]
                       runningTimer:nil
                          nextAlarm:nil
                     snoozeInterval:5 * 60];
    }
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (!self)
        return self;
    
    return [self initWithTimers:[decoder decodeObjectForKey:kTimers]
                   runningTimer:[decoder decodeObjectForKey:kRunningTimer]
                      nextAlarm:[decoder decodeObjectForKey:kNextAlarm]
                 snoozeInterval:[decoder decodeDoubleForKey:kSnoozeInterval]];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    // FIXME Looking at the plist is inscrutible.  This seems to work, but be sure about
    // boundary cases.
    [coder encodeObject:_timers forKey:kTimers];
    [coder encodeConditionalObject:_runningTimer forKey:kRunningTimer];
    [coder encodeObject:_nextAlarm forKey:kNextAlarm];
    [coder encodeDouble:_snoozeInterval forKey:kSnoozeInterval];
}

- (void)save {
    // FIXME Make this asynchronous
    BOOL success = [NSKeyedArchiver archiveRootObject:self toFile:[[self class] modelPath]];
    if (!success) {
        NSLog(@"State saving to %@ failed", [[self class] modelPath]);
    }
}

- (void)normalizeNextAlarm
{
    if (_nextAlarm) {
        NSDate * nextAlarm = _nextAlarm;
        Timer * runningTimer = _runningTimer;
        NSDate * now = [NSDate date];
        NSUInteger offset = 0;
        while ([nextAlarm compare:now] != NSOrderedDescending) {
            offset++;
            runningTimer = [self timerAtOffset:offset];
            nextAlarm = [nextAlarm dateByAddingTimeInterval:runningTimer.interval];
        }
        [self switchToTimer:runningTimer forAlarmTime:nextAlarm];
    }
}

- (void)updateColors
{
    // Original colors were #3e50b4 for work, #ff3f80 for rest, #795548 for stopped.
    // FIXME Improve the color selection algorithm to prefer that adjacent colors are far apart
    // in hue.
    NSUInteger timerCount = _timers.count + 1;
    NSUInteger timerCountDest = timerCount;
    NSUInteger timerCountRoundedUp = 1;
    NSUInteger timerBits = 0;
    while (timerCountDest) {
        timerBits++;
        timerCountDest >>= 1;
        timerCountRoundedUp <<= 1;
    }
    [_timers enumerateObjectsUsingBlock:^(Timer * _Nonnull timer, NSUInteger idx, BOOL * _Nonnull stop) {
        NSUInteger hueInt = 0;
        for (NSUInteger i = 0; i < timerBits; i++) {
            hueInt <<= 1;
            hueInt |= (idx & 1);
            idx >>= 1;
        }
        // The offset is to make the first few colors a little more aesthetically pleasing;
        // a 0.0 hue is red, which can be jarring.
        CGFloat hue = (((float)hueInt) / timerCountRoundedUp) + 0.8;
        if (hue > 1.0)
            hue -= 1.0;
        timer.color = [UIColor colorWithHue:hue saturation:1.0 brightness:0.667 alpha:1.0];
    }];
}

- (Timer *)newTimer
{
    Timer * newTimer = [[Timer alloc] initWithName:NSLocalizedString(@"New Timer", nil)
                                          interval:5 * 60];
    [[TimerManager sharedInstance].timers addObject:newTimer];
    [self updateColors];
    [self save];
    return newTimer;
}

- (NSString*)stringForTimerInterval:(Timer *)timer
{
    return [timerFormatter stringFromTimeInterval:timer.interval];
}

- (NSTimeInterval)timerIntervalForString:(NSString * _Nonnull)string
{
    static NSPredicate * stringIsEmpty;
    static NSCharacterSet * nonnumbers;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stringIsEmpty = [NSPredicate predicateWithFormat:@"SELF != ''"];
        NSRange numberRange;
        numberRange.location = '0';
        numberRange.length = 10;
        nonnumbers = [[NSCharacterSet characterSetWithRange:numberRange] invertedSet];
    });
    NSString * trimmed = [string stringByTrimmingCharactersInSet:nonnumbers];
    NSArray<NSString*>* components = [trimmed componentsSeparatedByCharactersInSet:nonnumbers];
    NSArray<NSString*>* contiguousComponents = [components filteredArrayUsingPredicate:stringIsEmpty];
    
    NSUInteger rv = 0;
    for (NSString* component in contiguousComponents) {
        rv = rv * 60 + [component integerValue];
    }
    return (NSTimeInterval)rv;
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

- (void)switchToTimer:(Timer * _Nullable)timer
         forAlarmTime:(NSDate * _Nullable)alarmTime
{
    // We do this here instead of in the view controller, since I'm not sure if the view controller can be freed while we're in the background.
    [[UIApplication sharedApplication] ignoreSnapshotOnNextApplicationLaunch];
    
    [self willChangeValueForKey:@"runningTimer"];
    [self willChangeValueForKey:@"nextAlarm"];
    _runningTimer = timer;
    _nextAlarm = alarmTime;
    [self didChangeValueForKey:@"nextAlarm"];
    [self didChangeValueForKey:@"runningTimer"];
    
    [self setupNotifications];
    [self save];
}

- (void)addInterval:(NSTimeInterval)interval
{
    [self willChangeValueForKey:@"nextAlarm"];
    _nextAlarm = [_nextAlarm dateByAddingTimeInterval:interval];
    [self didChangeValueForKey:@"nextAlarm"];

    [self setupNotifications];
    [self save];
}

- (void)switchToTimer:(Timer * _Nonnull)timer
          forInterval:(NSTimeInterval)interval
{
    [self switchToTimer:timer
           forAlarmTime:[NSDate dateWithTimeIntervalSinceNow:interval]];
}

- (void)switchToTimer:(Timer * _Nullable)timer
{
    if (timer) {
        [self switchToTimer:timer forInterval:timer.interval];
    } else {
        [self switchToTimer:timer forAlarmTime:nil];
    }
}

- (void)switchToNextTimerForInterval:(NSTimeInterval)interval
{
    [self switchToTimer:[self nextTimer] forInterval:interval];
}

- (void)switchToNextTimer
{
    [self switchToTimer:[self nextTimer]];
}

- (Timer * _Nonnull)nextTimer
{
    return [self timerAtOffset:1];
}

- (Timer * _Nonnull)timerAtOffset:(NSInteger)offset
{
    NSOrderedSet <Timer*> *timers = self.timers;
    if (!self.runningTimer)
        return [timers objectAtIndex:(offset - 1) % timers.count];
    NSUInteger idx = [self.timers indexOfObject:self.runningTimer];
    if (idx == NSNotFound)
        return [timers objectAtIndex:(offset - 1) % timers.count];
    NSUInteger newIdx = (idx + offset) % self.timers.count;
    return [timers objectAtIndex:newIdx];
}

#pragma mark - Notifications

- (void)setupNotifications
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    if (!self.runningTimer)
        return;
    NSDate * nextAlarm = self.nextAlarm;
    assert(nextAlarm);
    NSDate * now = [NSDate date];
    if ([now compare:nextAlarm] != NSOrderedAscending)
        return;
    
    // FIXME Arrange an NSTimer to preload the sound if we're in the foreground.

    NSUInteger totalTime = 0;
    for (Timer * timer in _timers) {
        totalTime += timer.interval;
    }
    NSCalendarUnit repeatInterval =
        totalTime == 60 ? NSCalendarUnitMinute :
        totalTime == 60 * 60 ? NSCalendarUnitHour :
        totalTime == 24 * 60 * 60 ? NSCalendarUnitDay:
        NSCalendarUnitEra;

    UILocalNotification * notificationTemplate = [[UILocalNotification alloc] init];
    notificationTemplate.category = @"alarm";
    notificationTemplate.soundName = [[[AlarmSoundManager sharedInstance] currentAlarm] filename];
    //notificationTemplate.alertAction = NSLocalizedString(@"View", nil);
    notificationTemplate.hasAction = NO;
    
    NSUInteger notificationCount;
    if (repeatInterval != NSCalendarUnitEra) {
        notificationTemplate.repeatInterval = repeatInterval;
        notificationCount = MIN(64, _timers.count);
    } else {
        notificationCount = 64;
    }
    
    NSDate * nextNotificationTime = nextAlarm;
    // We start with offset 1, since what we're getting is the "Time to Foo" message from
    // the timer after the one ringing, and adding the expiration time from that timer too.
    // We don't actually need anything from the timer at offset 0.
    for (int offset = 1; offset < notificationCount + 1; offset++) {
        UILocalNotification * notification = [notificationTemplate copy];
        notification.fireDate = nextNotificationTime;
        Timer * nextTimer = [self timerAtOffset:offset];
        notification.alertBody = [nextTimer callToAction];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        nextNotificationTime = [NSDate dateWithTimeInterval:nextTimer.interval sinceDate:nextNotificationTime];
        //NSLog(@"Scheduled notification %i: %@: %@", offset, nextTimer.name, notification);
    }
}

- (void)alarmFired
{
    AlarmSoundManager * sm = [AlarmSoundManager sharedInstance];
    [sm stopAll];
    [self switchToNextTimer];
    if (presentingAlert) {
        [presentingAlert.parentViewController dismissViewControllerAnimated:NO completion:nil];
    }
    
    NSString * appName = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:appName
                                                                   message:[self.runningTimer callToAction]
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    presentingAlert = alert;
    
    AlarmSound * alarm = [sm currentAlarm];
    UIAlertAction* stopAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Stop", nil)
                                                         style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [alarm stop];
                                                           presentingAlert = nil;
                                                           [self stopTimer];
                                                       }];
    [alert addAction:stopAction];
    UIAlertAction* snoozeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Snooze", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [alarm stop];
                                                             presentingAlert = nil;
                                                             [self snooze];
                                                         }];
    [alert addAction:snoozeAction];
    UIAlertAction* closeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Close", nil)
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
                                                            [alarm stop];
                                                            presentingAlert = nil;
                                                        }];
    [alert addAction:closeAction];

    AppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate.window.rootViewController presentViewController:alert
                                                        animated:YES
                                                      completion:^{
                                                          [alarm alarm];
                                                      }];
}

- (void)alarmAcknowledged
{
    [[AlarmSoundManager sharedInstance] stopAll];
}

#pragma mark - App state changes

- (void)resignActive
{
    [[AlarmSoundManager sharedInstance] stopAll];
}
- (void)becomeActive
{
    [self normalizeNextAlarm];
}
- (void)enterForeground
{
    [self normalizeNextAlarm];
    [[AlarmSoundManager sharedInstance] stopAll];
}
- (void)enterBackground
{
    [[AlarmSoundManager sharedInstance] stopAll];
}

#pragma mark - User inputs

- (void)startNextTimer
{
    [self switchToNextTimer];
}

- (void)snooze
{
    // By the time the user asks to snooze, we've already processed the timer advance.
    [[AlarmSoundManager sharedInstance] stopAll];
    [self switchToTimer:[self timerAtOffset:-1] forInterval:self.snoozeInterval];
}

- (void)fiveMoreMinutes
{
    if (!self.runningTimer) {
        [self switchToTimer:[self timerAtOffset:-1] forInterval:self.snoozeInterval];
        return;
    }
    [self addInterval:self.snoozeInterval];
}

- (void)stopTimer {
    [self switchToTimer:nil];
}

#pragma mark - UITableViewDataSource

- (Timer * _Nullable)timerForIndexPath:(NSIndexPath * _Nonnull)indexPath
{
    assert(indexPath.section == 0);
    if (indexPath.row == _timers.count)
        // This is the insert row
        return nil;
    else
        return [_timers objectAtIndex:indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.editing)
        return self.timers.count + 1;
    else
        return self.timers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Timer * timer = [self timerForIndexPath:indexPath];
    if (timer == nil) {
        return [tableView dequeueReusableCellWithIdentifier:@"timerInsert" forIndexPath:indexPath];
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timer" forIndexPath:indexPath];
    cell.textLabel.text = timer.name;
    cell.detailTextLabel.text = [timerFormatter stringFromTimeInterval:timer.interval];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL rv;
    if (_timers.count == 1 && indexPath.row == 0) {
        rv = NO;
    } else {
        rv = YES;
    }
    return rv;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.timers removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self save];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        // The settings controller should have handled this.
        abort();
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    [self.timers moveObjectsAtIndexes:[NSIndexSet indexSetWithIndex:fromIndexPath.row] toIndex:toIndexPath.row];
    [self save];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _timers.count)
        return NO;
    if (_timers.count == 1 && indexPath.row == 0)
        return NO;
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _timers.count)
        return UITableViewCellEditingStyleInsert;
    if (tableView.editing)
        return UITableViewCellEditingStyleDelete;
    return UITableViewCellEditingStyleNone;
}

- (NSIndexPath *)tableView:(UITableView *)tableView
targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath
                toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath

{
    assert(sourceIndexPath.section == 0);
    assert(proposedDestinationIndexPath.section == 0);
    if (proposedDestinationIndexPath.row >= _timers.count) {
        return [NSIndexPath indexPathForRow:_timers.count inSection:0];
    }
    return proposedDestinationIndexPath;
}

- (NSIndexPath *)highestMoveDestinationIndexPathForTableView:(UITableView *)tableView
{
    return [NSIndexPath indexPathForRow:_timers.count inSection:0];
}


@end
