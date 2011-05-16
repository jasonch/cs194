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
	
	UIBarButtonItem *blacklistButton = [[UIBarButtonItem alloc] initWithTitle:@"Blacklist" style:UIBarButtonItemStyleBordered target:self action:@selector(viewBlacklist)];
	self.navigationItem.rightBarButtonItem = blacklistButton;
	[blacklistButton release];

	// set up blacklist
	blacklist = [[[NSMutableArray alloc] init] retain];   	
	
	currentTask = [Task findTask:taskLabel.text inManagedObjectContext:context]; 	// placeholder
	calendarTasks = nil;

	[self updateCurrentTask];
}

-initInManagedObjectContext:(NSManagedObjectContext*)aContext
{
	context = aContext;
	[self setup];
	return self;
}


-(IBAction)startPressed:(UIButton*)sender
{
	[freeTimeLabel setText:@"You are currently working on..."];
	
	if ([self addCurrentTaskToCalendar] == YES) {
		// do something like update the task status in the DB
		[currentTask setValue:[NSNumber numberWithInt:1] forKey:@"status"]; // 1 => started
	}
	
	[sender setTitle: @"Finished" forState: UIControlStateNormal];
	[sender addTarget:self action:@selector(finishPressed:) forControlEvents:UIControlEventTouchUpInside];
}

-(IBAction)finishPressed:(UIButton*)sender
{
	[freeTimeLabel setText:@"You have some free time!"];
	[sender setTitle: @"Start" forState: UIControlStateNormal];
	[sender addTarget:self action:@selector(startPressed:) forControlEvents:UIControlEventTouchUpInside];
	
	//[context deleteObject:(NSManagedObject*)currentTask];
	[self updateCurrentTask];
}


-(IBAction)blacklistPressed:(UIButton*)sender
{
	
	if (currentTask == nil)
		return;
	
	
	NSString *blacklisted = [NSString stringWithFormat:@"'%@' will no longer be scheduled until you remove it from the Blacklist",
						 taskLabel.text];
	UIAlertView *blacklistAlert = [[UIAlertView alloc] initWithTitle: @"Task blacklisted" message: blacklisted
													   delegate:self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
	
	[blacklistAlert show];
	[blacklistAlert release];
	
	[blacklist addObject:currentTask];

	[currentTask setValue:[NSNumber numberWithBool:YES] forKey:@"blacklisted"];
	
	[self updateCurrentTask];
}


-(void)viewBlacklist
{		
	BlacklistViewController *bvc = [[BlacklistViewController alloc] initInManagedObjectContext:context withBlacklist:blacklist];
	[self.navigationController pushViewController:bvc animated:YES];
	[bvc release];
}

-(void) updateCurrentTask {
	Task * task = [self getNextScheduledTaskWithDurationOf:2.0];
	if (task == nil)
		[taskLabel setText:@"No task to schedule!"];
	else
		[taskLabel setText:[NSString stringWithFormat:@"%@",task.name]];
	currentTask = task;
	NSLog(@"%@", [task description]);
}

#pragma mark Shake Functionality
-(BOOL)canBecomeFirstResponder {
    return YES;
}


- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	if (event.type == UIEventSubtypeMotionShake) {
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
		
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
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
			if (feasible == NO)
				return nil;
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
							  message:[NSString stringWithFormat:@"Start working on %@, and come back when you're finished!", currentTask.name]
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
