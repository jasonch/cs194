//
//  ViewTaskViewController.m
//  SmartList
//
//  Created by Anna Shtengelova on 4/25/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import "ViewTaskViewController.h"


@implementation ViewTaskViewController

-(void) setup
{
	self.title = task.name;	
	[nameLabel setText: task.name];
	if ([task.due_date timeIntervalSinceNow] < 2592000)
	{
		NSDateFormatter *format = [[NSDateFormatter alloc] init];
		[format setDateFormat:@"MMM dd, yyyy HH:mm"];
		NSString *dateString = [format stringFromDate:task.due_date];
		[format release];
		[dueDateLabel setText:dateString];
	}

	[startButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
	if ([task.status intValue] == 1) { // started
		[startButton setTitle:@"Pause" forState:UIControlStateNormal];
		[startButton addTarget:self action:@selector(pausePressed:) forControlEvents:UIControlEventTouchUpInside];
	} else {
		[startButton setTitle:@"Start" forState:UIControlStateNormal];
		[startButton addTarget:self action:@selector(startPressed:) forControlEvents:UIControlEventTouchUpInside];
	}
}


-initInManagedObjectContext:(NSManagedObjectContext*)aContext withTask:(Task*)aTask
{
	if (self == [super initWithStyle:UITableViewStyleGrouped]) {
		context = aContext;
		task = aTask;
		
		startButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		startButton.frame = CGRectMake(30, 300, 125, 40);
		
		[startButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
		if ([task.status intValue] == 1) { // started
			[startButton setTitle:@"Pause" forState:UIControlStateNormal];
			[startButton addTarget:self action:@selector(pausePressed:) forControlEvents:UIControlEventTouchUpInside];
		} else {
			[startButton setTitle:@"Start" forState:UIControlStateNormal];
			[startButton addTarget:self action:@selector(startPressed:) forControlEvents:UIControlEventTouchUpInside];
		}
		

		completeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		completeButton.frame = CGRectMake(170, 300, 125, 40);
		[completeButton setTitle:@"Complete" forState:UIControlStateNormal];
		[completeButton addTarget:self action:@selector(completePressed:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:startButton];
		[self.view addSubview:completeButton];
		[self setup];
    }
	return self;
}


-(void)startPressed:(UIButton*)sender
{
	NSDictionary *dict = [NSDictionary dictionaryWithObject:task forKey:@"task"];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"startPressedWithTask" object:self userInfo:dict];
    [self setup];
}

-(void)pausePressed:(UIButton*)sender
{	
	NSDictionary *dict = [NSDictionary dictionaryWithObject:task forKey:@"task"];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"pausePressedWithTask" object:self userInfo:dict];
    [self setup];
}

-(void)completePressed:(UIButton*)sender
{
	UIAlertView *removeTask = [[UIAlertView alloc]
						  initWithTitle: @"Complete this task"
						  message: @"Marking this task as complete will remove it from your QuickList."
						  delegate: self
						  cancelButtonTitle:@"Cancel"
						  otherButtonTitles:@"Ok",nil];
	 
	[removeTask show];
	[removeTask release];
	
	NSDictionary *dict = [NSDictionary dictionaryWithObject:task forKey:@"task"];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"completePressedWithTask" object:self userInfo:dict];
}


-(void)editPressed
{
	AddTaskTableViewController *attvc = [[AddTaskTableViewController alloc] initInManagedObjectContext:context withTask:task];
	[self.navigationController pushViewController:attvc animated:YES];
	[attvc release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		// user pressed cancel, do nothing
	}
	else {
		[task setValue:[NSNumber numberWithInt:2] forKey:@"status"];
		[context deleteObject:task];
		[self.navigationController popViewControllerAnimated:YES];
	}
}

 - (void)viewDidLoad {
	 [super viewDidLoad];
	 [self setup];
 
	 self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(editPressed)];
	 
 }
 

/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 }
 */

 - (void)viewDidAppear:(BOOL)animated {
	 [super viewDidAppear:animated];
	 [self setup];
	 [self.tableView reloadData];
 }
 
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */
/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 6;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    switch (indexPath.row) {
		case 0:
			[cell.textLabel setText: @"Task"];
			nameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(110,10,190,25)] autorelease]; 
			[nameLabel setText: task.name];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			[cell addSubview:nameLabel];
			break;
		case 1:
			[cell.textLabel setText: @"Deadline"];			
			dueDateLabel = [[[UILabel alloc] initWithFrame:CGRectMake(110,10,190,25)] autorelease]; 
			NSString *dateString = @"";
			if ([task.due_date timeIntervalSinceNow] < 2592000)
			{
				NSDateFormatter *format = [[NSDateFormatter alloc] init];
				[format setDateFormat:@"MMM dd, yyyy HH:mm"];
				dateString = [format stringFromDate:task.due_date];
				[dueDateLabel setText:dateString];
				[format release];				
			}
			
//			if (dateString == nil) {
//				dateString = @"None";
//			}
//			
//			NSString *statusString = @"";
//			switch ([task.status intValue]) {
//				case 0:
//					statusString = @" (Not started)";
//					break;
//				case 1:
//					statusString = @" (Active)";
//					statusLabel.textColor = [UIColor greenColor];
//					break;
//				case 2:
//					statusString = @" (Completed)";
//					break;					
//				default:
//					break;
//			}
//			
//			if ([task.due_date compare:[[NSDate alloc] init]] == NSOrderedDescending) { // == 1
//				statusString = @" (Overdue)";
//			}
//			dateString = [dateString stringByAppendingString:statusString];	

			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			[cell addSubview:dueDateLabel];
			break;
		case 2:
			[cell.textLabel setText: @"Duration"];
			durationLabel = [[[UILabel alloc] initWithFrame:CGRectMake(110,10,190,25)] autorelease]; 
            NSString *durationString = [task.duration stringValue];
            if ([task.duration floatValue] == 1.0)
            {
                durationString = [durationString stringByAppendingString:@" hour"];
            }else
            {
                durationString = [durationString stringByAppendingString:@" hours"];
            }
			[durationLabel setText: durationString];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			[cell addSubview:durationLabel];
			break;
		case 3:
			[cell.textLabel setText: @"Slice"];
			chunksLabel = [[[UILabel alloc] initWithFrame:CGRectMake(110,10,190,25)] autorelease]; 
            NSString *chunksString = [task.chunk_size stringValue];
            if ([task.chunk_size floatValue] == 1.0)
            {
                chunksString = [chunksString stringByAppendingString:@" hour"];
            }else
            {
                chunksString = [chunksString stringByAppendingString:@" hours"];
            }
			[chunksLabel setText: chunksString];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			[cell addSubview:chunksLabel];			
			break;
		case 4:
			[cell.textLabel setText: @"Priority"];
            NSString *priorityString = @"";
			priorityLabel = [[[UILabel alloc] initWithFrame:CGRectMake(110,10,190,25)] autorelease]; 
            switch ([task.priority intValue]) {
                case 1:
                    priorityString = @"Very Low";
                    break;
                case 2:
                    priorityString = @"Low";
                    break;
                case 3:
                    priorityString = @"Medium";
                    break;
                case 4:
                    priorityString = @"High";
                    break;
                case 5:
                    priorityString = @"Very High";
                    break;
                default:
                    break;
            }
			[priorityLabel setText: priorityString];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			[cell addSubview:priorityLabel];			
			break;
		case 5:
			[cell.textLabel setText: @"Blacklist"];
            NSString *blacklistedString = @"";
			blacklistedLabel = [[[UILabel alloc] initWithFrame:CGRectMake(110,10,190,25)] autorelease]; 
            switch ([task.blacklisted intValue]) {
                case 0:
                    blacklistedString = @"No";
                    break;
                case 1:
                    blacklistedString = @"Yes";
                    break;
                default:
                    break;
            }
			[blacklistedLabel setText: blacklistedString];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			[cell addSubview:blacklistedLabel];			
			break;			
		default:
			break;
	}
    
    return cell;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
	 return YES;
 }
 
*/

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
