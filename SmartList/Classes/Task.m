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
@dynamic duration;
@dynamic sittings;
@dynamic progress;
@dynamic name;
@dynamic priority;
@dynamic user;


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
	}
	return task;
}

@end
