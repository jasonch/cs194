//
//  BlacklistViewController.h
//  SmartList
//
//  Created by Anna Shtengelova on 5/11/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewTaskViewController.h"
#import "CoreDataTableViewController.h"
#import "Task.h"

@interface BlacklistViewController : UITableViewController {
	NSManagedObjectContext *context;
	NSMutableArray *blacklist;
}

-initInManagedObjectContext:(NSManagedObjectContext*)aContext;

@end
