//
//  WorkTimeManager.h
//  WorkTimeRecord
//
//  Created by mookyung song on 8/19/15.
//  Copyright (c) 2015 moono. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WorkTimeManager : NSObject

+ (WorkTimeManager *)defaultInstance;

// methods

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
