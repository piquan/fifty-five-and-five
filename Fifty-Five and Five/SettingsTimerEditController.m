//
//  SettingsTimerEditController.m
//  Fifty-Five and Five
//
//  Created by Joel Ray Holveck on 4/11/16.
//  Copyright © 2016 Joel Ray Holveck. All rights reserved.
//

#import "SettingsTimerEditController.h"
#import "TimerManager.h"
#import "SettingsController.h"

@interface SettingsTimerEditController ()

@end

@implementation SettingsTimerEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nameField.text = self.timer.name;
    self.datePicker.countDownDuration = self.timer.interval;
    self.intervalField.text = [[TimerManager sharedInstance] stringForTimerInterval:_timer];

    self.intervalField.inputView = self.datePicker;
    self.intervalField.inputAccessoryView = self.datePickerAccessoryView;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)nameFieldChanged:(id)sender
{
    NSLog(@"Name field: %@", self.nameField.text);
    self.timer.name = self.nameField.text;
}

- (IBAction)nameFieldDone:(id)sender
{
    [[TimerManager sharedInstance] save];
}

- (IBAction)intervalFieldChanged:(id)sender
{
    // TODO This should also work with a hardware keyboard.
    _timer.interval = self.datePicker.countDownDuration;
    self.intervalField.text = [[TimerManager sharedInstance] stringForTimerInterval:_timer];
    NSLog(@"Now at interval %f text %@", _timer.interval, self.intervalField.text);
}

- (IBAction)intervalFieldDone:(id)sender
{
    [self.intervalField resignFirstResponder];
    [[TimerManager sharedInstance] save];
}

#pragma mark - Navigation

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // This save shouldn't be necessary.
    [[TimerManager sharedInstance] save];
}

@end
