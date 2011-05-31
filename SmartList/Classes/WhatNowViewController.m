//
//  WhatNowViewController.m
//  SmartList
//
//  Created by Justine DiPrete on 4/18/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import "WhatNowViewController.h"
#define	TASK_LABEL_TAG 9173 // same random number to uniquely identify the label

@implementation WhatNowViewController


/** moved all user-facing messages to the top so they're consistent **/
-(void)taskStartedAlert {
	NSString *message = [NSString stringWithFormat:@"You are working on %@.\n Task added to your calendar.", [taskLabel text]];
	UIAlertView *startAlert = [[UIAlertView alloc] initWithTitle: @"Task Started" message: message
														delegate:self cancelButtonTitle: @"OK" otherButtonTitles: nil];
	
	[startAlert show];
	[startAlert release];
}
-(void)busyAlert {
	NSString *message = [NSString stringWithFormat:@"You are working on %@.", [taskLabel text]];
	UIAlertView *busyAlert = [[UIAlertView alloc] initWithTitle: @"Currently Busy" message: message
													   delegate:self cancelButtonTitle: @"OK" otherButtonTitles: nil];
	
	[busyAlert show];
	[busyAlert release];	
}
-(void)blacklistAlert {
	NSString *blacklisted = [NSString stringWithFormat:@"'%@' will no longer be scheduled until you remove it from the Blacklist.",
							 taskLabel.text];
	UIAlertView *blacklistAlert = [[UIAlertView alloc] initWithTitle: @"Task blacklisted" message: blacklisted
															delegate:self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
	
	[blacklistAlert show];
	[blacklistAlert release];
}
-(void)dueDatePassedAlert:(int)number {
	NSString *message = [NSString stringWithFormat:@"%d tasks have passed their due date. Update the tasks with red names in your QuickList!", number];
	UIAlertView *passAlert = [[UIAlertView alloc] initWithTitle: @"Deadline Passed" message: message
													   delegate:self cancelButtonTitle: @"OK" otherButtonTitles: nil];
	
	[passAlert show];
	[passAlert release];	
}
-(void)calendarAlert:(Task *)aTask {
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Task added to your calendar"
						  message:[NSString stringWithFormat:@"You can review your day any time!", aTask.name]
						  delegate:nil
						  cancelButtonTitle:@"Okay"
						  otherButtonTitles:nil];
	[alert show];
	[alert release];	
}
/** end user-facing messages **/


/** state-changing functions **/
-(void)updateStateStartTask:(Task *)task {
	assert(!busy);
	busy = YES;
	
	currentTask = task;
		
	startButton.enabled = YES;
	[startButton removeTarget:self action:@selector(startPressed:) forControlEvents:UIControlEventTouchUpInside];
	[startButton setTitle: @"Pause" forState: UIControlStateNormal];
	[startButton addTarget:self action:@selector(pausePressed:) forControlEvents:UIControlEventTouchUpInside];
	blacklistButton.enabled = NO;
		
	[self addTaskToCalendar:currentTask fromTime:[NSDate date] 
					toTime:[NSDate dateWithTimeIntervalSinceNow:([currentTask.chunk_size doubleValue]*3600)]];

	[freeTimeLabel setText:[NSString stringWithFormat:@"You are currently working on ..."]];	
	[taskLabel setText:task.name];
	
}
-(void)updateStatePauseTask:(Task *)task {
	assert(busy && currentTask != nil);
	busy = NO;
	
	startButton.enabled = YES;
	[startButton removeTarget:self action:@selector(pausePressed:) forControlEvents:UIControlEventTouchUpInside];
	[startButton setTitle: @"Start" forState: UIControlStateNormal];
	[startButton addTarget:self action:@selector(startPressed:) forControlEvents:UIControlEventTouchUpInside];
	
	blacklistButton.enabled = YES;

	EKEvent *currentEvent = [self getCurrentCalendarTask];
	
	if ([currentEvent.title isEqualToString:task.name]) {
		[currentEvent setEndDate:[NSDate date]];
		NSError *error;
		[eventStore	saveEvent:currentEvent span:EKSpanThisEvent error:&error];
		if (error) {
			NSLog (@"error: %@", [error description]);
		}
	}
	
}
-(void)updateStateCalendarBusy:(EKEvent *)event {
	busy = YES;
	currentTask = nil;
	startButton.enabled = NO;
	blacklistButton.enabled = NO;
	[freeTimeLabel setText:[NSString stringWithFormat:@"Your calendar indicates you are currently ..."]];
	[taskLabel setText:event.title];
}
/** end state-changing functions **/


-(void) setup
{
	UITabBarItem *item = [[UITabBarItem alloc] initWithTitle: @"What Now?" image:[UIImage imageNamed: @"169-8ball.png"] tag:0];
	self.tabBarItem = item;
	[item release];
	
	UIBarButtonItem *viewBlacklist = [[UIBarButtonItem alloc] initWithTitle:@"View Blacklist" style:UIBarButtonItemStyleBordered target:self action:@selector(viewBlacklist)];
	self.navigationItem.rightBarButtonItem = viewBlacklist;
	[viewBlacklist release];

	// set up blacklist
	blacklist = [[[NSMutableArray alloc] init] retain];   	
	[startButton setTitle:@"Start" forState:UIControlStateNormal];
	[startButton setTitleColor: [UIColor grayColor] forState:UIControlStateDisabled];
	[blacklistButton setTitle:@"Blacklist" forState:UIControlStateNormal];
	[blacklistButton setTitleColor: [UIColor grayColor] forState:UIControlStateDisabled];
	[self.view addSubview:startButton];
	[self.view addSubview:blacklistButton];
	
	currentTask = nil; //[Task findTask:taskLabel.text inManagedObjectContext:context]; 	// placeholder
	busy = NO;
	
	[self updateCurrentTask];
}

-initInManagedObjectContext:(NSManagedObjectContext*)aContext
{
	context = aContext;
	// set up event listeners
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startPressedWithTask:) name:@"startPressedWithTask" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pausePressedWithTask:) name:@"pausePressedWithTask" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completePressedWithTask:) name:@"completePressedWithTask" object:nil];

	self.title = @"What Now?";	
	taskLabel.tag = TASK_LABEL_TAG;
	calendarTasks = nil;
	eventStore = [[EKEventStore alloc] init];
	
	[self checkForLateTasks];
	
	[self setup];
	[self checkAndSetCurrentTask];
	
	return self;
}

-(void)startPressedWithTask:(NSNotification *)note
{
	NSLog(@"start pressed with task");
	if (busy) {
		[self busyAlert];
	} else {
		Task *aTask = [[note userInfo] valueForKey:@"task"];

		[aTask setValue:[NSNumber numberWithInt:1] forKey:@"status"]; // 1 => started
		[aTask setValue:[NSDate date] forKey:@"started_time"];		

		[self updateStateStartTask:aTask];
		[self taskStartedAlert];
	}
}

-(void)pausePressedWithTask:(NSNotification *)note
{
	assert (currentTask != nil);
	NSLog(@"pause pressed with task");
	
	Task *aTask = [[note userInfo] valueForKey:@"task"];
	
	[self updateProgressOfTask:aTask];	
	[self updateStatePauseTask:aTask];

	[self updateCurrentTask];	
}

-(void)completePressedWithTask:(NSNotification *)note
{
	NSLog(@"complete pressed");
		
	Task *aTask = [[note userInfo] valueForKey:@"task"];

	if (busy && [aTask.name isEqualToString:currentTask.name]) {
		[self updateProgressOfTask:aTask];
		[self updateStatePauseTask:aTask];
	}
	
	[aTask setValue:[NSNumber numberWithInt:2] forKey:@"status"];
	
	[self updateCurrentTask];
}

-(void)startPressed:(UIButton*)sender
{
	NSLog(@"start pressed");

	if (!busy && currentTask != nil) {
		assert ([currentTask.name isEqualToString:[taskLabel text]]);
		[currentTask setValue:[NSNumber numberWithInt:1] forKey:@"status"]; // 1 => started
		[currentTask setValue:[NSDate date] forKey:@"started_time"];

		[self updateStateStartTask:currentTask];
		[self taskStartedAlert];
		
	} 
}


-(void)pausePressed:(UIButton*)sender
{

	[self updateProgressOfTask:currentTask];	
	[self updateStatePauseTask:currentTask];
	
	[self updateCurrentTask];
}


-(void)blacklistPressed:(UIButton*)sender
{
	assert (currentTask != nil);

	[self blacklistAlert];
	[blacklist addObject:currentTask];

	[currentTask setValue:[NSNumber numberWithBool:YES] forKey:@"blacklisted"];
	
	busy = NO;
	[self updateCurrentTask];
}


-(void)viewBlacklist
{		
	BlacklistViewController *bvc = [[BlacklistViewController alloc] initInManagedObjectContext:context withBlacklist:blacklist];
	[self.navigationController pushViewController:bvc animated:YES];
	[bvc release];
}

// called on a "started" task, finish up the task, calculates its progress,
// adds to the calendar, and sets its status as appropriate 
- (BOOL)updateProgressOfTask:(Task *)task {
	if ([task.status intValue] != 1)
		return NO;
	
	NSTimeInterval timePassed = [task.started_time timeIntervalSinceNow];
	if (timePassed > 0.0) {
		NSLog(@"update progress of task: %@, error: started in the future", task.name);
		[task setValue:[NSNumber numberWithInt:2] forKey:@"status"]; // say it's completed
		return NO; // started in the future!?
	}
	timePassed = -1*timePassed;
	
	if (timePassed/3600. >= [task.chunk_size doubleValue])
		timePassed = [task.chunk_size doubleValue];
	
	//[self addTaskToCalendar:task fromTime:task.started_time toTime:[NSDate date]];
	
	double progress = timePassed / (3600.*[task.duration doubleValue]) + [task.progress doubleValue];
	
	
	if (progress >= 1)
		[task setValue:[NSNumber numberWithInt:2] forKey:@"status"]; // 2 => completed
	else 
		[task setValue:[NSNumber numberWithInt:0] forKey:@"status"]; // 0 => active
	
	[task setValue:[NSNumber numberWithDouble:progress] forKey:@"progress"];
	
	return YES;
}


-(void) updateCurrentTask {
    
	assert (!busy);
	EKEvent *calendarTask = [self getCurrentCalendarTask];
	if (calendarTask != nil) {
		[self updateStateCalendarBusy:calendarTask];
		return;
	}
	
	EKEvent *nextCalendarTask = [self getNextCalendarTask];
	double spareTime = nextCalendarTask==nil?24.:[nextCalendarTask.startDate timeIntervalSinceNow]/3600.;
	
	currentTask = [self getNextScheduledTaskWithDurationOf:spareTime];
	if (currentTask == nil) {
		[taskLabel setText:@"No task to schedule!"];
		startButton.enabled = NO;
		blacklistButton.enabled = NO;
	} else {
		[taskLabel setText:[NSString stringWithFormat:@"%@",currentTask.name]];
		startButton.enabled = YES;
		blacklistButton.enabled = YES;
		NSLog(@"current task updated: %@", [currentTask description]);
	}
	[freeTimeLabel setText:[NSString stringWithFormat:@"You have at least %.2f hours of free time!", spareTime]];
}

#pragma mark Shake Functionality
-(BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	if (event.type == UIEventSubtypeMotionShake) {
		if (currentTask == nil || !busy) {
			AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
			[self updateCurrentTask];
		}
	}
}


#pragma mark memory management

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self setup];		
}

-(void)viewDidAppear:(BOOL)animated {
    [self becomeFirstResponder];

	if (!busy) {
		NSLog(@"refreshing What Now? view controller");
		[self updateCurrentTask];
	} else if (currentTask == nil) { // means we're on a calendar task
		EKEvent *event = [self getCurrentCalendarTask];
		if (event == nil) { // but the event ended
			busy = NO;
		}
	}
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

/* called on start up, check for tasks whose due dates have passed. */
- (void)checkForLateTasks {
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	request.entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:context];
	// find all active, uncompleted tasks due in the next 15 mintues 
	request.predicate = [NSPredicate predicateWithFormat:@"status == 0 AND progress < 1 AND due_date < %@", [NSDate dateWithTimeIntervalSinceNow:(15*60)]];
						 
	NSError *error = nil; 
						 
	NSArray *array = [context executeFetchRequest:request error:&error];
						 
	if (!error && array != nil && [array count] != 0) {
		[self dueDatePassedAlert:[array count]];
		[array makeObjectsPerformSelector:@selector(setStatus:) withObject:[NSNumber numberWithInt:3]];
	}
	
	[request release];
}
						 

/* called on startup, checks the DB for any task already started. If so, and it is not yet 
 * finished, set it as current task. */
- (void)checkAndSetCurrentTask {
	Task *started = [self checkAndUpdateTaskDB];
	if (started != nil) {
		NSLog(@"started task: %@", [started description]);
		[self updateStateStartTask:started];
		return;
	}
}

/* check the DB for all tasks of status 1 (there should only be one). If it is done with its slice,
 * then calculate progress accordingly. Otherwise return it. */
- (Task *)checkAndUpdateTaskDB {
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	request.entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"status == 1"];
	
	NSError *error = nil; 
	NSArray *array = [context executeFetchRequest:request error:&error];
	
	[request release];
	
	Task *startedTask = nil;
	
	if (error || array == nil) // some error
		return nil;
	
	for (int i = 0; i < [array count]; i++) {
		Task *task = [array objectAtIndex:i];
		if ([task.started_time timeIntervalSinceNow]*-1/3600. >= [task.chunk_size doubleValue]) {
			[self updateProgressOfTask:task];
		} else {
			if (startedTask == nil) {
				startedTask = task;
			} else {
				NSLog(@"ERROR: more than one currently started task");
			}
		}
	}

	return startedTask;
}

- (BOOL)ScheduleFeasibleWith:(NSMutableArray *)m_array at:(int)k {
	
	return YES;
}

- (void)MutableArraySwap:(NSMutableArray *)m_array indexOne:(int)i indexTwo:(int)j {
	NSObject *tmp = [m_array objectAtIndex:i];
	[m_array replaceObjectAtIndex:i withObject:[m_array objectAtIndex:j]];
	[m_array replaceObjectAtIndex:j withObject:tmp];
}

- (Task *)getTaskWithPriorityArray:(NSMutableArray *)m_array {
	int count = [m_array count];
	if (count == 0) return nil;
	
	// use parabolic function
	int total = count * (count + 1) * (2*count + 1) / 6;
	int rand = arc4random() % (total + 1);
	
	int j = 1;
	for (; j <= count; j++) {
		if (j*(j+1)*(2*j + 1) / 6 >= rand) break;
	}
	// reverse the index because lowest index is highest priority
	int index = count - j;
	return [m_array objectAtIndex:index];
}


- (Task *)getNextScheduledTaskWithDurationOf: (double)spareTime {
			
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	request.entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"status == 0 AND chunk_size <= %f and blacklisted == NO", spareTime];

	NSError *error = nil; 
	
	NSArray *array = [context executeFetchRequest:request error:&error];
	
	[request release];
	
	if (!error && array != nil) {
		// schedule 
		int count = [array count];
		
		// short circuit out if we already know the decision
		// also prevents infinite loop at the end
		if (count == 0) return nil;
		if (count == 1) return [array objectAtIndex:0];
		
		NSMutableArray *m_array = [[NSMutableArray alloc] initWithCapacity:[array count]];
		[m_array addObjectsFromArray:array];
		
		
		// pre-sort it by due date, progress, and priority
		// eff_priority = priority * duration * (1 - progress) / (due_date - today)
		NSComparator taskSorter = ^(id id1, id id2) {
			double effective_priority_1 = [[id1 valueForKey:@"priority"] doubleValue]
				//* [[id1 valueForKey:@"duration"] doubleValue] * (1 - [[id1 valueForKey:@"progress"] doubleValue])
				/ [[id1 valueForKey:@"due_date"] timeIntervalSinceNow];
						
			double effective_priority_2 = [[id2 valueForKey:@"priority"] doubleValue]
				//* [[id2 valueForKey:@"duration"] doubleValue] * (1 - [[id2 valueForKey:@"progress"] doubleValue])
				/ [[id2 valueForKey:@"due_date"] timeIntervalSinceNow];
			return effective_priority_1 > effective_priority_2? NSOrderedAscending: NSOrderedDescending;
		};
		[m_array sortUsingComparator:taskSorter];
		
		for (int k = count - 1; k >= 0; k--){
			BOOL feasible = YES;
			for (int next = k; next >= 0; next--) {
				[self MutableArraySwap:m_array indexOne:k indexTwo:next];
				
				feasible = [self ScheduleFeasibleWith:m_array at:k];
				if (feasible)
					break;
			}
			if (feasible == NO) {
				[m_array release];
				return nil;
			}
		}
		
		Task *candidate = [self getTaskWithPriorityArray:m_array];
		
        
			candidate = [self getTaskWithPriorityArray:m_array];
		return candidate;
	}
	return nil;
}

-(void)getTaskFromCalendar {
	
	NSPredicate *fromNowPredicate = [eventStore predicateForEventsWithStartDate:[NSDate date] endDate:[NSDate dateWithTimeIntervalSinceNow:(24*3600)] calendars:nil];
		
	NSArray *events = [eventStore eventsMatchingPredicate:fromNowPredicate];
	NSLog(@"fetched %d events from calendar", [events count]);
	
	if (calendarTasks != nil)
		[calendarTasks release];
	calendarTasks = [[NSMutableArray alloc] initWithCapacity:[events count]];
	[calendarTasks addObjectsFromArray:events];
	
}

- (BOOL)addTaskToCalendar:(Task *)aTask fromTime:(NSDate *)from toTime:(NSDate *)to {
	
	EKEvent *event = [EKEvent eventWithEventStore:eventStore];
	event.title = aTask.name;
	event.startDate = from;
	event.endDate = to;
	[event setCalendar:[eventStore defaultCalendarForNewEvents]];
	
	NSError *error;
	[eventStore	saveEvent:event span:EKSpanThisEvent error:&error];
	if (error == noErr) {
		//[self calendarAlert:aTask];
		return YES;
	} else {
		NSLog(@"Add to Calendar Error: %@", [error description]);
		return NO;
	}
}

- (EKEvent *)getNextCalendarTask {
	[self getTaskFromCalendar];

	if ([calendarTasks count] == 0)
		return nil;	
	
	for (int i = 0; i < [calendarTasks count]; i++) {
		EKEvent *event = [calendarTasks objectAtIndex:i];
		if ([event.startDate timeIntervalSinceNow] < 0) continue;
		return event;
	}
	return nil;
}

- (EKEvent *)getCurrentCalendarTask {
	[self getTaskFromCalendar];

	if ([calendarTasks count] == 0) {
		NSLog (@"calendarTasks empty");
		return nil;
	}
		
	for (int i = 0; i < [calendarTasks count]; i++) {
		EKEvent *event = [calendarTasks objectAtIndex:i];
		if ([event.startDate timeIntervalSinceNow] > 0) break;
		if ([event.endDate timeIntervalSinceNow] < 0) continue;
		NSLog(@"found calendar task: %@", event.title);
		return event;
	}
	return nil;
}


- (void)dealloc {
	[blacklist release];
	[calendarTasks release];
	[eventStore release];
    [super dealloc];
}



@end
