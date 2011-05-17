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

	startButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	startButton.frame = CGRectMake(30, 300, 125, 40);
	[startButton setTitle:@"Start" forState:UIControlStateNormal];
	[startButton setTitleColor: [UIColor grayColor] forState:UIControlStateDisabled];
	[startButton addTarget:self action:@selector(startPressed:) forControlEvents:UIControlEventTouchUpInside];
	blacklistButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	blacklistButton.frame = CGRectMake(170, 300, 125, 40);
	[blacklistButton setTitle:@"Blacklist" forState:UIControlStateNormal];
	[blacklistButton addTarget:self action:@selector(blacklistPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:startButton];
	[self.view addSubview:blacklistButton];
	
	currentTask = [Task findTask:taskLabel.text inManagedObjectContext:context]; 	// placeholder
	calendarTasks = nil;

	busy = NO;
	
	[self updateCurrentTask];
}

-initInManagedObjectContext:(NSManagedObjectContext*)aContext
{
	context = aContext;
	[self setup];
	return self;
}


-(void)startPressed:(UIButton*)sender
{
	
	if (!busy && [self addCurrentTaskToCalendar] == YES) {
		[freeTimeLabel setText:@"You are currently working on..."];

		[currentTask setValue:[NSNumber numberWithInt:1] forKey:@"status"]; // 1 => started
		[currentTask setValue:[NSDate date] forKey:@"started_time"];
		[sender setTitle: @"Pause" forState: UIControlStateNormal];
		[sender addTarget:self action:@selector(pausePressed:) forControlEvents:UIControlEventTouchUpInside];
		busy = YES;
		NSLog (@"%@", [currentTask description]);
	}
}

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
	[sender addTarget:self action:@selector(startPressed:) forControlEvents:UIControlEventTouchUpInside];
	
	// update database
	[self updateProgressOfTask:currentTask];	
	busy = NO;
	
	[self updateCurrentTask];
}


-(void)blacklistPressed:(UIButton*)sender
{
//	if (currentTask == nil) {
//		UIAlertView *noTasks = [[UIAlertView alloc] initWithTitle: @"No tasks" 
//														  message: @"Action could not be performed because there are no tasks in your QuickList." 
//														 delegate:self 
//												cancelButtonTitle: @"Ok" 
//												otherButtonTitles: nil];
//		
//		[noTasks show];
//		[noTasks release];
//		return;
//	} else if (busy) {
//		UIAlertView *currentlyBusy = [[UIAlertView alloc] initWithTitle: @"Task cannot be Blacklisted" 
//														  message: @"You cannot Blacklist a task you are currently working on. Pause or Complete the task." 
//														 delegate:self 
//												cancelButtonTitle: @"Ok" 
//												otherButtonTitles: nil];
//		
//		[currentlyBusy show];
//		[currentlyBusy release];
//		return;
//	}	
	
	if (currentTask == nil || busy) {
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
	BlacklistViewController *bvc = [[BlacklistViewController alloc] initInManagedObjectContext:context];
	[self.navigationController pushViewController:bvc animated:YES];
	[bvc release];
}

-(void) updateCurrentTask {
	
	// checks all started tasks and update their status if needed
	
	Task * task = [self getNextScheduledTaskWithDurationOf:2.0];
	if (task == nil) {
		busy = YES;
		[taskLabel setText:@"No task to schedule!"];
		//startButton.enabled = NO;
	} else
		[taskLabel setText:[NSString stringWithFormat:@"%@",task.name]];
		currentTask = task;
		NSLog(@"%@", [task description]);
		//startButton.enabled = YES;
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
	
	NSLog(@"%@", [calendarTasks description]);
	
}

-(void)viewDidAppear:(BOOL)animated {
    [self becomeFirstResponder];
	NSLog(@"refreshing What Now? view controller");
	[self updateCurrentTask];
	
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
	
	// use a parabolic function to give higher priority more weight
	int total = (count - 1) * count * (2*count - 1) / 6;
	
	int rand = arc4random() % (1 + total);
	rand = sqrt(rand + 0.0);

	// reverse the index because zero priority is highest
	int index = count - rand - 1; 
	
	return [m_array objectAtIndex:index];
}


- (Task *)getNextScheduledTaskWithDurationOf: (double)spareTime {
	
	NSLog(@"Get Next Scheduled Task");
		
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	
	request.entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"status == 0 AND chunk_size <= %d and blacklisted == NO", spareTime];

	NSError *error = nil; 
	
	NSArray *array = [context executeFetchRequest:request error:&error];
	
	if (!error & array != nil) {
		NSLog(@"Fetched %d objects", [array count]);

		// schedule 
		int count = [array count];
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
		return [self getTaskWithPriorityArray:m_array];
	}
	return nil;
}

- (BOOL)addCurrentTaskToCalendar {
	EKEventStore *eventStore = [[EKEventStore alloc] init];
	EKEvent *event = [EKEvent eventWithEventStore:eventStore];
	event.title = currentTask.name;
	event.startDate = [NSDate date];
	event.endDate = [NSDate dateWithTimeIntervalSinceNow:60*60*2];
	[event setCalendar:[eventStore defaultCalendarForNewEvents]];
	
	NSError *error;
	[eventStore	saveEvent:event span:EKSpanThisEvent error:&error];
	if (error == noErr) {
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"Task Added to Calendar"
							  message:[NSString stringWithFormat:@"Start working on %@, and come back when you're done!", currentTask.name]
							  delegate:nil
							  cancelButtonTitle:@"Okay"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
		[eventStore release];
		return YES;
	}
	[eventStore release];
	
	return NO;
}

- (EKEvent *)getNextCalendarTask {
	if ([calendarTasks count] == 0)
		return nil;	
	return nil;
}

@end
