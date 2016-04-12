//
//  ViewController.h
//  Fifty-Five and Five
//
//  Created by Joel Ray Holveck on 4/5/16.
//  Copyright © 2016 Joel Ray Holveck. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView * coloringView;
@property (weak, nonatomic) IBOutlet UILabel * whichTimerLabel;
@property (weak, nonatomic) IBOutlet UILabel * timeRemainingLabel;

- (IBAction)startNextTimer:(id)sender;
- (IBAction)fiveMoreMinutes:(id)sender;
- (IBAction)stopTimer:(id)sender;

- (IBAction)doneWithSettings:(UIStoryboardSegue*)unwindSegue;

@end

