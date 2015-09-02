//
//  WorkTimeManager.m
//  WorkTimeRecord
//
//  Created by mookyung song on 8/19/15.
//  Copyright (c) 2015 moono. All rights reserved.
//

#import "WorkTimeManager.h"

@interface WorkTimeManager ()

// contains all history of the time
// [
//      {
//      "date" : NSDate ==> NSString with dateFormatter
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
//      "date" : NSDate ==> NSString with dateFormatter
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
- (void)addTimeStamp:(NSDate *)time {
    _isInsideBuilding = !_isInsideBuilding;
    
    // find today's dictionary
    NSArray *currentDayArray = [self getTodaysInformation:time];
    
    // going out from work place
	if (_isInsideBuilding == NO) {
		_lastInDate = time;
	}
    // cominig in to work place
	else {
		if (_lastInDate == nil) {
            if ([currentDayArray count] == 0) {
                // create 00:00:00 date component
                NSCalendar *calendar = [NSCalendar currentCalendar];
                NSDateComponents *startComponents = [calendar components:(NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitYear|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond) fromDate:time];
                [startComponents setHour: 00];
                [startComponents setMinute: 00];
                [startComponents setSecond: 00];
                
                // add new one
                [_history addObject: @{ kDate : [_dateTimeFormatter stringFromDate:[calendar dateFromComponents:startComponents]],
                                        kStart : [_dateTimeFormatter stringFromDate:time],
                                        kEnd : [NSNull null],
                                        kList : [[NSMutableArray alloc] init] }];
            }
            else {
                NSLog(@"Unexpected control...");
            }
		}
        else {
            NSMutableArray *listArray = currentDayArray[0][kList];
            
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
    
//    // search within the history and return today's time stamp history
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    NSDateComponents *startComponents = [calendar components:(NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitYear|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond) fromDate:today];
//    [startComponents setHour: 00];
//    [startComponents setMinute: 00];
//    [startComponents setSecond: 00];
//    
//    NSDateComponents *endComponents = [calendar components:(NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitYear|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond) fromDate:today];
//    [endComponents setHour: 23];
//    [endComponents setMinute: 59];
//    [endComponents setSecond: 59];
//    
//    NSDate *startDate = [calendar dateFromComponents:startComponents];
//    NSDate *endDate = [calendar dateFromComponents:endComponents];
//	NSLog(@"Today: %@", today);
//    NSLog(@"기준: %@ ~ %@", startDate, endDate);
//    
//    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(in >= %@) AND (in =< %@)", startDate, endDate];
//    NSPredicate *predicate = [NSPredicate predicateWithBlock:
//                              ^BOOL(id evaluatedObject, NSDictionary *bindings)
//    {
//		NSDate *inDate = [_dateTimeFormatter dateFromString:[evaluatedObject valueForKey:kIn]];
//		NSDate *outDate = [_dateTimeFormatter dateFromString:[evaluatedObject valueForKey:kOut]];
//        NSLog(@"내부: %@ ~ %@", inDate, outDate);
//        return ( (inDate >= startDate) &&  (outDate <= endDate) );
//    }];
//    
//    return [_history filteredArrayUsingPredicate:predicate];
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
