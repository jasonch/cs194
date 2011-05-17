//
//  ViewTaskViewController.h
//  SmartList
//
//  Created by Anna Shtengelova on 4/25/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DueDateViewController.h"
#import "DurationViewController.h"
#import "AddTaskTableViewController.h"
#import "Task.h"


@interface ViewTaskViewController : UITableViewController <UIAlertViewDelegate> {
	NSManagedObjectContext *context;
	UILabel *chunksLabel;
	UILabel *nameLabel;
	UILabel *dueDateLabel;
	UILabel *durationLabel;
	UILabel *priorityLabel;
	UIButton *startButton;
	UIButton *completeButton;
	Task *task;
}

-initInManagedObjectContext:(NSManagedObjectContext*)aContext withTask:(Task*)aTask;
-(void)startPressed:(UIButton*)sender;
-(void)completePressed:(UIButton*)sender; 

@end