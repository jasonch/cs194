//
//  AddTaskTableViewController.h
//  SmartList
//
//  Created by Justine DiPrete on 4/18/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"


@interface AddTaskTableViewController : UITableViewController {
	NSManagedObjectContext *context;
	UISlider *slider;
}

-initInManagedObjectContext:(NSManagedObjectContext*)aContext;

@end
