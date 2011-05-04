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


@interface AddTaskTableViewController : UITableViewController <UITextFieldDelegate> {
	NSManagedObjectContext *context;
	UISlider *slider;
	UITextField *nameField;
	UILabel *dueDateLabel;
	UILabel *durationLabel;
	UIProgressView *progress;
}

-initInManagedObjectContext:(NSManagedObjectContext*)aContext;

@end
