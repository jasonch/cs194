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
#import <AudioToolbox/AudioServices.h>
#import "BlacklistViewController.h"
#import "Task.h"

@interface WhatNowViewController : UIViewController {	
	NSManagedObjectContext *context;
	NSMutableArray *blacklist;
	NSMutableArray *calendarTasks;
	Task *currentTask;
	EKEventStore *eventStore;
	BOOL busy;
	IBOutlet UITextView *taskLabel;
	IBOutlet UILabel *freeTimeLabel;
	IBOutlet UIButton *startButton;
	IBOutlet UIButton *blacklistButton;
}


-initInManagedObjectContext:(NSManagedObjectContext*)aContext;
-(void)startPressed:(UIButton*)sender;
-(void)pausePressed:(UIButton*)sender;
-(void)startPressedWithTask:(NSNotification *)note;
-(void)pausePressedWithTask:(NSNotification *)note;
-(void)completePressedWithTask:(NSNotification *)note;
-(void)blacklistPressed:(UIButton*)sender; 
-(void)viewBlacklist;
-(Task *)checkAndUpdateTaskDB;
-(void)checkAndSetCurrentTask;
-(void) checkForLateTasks;
-(void)getTaskFromCalendar;
-(EKEvent *)getCurrentCalendarTask;
-(EKEvent *)getNextCalendarTask;
-(void)updateCurrentTask;
-(BOOL)canBecomeFirstResponder;
-(void)viewDidAppear:(BOOL)animated;
-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event;
-(Task *)getNextScheduledTaskWithDurationOf: (double)spare;
-(BOOL)ScheduleFeasibleWith:(NSMutableArray *)m_array at:(int)k;
-(void)MutableArraySwap:(NSMutableArray *)m_array indexOne:(int)i indexTwo:(int)j;
-(BOOL)addTaskToCalendar:(Task *)aTask fromTime:(NSDate *)from toTime:(NSDate *)to;
-(BOOL)updateProgressOfTask:(Task *)task;


@end
