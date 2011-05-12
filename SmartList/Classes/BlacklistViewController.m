//
//  BlacklistViewController.m
//  SmartList
//
//  Created by Anna Shtengelova on 5/11/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import "BlacklistViewController.h"


@implementation BlacklistViewController


-(void) setup
{
	self.title = @"Blacklist";	
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
}

-initInManagedObjectContext:(NSManagedObjectContext*)aContext withBlacklist:(NSMutableArray*)aBlacklist
{
	context = aContext;	
	blacklist = aBlacklist;
	
	if (self = [super initWithStyle:UITableViewStylePlain])
	{
		[self setup];
	}	
	
	return self;
}

#pragma mark tableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [blacklist count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath { 
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DefaultCell"]; 
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DefaultCell"] autorelease];
    }
    [cell.textLabel setText:[blacklist objectAtIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	Task *task = [Task findTask:[blacklist objectAtIndex:indexPath.row] inManagedObjectContext:context];
	
	ViewTaskViewController *vtvc = [[ViewTaskViewController alloc] initInManagedObjectContext:context withTask:task];
	[self.navigationController pushViewController:vtvc animated:YES];
	[vtvc release];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[blacklist removeObjectAtIndex:indexPath.row];
		// let what now? controller know
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
	}
}

- (void)dealloc {
    [super dealloc];
}

@end
