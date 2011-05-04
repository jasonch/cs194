//
//  QuickListTableViewController.h
//  SmartList
//
//  Created by Justine DiPrete on 4/18/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddTaskTableViewController.h"
#import "CoreDataTableViewController.h"
#import "ViewTaskViewController.h"
#import "User.h"
#import "Task.h"


@interface QuickListTableViewController : CoreDataTableViewController {
	NSManagedObjectContext *context;
	User *user;
}


-initInManagedObjectContext:(NSManagedObjectContext*)aContext withUser:(User*)aUser;

@end
