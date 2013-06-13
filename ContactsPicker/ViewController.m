//
//  ViewController.m
//  ContactsPicker
//
//  Created by Jeffrey Murphy on 6/12/13.
//  Copyright (c) 2013 Nickel City Software LLC. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, retain) IBOutlet UITextView *tv;

@end

@implementation ViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SegueToContactPicker"])
    {
        self.tv.text = nil;
        [[segue destinationViewController] setDelegate:self];
    }
}

- (void)contactPickerDoneWithResults:(NSArray *)results
{
    for (NSString *email in results) {
        self.tv.text = [self.tv.text stringByAppendingString:email];
        self.tv.text = [self.tv.text stringByAppendingString:@"\n"];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
