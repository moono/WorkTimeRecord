//
//  WorkTimeManager.m
//  WorkTimeRecord
//
//  Created by mookyung song on 8/19/15.
//  Copyright (c) 2015 moono. All rights reserved.
//

#import "WorkTimeManager.h"

@interface WorkTimeManager ()

//// temporary state saving data structure
//// {
////  "inside" : BOOL ==> NSNumber
////  "last": NSDate ==> NSString with dateTimeFormatter
//// }
//@property (nonatomic, strong) NSMutableDictionary *state;

// contains all history of the time
// [
//      {
//      "date" : NSDate ==> NSString with dateTimeFormatter
//      "start" : NSDate ==> NSString with dateTimeFormatter
//      "end" : NSDate ==> NSString with dateTimeFormatter
//      "list" : [
//                  {
//                  "duration" : (int)
//                  "in"  : NSDate ==> NSString with dateTimeFormatter
//                  "out" : NSDate ==> NSString with dateTimeFormatter
//                  },
//                  {
//                  "duration" : (int)
//                  "in"  : NSDate ==> NSString with dateTimeFormatter
//                  "out" : NSDate ==> NSString with dateTimeFormatter
//                  },
//                  ...
//              ]
//      },
//      {
//      "date" : NSDate ==> NSString with dateTimeFormatter
//      "start" : NSDate ==> NSString with dateTimeFormatter
//      "end" : NSDate ==> NSString with dateTimeFormatter
//      "list" : [
//                  {
//                  "duration" : (int)
//                  "in"  : NSDate ==> NSString with dateTimeFormatter
//                  "out" : NSDate ==> NSString with dateTimeFormatter
//                  },
//                  {
//                  "duration" : (int)
//                  "in"  : NSDate ==> NSString with dateTimeFormatter
//                  "out" : NSDate ==> NSString with dateTimeFormatter
//                  },
//                  ...
//              ]
//      },
//      ...
// ]
@property (nonatomic, strong) NSMutableArray *history;

// file name to backup the data
@property (nonatomic, strong) NSString *historyFileName;
@property (nonatomic, strong) NSString *stateFileName;

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
	
	//// set initial state
	//_isInsideBuilding = NO;
	
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
    _stateFileName = [currentDirectory stringByAppendingPathComponent:@"state.json"];
    
    //// set last In date
    //_lastInDate = nil;
    
//    // load data from file if exists
//	// or create new NSMutableArray instance
//    [self loadData];
    
    return self;
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

- (BOOL)removeWholeDay:(NSDate *)date {
    // prepare to find appropriate item
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *startComponents = [calendar components:(NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitYear|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond) fromDate:date];
    [startComponents setHour: 00];
    [startComponents setMinute: 00];
    [startComponents setSecond: 00];
    
    NSDate *newDate = [calendar dateFromComponents:startComponents];
    
    NSInteger index = [_history indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        NSDate *referenceDate = [_dateTimeFormatter dateFromString:obj[kDate]];
        if (referenceDate == newDate) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    
    if (index == NSNotFound) {
        return NO;
    }
    else {
        [_history removeObjectAtIndex:index];
        return YES;
    }
}

#pragma mark - file operations
- (void)saveAsFile {
    // save history file
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
    
    // save state file
    NSString *lastInDateInString = @"";
    if (_lastInDate != nil) {
        lastInDateInString = [_dateTimeFormatter stringFromDate:_lastInDate];
    }
    NSDictionary *state = @{ kInside : [NSNumber numberWithBool:_isInsideBuilding],
                             kLast : lastInDateInString };
    if ([NSJSONSerialization isValidJSONObject:state])
    {
        // Serialize the dictionary
        NSError *error;
        NSData *json = [NSJSONSerialization dataWithJSONObject:state options:NSJSONWritingPrettyPrinted error:&error];
        
        // If no errors, let's view the JSON
        if (json != nil && error == nil)
        {
            // save
            [json writeToFile:_stateFileName atomically:YES];
        }
    }
}

- (void)loadData {
    // for history file
    // check if the file already exists
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:_historyFileName];
    // load from data
    if (fileExists) {
        NSData *data = [fileManager contentsAtPath:_historyFileName];
        NSError *error;
        NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        _history = [array mutableCopy];
        
        if (_history == nil || error) {
            NSLog(@"Error loading %@", _history);
        }
    }
    // initial setup
    else {
        // initialize NSMutableDictionary
        _history = [[NSMutableArray alloc] init];
    }
    
    // for temprary state file
    fileExists = [fileManager fileExistsAtPath:_stateFileName];
    // load from data
    if (fileExists) {
        NSData *data = [fileManager contentsAtPath:_stateFileName];
        NSError *error;
        NSDictionary *item = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if (item == nil || error) {
            NSLog(@"Error loading %@", _stateFileName);
        }
        else {
            _isInsideBuilding = item[kInside] ? YES : NO;
            _lastInDate = [item[kLast] isEqualToString:@""] ? nil : [_dateTimeFormatter dateFromString:item[kLast]];
        }
    }
    // initial setup
    else {
        _isInsideBuilding = NO;
        _lastInDate = nil;
    }
}


#pragma mark - my methods (Accessors)
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

- (NSInteger)getNumberOfHistoryCount {
    return [_history count];
}

- (NSDictionary *)getHistoryItemByIndex:(NSInteger)index {
    return _history[index];
}

- (NSNumber *)getOutsideDurationWholeDay:(NSDate *)today {
    NSArray *currentDayArray = [self getTodaysInformation:today];
    if ([currentDayArray count] == 0) {
        return nil;
    }
    else {
        // grap appropriate dictionary item
        // getTodaysInformation method only returns size 1 array of NSDictionary if found
        NSDictionary *correspondingItem = [currentDayArray firstObject];
        NSArray *list = correspondingItem[kList];
        
        return [self getTotalOutsideDurationWithinList:list];
    }
}

- (NSNumber *)getWorkDurationWholeDay:(NSDate *)today {
    NSArray *currentDayArray = [self getTodaysInformation:today];
    if ([currentDayArray count] == 0) {
        return nil;
    }
    else {
        // grap appropriate dictionary item
        // getTodaysInformation method only returns size 1 array of NSDictionary if found
        NSDictionary *correspondingItem = [currentDayArray firstObject];
        NSArray *list = correspondingItem[kList];
        NSNumber *outsideDuration = [self getTotalOutsideDurationWithinList:list];
        
        NSDate *startDate = [_dateTimeFormatter dateFromString:correspondingItem[kStart]];
        NSDate *endDate = [_dateTimeFormatter dateFromString:correspondingItem[kEnd]];
        NSTimeInterval secondsBetween = [endDate timeIntervalSinceDate:startDate];
        int inMinutes = secondsBetween / 60;
        
        int totalSum = inMinutes - [outsideDuration intValue];
        return [NSNumber numberWithInt:totalSum];
    }
}

- (NSNumber *)getThisWeeksOutsideDuration:(NSDate *)today {
    // get week indicator from input
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *todaysComponents = [gregorian components:NSCalendarUnitWeekOfYear fromDate:today];
    NSUInteger todaysWeek = [todaysComponents weekOfYear];
    
    // iterate through history and get corresponding week property
    __block int sum = 0;
    [_history enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDate *anotherDate = [_dateTimeFormatter dateFromString:obj[kDate]];
        NSDateComponents *otherComponents = [gregorian components:NSCalendarUnitWeekOfYear fromDate:anotherDate];
        NSUInteger anotherWeek = [otherComponents weekOfYear];
        
        if(todaysWeek == anotherWeek) {
            NSArray *list = obj[kList];
            sum += [[self getTotalOutsideDurationWithinList:list] intValue];
        }
    }];
    
    return [NSNumber numberWithInt:sum];
}

- (NSNumber *)getThisWeeksWorkDuration:(NSDate *)today {
    // get week indicator from input
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *todaysComponents = [gregorian components:NSCalendarUnitWeekOfYear fromDate:today];
    NSUInteger todaysWeek = [todaysComponents weekOfYear];
    
    // iterate through history and get corresponding week property
    __block int sum = 0;
    [_history enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDate *anotherDate = [_dateTimeFormatter dateFromString:obj[kDate]];
        NSDateComponents *otherComponents = [gregorian components:NSCalendarUnitWeekOfYear fromDate:anotherDate];
        NSUInteger anotherWeek = [otherComponents weekOfYear];
        
        if(todaysWeek == anotherWeek) {
            sum += [[self getWorkDurationWholeDay:today] intValue];
        }
    }];
    
    return [NSNumber numberWithInt:sum];
}

#pragma mark - my methods (peripherals)
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

- (NSNumber *)getTotalOutsideDurationWithinList:(NSArray *)todayList {
    __block int sum = 0;
    
    [todayList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSNumber *duration = [obj valueForKey:kDuration];
        if ([duration intValue] > kDurationThreshold) {
            sum += [duration intValue];
        }
    }];
    
    // convert seconds to minutes
    int inMinutes = sum / 60;
    return [NSNumber numberWithInt:inMinutes];
}

@end
