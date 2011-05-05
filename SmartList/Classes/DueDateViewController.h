//
//  DueDateViewController.h
//  SmartList
//
//  Created by Justine DiPrete on 4/24/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DueDateViewController;

@protocol DueDateViewControllerDelegate <NSObject>

-(void)setDate: (NSDate*) aDate;

@end

@interface DueDateViewController : UIViewController {
	IBOutlet UIDatePicker *dueDatePicker;
}

@property(assign) id delegate;

-initWithDate:(NSDate*)aDate;

@end



