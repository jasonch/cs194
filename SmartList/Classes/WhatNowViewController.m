//
//  WhatNowViewController.m
//  SmartList
//
//  Created by Justine DiPrete on 4/18/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import "WhatNowViewController.h"


@implementation WhatNowViewController

-(void) setup
{
	self.title = @"What Now?";	
	UITabBarItem *item = [[UITabBarItem alloc] initWithTitle: @"What Now?" image:[UIImage imageNamed: @"78-stopwatch.png"] tag:0];
	self.tabBarItem = item;
	[item release];
	
	UIBarButtonItem *viewBlacklist = [[UIBarButtonItem alloc] initWithTitle:@"Blacklist" style:UIBarButtonItemStyleBordered target:self action:@selector(viewBlacklist)];
	self.navigationItem.rightBarButtonItem = viewBlacklist;
	[viewBlacklist release];

	// set up blacklist
	blacklist = [[[NSMutableArray alloc] init] retain];   	

	[startButton setTitle:@"Start!" forState:UIControlStateNormal];
	[startButton setTitleColor: [UIColor grayColor] forState:UIControlStateDisabled];
	[blacklistButton setTitle:@"Blacklist" forState:UIControlStateNormal];
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
	[self getTaskFromCalendar];
	
	[self setup];
	return self;
}


-(void)startPressedWithTask:(NSNotification *)note
{
	if (busy) {
		assert(currentTask != nil);
		NSString *message = [NSString stringWithFormat:@"You are working on %@", [currentTask name]];
		UIAlertView *busyAlert = [[UIAlertView alloc] initWithTitle: @"Currently Busy" message: message
													delegate:self cancelButtonTitle: @"OK" otherButtonTitles: nil];
		
		[busyAlert show];
		[busyAlert release];
	} else {
		Task *aTask = [[note userInfo] valueForKey:@"task"];
		[freeTimeLabel setText:@"You are currently working on..."];
		
		currentTask = aTask;
		busy = YES;
		
		NSLog(@"task duration: %.2f", [currentTask duration]);
		[currentTask setValue:[NSNumber numberWithInt:1] forKey:@"status"]; // 1 => started
		[currentTask setValue:[NSDate date] forKey:@"started_time"];		
		[startButton setTitle: @"Pause" forState: UIControlStateNormal];
		[startButton addTarget:self action:@selector(pausePressed:) forControlEvents:UIControlEventTouchUpInside];
	}
}

-(void)pausePressedWithTask:(NSNotification *)note
{
	assert (currentTask != nil);
	
	Task *aTask = [[note userInfo] valueForKey:@"task"];
	assert (currentTask.id == aTask.id);	
	
	[freeTimeLabel setText:@"You have some free time!"];
	[startButton setTitle: @"Start" forState: UIControlStateNormal];
	//[sender removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents]; 
	[startButton addTarget:self action:@selector(startPressed:) forControlEvents:UIControlEventTouchUpInside];
	
	// update database
	[self updateProgressOfTask:aTask];	
	busy = NO;
	
	[self updateCurrentTask];	
}

-(void)startPressed:(UIButton*)sender
{
	NSLog(@"start pressed");
	
	//if (!busy && currentTask != nil && [self addCurrentTaskToCalendar] == YES) {
	if (!busy && currentTask != nil) {
		
		[freeTimeLabel setText:@"You are currently working on..."];

		[currentTask setValue:[NSNumber numberWithInt:1] forKey:@"status"]; // 1 => started
		[currentTask setValue:[NSDate date] forKey:@"started_time"];
		[sender setTitle: @"Pause" forState: UIControlStateNormal];
		//[sender removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents]; 
		[sender addTarget:self action:@selector(pausePressed:) forControlEvents:UIControlEventTouchUpInside];
		busy = YES;
		NSLog (@"%@", [currentTask description]);
	} else if (currentTask == nil) {
		UIAlertView *noTasks = [[UIAlertView alloc] initWithTitle: @"No tasks" 
														  message: @"Action could not be performed because there are no tasks in your QuickList." 
														 delegate:self 
												cancelButtonTitle: @"Ok" 
												otherButtonTitles: nil];
		
		[noTasks show];
		[noTasks release];
	}
}

// called on a "started" task, finish up the task, calculates its progress,
// adds to the calendar, and sets its status as appropriate 
- (BOOL)updateProgressOfTask:(Task *)task {
	if ([task.status intValue] != 1)
		return NO;
	
	NSTimeInterval timePassed = [task.started_time timeIntervalSinceNow];
	if (timePassed > 0.0) {
		[task setValue:[NSNumber numberWithInt:3] forKey:@"status"]; // 3 => error
		return NO; // started in the future!?
	}
	timePassed = -1*timePassed;
	
	if (timePassed/3600. >= [task.chunk_size doubleValue])
		timePassed = [task.chunk_size doubleValue];
	
	[self addTaskToCalendar:task fromTime:task.started_time toTime:[NSDate date]];
	
	double progress = timePassed / (3600.*[task.duration doubleValue]) + [task.progress doubleValue];

	if (progress >= 1)
		[task setValue:[NSNumber numberWithInt:2] forKey:@"status"]; // 2 => completed
	else 
		[task setValue:[NSNumber numberWithInt:0] forKey:@"status"]; // 0 => active

	[task setValue:[NSNumber numberWithDouble:progress] forKey:@"progress"];
		
	return YES;
}

-(void)pausePressed:(UIButton*)sender
{
	[freeTimeLabel setText:@"You have some free time!"];
	[sender setTitle: @"Start" forState: UIControlStateNormal];
	//[sender removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents]; 
	[sender addTarget:self action:@selector(startPressed:) forControlEvents:UIControlEventTouchUpInside];
	
	// update database
	[self updateProgressOfTask:currentTask];	
	busy = NO;
	
	[self updateCurrentTask];
}


-(void)blacklistPressed:(UIButton*)sender
{
	
	if (currentTask == nil) {
		UIAlertView *noTasks = [[UIAlertView alloc] initWithTitle: @"No tasks" 
														  message: @"Action could not be performed because there are no tasks in your QuickList." 
														 delegate:self 
												cancelButtonTitle: @"Ok" 
												otherButtonTitles: nil];
		
		[noTasks show];
		[noTasks release];
		return;
	} else if (busy) {
		UIAlertView *currentlyBusy = [[UIAlertView alloc] initWithTitle: @"Task cannot be Blacklisted" 
														  message: @"You cannot Blacklist a task you are currently working on. Pause or Complete the task." 
														 delegate:self 
												cancelButtonTitle: @"Ok" 
												otherButtonTitles: nil];
		
		[currentlyBusy show];
		[currentlyBusy release];
		return;
	}	
		
	NSString *blacklisted = [NSString stringWithFormat:@"'%@' will no longer be scheduled until you remove it from the Blacklist.",
						 taskLabel.text];
	UIAlertView *blacklistAlert = [[UIAlertView alloc] initWithTitle: @"Task blacklisted" message: blacklisted
													   delegate:self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
	
	[blacklistAlert show];
	[blacklistAlert release];
	
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

-(void) updateCurrentTask {
	
	EKEvent *calendarTask = [self getCurrentCalendarTask];
	if (calendarTask != nil) {
		busy = YES;
		currentTask = nil;
		[freeTimeLabel setText:@"You are currently working on..."];
		[taskLabel setText:calendarTask.title];
		NSLog(@"CALENDAR BUSY!!");
		return;
	}
	
	EKEvent *nextCalendarTask = [self getNextCalendarTask];
	double spareTime = nextCalendarTask==nil?100.0:[nextCalendarTask.startDate timeIntervalSinceNow]/3600.;
	
	Task * task = [self getNextScheduledTaskWithDurationOf:spareTime];
	if (task == nil) {
		[taskLabel setText:@"No task to schedule!"];
	} else {
		[taskLabel setText:[NSString stringWithFormat:@"%@",task.name]];
		currentTask = task;
	}
}

#pragma mark Shake Functionality
-(BOOL)canBecomeFirstResponder {
    return YES;
}


- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	if (event.type == UIEventSubtypeMotionShake) {
		if (currentTask == nil || !busy) 
			[self updateCurrentTask];
	}
}

#pragma mark memory management

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self setup];
		
}

-(void)getTaskFromCalendar {
	
	EKEventStore *eventStore = [[EKEventStore alloc] init];
	NSPredicate *fromNowPredicate = [eventStore predicateForEventsWithStartDate:[NSDate date] endDate:[NSDate distantFuture] calendars:nil];

	if (calendarTasks != nil)
		[calendarTasks release];

	NSArray *events = [eventStore eventsMatchingPredicate:fromNowPredicate];
	calendarTasks = [[NSMutableArray alloc] initWithCapacity:[events count]];
	[calendarTasks addObjectsFromArray:events];
		
	[calendarTasks sortUsingSelector:@selector(compareStartDateWithEvent:)];
	
	[eventStore release];
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


- (void)dealloc {
	[blacklist release];
    [super dealloc];
}

- (void)checkAndUpdateTaskDB {
	
	
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
	
	// use a linear function to give higher priority more weight
	// total number of "lottery tickets"
	int total = (count + 1) * count / 2;
	
	// randomly pick one lottery ticket
	int rand = arc4random() % total + 1;
	
	// convert lottery ticket number back to the ticket holder
	// this should be the inverse function of assigning tickets
	rand = floor(sqrt(1+8*rand)-1)/2; 
	
	// reverse the index because zero priority is highest
	int index = count - rand; 
	NSLog(@"random index: %d", index);
	
	return [m_array objectAtIndex:index];
}


- (Task *)getNextScheduledTaskWithDurationOf: (double)spareTime {
	
	NSLog(@"Get Next Scheduled Task");
		
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	
	request.entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"status == 0 AND chunk_size <= %f and blacklisted == NO", spareTime];

	NSError *error = nil; 
	
	NSArray *array = [context executeFetchRequest:request error:&error];
	
	if (!error & array != nil) {
		// schedule 
		int count = [array count];
		NSLog(@"Fetched %d objects", count);
		
		// short circuit out if we already know the decision
		// also prevents infinite loop at the end
		if (count == 0) return nil;
		if (count == 1) return [array objectAtIndex:0];
		
		NSMutableArray *m_array = [[NSMutableArray alloc] initWithCapacity:[array count]];
		[m_array addObjectsFromArray:array];
		
		
		// pre-sort it by due date, progress, and priority
		// eff_priority = priority * duration * progress / (due_date - today)
		NSComparator taskSorter = ^(id id1, id id2) {
			double effective_priority_1 = [[id1 valueForKey:@"priority"] doubleValue]
				* [[id1 valueForKey:@"duration"] doubleValue] * (1 - [[id1 valueForKey:@"progress"] doubleValue])
				/ [[id1 valueForKey:@"due_date"] timeIntervalSinceNow];
						
			double effective_priority_2 = [[id2 valueForKey:@"priority"] doubleValue]
				* [[id2 valueForKey:@"duration"] doubleValue] * (1 - [[id2 valueForKey:@"progress"] doubleValue])
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
		while (currentTask != nil && candidate.id == currentTask.id)
			candidate = [self getTaskWithPriorityArray:m_array];
		return candidate;
	}
	return nil;
}

- (BOOL)addTaskToCalendar:(Task *)aTask fromTime:(NSDate *)from toTime:(NSDate *)to {
	EKEventStore *eventStore = [[EKEventStore alloc] init];
	EKEvent *event = [EKEvent eventWithEventStore:eventStore];
	event.title = currentTask.name;
	event.startDate = from;
	event.endDate = to;
	[event setCalendar:[eventStore defaultCalendarForNewEvents]];
	
	NSError *error;
	[eventStore	saveEvent:event span:EKSpanThisEvent error:&error];
	if (error == noErr) {
		//UIAlertView *alert = [[UIAlertView alloc]
//							  initWithTitle:@"Task Added to Calendar"
//							  message:[NSString stringWithFormat:@"Start working on %@, and come back when you're done!", currentTask.name]
//							  delegate:nil
//							  cancelButtonTitle:@"Okay"
//							  otherButtonTitles:nil];
//		[alert show];
//		[alert release];
		[eventStore release];
		return YES;
	}
	[eventStore release];
	
	return NO;
}

- (EKEvent *)getNextCalendarTask {
	
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
	if ([calendarTasks count] == 0)
		return nil;
	
	for (int i = 0; i < [calendarTasks count]; i++) {
		EKEvent *event = [calendarTasks objectAtIndex:i];
		if ([event.startDate timeIntervalSinceNow] > 0) break;
		if ([event.endDate timeIntervalSinceNow] < 0) continue;
		NSLog(@"found calendar task: %@", [event description]);
		return event;
	}
	return nil;
}

//+ (Task*) currentTask {
//	return currentTask;
//}
//
//+ (BOOL) busy {
//	return busy;
//}

@end
