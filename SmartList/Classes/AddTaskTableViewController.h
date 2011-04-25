//
//  AddTaskTableViewController.h
//  SmartList
//
//  Created by Justine DiPrete on 4/18/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AddTaskTableViewController : UITableViewController {
	NSManagedObjectContext *context;
	UISlider *slider;
	UITextField *nameField;
	UILabel *dueDateLabel;
	UILabel *durationLabel;
}

-initInManagedObjectContext:(NSManagedObjectContext*)aContext;

@end
