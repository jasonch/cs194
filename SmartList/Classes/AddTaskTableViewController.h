//
//  AddTaskTableViewController.h
//  SmartList
//
//  Created by Justine DiPrete on 4/18/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DueDateViewController.h"
#import "DurationViewController.h"
#import "Task.h"


@interface AddTaskTableViewController : UITableViewController <DueDateViewControllerDelegate> {
	NSManagedObjectContext *context;
	UISlider *slider;
	UITextField *nameField;
	UILabel *dueDateLabel;
	UILabel *durationLabel;
	NSDate *dueDate;
	NSNumber *duration;
	NSDateFormatter *formatter;
	DueDateViewController *ddvc;
}

-(void)setDate:(NSDate *)aDate;
-initInManagedObjectContext:(NSManagedObjectContext*)aContext;

@end
