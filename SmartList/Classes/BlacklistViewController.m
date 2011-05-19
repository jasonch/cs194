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
	
	NSArray *fetchResults = [[NSArray alloc] init];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	request.entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"blacklisted = %@ AND (status == 0 OR status == 1)", [NSNumber numberWithBool:YES]];
	NSError *error = nil;
	fetchResults = [context executeFetchRequest:request error:&error];
	NSLog(@"%@", fetchResults); //works ok
	
	blacklist = [[NSMutableArray arrayWithArray:fetchResults] retain];
	
	
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
	Task *task = (Task*)[blacklist objectAtIndex:indexPath.row];
    [cell.textLabel setText:task.name];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	Task *task = (Task*)[blacklist objectAtIndex:indexPath.row];
	
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
		Task *deleted = [blacklist objectAtIndex:indexPath.row];
		[deleted setValue:[NSNumber numberWithBool:NO] forKey:@"blacklisted"];
		NSLog (@"unblacklisted: %@", [deleted description]);
		[blacklist removeObjectAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.tableView reloadData];
}

- (void)dealloc {
    [super dealloc];
}

@end
