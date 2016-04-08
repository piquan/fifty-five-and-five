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
@property UIColor * stoppedColor;
@property UIColor * fiftyFiveColor;
@property UIColor * fiveColor;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _refreshTimer = nil;
    _timerFormatter = [[NSDateComponentsFormatter alloc] init];
    _timerFormatter.unitsStyle = NSDateComponentsFormatterUnitsStylePositional;
    _timerFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorDefault;
    _stoppedColor = [UIColor colorWithRed:.475 green:.333 blue:.282 alpha:1.0]; // #795548
    _fiftyFiveColor = [UIColor colorWithRed:.243 green:.314 blue:.706 alpha:1.0]; // #3e50b4
    _fiveColor = [UIColor colorWithRed:1.0 green:.247 blue:.502 alpha:1.0]; // #ff3f80
    
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

- (void)prepareForSnapshot
{
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
    [[TimerManager sharedInstance] stopTimer];
}

- (void)updateRunningMode
{
    enum RunningMode mode = [TimerManager sharedInstance].runningMode;
    NSString * modeString;
    UIColor * runningColor;
    if (mode == RUNNING_MODE_STOPPED) {
        modeString = NSLocalizedString(@"Stopped", nil);
        runningColor = _stoppedColor;
    } else if (mode == RUNNING_MODE_55) {
        modeString = NSLocalizedString(@"Working", nil);
        runningColor = _fiftyFiveColor;
    } else if (mode == RUNNING_MODE_5) {
        modeString = NSLocalizedString(@"Resting", nil);
        runningColor = _fiveColor;
    }
    self.whichTimerLabel.text = modeString;
    self.coloringView.backgroundColor = runningColor;
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
    return [self.timerFormatter stringFromTimeInterval:timeRemaining];
}

@end
