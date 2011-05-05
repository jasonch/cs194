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
}

-initInManagedObjectContext:(NSManagedObjectContext*)aContext withTask:(Task*)aTask
{
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		context = aContext;
		task = aTask;
		[self setup];
    }
	return self;
}


 - (void)viewDidLoad {
	 [super viewDidLoad];
	 [self setup];
 
 // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
     self.navigationItem.rightBarButtonItem = self.editButtonItem;
 }
 

/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 }
 */
/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
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
    return 5;
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
			nameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(200,15,100,15)] autorelease]; 
			[nameLabel setText: task.name];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			[cell addSubview:nameLabel];
			break;
		case 1:
			[cell.textLabel setText: @"Due Date"];
			dueDateLabel = [[[UILabel alloc] initWithFrame:CGRectMake(200,15,100,15)] autorelease]; 
			NSDateFormatter *format = [[NSDateFormatter alloc] init];
			[format setDateFormat:@"MMM dd, yyyy HH:mm"];
			NSString *dateString = [format stringFromDate:task.due_date];
			[dueDateLabel setText:dateString];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			[cell addSubview:dueDateLabel];
			break;
		case 2:
			[cell.textLabel setText: @"Duration"];
			durationLabel = [[[UILabel alloc] initWithFrame:CGRectMake(200,15,100,15)] autorelease]; 
			[durationLabel setText: [task.duration stringValue]];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			[cell addSubview:durationLabel];
			break;
		case 3:
			[cell.textLabel setText: @"Chunks"];
			chunksLabel = [[[UILabel alloc] initWithFrame:CGRectMake(200,15,100,15)] autorelease]; 
			[chunksLabel setText: [task.sittings stringValue]];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			[cell addSubview:chunksLabel];			
			break;
		case 4:
			[cell.textLabel setText: @"Priority"];
			priorityLabel = [[[UILabel alloc] initWithFrame:CGRectMake(200,15,100,15)] autorelease]; 
			[priorityLabel setText: [task.priority stringValue]];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			[cell addSubview:priorityLabel];			
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
