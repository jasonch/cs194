//
//  AddTaskTableViewController.m
//  SmartList
//
//  Created by Justine DiPrete on 4/18/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import "AddTaskTableViewController.h"


@implementation AddTaskTableViewController

-(void)setDate:(NSDate *)aDate
{
	dueDate = aDate;
}

-(void)setDuration: (float) aDuration
{
	[slider setMaximumValue:aDuration];
	[slider setValue:aDuration];
	chunk_size = aDuration;
	[hourLabel setText:[NSString stringWithFormat:@"%.2f", aDuration]];
	duration = aDuration;
}

-(void) setup
{
	self.title = @"New Task";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveTask)];	

	formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterNoStyle];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
	[formatter setDateFormat:(NSString*) @"EEE, MM/d, hh:mm aaa"];
	
	dueDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(115,15,175,15)]; 
	dueDate = [[NSDate alloc] init];
	dueDate = [NSDate distantFuture];
	//[dueDateLabel setText:[formatter stringFromDate:dueDate]];
	
	durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, 15, 175, 15)];
	duration = 1;
	[durationLabel setText:@"1 hour and 0 minutes"];
	
	name = @"";
	
	//Declare DueDateViewController
	ddvc = [[DueDateViewController alloc] initWithDate:[NSDate date]];
	[ddvc setDelegate:self];
	dvc = [[DurationViewController alloc] init];
	[dvc setDelegate:self];
}

-initInManagedObjectContext:(NSManagedObjectContext*)aContext
{
	if (self == [super initWithStyle:UITableViewStyleGrouped]) {
		context = aContext;
		[self setup];
    }
	return self;
}


-(void)setDurationLabel
{
	NSString *durationString = @"";
	int hours = (int)duration;
	durationString = [durationString stringByAppendingString:[NSString stringWithFormat:@"%d", hours]];
	durationString = [durationString stringByAppendingString:@" hours and "];
	double minutes = duration - (double)hours;
	minutes *= 60.0;
	durationString = [durationString stringByAppendingString:[NSString stringWithFormat:@"%g", minutes]];
	durationString = [durationString stringByAppendingString:@" mins"];
	[durationLabel setText:durationString];
}

-(void) setupEditMode
{
	self.title = @"Edit Task";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveExistingTask)];
	
	formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterNoStyle];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
	[formatter setDateFormat:(NSString*) @"EEE, MM/d, hh:mm aaa"];
	
	dueDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(115,15,175,15)]; 
	dueDate = [[NSDate alloc] init];
	dueDate = task.due_date;

	if ([dueDate timeIntervalSinceNow] < 2592000)
	{
		[dueDateLabel setText:[formatter stringFromDate:dueDate]];
	}
	durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, 15, 175, 15)];
	duration = [task.duration floatValue];
	[self setDurationLabel];
	name = task.name;
	priority = [task.priority intValue];
	chunk_size = [task.chunk_size intValue];
	
	[blacklistedSwitch setOn:[task.blacklisted boolValue] animated:NO];
	NSLog(@"edit task: %@", [task description]);
		
	//Declare DueDateViewController
	ddvc = [[DueDateViewController alloc] initWithDate:dueDate];
	[ddvc setDelegate:self];
	dvc = [[DurationViewController alloc] init];
	[dvc setDelegate:self];
}

-initInManagedObjectContext:(NSManagedObjectContext*)aContext withTask:(Task*)aTask
{
	task = aTask;
	if (self == [super initWithStyle:UITableViewStyleGrouped]) {
		context = aContext;
		[self setupEditMode];
    }
	return self;
}

#pragma mark currently working on
-(void) saveTask
{
	if (nameField.text == nil || [nameField.text isEqualToString:@""]) { // This seems kind of dumb.
		// blank task name exception
		UIAlertView *noName = [[UIAlertView alloc] initWithTitle: @"No task name" message: @"You must enter a name for your task." 
														   delegate:self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
		
		[noName show];
		[noName release];
	} 
	else if ([Task findTask:nameField.text inManagedObjectContext:context]) 
	{
		// duplicate task name exception
		UIAlertView *duplicate = [[UIAlertView alloc] initWithTitle: @"Duplicate task" message: @"A task with this name already exists." 
															   delegate:self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
			
		[duplicate show];
		[duplicate release];
	
	}
	else 
	{
		task = [Task taskWithName:nameField.text inManagedObjectContext:context];
		task.duration = [NSNumber numberWithFloat:duration];
		task.due_date = dueDate;
		NSLog(@"Priority: %d", [prioritySlider value]);
		task.priority = [NSNumber numberWithInt:(([prioritySlider value]))];
		task.chunk_size = [NSNumber numberWithDouble:[slider value]];
		task.blacklisted = [NSNumber numberWithBool:blacklistedSwitch.on];
		NSLog(@"task: %@", [task description]);
		[self.navigationController popViewControllerAnimated: YES];
	}
}

-(void) saveExistingTask
{
	if (nameField.text == nil || [nameField.text isEqualToString:@""]) { // This seems kind of dumb.
		// blank task name exception
		UIAlertView *noName = [[UIAlertView alloc] initWithTitle: @"No task name" message: @"You must enter a name for your task." 
														delegate:self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
		
		[noName show];
		[noName release];
	} 
	else 
	{
		task.duration = [NSNumber numberWithFloat:duration];
		task.name = nameField.text;
		task.due_date = dueDate;
		task.priority = [NSNumber numberWithInt:([prioritySlider value])];
		task.chunk_size = [NSNumber numberWithDouble:([slider value])];
		task.blacklisted = [NSNumber numberWithBool:blacklistedSwitch.on];
		[self.navigationController popViewControllerAnimated: YES];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self setDurationLabel];	
	if ([dueDate timeIntervalSinceNow] < 2592000)
	{
		[dueDateLabel setText:[formatter stringFromDate:dueDate]];
	}
	NSLog(@"Date: %@", [formatter stringFromDate:dueDate]);
	
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	if (task != nil && name != nil)
	{
        [nameField setText:name];
		prioritySlider.minimumValue = 1;
		prioritySlider.maximumValue = 5;
		prioritySlider.value = priority;
		//slider.maximumValue = 20;
		//slider.value = chunk_size;
		[blacklistedSwitch setOn:[task.blacklisted boolValue] animated:NO];
	}
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


-(void)sliderChanged:(id)sender
{
	UISlider *sittingsSlider = (UISlider *)sender;
	sittingsSlider.maximumValue = duration;
	sittingsSlider.minimumValue = .25;
	double minutes = floor([sittingsSlider value]*4)/4;
	NSString *hourString = [NSString stringWithFormat:@"%.2f", minutes];
	hourString = [hourString stringByAppendingString:@" hours"];
	slider.value = minutes;
	hourLabel.text = hourString;
}

-(void)prioritySliderChanged:(id)sender
{
	UISlider *thePrioritySlider = (UISlider *)sender;
	int priorityValue = floor([thePrioritySlider value]*5)/5;
	
	switch (priorityValue) {
		case 1:
			priorityLabel.text = @"Very Low";
			break;
		case 2:
			priorityLabel.text = @"Low";
			break;
		case 3:
			priorityLabel.text = @"Medium";
			break;
		case 4:
			priorityLabel.text = @"High";
			break;
		case 5:
			priorityLabel.text = @"Very High";
			break;
		default:
			break;
	}
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
			nameField = [[UITextField alloc] initWithFrame:CGRectMake(80,8,214,31)];
			nameField.borderStyle = UITextBorderStyleRoundedRect;
			nameField.returnKeyType = UIReturnKeyDone;
			nameField.delegate = self;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			[cell.textLabel setText: @"Task"];
			[cell addSubview:nameField];
			break;
		case 1:
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			[cell.textLabel setText: @"Due Date"];
			[cell addSubview:dueDateLabel];
			break;
		case 2:
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			[cell.textLabel setText: @"Duration"];
			[cell addSubview:durationLabel];
			break;
		case 3:			
			hourLabel = [[UILabel alloc] initWithFrame:CGRectMake(181, 5, 120, 15)];
			hourLabel.text = @"1 hour";
			slider = [[UISlider alloc] initWithFrame:CGRectMake(144,20,154,15)];
			[slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
			[cell.textLabel setText: @"Sitting Length"];
			[slider setValue:1];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			[cell addSubview:slider];
			[cell addSubview:hourLabel];

			break;
		case 4:
			priorityLabel = [[UILabel alloc] initWithFrame:CGRectMake(181, 5, 120, 18)];
			priorityLabel.text = @"Medium";
			prioritySlider = [[UISlider alloc] initWithFrame:CGRectMake(144,23,154,15)];
			[prioritySlider addTarget:self action:@selector(prioritySliderChanged:) forControlEvents:UIControlEventValueChanged];
			[cell.textLabel setText: @"Priority"];
			prioritySlider.minimumValue = 1;
			prioritySlider.maximumValue = 5;
			prioritySlider.value = 3;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			[cell addSubview:prioritySlider];
			[cell addSubview:priorityLabel];
			break;
		case 5:
			[cell.textLabel setText:@"Blacklisted"];
			blacklistedSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(130, 10, 50, 23)];
			[blacklistedSwitch setOn:NO animated:NO];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			[cell addSubview:blacklistedSwitch];
			break;
		default:
			break;
	}
    
    return cell;
}




#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.row != 0) {
		[nameField resignFirstResponder];
	}
	
	if (indexPath.row == 1)
	{
		name = nameField.text;
        NSLog(@"Name: %@", name);
		priority = [prioritySlider value];
		chunk_size = [slider value];
		[self.navigationController pushViewController:ddvc animated:YES];
	}
	else if (indexPath.row == 2)
	{
        NSLog(@"Name: %@", name);
		name = nameField.text;
		priority = [prioritySlider value];
		chunk_size = [slider value];
		[self.navigationController pushViewController:dvc animated:YES];
	}
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
	//[dueDate release];
	[dueDateLabel release];
	[formatter release];
	[durationLabel release];
	[nameField release];
	[slider release];
	[prioritySlider release];
	[blacklistedSwitch release];
	[hourLabel release];
	//[ddvc setDelegate:nil];
	//[ddvc release];
	//[dvc release];
	[super dealloc];
}


@end

