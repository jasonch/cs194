//
//  DueDateViewController.m
//  SmartList
//
//  Created by Justine DiPrete on 4/24/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import "DueDateViewController.h"


@implementation DueDateViewController

@synthesize delegate;

-initWithDate:(NSDate*)aDate
{
	dueDatePicker = [[UIDatePicker alloc] init];
	date = [[NSDate alloc] initWithDate:aDate];
	return self;
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


- (void) dateChanged:(id)sender{
    if ([[dueDatePicker date] timeIntervalSinceNow] < 525600*60*10)
    {
        int year = [[dueDatePicker date] timeIntervalSince1970]/(60*525600);
        year += 1970;
        NSString *yearString = @"";
        yearString = [yearString stringByAppendingFormat:@"%d", year];
        yearLabel.text = yearString;
    }else
    {
        [dueDatePicker setDate:[NSDate date]];
        yearLabel.text = @"";
    }
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"Deadline";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(saveDate)];
    [dueDatePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    if ([date timeIntervalSinceNow] < 525600*60*10)
    {
        [dueDatePicker setDate:date animated:NO];
        int year = [date timeIntervalSince1970]/(60*525600);
        year += 1970;
        NSString *yearString = @"";
        yearString = [yearString stringByAppendingFormat:@"%d", year];
        yearLabel.text = yearString;
    }else
    {
        [dueDatePicker setDate:[NSDate date]];
        yearLabel.text = @"";
    }
}

-(void)saveDate
{
	if ([[dueDatePicker date] timeIntervalSinceNow] < 900) { // within the next 15 minutes
		NSString *message = [NSString stringWithFormat:@"Deadline must be in the future."];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Invalid Deadline" message: message
														   delegate:self cancelButtonTitle: @"OK" otherButtonTitles: nil];
		
		[alert show];
		[alert release];	
		return;
	}
	
	[self.delegate setDate:[dueDatePicker date]];
	[self.navigationController popViewControllerAnimated:YES];
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
	[dueDatePicker release];
	[date release];
}


@end
