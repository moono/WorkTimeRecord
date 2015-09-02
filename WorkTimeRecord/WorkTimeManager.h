//
//  WorkTimeManager.h
//  WorkTimeRecord
//
//  Created by mookyung song on 8/19/15.
//  Copyright (c) 2015 moono. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// define the keys for dictionary
#define kDate @"date"           // NSString from NSDate
#define kStart @"start"         // NSString from NSDate
#define kEnd @"end"             // NSString from NSDate
#define kList @"list"           // NSString from NSDate
#define kIn @"in"				// NSString from NSDate
#define kOut @"out"				// NSString from NSDate
#define kDuration @"duration"	// integer

@interface WorkTimeManager : NSObject

#pragma mark - properties
// flag to indicate whether the user is inside the building or not
@property (nonatomic) BOOL isInsideBuilding;

// for managing time
@property (nonatomic, strong) NSDateFormatter *dateTimeFormatter;   // represents date & time format
@property (nonatomic, strong) NSDateFormatter *dateFormatter;       // represents date format
@property (nonatomic, strong) NSDateFormatter *timeFormatter;       // represents time format

#pragma mark - class methods
// returns singleton
+ (WorkTimeManager *)defaultInstance;


#pragma mark - instance methods

// add time stamp
- (void)addTimeStamp:(NSDate *)time;

// backup
- (void)saveAsFile;

// dummy method
- (void)createInstance;

// accessor
- (NSArray *)getTimeList:(NSDate *)today;

// UI related
- (void)setSwitch:(UISwitch *)mySwitch andLabel:(UILabel *)label;

@end
