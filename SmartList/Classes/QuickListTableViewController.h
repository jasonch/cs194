//
//  QuickListTableViewController.h
//  SmartList
//
//  Created by Justine DiPrete on 4/18/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddTaskTableViewController.h"



@interface QuickListTableViewController : UITableViewController {
	NSManagedObjectContext *context;
}


-initInManagedObjectContext:(NSManagedObjectContext*)aContext;

@end
