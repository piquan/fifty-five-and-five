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

    self.timePicker.delegate = self;
    self.timePicker.dataSource = self;
    
    self.intervalField.text = [[TimerManager sharedInstance] stringForTimerInterval:_timer];
    self.intervalField.inputView = self.timePicker;
    self.intervalField.inputAccessoryView = self.timePickerAccessoryView;
    
    [self updateTimePickerAnimated:NO];
    
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
    NSLog(@"Set name to %@", self.nameField.text);
    self.timer.name = self.nameField.text;
}

- (IBAction)nameFieldDone:(id)sender
{
    [[TimerManager sharedInstance] save];
}

- (IBAction)intervalFieldChanged:(id)sender
{
    // FIXME This could be done better, but it's not like entering times with a keyboard
    // is likely to be a common thing here.
    _timer.interval = [[TimerManager sharedInstance] timerIntervalForString:_intervalField.text];
    if (_timer.interval == 0)
        _timer.interval = 60;
    NSLog(@"Set interval to %f", _timer.interval);
    [self updateTimePickerAnimated:YES];
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

#pragma mark - UIPickerViewDataSource, UIPickerViewDelegate

- (void)updateTimePickerAnimated:(BOOL)animated
{
    NSUInteger interval = _timer.interval;
    [_timePicker selectRow:interval / 3600 inComponent:0 animated:animated];
    [_timePicker selectRow:(interval / 60) % 60 inComponent:2 animated:animated];
    [_timePicker selectRow:interval % 60 inComponent:4 animated:animated];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 6;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return (component == 1 || component == 3 || component == 5 ? 1 :
            component == 0 ? 24 :
            60);
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    if (component == 1)
        return NSLocalizedString(@"hr", nil);
    else if (component == 3)
        return NSLocalizedString(@"min", nil);
    else if (component == 5)
        return NSLocalizedString(@"sec", nil);
    else
        return [NSString stringWithFormat:@"%li", (long)row];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
    _timer.interval = ([pickerView selectedRowInComponent:0] * 3600 +
                       [pickerView selectedRowInComponent:2] * 60 +
                       [pickerView selectedRowInComponent:4]);
    if (_timer.interval == 0) {
        NSLog(@"Avoiding a 0-length selected timer");
        _timer.interval = 60;
        [pickerView selectRow:1 inComponent:2 animated:YES];
    }
    self.intervalField.text = [[TimerManager sharedInstance] stringForTimerInterval:_timer];
    NSLog(@"Set interval to %f, text %@", _timer.interval, self.intervalField.text);
}

@end
