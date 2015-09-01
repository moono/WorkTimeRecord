//
//  DetailViewController.m
//  WorkTimeRecord
//
//  Created by mookyung song on 8/19/15.
//  Copyright (c) 2015 moono. All rights reserved.
//

#import "DetailViewController.h"

// my import
#import "WorkTimeManager.h"


@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

#pragma mark - simulation methods
- (IBAction)simulateEntranceButton:(id)sender {
	WorkTimeManager *workManager = [WorkTimeManager defaultInstance];
	[workManager setIsInsideBuilding:![workManager isInsideBuilding]];
	[workManager addTimeStamp:[NSDate date]];
}

- (IBAction)simulateExitButton:(id)sender {
    //WorkTimeManager *manager = [WorkTimeManager defaultInstance];
    //[manager addExitTime:[NSDate date]];
}

- (IBAction)simulateSaveButton:(id)sender {
    WorkTimeManager *manager = [WorkTimeManager defaultInstance];
    NSArray *filtered = [manager getTodaysList:[NSDate date]];
    NSLog(@"Today's list: %@", filtered);
}
@end
