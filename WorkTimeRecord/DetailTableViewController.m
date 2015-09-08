//
//  DetailTableViewController.m
//  WorkTimeRecord
//
//  Created by mookyung song on 9/2/15.
//  Copyright (c) 2015 moono. All rights reserved.
//

#import "DetailTableViewController.h"

#import "HomeViewController.h"
#import "WorkTimeManager.h"
#import "DetailTableViewCell.h"

@interface DetailTableViewController ()

@end

@implementation DetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // set refresh control to table view
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshTableView:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshTableView:(UIRefreshControl *)refreshControl {
    // do refreshing job
    //[self refreshUI];
    
    [refreshControl endRefreshing];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    WorkTimeManager *manager = [WorkTimeManager defaultInstance];
    return [manager getNumberOfHistoryCount];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"detailCell";
    DetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    WorkTimeManager *manager = [WorkTimeManager defaultInstance];
    NSDictionary *item = [manager getHistoryItemByIndex:indexPath.row];
    NSDate *currentDate = [[manager dateTimeFormatter] dateFromString:[item valueForKey:kDate]];
    cell.textLabel.text = [[manager dateFormatter] stringFromDate:currentDate];
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        WorkTimeManager *manager = [WorkTimeManager defaultInstance];
        NSDictionary *item = [manager getHistoryItemByIndex:indexPath.row];
        NSDate *currentDate = [[manager dateTimeFormatter] dateFromString:[item valueForKey:kDate]];
        [manager removeWholeDay:currentDate];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
//    else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //DetailTableViewCell *cell = (DetailTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    // perform segue for detail view
    //[self performSegueWithIdentifier:<#(NSString *)#> sender:self];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - my methods
//- (void)refreshUI {
//    // get current date
//    NSDate *currentDate = [NSDate date];
//    
//    // get todays array
//    WorkTimeManager *manager = [WorkTimeManager defaultInstance];
//    
//    // get starting time
//    _startTime = [manager getStartTime:currentDate];
//    if (_startTime == nil) {
//        _startTime = @"";
//    }
//    
//    // get end time
//    _endTime = [manager getEndTime:currentDate];
//    if (_endTime == nil) {
//        _endTime = @"";
//    }
//    
//    // get total in office duration: day
//    NSNumber *workDurationDay = [manager getWorkDurationWholeDay:currentDate];
//    if (workDurationDay == nil) {
//        _totalWorkDurationDay = @"";
//    }
//    else {
//        _totalWorkDurationDay = [NSString stringWithFormat:@"%@ m", [workDurationDay stringValue]];
//    }
//    
//    // get total off office duration: day
//    NSNumber *outsideDurationDay = [manager getOutsideDurationWholeDay:currentDate];
//    if(outsideDurationDay == nil) {
//        _totalOffDurationDay = @"";
//    }
//    else {
//        _totalOffDurationDay = [NSString stringWithFormat:@"%@ m", [outsideDurationDay stringValue]];
//    }
//    
//    // get list of all off office list
//    _todaysList = [manager getTimeList:currentDate];
//    if (_todaysList == nil) {
//        _todaysList = [[NSArray alloc] init];
//    }
//    
//    // get total in office duration: week
//    NSNumber *workDurationWeek = [manager getThisWeeksWorkDuration:currentDate];
//    if (workDurationWeek == nil) {
//        _totalWorkDurationWeek = @"";
//    }
//    else {
//        _totalWorkDurationWeek = [NSString stringWithFormat:@"%@ m", [workDurationWeek stringValue]];
//    }
//    
//    // get total off office duration: week
//    NSNumber *outsideDurationWeek = [manager getThisWeeksOutsideDuration:currentDate];
//    if(outsideDurationWeek == nil) {
//        _totalOffDurationWeek = @"";
//    }
//    else {
//        _totalOffDurationWeek = [NSString stringWithFormat:@"%@ m", [outsideDurationWeek stringValue]];
//    }
//    
//    // set switch control
//    [manager setSwitch:_insideSwitch andLabel:_insideTextLabel];
//    
//    // refresh table view
//    [_tableView reloadData];
//}

#pragma mark - Action events
- (IBAction)closeView:(id)sender {
    // tell HomeViewController to refresh table view
    //HomeViewController *homeViewController = _delegate;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)testing:(id)sender {
}
@end
