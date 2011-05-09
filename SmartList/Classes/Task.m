// 
//  Task.m
//  SmartList
//
//  Created by Justine DiPrete on 4/24/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import "Task.h"


@implementation Task 

@dynamic status;
@dynamic creation_time;
@dynamic id;
@dynamic due_date;
@dynamic progress;
@dynamic name;
@dynamic priority;
@dynamic user;
@dynamic chunk_size;
@dynamic duration;






+(Task*) taskWithName:(NSString*)aName inManagedObjectContext:(NSManagedObjectContext*)aContext
{
	Task *task = nil;
		
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	request.entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:aContext];
	request.predicate = [NSPredicate predicateWithFormat:@"name =[c] %@", aName];
	NSError *error = nil;
	task = [[aContext executeFetchRequest:request error:&error] lastObject];
	
	if (!error && !task) {
		task = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:aContext];
		task.name = aName;
		
		//defaults
		task.status = [NSNumber numberWithInt:0];
		task.progress = [NSDecimalNumber decimalNumberWithString:@"0.0"];
		task.creation_time = [[[NSDate alloc] init] autorelease];
		task.user = nil;
		
	}
	return task;
}

// This code is duplicate. Find a way to condense it with the above function while maintaining the full functionality.
+(BOOL) checkExistenceOfTask:(NSString*)aName inManagedObjectContext:(NSManagedObjectContext*)aContext 
{
	Task *task = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	request.entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:aContext];
	request.predicate = [NSPredicate predicateWithFormat:@"name =[c] %@", aName];
	NSError *error = nil;
	task = [[aContext executeFetchRequest:request error:&error] lastObject];
	
	if (task) return YES;	
	return NO;
}

@end
