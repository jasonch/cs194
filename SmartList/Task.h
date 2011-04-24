//
//  Task.h
//  SmartList
//
//  Created by Justine DiPrete on 4/24/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Task :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSDate * creation_time;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSDate * due_date;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * sittings;
@property (nonatomic, retain) NSDecimalNumber * progress;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) NSManagedObject * user;

@end



