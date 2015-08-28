//
//  HomeViewController.m
//  WorkTimeRecord
//
//  Created by mookyung song on 8/19/15.
//  Copyright (c) 2015 moono. All rights reserved.
//

#import "HomeViewController.h"

#import "WorkTimeManager.h"


@interface HomeViewController ()

//@property (nonatomic) WorkTimeManager *timeManager;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //WorkTimeManager *manager = [WorkTimeManager defaultInstance];
    
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


@end
