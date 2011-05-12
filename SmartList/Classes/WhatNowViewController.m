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
	[sender setTitle: @"Finished" forState: UIControlStateNormal];
//	[sender setTitle: @"Finished" forState: UIControlStateApplication];
//	[sender setTitle: @"Finished" forState: UIControlStateHighlighted];
//	[sender setTitle: @"Finished" forState: UIControlStateReserved];
//	[sender setTitle: @"Finished" forState: UIControlStateSelected];
//	[sender setTitle: @"Finished" forState: UIControlStateDisabled];
}


-(IBAction)blacklistPressed:(UIButton*)sender
{
	
}

#pragma mark Shake Functionality
-(BOOL)canBecomeFirstResponder {
    return YES;
}

-(void)viewDidAppear:(BOOL)animated {
    [self becomeFirstResponder];
}

- (void) updateWhatNowTask {
	Task * task = [self getNextScheduledTaskWithDurationOf:2.0];
	if (task == nil)
		[taskLabel setText:@"No task to schedule"];
	else
		[taskLabel setText:[NSString stringWithFormat:@"%@",task.name]];
	NSLog(@"%@", [task description]);
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	if (event.type == UIEventSubtypeMotionShake) {
		[self updateWhatNowTask];
	}
}


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self setup];
	[self updateWhatNowTask];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
	
	// use a parabolic function to give higher priority more weight
	int total = (count - 1) * count * (2*count - 1) / 6;
	
	int rand = arc4random() % (1 + total);
	rand = sqrt(rand + 0.0);

	// reverse the index because zero priority is highest
	int index = count - rand - 1; 
	
	return [m_array objectAtIndex:rand];
}


- (Task *)getNextScheduledTaskWithDurationOf: (double)spareTime {
	
	NSLog(@"Get Next Scheduled Task");
		
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	request.entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"status == 0 AND chunk_size <= %d", spareTime];

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



@end
