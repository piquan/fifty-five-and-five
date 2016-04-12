//
//  SettingsController.m
//  Fifty-Five and Five
//
//  Created by Joel Ray Holveck on 4/11/16.
//  Copyright © 2016 Joel Ray Holveck. All rights reserved.
//

#import "SettingsController.h"
#import "SettingsTimerEditController.h"
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
    return [[TimerManager sharedInstance] numberOfSectionsInTableView:tableView] + 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return [[TimerManager sharedInstance] tableView:tableView numberOfRowsInSection:section];
    abort();
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        return [[TimerManager sharedInstance] tableView:tableView cellForRowAtIndexPath:indexPath];
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
    if (indexPath.section == 0) {
        [[TimerManager sharedInstance] tableView:tableView
                              commitEditingStyle:editingStyle
                               forRowAtIndexPath:indexPath];
        return;
    }
    abort();
#if 0
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
#endif
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
    // Invoke the superclass first, since we'll
    [super setEditing:editing animated:animated];
    
    NSLog(@"editing: %i; wasEditing: %i; now editing: %i; row count: %li timer count: %lu",
          editing, wasEditing, self.tableView.editing,
          (long)[self.tableView numberOfRowsInSection:0], (unsigned long)[TimerManager sharedInstance].timers.count);
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

- (IBAction)addTimer:(id)sender
{
    Timer * newTimer = [[Timer alloc] initWithName:NSLocalizedString(@"New Timer", nil)
                                          interval:5 * 60];
    [[TimerManager sharedInstance].timers addObject:newTimer];
    selectedTimer = newTimer;
    [self performSegueWithIdentifier:@"editTimer" sender:self];
}

@end
