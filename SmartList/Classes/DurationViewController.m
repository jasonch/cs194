//
//  DurationViewController.m
//  SmartList
//
//  Created by Justine DiPrete on 4/24/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import "DurationViewController.h"


@implementation DurationViewController

@synthesize durationPicker;
@synthesize delegate;

-(void) setup
{	
	minuteArray = [[NSMutableArray alloc] init];
	[minuteArray addObject:@"0 minutes"];
	[minuteArray addObject:@"15 minutes"];
	[minuteArray addObject:@"30 minutes"];
	[minuteArray addObject:@"45 minutes"];
	
	hourArray = [[NSMutableArray alloc] init];
	for (int i = 0; i < 200; i++)
	{
		NSString *hourString = @"";
		hourString = [hourString stringByAppendingString: [NSString stringWithFormat:@"%d", i]];
		if (i != 1)
		{
			hourString = [hourString stringByAppendingString: @" hours"];
		}else {
			hourString = [hourString stringByAppendingString: @" hour"];
		}

		[hourArray addObject:hourString];
	}
}

-(void) viewDidLoad
{
	self.title = @"Duration";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(saveDuration)];
	[self setup];
}

-(void)saveDuration
{
	float hour = [durationPicker selectedRowInComponent:0];
	int minute = [durationPicker selectedRowInComponent:1];
	switch (minute) {
		case 0:
			break;
		case 1:
			hour += 0.25;
			break;
		case 2:
			hour += 0.5;
			break;
		case 3:
			hour += 0.75;
			break;
		default:
			break;
	}
	[self.delegate setDuration:hour];
	[self.navigationController popViewControllerAnimated:YES];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
	return 2;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
	if (component == 0)
	{
		return [hourArray count];
	}
	else
	{
		return [minuteArray count];
	}
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	if (component == 0)
	{
		return [hourArray objectAtIndex:row];
	}
	else 
	{
		return [minuteArray objectAtIndex:row];
	}

}

- (void)dealloc {
    [super dealloc];
}


@end
