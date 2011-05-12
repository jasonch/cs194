//
//  WhatNowViewController.h
//  SmartList
//
//  Created by Justine DiPrete on 4/18/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlacklistViewController.h"
#import "Task.h"

@interface WhatNowViewController : UIViewController {	
	NSManagedObjectContext *context;
	NSMutableArray *blacklist;
	Task *currentTask;
	IBOutlet UILabel *taskLabel;
	IBOutlet UILabel *freeTimeLabel;
}


-initInManagedObjectContext:(NSManagedObjectContext*)aContext;
-(IBAction)startPressed:(UIButton*)sender;
-(IBAction)finishPressed:(UIButton*)sender;
-(IBAction)blacklistPressed:(UIButton*)sender; 
-(void)viewBlacklist;
-(void)updateCurrentTask;
-(BOOL)canBecomeFirstResponder;
-(void)viewDidAppear:(BOOL)animated;
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event;

@end
