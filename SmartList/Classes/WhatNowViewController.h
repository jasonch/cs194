//
//  WhatNowViewController.h
//  SmartList
//
//  Created by Justine DiPrete on 4/18/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EKEventStore.h>
#import <EventKit/EKEvent.h>
#import "BlacklistViewController.h"
#import "Task.h"

@interface WhatNowViewController : UIViewController {	
	NSManagedObjectContext *context;
	NSMutableArray *blacklist;
	NSMutableArray *calendarTasks;
	Task *currentTask;
	BOOL busy;
	IBOutlet UILabel *taskLabel;
	IBOutlet UILabel *freeTimeLabel;
}


-initInManagedObjectContext:(NSManagedObjectContext*)aContext;
-(IBAction)startPressed:(UIButton*)sender;
-(IBAction)finishPressed:(UIButton*)sender;
-(IBAction)blacklistPressed:(UIButton*)sender; 
-(void)viewBlacklist;
-(void)getTaskFromCalendar;
-(void)updateCurrentTask;
-(BOOL)canBecomeFirstResponder;
-(void)viewDidAppear:(BOOL)animated;
-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event;
-(Task *)getNextScheduledTaskWithDurationOf: (double)spare;
-(BOOL)ScheduleFeasibleWith:(NSMutableArray *)m_array at:(int)k;
-(void)MutableArraySwap:(NSMutableArray *)m_array indexOne:(int)i indexTwo:(int)j;
-(BOOL)addCurrentTaskToCalendar;
-(BOOL)updateProgressOfTask:(Task *)task;

@end
