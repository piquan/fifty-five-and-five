//
//  Fifty_Five_and_Five_Snapshots.m
//  Fifty-Five and Five Snapshots
//
//  Created by Joel Ray Holveck on 4/16/16.
//  Copyright © 2016 Joel Ray Holveck. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Fifty-Five and Five Snapshots-Bridging-Header.h"
//#import "Fifty_Five_and_Five_Snapshots-Swift.h"

@interface Fifty_Five_and_Five_Snapshots : XCTestCase

@end

@implementation Fifty_Five_and_Five_Snapshots

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    XCUIApplication *app = [[XCUIApplication alloc] init];
    //[Snapshot setupSnapshot:app];
    [app launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    
    XCUIElement *notificationAlert = app.alerts[@"\u201cFifty-Five and Five\u201d Would Like to Send You Notifications"];
    if ([notificationAlert exists]) {
        [notificationAlert.collectionViews.buttons[@"OK"] tap];
    }
    
    sleep(3);
    
    [app.buttons[@"Start"] tap];
    sleep(1);
    
    if ([app.buttons[@"Sprint"] exists]) {
        [app.buttons[@"Stop"] tap];
        [app.buttons[@"More Info"] tap];
        //[Snapshot snapshot:@"02IntervalTrainingTimerList" waitForLoadingIndicator:YES];
        return;
    }
    
    [app.buttons[@"Rest"] tap];
    sleep(5);
    //[Snapshot snapshot:@"01LaunchScreen" waitForLoadingIndicator:YES];
    [app.buttons[@"Stop"] tap];
    
}

@end
