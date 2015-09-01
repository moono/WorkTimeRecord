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

@property (nonatomic, strong) NSArray *todaysList;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	// set switch control
    WorkTimeManager *manager = [WorkTimeManager defaultInstance];
	[manager setSwitch:_insideSwitch andLabel:_insideTextLabel];
	
	// get today's lists
	_todaysList = [manager getTodaysList:[NSDate date]];
	
	// show current time
    [self checkTime:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - my methods
- (void)checkTime:(id)sender
{
    // to get current date
    NSDate *today = [NSDate date];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    // set format of date: time
    [timeFormatter setDateFormat:@"HH:mm:ss"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    // set time & date to label
    [_currentTimeLabel setText:[timeFormatter stringFromDate:today]];
    [_todaysDateLabel setText:[dateFormatter stringFromDate:today]];
    
    // tell controller to call this method for every second
    [self performSelector:@selector(checkTime:) withObject:self afterDelay:1.0];
}

#pragma mark - table view protocols
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_todaysList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if(cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
	// customize cell
	NSDictionary *data = _todaysList[indexPath.row];
	if (data) {
		NSString *displayString = [NSString stringWithFormat:@"duration: %@", [data[kDuration] stringValue]];
		[cell.textLabel setText:displayString];
	}
	
	return cell;
}

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


@end
