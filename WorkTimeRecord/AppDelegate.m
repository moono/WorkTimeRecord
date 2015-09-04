//
//  AppDelegate.m
//  WorkTimeRecord
//
//  Created by mookyung song on 8/19/15.
//  Copyright (c) 2015 moono. All rights reserved.
//

#import "AppDelegate.h"

// import estimote SDK
#import <EstimoteSDK/EstimoteSDK.h>

// import my headers
#import "WorkTimeManager.h"

@interface AppDelegate () <ESTBeaconManagerDelegate>

// add property to hold the beacon manager
@property (nonatomic) ESTBeaconManager *beaconManager;


@end

@implementation AppDelegate


#pragma  mark - ESTBeaconManager protocols
- (void)beaconManager:(id)manager didEnterRegion:(CLBeaconRegion *)region {
    // show notification to user
    UILocalNotification *notification = [UILocalNotification new];
    notification.alertBody = @"You're entering the beacon region!!";
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    
    // save current status
    WorkTimeManager *workManager = [WorkTimeManager defaultInstance];
	//[workManager setIsInsideBuilding:![workManager isInsideBuilding]];
    BOOL isAppropriate = [workManager addTimeStamp:[NSDate date]];
    if (isAppropriate == FALSE) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Something Wrong!!" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)beaconManager:(id)manager didExitRegion:(CLBeaconRegion *)region {
    UILocalNotification *notification = [UILocalNotification new];
    notification.alertBody = @"You're leaving the beacon region!!";
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

#pragma mark - AppDelegate protocols
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // set EST beacon manager
    _beaconManager = [ESTBeaconManager new];
    _beaconManager.delegate = self;
    
    // request aurthorization
    [_beaconManager requestAlwaysAuthorization];    // authorization granted even if the app is not running
    
    // set beacon id for region monitoring
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    CLBeaconMajorValue majorVal = 300;
    CLBeaconMinorValue minorVal = 444;
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:majorVal minor:minorVal identifier:@"work gate region"];
    [_beaconManager startMonitoringForRegion:beaconRegion];
    
    // register notification
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:nil]];
    
    // create or load WorkTimeManager
    WorkTimeManager *workManager = [WorkTimeManager defaultInstance];
    [workManager loadData];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    // backup
    WorkTimeManager *workManager = [WorkTimeManager defaultInstance];
    [workManager saveAsFile];
}

@end
