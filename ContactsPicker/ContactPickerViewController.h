//
//  ContactPickerViewController.h
//  Ensemble
//
//  Created by Jeffrey Murphy on 5/21/13.
//  Copyright (c) 2013 Nickel City Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ContactPickerDelegate;

@interface ContactPickerViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<ContactPickerDelegate> delegate;
- (IBAction) doneButtonPressed:(id)sender;

@end



@protocol ContactPickerDelegate <NSObject>

@required

- (void)contactPickerDoneWithResults:(NSArray *)results;


@end