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
#import "Task.h"


@interface ViewTaskViewController : UITableViewController {
	NSManagedObjectContext *context;
	UILabel *chunksLabel;
	UILabel *nameLabel;
	UILabel *dueDateLabel;
	UILabel *durationLabel;
	UILabel *priorityLabel;
	Task *task;
}

-initInManagedObjectContext:(NSManagedObjectContext*)aContext withTask:(Task*)aTask;

@end