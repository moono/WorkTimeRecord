//
//  WorkTimeManager.m
//  WorkTimeRecord
//
//  Created by mookyung song on 8/19/15.
//  Copyright (c) 2015 moono. All rights reserved.
//

#import "WorkTimeManager.h"

// define the keys for dictionary
#define kIn @"in"				// NSString from NSDate
#define kOut @"out"				// NSString from NSDate
#define kDuration @"duration"	// integer

//#define kTime @"time"
//#define kInOut @"inout"
//#define kIndex @"index"


@interface WorkTimeManager ()

// contains all history of the time
@property (nonatomic, strong) NSMutableArray *history;

// file name to backup the data
@property (nonatomic, strong) NSString *historyFileName;

// for managing time
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

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
	
    // set date formatter
    _dateFormatter = [NSDateFormatter new];
    [_dateFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm:ss"];
    [_dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    
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
- (void)addEntranceTime:(NSDate *)entranceTime {
    _lastInDate = entranceTime;
    
    NSLog(@"%@", _history);
}

- (void)addExitTime:(NSDate *)exitTime {
    // check if last In Date exists
    if (_lastInDate == nil) {
        NSLog(@"Something Wrong....!!!");
        return;
    }
    
    // compute time difference between enter & exit
    double timeInterval = [exitTime timeIntervalSinceDate:_lastInDate];
    int rounded = (int)round(timeInterval);
    
    // save
    [_history addObject:@{kIn : [_dateFormatter stringFromDate:_lastInDate],
                          kOut : [_dateFormatter stringFromDate:exitTime],
                          kDuration : [NSNumber numberWithDouble:rounded]}];
	
    // set last In time as nil
    _lastInDate = nil;
    
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
- (NSArray *)getTodaysList:(NSDate *)today {
    // //////////////////////////////////////////////// //
    // all the dates inside this method is GMT based!!! //
    // //////////////////////////////////////////////// //
    
    // search within the history and return today's time stamp history
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *startComponents = [calendar components:(NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitYear|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond) fromDate:today];
    [startComponents setHour: 00];
    [startComponents setMinute: 00];
    [startComponents setSecond: 00];
    
    NSDateComponents *endComponents = [calendar components:(NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitYear|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond) fromDate:today];
    [endComponents setHour: 23];
    [endComponents setMinute: 59];
    [endComponents setSecond: 59];
    
    NSDate *startDate = [calendar dateFromComponents:startComponents];
    NSDate *endDate = [calendar dateFromComponents:endComponents];
	NSLog(@"Today: %@", today);
    NSLog(@"기준: %@ ~ %@", startDate, endDate);
    
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(in >= %@) AND (in =< %@)", startDate, endDate];
    NSPredicate *predicate = [NSPredicate predicateWithBlock:
                              ^BOOL(id evaluatedObject, NSDictionary *bindings)
    {
		NSDate *inDate = [_dateFormatter dateFromString:[evaluatedObject valueForKey:kIn]];
		NSDate *outDate = [_dateFormatter dateFromString:[evaluatedObject valueForKey:kOut]];
        NSLog(@"내부: %@ ~ %@", inDate, outDate);
        return ( (inDate >= startDate) &&  (outDate <= endDate) );
    }];
    
    return [_history filteredArrayUsingPredicate:predicate];
}

@end
