//
//  HomeViewController.h
//  WorkTimeRecord
//
//  Created by mookyung song on 8/19/15.
//  Copyright (c) 2015 moono. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *todaysDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UISwitch *insideSwitch;
@property (weak, nonatomic) IBOutlet UILabel *insideTextLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)switchValueChanged:(id)sender;
@end
