//
//  WorkTimeManager.h
//  WorkTimeRecord
//
//  Created by mookyung song on 8/19/15.
//  Copyright (c) 2015 moono. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WorkTimeManager : NSObject

#pragma mark - properties
// flag to indicate whether the user is inside the building or not
@property (nonatomic) BOOL isInsideBuilding;


#pragma mark - class methods
// returns singleton
+ (WorkTimeManager *)defaultInstance;


#pragma mark - instance methods

// enter & exit setter
- (void)addEntranceTime:(NSDate *)entranceTime;
- (void)addExitTime:(NSDate *)exitTime;

// backup
- (void)saveAsFile;

// dummy method
- (void)createInstance;

// accessor
- (NSArray *)getTodaysList:(NSDate *)today;

@end
