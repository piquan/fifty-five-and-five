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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _refreshTimer = nil;
    
    [[TimerManager sharedInstance] addObserver:self
                                    forKeyPath:@"runningMode"
                                       options:NSKeyValueObservingOptionNew
                                       context:nil];
    [[TimerManager sharedInstance] addObserver:self
                                    forKeyPath:@"nextAlarm"
                                       options:NSKeyValueObservingOptionNew
                                       context:nil];
    [self updateRunningMode];
    [self updateTimerDisplay];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"runningMode"])
        [self updateRunningMode];
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
    [[TimerManager sharedInstance] stopTimer];
}

- (void)updateRunningMode
{
    enum RunningMode mode = [TimerManager sharedInstance].runningMode;
    NSString * modeString;
    if (mode == RUNNING_MODE_STOPPED) {
        modeString = NSLocalizedString(@"Stopped", nil);
    } else if (mode == RUNNING_MODE_55) {
        modeString = NSLocalizedString(@"Working", nil);
    } else if (mode == RUNNING_MODE_5) {
        modeString = NSLocalizedString(@"Resting", nil);
    }
    self.whichTimerLabel.text = modeString;
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
    // FIXME Is there anything locale-specific I should do here instead?
    if (timeRemaining < 0) {
        return @"0:00";
    } else {
        return [NSString stringWithFormat:@"%i:%02i", ((int)timeRemaining / 60), ((int)timeRemaining % 60)];
    }
}

@end
