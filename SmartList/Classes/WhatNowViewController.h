//
//  WhatNowViewController.h
//  SmartList
//
//  Created by Justine DiPrete on 4/18/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WhatNowViewController : UIViewController {	
	NSManagedObjectContext *context;
	IBOutlet UILabel *taskLabel;
	IBOutlet UILabel *freeTimeLabel;
}


-initInManagedObjectContext:(NSManagedObjectContext*)aContext;
-(IBAction)startPressed:(UIButton*)sender;
-(IBAction)blacklistPressed:(UIButton*)sender; 
-(BOOL)canBecomeFirstResponder;
-(void)viewDidAppear:(BOOL)animated;
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event;

@end
