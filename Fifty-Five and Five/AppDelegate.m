//
//  AppDelegate.m
//  Fifty-Five and Five
//
//  Created by Joel Ray Holveck on 4/5/16.
//  Copyright © 2016 Joel Ray Holveck. All rights reserved.
//

#import "AppDelegate.h"
#import "TimerManager.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // FIXME If we're launching in response to a notification, handle it.
    // FIXME Manage badging for which phase we're in.
    // FIXME Handle actions.
    
    UIMutableUserNotificationAction * startNextTimerAction = [[UIMutableUserNotificationAction alloc] init];
    startNextTimerAction.identifier = @"startNextTimer";
    startNextTimerAction.title = NSLocalizedString(@"Next Timer", nil);
    startNextTimerAction.activationMode = UIUserNotificationActivationModeBackground;
    UIMutableUserNotificationAction * snoozeAction = [[UIMutableUserNotificationAction alloc] init];
    snoozeAction.identifier = @"snoozeTimer";
    snoozeAction.title = NSLocalizedString(@"Snooze", nil);
    snoozeAction.activationMode = UIUserNotificationActivationModeBackground;
    UIMutableUserNotificationAction * stopAction = [[UIMutableUserNotificationAction alloc] init];
    stopAction.identifier = @"stopTimer";
    stopAction.title = NSLocalizedString(@"Stop", nil);
    stopAction.destructive = YES;
    stopAction.activationMode = UIUserNotificationActivationModeBackground;
    
    UIMutableUserNotificationCategory * alarmCategory = [[UIMutableUserNotificationCategory alloc] init];
    alarmCategory.identifier = @"alarm";
    [alarmCategory setActions:@[stopAction, snoozeAction, startNextTimerAction] forContext:UIUserNotificationActionContextDefault];
    [alarmCategory setActions:@[snoozeAction, startNextTimerAction] forContext:UIUserNotificationActionContextMinimal];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:[NSSet setWithObject:alarmCategory]]];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[TimerManager sharedInstance] resignActive];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    // This is also where we prepare for the snapshot when we go to the background.  (Yes, here, not in applicationWillEnterBackground:, according to https://developer.apple.com/library/ios/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/StrategiesforHandlingAppStateTransitions/StrategiesforHandlingAppStateTransitions.html#//apple_ref/doc/uid/TP40007072-CH8-SW27 )
    [((ViewController*)[application.windows objectAtIndex:0].rootViewController) prepareForSnapshot];
    [[TimerManager sharedInstance] enterBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[TimerManager sharedInstance] enterForeground];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[TimerManager sharedInstance] becomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Notification management

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
    if ([identifier isEqualToString:@"startNextTimer"]) {
        [[TimerManager sharedInstance] startNextTimer];
    } else if ([identifier isEqualToString:@"snoozeTimer"]) {
        [[TimerManager sharedInstance] fiveMoreMinutes];
    } else if ([identifier isEqualToString:@"stopTimer"]) {
        [[TimerManager sharedInstance] stopTimer];
    }
    completionHandler();
}

@end
