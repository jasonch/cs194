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

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	if (event.type == UIEventSubtypeMotionShake) {
		[taskLabel setText:@"New task!"];
		[self getNextScheduledTaskWithDurationOf:2.0];

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
	[self getNextScheduledTaskWithDurationOf:2.0];
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

- (Task *)getNextScheduledTaskWithDurationOf: (double)spareTime {
	
	NSLog(@"Get Next Scheduled Task");
	
	Task *task = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	request.entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:context];
	//request.predicate = [NSPredicate predicateWithFormat:@"status == 0 AND chunk_size < %d", spareTime]; 
	request.predicate = nil;
	
	NSError *error = nil; 
	
	NSArray *array = [[context executeFetchRequest:request error:&error] lastObject];

	NSLog(@"Fetched %d objects", [array count]);
	
	if (!error & array != nil) {
		int count = [array count];
		for (int i = 0; i < count; i++) {
			//NSLog (@"%d. %@\n", i, [array objectAtIndex:i]);
		}
	}

	
	return nil;
}




@end
