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



- (UITableViewCell *)tableView:(UITableView *)tableView cellForManagedObject:(NSManagedObject *)managedObject
{
    static NSString *ReuseIdentifier = @"CoreDataTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseIdentifier];
    if (cell == nil) {
		UITableViewCellStyle cellStyle = self.subtitleKey ? UITableViewCellStyleSubtitle : UITableViewCellStyleDefault;
        cell = [[[UITableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:ReuseIdentifier] autorelease];
    }
	
	if (self.titleKey) {
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, cell.frame.size.width - 20, 20)];
		titleLabel.text = [managedObject valueForKey:self.titleKey];
		[titleLabel setFont:[UIFont fontWithName:@"MarkerFelt-Thin" size:20]];
		[cell addSubview:titleLabel];
//		cell.textLabel.text = [managedObject valueForKey:self.titleKey];
//		cell.textLabel.frame = CGRectMake(5, 0, cell.frame.size.width - 20, 20);
//		[cell.textLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16]];
	}
	if (self.subtitleKey) cell.detailTextLabel.text = [managedObject valueForKey:self.subtitleKey];
	cell.accessoryType = [self accessoryTypeForManagedObject:managedObject];
	
	UIProgressView *progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
	[progressBar setProgress:[((Task*)managedObject).progress floatValue]];
	[progressBar setFrame:CGRectMake(5, cell.frame.size.height - 15, 150, 10)];
	[cell addSubview:progressBar];
	UIImage *thumbnail = [self thumbnailImageForManagedObject:managedObject];
	if (thumbnail) cell.imageView.image = thumbnail;
	
	return cell;
}


-(void)managedObjectSelected:(NSManagedObject *)managedObject
{
	Task *task = (Task*)managedObject;
	NSLog(@"task name: %@", task.name);
	
	ViewTaskViewController *vtvc = [[ViewTaskViewController alloc] initInManagedObjectContext:context withTask:task];
	[self.navigationController pushViewController:vtvc animated:YES];
	[vtvc release];
}

- (void)deleteManagedObject:(NSManagedObject *)managedObject
{
	//remove from database
	NSLog(@"something happened");
	[context deleteObject:managedObject];
}

- (BOOL)canDeleteManagedObject:(NSManagedObject *)managedObject
{
	return YES;
}


- (void)dealloc {
    [super dealloc];
}

@end