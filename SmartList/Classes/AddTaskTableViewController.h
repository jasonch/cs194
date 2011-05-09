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


@interface AddTaskTableViewController : UITableViewController <UITextFieldDelegate, DueDateViewControllerDelegate, DurationViewControllerDelegate> {
	NSManagedObjectContext *context;
	UISlider *slider;
	UITextField *nameField;
	UILabel *dueDateLabel;
	UILabel *durationLabel;
	NSDate *dueDate;
	NSNumber *duration;
	NSDateFormatter *formatter;
	UISlider *prioritySlider;
	DueDateViewController *ddvc;
	DurationViewController *dvc;
	Task *task;
}

-(void)setDate:(NSDate *)aDate;
-(void)setDuration: (NSNumber*) aDuration;
-initInManagedObjectContext:(NSManagedObjectContext*)aContext;
-initInManagedObjectContext:(NSManagedObjectContext*)aContext withTask:(Task*)aTask;

@end
