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
	
	NSString *blacklisted = [NSString stringWithFormat:@"You have blacklisted the task '%@'",
						 taskLabel.text];
	UIAlertView *blacklistAlert = [[UIAlertView alloc] initWithTitle: @"Task blacklisted" message: blacklisted
													   delegate:self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
	
	[blacklistAlert show];
	[blacklistAlert release];
	
	[blacklist addObject:taskLabel.text]; //[blacklist addObject:currentTask.name];
	[self updateCurrentTask];
}


-(void)viewBlacklist
{		
	BlacklistViewController *bvc = [[BlacklistViewController alloc] initInManagedObjectContext:context withBlacklist:blacklist];
	[self.navigationController pushViewController:bvc animated:YES];
	[bvc release];
}

-(void) updateCurrentTask {
	//currentTask = some new task;
	//make sure this task is not on the blacklist
	//taskLabel.text = currentTask.name;
}

#pragma mark Shake Functionality
-(BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	if (event.type == UIEventSubtypeMotionShake) {
		[taskLabel setText:@"New task!"]; //placeholder
		[self updateCurrentTask];
	}
}

#pragma mark memory management

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// accessing calendar
	
	/*
	 NOTE: need to import proper files!
	 
	EKEventStore *eventStore = [[EKEventStore alloc] init];
	
	 can use this method to look up events within the specified time range
	 
	 - (NSPredicate *)predicateForEventsWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate calendars:(NSArray *)calendars
	 
	 followed by
	 
	 - (NSArray *)eventsMatchingPredicate:(NSPredicate *)predicate

	 we can then use this array of EKEvent objects to make our What Now? suggestion make sense by checking start/end date, and even location if we want to
	 
	 */
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


@end
