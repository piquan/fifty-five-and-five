//
//  ViewController.m
//  Fifty-Five and Five
//
//  Created by Joel Ray Holveck on 4/5/16.
//  Copyright © 2016 Joel Ray Holveck. All rights reserved.
//

#import "ViewController.h"
#import "TimerManager.h"

@interface ViewController ()

@property NSTimer * refreshTimer;
@property NSDateComponentsFormatter * timerFormatter;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _refreshTimer = nil;
    // If you change this, it may be worth changing the one in TimerManager.
    //
    // It may be worth noting that the _timerFormatter is not quite consistent in handling single digits.
    // If it's previously written "1:00" (or similar), it will keep using two-digit seconds even <10.
    // But until then, it will use single digits for seconds <10.
    _timerFormatter = [[NSDateComponentsFormatter alloc] init];
    _timerFormatter.unitsStyle = NSDateComponentsFormatterUnitsStylePositional;
    _timerFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorDefault;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(prepareForSnapshot:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[TimerManager sharedInstance] addObserver:self
                                    forKeyPath:@"runningTimer"
                                       options:NSKeyValueObservingOptionNew
                                       context:nil];
    [[TimerManager sharedInstance] addObserver:self
                                    forKeyPath:@"nextAlarm"
                                       options:NSKeyValueObservingOptionNew
                                       context:nil];
    [self updateRunningTimer];
    [self updateTimerDisplay];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"runningTimer"])
        [self updateRunningTimer];
    else if ([keyPath isEqualToString:@"nextAlarm"])
        [self updateRefreshTimer];
    else
        abort();
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateRefreshTimer];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (_refreshTimer) {
        [_refreshTimer invalidate];
        self.refreshTimer = nil;
    }
    [super viewDidDisappear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)prepareForSnapshot:(NSNotification *)notification
{
    // This is also where we prepare for the snapshot when we go to the background.  (Yes, here, not in applicationWillEnterBackground:, according to https://developer.apple.com/library/ios/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/StrategiesforHandlingAppStateTransitions/StrategiesforHandlingAppStateTransitions.html#//apple_ref/doc/uid/TP40007072-CH8-SW27 )
    self.timeRemainingLabel.text = @"";
    [self.view snapshotViewAfterScreenUpdates:YES];
}

- (IBAction)startNextTimer:(id)sender
{
    [[TimerManager sharedInstance] startNextTimer];
}
- (IBAction)fiveMoreMinutes:(id)sender
{
    [[TimerManager sharedInstance] fiveMoreMinutes];
}
- (IBAction)stopTimer:(id)sender
{
    TimerManager *tm = [TimerManager sharedInstance];
    if (tm.runningTimer)
        [tm stopTimer];
    else
        [tm startNextTimer];
}

- (void)updateRunningTimer
{
    Timer * timer = [TimerManager sharedInstance].runningTimer;
    NSLog(@"Updating screen for %@", timer.name);
    UIColor * color;
    if (timer) {
        self.whichTimerLabel.text = [[timer name] capitalizedStringWithLocale:[NSLocale currentLocale]];
        color = [timer color];
        [_stopButton setTitle:NSLocalizedString(@"Stop", nil) forState:UIControlStateNormal];
        _continueButton.enabled = YES;
        [_continueButton setTitle:[[TimerManager sharedInstance] nextTimer].name forState:UIControlStateNormal];
        _snoozeButton.enabled = YES;
    } else {
        self.whichTimerLabel.text = NSLocalizedString(@"Stopped", nil);
        color = [UIColor darkGrayColor];
        [_stopButton setTitle:NSLocalizedString(@"Start", nil) forState:UIControlStateNormal];
        _continueButton.enabled = NO;
        _snoozeButton.enabled = NO;
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.coloringView.backgroundColor = color;
    }];
}

- (void)updateRefreshTimer
{
    [self updateTimerDisplay];
    if (_refreshTimer) {
        [_refreshTimer invalidate];
        self.refreshTimer = nil;
    }
    NSDate * nextAlarm = [TimerManager sharedInstance].nextAlarm;
    if (nextAlarm == nil) {
        return;
    }
    // We use the current time twice, and want to make sure it's the same now.
    NSDate * now = [NSDate date];
    NSTimeInterval timeRemaining = [nextAlarm timeIntervalSinceDate:now];
    if (timeRemaining < 0) {
        return;
    }
    NSTimeInterval nextSecondChangeDelay = timeRemaining - floor(timeRemaining);
    self.refreshTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeInterval:nextSecondChangeDelay
                                                                             sinceDate:now]
                                                 interval:1
                                                   target:self
                                                 selector:@selector(refreshTimerFired:)
                                                 userInfo:nil
                                                  repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.refreshTimer
                                 forMode:NSDefaultRunLoopMode];
}

- (void)refreshTimerFired:(NSTimer * _Nonnull)timer
{
    [self updateTimerDisplay];
}

- (void)updateTimerDisplay
{
    self.timeRemainingLabel.text = [self timerString];
}

- (NSString * _Nonnull)timerString
{
    NSDate * nextAlarm = [TimerManager sharedInstance].nextAlarm;
    if (!nextAlarm) {
        return @"";
    }
    
    NSTimeInterval timeRemaining = [nextAlarm timeIntervalSinceNow];
    if (timeRemaining < 0) {
        timeRemaining = 0;
    }
    // We round tenths of a second up, since odds are we didn't get called exactly at the refresh time.
    timeRemaining += 0.1;
    return [self.timerFormatter stringFromTimeInterval:timeRemaining];
}

#pragma mark - Navigation

- (IBAction)doneWithSettings:(UIStoryboardSegue*)unwindSegue
{
    // This method intentionally left blank.
}

@end
