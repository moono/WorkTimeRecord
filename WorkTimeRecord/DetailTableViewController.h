//
//  DetailTableViewController.h
//  WorkTimeRecord
//
//  Created by mookyung song on 9/2/15.
//  Copyright (c) 2015 moono. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailTableViewController : UITableViewController

@property (weak, nonatomic) id delegate;

- (IBAction)closeView:(id)sender;
- (IBAction)testing:(id)sender;

@end
