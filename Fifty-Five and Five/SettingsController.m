//
//  SettingsController.m
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

#import "SettingsController.h"
#import "SettingsTimerEditController.h"
#import "AlarmSoundManager.h"
#import "TimerManager.h"

@interface SettingsController ()

@end

@implementation SettingsController {
    Timer * selectedTimer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[TimerManager sharedInstance] numberOfSectionsInTableView:tableView] + 2;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0: return NSLocalizedString(@"Timers", nil);
        case 1: return NSLocalizedString(@"Alert Sound", nil);
        case 2: return nil;
        default: abort();
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 2)
        return NSLocalizedString(@"Fifty-Five and Five is Copyright \u00a9 2016 Joel Ray Holveck.  It comes with ABSOLUTELY NO WARRANTY.  The source code is available as free software, so you can modify and improve it.  See http://fifty-five-and-five.piquan.org/ for full details.", nil);
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return [[TimerManager sharedInstance] tableView:tableView numberOfRowsInSection:section];
        case 1: return 2;
        case 2: return 0;
        default: abort();
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [[TimerManager sharedInstance] tableView:tableView cellForRowAtIndexPath:indexPath];
    } else if (indexPath.section == 1) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"sound" forIndexPath:indexPath];
        AlarmSoundManager *sm = [AlarmSoundManager sharedInstance];
        cell.textLabel.text = [sm.alarmSounds objectAtIndex:indexPath.row].localizedName;
        if ([AlarmSoundManager sharedInstance].currentAlarmSoundIdx == indexPath.row) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        return cell;
    }
    abort();
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        return [[TimerManager sharedInstance] tableView:tableView canEditRowAtIndexPath:indexPath];
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        [self addTimer:tableView];
        return;
    } else if (indexPath.section == 0) {
        [[TimerManager sharedInstance] tableView:tableView
                              commitEditingStyle:editingStyle
                               forRowAtIndexPath:indexPath];
        return;
    } else {
        abort();
    }
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    if (fromIndexPath.section == 0 && toIndexPath.section == 0) {
        [[TimerManager sharedInstance] tableView:tableView moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
        return;
    }
    abort();
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        return [[TimerManager sharedInstance] tableView:tableView canMoveRowAtIndexPath:indexPath];
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}

// Note that this method is part of UITableViewDelegate, not UITableViewDataSource, but
// we treat it like we do our data source methods anyway.
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [[TimerManager sharedInstance] tableView:tableView editingStyleForRowAtIndexPath:indexPath];
    }
    return UITableViewCellEditingStyleNone;
}

- (NSIndexPath *)tableView:(UITableView *)tableView
targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath
       toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (sourceIndexPath.section == 0 && proposedDestinationIndexPath.section == 0) {
        return [[TimerManager sharedInstance] tableView:tableView
               targetIndexPathForMoveFromRowAtIndexPath:sourceIndexPath
                                    toProposedIndexPath:proposedDestinationIndexPath];
    }
    if (sourceIndexPath.section == 0) {
        return [[TimerManager sharedInstance] highestMoveDestinationIndexPathForTableView:tableView];
    }
    abort();
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    BOOL wasEditing = self.tableView.editing;
    // Invoke the superclass first, since we'll be changing the row count, and if we do that before setting
    // the edited attribute then the tableView will throw an exception about a mismatch in the number of
    // rows in the table.
    [super setEditing:editing animated:animated];
    
    if (editing && !wasEditing) {
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[TimerManager sharedInstance].timers.count
                                                                    inSection:0]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    } else if (!editing && wasEditing) {
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[TimerManager sharedInstance].timers.count
                                                                    inSection:0]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}

#pragma mark - Navigation

- (NSIndexPath *)tableView:(UITableView *)tableView
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        selectedTimer = [[TimerManager sharedInstance] timerForIndexPath:indexPath];
        if (selectedTimer)
            return indexPath;
        else
            return nil;
    } else if (indexPath.section == 1) {
        AlarmSoundManager * alarmMgr = [AlarmSoundManager sharedInstance];
        UITableViewCell * oldCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:alarmMgr.currentAlarmSoundIdx inSection:1]];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        [alarmMgr stopAll];
        alarmMgr.currentAlarmSoundIdx = indexPath.row;
        [alarmMgr.currentAlarm play];
        UITableViewCell * newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        return indexPath;
    }
    return nil;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[SettingsTimerEditController class]]) {
        ((SettingsTimerEditController*)segue.destinationViewController).timer = selectedTimer;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // This is to make sure we've got current data when we're rewinding from editing a timer.
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[AlarmSoundManager sharedInstance] stopAll];
    [super viewWillDisappear:animated];
}

- (IBAction)addTimer:(id)sender
{
    Timer * newTimer = [[Timer alloc] initWithName:NSLocalizedString(@"New Timer", nil)
                                          interval:5 * 60];
    [[TimerManager sharedInstance].timers addObject:newTimer];
    [[TimerManager sharedInstance] updateColors];
    selectedTimer = newTimer;
    [self performSegueWithIdentifier:@"editTimer" sender:self];
}

@end
