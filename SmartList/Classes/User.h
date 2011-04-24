//
//  User.h
//  SmartList
//
//  Created by Justine DiPrete on 4/24/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Task;

@interface User :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSSet* tasks;

@end


@interface User (CoreDataGeneratedAccessors)
- (void)addTasksObject:(Task *)value;
- (void)removeTasksObject:(Task *)value;
- (void)addTasks:(NSSet *)value;
- (void)removeTasks:(NSSet *)value;

@end

