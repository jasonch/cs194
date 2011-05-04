//
//  QuickListTableViewController.m
//  SmartList
//
//  Created by Justine DiPrete on 4/18/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import "QuickListTableViewController.h"


@implementation QuickListTableViewController

-(void) setup
{
	self.title = @"QuickList";	
	UITabBarItem *item = [[UITabBarItem alloc] initWithTitle: @"QuickList" image:[UIImage imageNamed: @"179-notepad.png"] tag:0];
	self.tabBarItem = item;
	[item release];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStyleBordered target:self action:@selector(addTask
																																						   )];

}

-initInManagedObjectContext:(NSManagedObjectContext*)aContext withUser:(User*)aUser
{
	context = aContext;
	user = aUser;
	
	[self setup];
	
	if (self = [super initWithStyle:UITableViewStylePlain])
	{
		if (user == nil)
		{
			NSFetchRequest *request = [[NSFetchRequest alloc] init];
			request.entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:context];
			request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name"
																							 ascending:YES
																							  selector:@selector(caseInsensitiveCompare:)]];
			
			request.predicate = nil;
			//request.predicate = [NSPredicate predicateWithFormat:@"user = %@", user];
			request.fetchBatchSize = 20;
			
			NSFetchedResultsController *frc = [[NSFetchedResultsController alloc]
											   initWithFetchRequest:request
											   managedObjectContext:context
											   sectionNameKeyPath:nil
											   cacheName:nil];
			
			[request release];
			
			self.fetchedResultsController = frc;
			[frc release];
			
			self.titleKey = @"name";
			self.searchKey = @"name";
		}
	}
	
	return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	[self setup];
	self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

-(void)addTask
{
	AddTaskTableViewController *attvc = [[AddTaskTableViewController alloc] initInManagedObjectContext:context];
	[self.navigationController pushViewController:attvc animated:YES];
	[attvc release];
}



/**
 * Pushes BookForSaleViewController with selected bookForSale
 **/


-(void)managedObjectSelected:(NSManagedObject *)managedObject
{
	Task *task = (Task*)managedObject;
	NSLog(@"task name: %@", task.name);
	
	ViewTaskViewController *vtvc = [[ViewTaskViewController alloc] initInManagedObjectContext:context withTask:task];
	[self.navigationController pushViewController:vtvc animated:YES];
	[vtvc release];
}





- (void)dealloc {
    [super dealloc];
}

@end