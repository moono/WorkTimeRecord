//
//  HomeViewController.m
//  WorkTimeRecord
//
//  Created by mookyung song on 8/19/15.
//  Copyright (c) 2015 moono. All rights reserved.
//

#import "HomeViewController.h"

#import "WorkTimeManager.h"


@interface HomeViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSString *endTime;
@property (nonatomic, strong) NSArray *todaysList;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *timeFormatter;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
    // set refresh control to table view
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshTableView:) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:refreshControl];
	
    // initialize date formatter
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"yyyy-MM-dd"];
    _timeFormatter = [[NSDateFormatter alloc] init];
    [_timeFormatter setDateFormat:@"HH:mm:ss"];
    
    // update UI
    [self refreshUI];
    
	// show current time
    [self checkTime:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshTableView:(UIRefreshControl *)refreshControl {
    // do refreshing job
    [self refreshUI];
    
    [refreshControl endRefreshing];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UIViewController *destination = [segue destinationViewController];
    if ([segue.identifier isEqualToString:@"detailSegue"]) {
        //[destination setValue:sender forKey:<#(NSString *)#>];
    }
    else {
        destination = [segue.destinationViewController topViewController];
    }
    
    [destination setValue:self forKeyPath:@"delegate"];
}

#pragma mark - my methods
- (void)checkTime:(id)sender
{
    // to get current date
    NSDate *today = [NSDate date];
    
    // set time & date to label
    [_currentTimeLabel setText:[_timeFormatter stringFromDate:today]];
    [_todaysDateLabel setText:[_dateFormatter stringFromDate:today]];
    
    // tell controller to call this method for every second
    [self performSelector:@selector(checkTime:) withObject:self afterDelay:1.0];
}

- (void)refreshUI {
    // get current date
    NSDate *currentDate = [NSDate date];
    
    // get todays array
    WorkTimeManager *manager = [WorkTimeManager defaultInstance];
    _startTime = [manager getStartTime:currentDate];
    if (_startTime == nil) {
        _startTime = @"";
    }
    _endTime = [manager getEndTime:currentDate];
    if (_endTime == nil) {
        _endTime = @"";
    }
    
    _todaysList = [manager getTimeList:currentDate];
    if (_todaysList == nil) {
        _todaysList = [[NSArray alloc] init];
    }
    // set switch control
    [manager setSwitch:_insideSwitch andLabel:_insideTextLabel];
    
    // refresh table view
    [_tableView reloadData];
}

#pragma mark - table view protocols
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;   // start, list, end
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    switch (section) {
        case 0:
            rows = 1;
            break;
        case 1:
            rows = [_todaysList count];
            break;
        case 2:
            rows = 1;
            break;
        default:
            rows = 0;
            break;
    }
	return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if(cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
    switch (indexPath.section) {
        case 0:
            if ([_startTime isEqualToString:@""]) {
                cell.textLabel.text = @"Not yet specified!!";
            }
            else {
                cell.textLabel.text = _startTime;
            }
            break;
        case 1:
        {
            // customize cell
            NSDictionary *data = _todaysList[indexPath.row];
            if (data) {
                NSDateFormatter *managerDateTimeFormatter = [[WorkTimeManager defaultInstance] dateTimeFormatter];
                NSDate *inDate = [managerDateTimeFormatter dateFromString:[data valueForKey:kIn]];
                NSDate *outDate = [managerDateTimeFormatter dateFromString:[data valueForKey:kOut]];
                NSString *displayString = [NSString stringWithFormat:@"[%@s]: %@ ~ %@", [data[kDuration] stringValue], [_timeFormatter stringFromDate:inDate], [_timeFormatter stringFromDate:outDate]];
                [cell.textLabel setText:displayString];
                
                // change color
                if ([data[kDuration] intValue] > 10) {
                    cell.textLabel.backgroundColor = [UIColor redColor];
                    cell.textLabel.textColor = [UIColor whiteColor];
                }
                else {
                    cell.textLabel.backgroundColor = [UIColor whiteColor];
                    cell.textLabel.textColor = [UIColor blackColor];
                }
            }
            break;
        }
        case 2:
            if ([_endTime isEqualToString:@""]) {
                cell.textLabel.text = @"Not yet specified!!";
            }
            else {
                cell.textLabel.text = _endTime;
            }
            break;
        default:
            break;
    }
	
	
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = @"Start time";
            break;
        case 1:
            sectionName = @"Today's list";
            break;
        case 2:
            sectionName = @"End time";
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}


#pragma mark - action events
- (IBAction)switchValueChanged:(id)sender {
	WorkTimeManager *manager = [WorkTimeManager defaultInstance];
	if ([sender isOn]) {
		[manager setIsInsideBuilding:YES];
		[manager setSwitch:_insideSwitch andLabel:_insideTextLabel];
	}
	else {
		[manager setIsInsideBuilding:NO];
		[manager setSwitch:_insideSwitch andLabel:_insideTextLabel];
	}
}

- (IBAction)testing:(id)sender {
    WorkTimeManager *manager = [WorkTimeManager defaultInstance];
    [manager addTimeStamp:[NSDate date]];
    
    // update UI
    [self refreshUI];
}


@end
