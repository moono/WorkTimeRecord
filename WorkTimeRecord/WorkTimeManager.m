//
//  WorkTimeManager.m
//  WorkTimeRecord
//
//  Created by mookyung song on 8/19/15.
//  Copyright (c) 2015 moono. All rights reserved.
//

#import "WorkTimeManager.h"

@interface WorkTimeManager ()

// file name to backup the data
@property (nonatomic, strong) NSString *historyFileName;

// stores date(time) of previously entered the monitoring region
@property (nonatomic, strong) NSDate *lastInDate;

@end

@implementation WorkTimeManager

#pragma mark - class initializer
+ (WorkTimeManager *)defaultInstance {
    static WorkTimeManager *singleton = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^
                  {
                      singleton = [[WorkTimeManager alloc] init];
                  });
    
    return singleton;
}

- (instancetype)init {
    self = [super init];
	
	// set initial state
	_isInsideBuilding = NO;
	
    // set date formatters
    _dateTimeFormatter = [NSDateFormatter new];
    [_dateTimeFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm:ss"];
    //[_dateTimeFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"yyyy-MM-dd"];
    _timeFormatter = [[NSDateFormatter alloc] init];
    [_timeFormatter setDateFormat:@"HH:mm:ss"];
    
    // get the documents directory
    NSString *currentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    // set file name
    _historyFileName = [currentDirectory stringByAppendingPathComponent:@"time_history.json"];
    
    // set last In date
    _lastInDate = nil;
    
    // load data from file if exists
	// or create new NSMutableArray instance
    [self loadData];
    
    return self;
}

- (void)createInstance {
    // do nothing
}

#pragma mark - time management inputs
- (BOOL)addTimeStamp:(NSDate *)time {
    _isInsideBuilding = !_isInsideBuilding;
    
    // find today's dictionary
    NSArray *currentDayArray = [self getTodaysInformation:time];
    
    // check error state
    if ([currentDayArray count] == 0 && _isInsideBuilding == NO) {
        return FALSE;
    }
    // check if there are no information about today...
    else if ([currentDayArray count] == 0 && _isInsideBuilding == YES) {
        // create 00:00:00 date component
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *startComponents = [calendar components:(NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitYear|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond) fromDate:time];
        [startComponents setHour: 00];
        [startComponents setMinute: 00];
        [startComponents setSecond: 00];
        
        // add new one
        [_history addObject: @{ kDate : [_dateTimeFormatter stringFromDate:[calendar dateFromComponents:startComponents]],
                                kStart : [_dateTimeFormatter stringFromDate:time],
                                kEnd : @"",
                                kList : [[NSMutableArray alloc] init] }];
        
        return TRUE;
    }
    
    // grap appropriate dictionary item
    // getTodaysInformation method only returns size 1 array of NSDictionary if found
    NSDictionary *correspondingItem = [currentDayArray firstObject];
    
    // going out from work place
	if (_isInsideBuilding == NO) {
		_lastInDate = time;
        
        // replace end time
        NSInteger index = [_history indexOfObject:correspondingItem];
        if (index != NSNotFound) {
            NSMutableDictionary *todaysItem = [NSMutableDictionary dictionaryWithDictionary:correspondingItem];
            [todaysItem setObject:[_dateTimeFormatter stringFromDate:time] forKey:kEnd];
            [_history replaceObjectAtIndex:index withObject:todaysItem];
        }
	}
    // cominig in to work place
	else {
		if (_lastInDate == nil) {
            NSLog(@"Unexpected control...");
		}
        else {
            NSMutableArray *listArray = correspondingItem[kList];
            
            // compute time difference between enter & exit
            double timeInterval = [time timeIntervalSinceDate:_lastInDate];
            int rounded = (int)round(timeInterval);
            
            // save
            [listArray addObject:@{kIn : [_dateTimeFormatter stringFromDate:_lastInDate],
                                   kOut : [_dateTimeFormatter stringFromDate:time],
                                   kDuration : [NSNumber numberWithDouble:rounded]}];
            
            // set last In time as nil
            _lastInDate = nil;
        }
	}
	
    NSLog(@"%@", _history);
    
    return TRUE;
}

#pragma mark - file operations
- (void)saveAsFile {
    // Dictionary convertable to JSON ?
    if ([NSJSONSerialization isValidJSONObject:_history])
    {
        // Serialize the dictionary
        NSError *error;
        NSData *json = [NSJSONSerialization dataWithJSONObject:_history options:NSJSONWritingPrettyPrinted error:&error];
        
        // If no errors, let's view the JSON
        if (json != nil && error == nil)
        {
            // save
            [json writeToFile:_historyFileName atomically:YES];
        }
    }
}

- (void)loadData {
    // check if the file already exists
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:_historyFileName];
    if (fileExists) {
        NSData *data = [fileManager contentsAtPath:_historyFileName];
        NSError *error;
        NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        _history = [array mutableCopy];
        
        if (_history == nil || error) {
            
        }
    }
    else {
        // initialize NSMutableDictionary
        _history = [[NSMutableArray alloc] init];
    }
}


#pragma mark - my methods
- (NSArray *)getTodaysInformation:(NSDate *)today {
    // //////////////////////////////////////////////// //
    // all the dates inside this method is GMT based!!! //
    // //////////////////////////////////////////////// //
    
    // search within the history and return today's time stamp history
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *startComponents = [calendar components:(NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitYear|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond) fromDate:today];
    [startComponents setHour: 00];
    [startComponents setMinute: 00];
    [startComponents setSecond: 00];
    
    NSDate *startDate = [calendar dateFromComponents:startComponents];
    
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(in >= %@) AND (in =< %@)", startDate, endDate];
    NSPredicate *predicate = [NSPredicate predicateWithBlock:
                              ^BOOL(id evaluatedObject, NSDictionary *bindings)
                              {
                                  NSDate *currentDate = [_dateTimeFormatter dateFromString:[evaluatedObject valueForKey:kDate]];
                                  return startDate == currentDate;
                              }];
    
    return [_history filteredArrayUsingPredicate:predicate];
}

- (NSString *)getStartTime:(NSDate *)today {
    NSArray *currentDayArray = [self getTodaysInformation:today];
    if ([currentDayArray count] == 0) {
        return nil;
    }
    else {
        NSDate *startDate = [_dateTimeFormatter dateFromString:currentDayArray[0][kStart]];
        return [_timeFormatter stringFromDate:startDate];
    }
}

- (NSString *)getEndTime:(NSDate *)today {
    NSArray *currentDayArray = [self getTodaysInformation:today];
    if ([currentDayArray count] == 0) {
        return nil;
    }
    else {
        NSString *endDateString = currentDayArray[0][kEnd];
        if ([endDateString isEqualToString:@""]) {
            return nil;
        }
        else {
            NSDate *startDate = [_dateTimeFormatter dateFromString:endDateString];
            return [_timeFormatter stringFromDate:startDate];
        }
    }
}

- (NSArray *)getTimeList:(NSDate *)today {
    // //////////////////////////////////////////////// //
    // all the dates inside this method is GMT based!!! //
    // //////////////////////////////////////////////// //
    
    NSArray *currentDayArray = [self getTodaysInformation:today];
    if ([currentDayArray count] == 0) {
        return nil;
    }
    else {
        return currentDayArray[0][kList];
    }
}


- (NSNumber *)getTotalOutSideDuration:(NSDate *)today {
    NSArray *currentDayArray = [self getTodaysInformation:today];
    if ([currentDayArray count] == 0) {
        return nil;
    }
    else {
        // grap appropriate dictionary item
        // getTodaysInformation method only returns size 1 array of NSDictionary if found
        NSDictionary *correspondingItem = [currentDayArray firstObject];
        NSArray *list = correspondingItem[kList];
        __block NSNumber *durationSum = @0;

        [list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSNumber *duration = [obj valueForKey:kDuration];
            if ([duration intValue] > kDurationThreshold) {
                durationSum = @( [durationSum intValue] + [duration intValue]);
            }
        }];
        
        return durationSum;
    }
}

- (void)setSwitch:(UISwitch *)mySwitch andLabel:(UILabel *)label {
	if (_isInsideBuilding) {
		[mySwitch setOn:YES animated:YES];
		[label setText:@"Inside!!"];
	}
	else {
		[mySwitch setOn:NO animated:YES];
		[label setText:@"Outside!!"];
	}
	
	NSLog(@"current inside flag: %@", @(_isInsideBuilding));
}

@end
