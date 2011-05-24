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
	
	if (self == [super initWithStyle:UITableViewStylePlain])
	{
		if (user == nil)
		{
			NSFetchRequest *request = [[NSFetchRequest alloc] init];
			request.entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:context];
			request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"creation_time"
																							 ascending:NO
																							  selector:@selector(compare:)]];
			
			//request.predicate = nil;
			request.predicate = [NSPredicate predicateWithFormat:@"(status == 0) OR (status == 1) OR (status == 3)"];
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
    
		// predefine all spaces where subviews would go
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, cell.frame.size.width - 82, 20)];
		[titleLabel setFont:[UIFont fontWithName:@"MarkerFelt-Thin" size:20]];
		titleLabel.tag = 1;
		[cell addSubview:titleLabel];
		[titleLabel release];
		
		UIProgressView *progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
		[progressBar setFrame:CGRectMake(5, cell.frame.size.height - 15, 150, 10)];
		progressBar.tag = 2;
		[cell addSubview:progressBar];
		[progressBar release];
		
		UILabel *dueDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width - 80, (cell.frame.size.height - 15)/2, 80, 15)]; 
		dueDateLabel.tag = 3;
		[dueDateLabel setFont:[UIFont fontWithName:@"MarkerFelt-Thin" size:14]];
		[cell addSubview:dueDateLabel];
		[dueDateLabel release];
	}
	
	
	Task *task = (Task *)managedObject;
	int taskStatus = [task.status intValue];
	int NUM_CELL_SUBVIEWS = 3;
	
	for (int i = 1; i <= NUM_CELL_SUBVIEWS; i++) {
		UIView *subview = [cell viewWithTag:i];
		switch (i) {
			case 1: // title
				if (self.titleKey) {
					if (taskStatus == 1)
						((UILabel*)subview).textColor = [UIColor colorWithRed:0 green:.7 blue:0 alpha:1];
					else if (taskStatus)
						((UILabel*)subview).textColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
					else 
						((UILabel*)subview).textColor = [UIColor blackColor];
					[(UILabel *)subview setText:task.name];
				}
				break;
			case 2: // progress bar
				[((UIProgressView*)subview) setProgress:[task.progress floatValue]];
				break;
				
			case 3: // due date
				if ([task.due_date timeIntervalSinceNow] < 2592000) // 30 days
				{
					NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
					[formatter setDateStyle:NSDateFormatterNoStyle];
					[formatter setTimeStyle:NSDateFormatterShortStyle];
					[formatter setDateFormat:(NSString*) @"MMM dd"];
					[(UILabel *)subview setText:[formatter stringFromDate:task.due_date]];
					if ([task.due_date timeIntervalSinceNow] < 86400) // one day
					{
						((UILabel *)subview).textColor = [UIColor redColor];
					}
					[formatter release];
				} else {
					[(UILabel *)subview setText:@""];
				}
				break;
			default:
				break;
		}
		
	}
		
	//if (self.subtitleKey) cell.detailTextLabel.text = [managedObject valueForKey:self.subtitleKey];
	cell.accessoryType = [self accessoryTypeForManagedObject:managedObject];
	
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
	[(Task*)managedObject setStatus:[NSNumber numberWithInt:2]];
	
	//[context deleteObject:managedObject];
}

- (BOOL)canDeleteManagedObject:(NSManagedObject *)managedObject
{
	return YES;
}


- (void)dealloc {
    [super dealloc];
}

@end