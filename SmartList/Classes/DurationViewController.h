//
//  DurationViewController.h
//  SmartList
//
//  Created by Justine DiPrete on 4/24/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DurationViewController;

@protocol DurationViewControllerDelegate <NSObject>

-(void)setDuration: (float) aDuration;

@end


@interface DurationViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate> {
	NSMutableArray *minuteArray;
	NSMutableArray *hourArray;
}

@property(assign) id delegate;
@property (nonatomic, retain) IBOutlet UIPickerView *durationPicker;

@end
