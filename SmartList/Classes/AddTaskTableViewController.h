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
	UILabel *hourLabel;
	UILabel *priorityLabel;
	UISwitch *blacklistedSwitch;
	NSDate *dueDate;
	float duration;
	NSDateFormatter *formatter;
	UISlider *prioritySlider;
	DueDateViewController *ddvc;
	DurationViewController *dvc;
	Task *task;
	NSString *name;
	int priority;
	int chunk_size;
}

-(void)setDate:(NSDate *)aDate;
-(void)setDuration: (float) aDuration;
-(BOOL)dueDateCheck;
-initInManagedObjectContext:(NSManagedObjectContext*)aContext;
-initInManagedObjectContext:(NSManagedObjectContext*)aContext withTask:(Task*)aTask;

@end
