//
//  SettingsTimerEditController.h
//  Fifty-Five and Five
//
//  Created by Joel Ray Holveck on 4/11/16.
//  Copyright © 2016 Joel Ray Holveck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Timer.h"

@interface SettingsTimerEditController : UITableViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property IBOutlet UITextField * nameField;
@property IBOutlet UITextField * intervalField;
@property IBOutlet UIPickerView * timePicker;
@property IBOutlet UIToolbar * timePickerAccessoryView;

@property Timer * timer;

- (IBAction)nameFieldDone:(id)sender;
- (IBAction)intervalFieldChanged:(id)sender;
- (IBAction)intervalFieldDone:(id)sender;

@end
