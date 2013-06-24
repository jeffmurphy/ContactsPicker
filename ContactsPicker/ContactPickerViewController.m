//
//  ContactPickerViewController.m
//  Ensemble
//
//  Created by Jeffrey Murphy on 5/21/13.
//  Copyright (c) 2013 Nickel City Software LLC. All rights reserved.
//

#import "ContactPickerViewController.h"
#import <AddressBook/AddressBook.h>

@interface ContactPickerViewController ()

@property (nonatomic, retain) NSMutableArray *lastNames;
@property (nonatomic, retain) NSMutableArray *firstNames;
@property (nonatomic, retain) NSMutableArray *selected;
@property (nonatomic, retain) NSMutableArray *emails;
@property (nonatomic, retain) NSMutableDictionary *countByFirstLetterOfLastName;
@property (nonatomic, retain) NSMutableArray *sectionOffset;
@property (nonatomic, retain) NSArray *AB;

@end

@implementation ContactPickerViewController

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSIndexPath *oldIndex = [self.tableView indexPathForSelectedRow];
    //[self.tableView cellForRowAtIndexPath:oldIndex].accessoryType = UITableViewCellAccessoryNone;
    [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    return indexPath;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSIndexPath *oldIndex = [self.tableView indexPathForSelectedRow];
    //[self.tableView cellForRowAtIndexPath:oldIndex].accessoryType = UITableViewCellAccessoryCheckmark;
    [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    return indexPath;
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *offset = [NSNumber numberWithInt:0];
    
    if ([indexPath section] > 0) {
        offset = [self.sectionOffset objectAtIndex:[indexPath section]-1];
    }
    int element = [offset intValue] + [indexPath row];

    
    [self.selected setObject:[NSNumber numberWithInt:0] atIndexedSubscript:element];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *offset = [NSNumber numberWithInt:0];
    
    if ([indexPath section] > 0) {
        offset = [self.sectionOffset objectAtIndex:[indexPath section]-1];
    }
    int element = [offset intValue] + [indexPath row];

    
    [self.selected setObject:[NSNumber numberWithInt:1] atIndexedSubscript:element];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 26;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSNumber *cc = [self.countByFirstLetterOfLastName objectForKey:[self.AB objectAtIndex:section]];
    return [cc intValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyCell" forIndexPath:indexPath];
    
    NSNumber *offset = [NSNumber numberWithInt:0];
    
    if ([indexPath section] > 0) {
        offset = [self.sectionOffset objectAtIndex:[indexPath section]-1];
    }
    
    //NSLog(@"section %d offset %d", [indexPath section], [offset intValue]);
    
    int element = [offset intValue] + [indexPath row];
    NSString *fn = [self.firstNames objectAtIndex:element];
    NSString *ln = [self.lastNames objectAtIndex:element];
    NSNumber *s = [self.selected objectAtIndex:element];
    
    NSString *celltext = [[NSString alloc] initWithFormat:@"%@ %@", ln, fn, nil];

    cell.textLabel.text = celltext;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if ([s intValue] == 0)
        cell.accessoryType = UITableViewCellAccessoryNone;
    else
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.AB;
}

- (IBAction) doneButtonPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(contactPickerDoneWithResults:)]) {
        NSMutableArray *rv = [[NSMutableArray alloc] init];
        int idx = 0;
        
        for (NSNumber *val in self.selected) {
            if ([val intValue] == 1) {
                [rv addObject:[self.emails objectAtIndex:idx]];
            }
            idx++;
        }

        [self.delegate contactPickerDoneWithResults:rv];
        [self.navigationController popViewControllerAnimated:YES];
    }

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.AB =   [[NSArray alloc] initWithObjects:
                                @"A", @"B", @"C", @"D", @"E", @"F",
                                @"G", @"H", @"I", @"J", @"K", @"L",
                                @"M", @"N", @"O", @"P", @"Q", @"R",
                                @"S", @"T", @"U", @"V", @"W", @"X",
                                @"Y", @"Z", nil];
    
    CFErrorRef *error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions (
                                                     NULL,
                                                     error
                                                     );
    
    
    if (error) { NSLog(@"error"); }
    
    __block BOOL accessGranted = NO;
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        accessGranted = granted;
        dispatch_semaphore_signal(sema);
    });
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    // http://stackoverflow.com/questions/3184718/getting-iphone-addressbook-contents-without-gui
    
    
    if (accessGranted) {
        ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
        NSArray *thePeople = (__bridge NSArray*)ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByLastName);

        self.emails = [[NSMutableArray alloc] init];
        self.lastNames = [[NSMutableArray alloc] init];
        self.firstNames = [[NSMutableArray alloc] init];
        self.selected = [[NSMutableArray alloc] init];
        self.sectionOffset = [[NSMutableArray alloc] init];
                
        // http://stackoverflow.com/questions/2613045/reading-email-address-from-contacts-fails-with-weird-memory-issue
        
        NSUInteger peopleCounter = 0;
        NSMutableArray *Zs = [[NSMutableArray alloc] initWithCapacity:26];
        for(int i = 0 ; i < 26 ; i++) {
            [Zs addObject:[NSNumber numberWithInt:0]];
        }
        
        self.countByFirstLetterOfLastName =
        [[NSMutableDictionary alloc]
         initWithObjects:Zs
         forKeys:[[NSArray alloc]
                            initWithObjects:
                                   @"A", @"B", @"C", @"D", @"E", @"F",
                                   @"G", @"H", @"I", @"J", @"K", @"L",
                                   @"M", @"N", @"O", @"P", @"Q", @"R",
                                   @"S", @"T", @"U", @"V", @"W", @"X",
                                   @"Y", @"Z", nil]];
        
        for (peopleCounter = 0;peopleCounter < [thePeople count]; peopleCounter++) {
            ABRecordRef thisPerson = (__bridge ABRecordRef) [thePeople objectAtIndex:peopleCounter];
            
            if (ABRecordCopyValue(thisPerson, kABPersonKindProperty) == kABPersonKindPerson) {
                //NSString *name = (__bridge_transfer NSString *) ABRecordCopyCompositeName(thisPerson);
                
                NSString *firstName = (__bridge NSString *)ABRecordCopyValue(thisPerson, kABPersonFirstNameProperty);
                NSString *lastName = (__bridge NSString *)ABRecordCopyValue(thisPerson,
                                                                            kABPersonLastNameProperty);
                
                ABMultiValueRef multi =  ABRecordCopyValue(thisPerson, kABPersonEmailProperty);
                CFIndex emailCount = ABMultiValueGetCount(multi);
                
                if (emailCount > 0) {
                    // we only take the first email found
                    CFStringRef emailRef = ABMultiValueCopyValueAtIndex(multi, 0);
                    if (emailRef != nil) {
                        [self.emails addObject:(__bridge NSString *)emailRef];
                        if (lastName)
                            [self.lastNames addObject:lastName];
                        else
                            [self.lastNames addObject:@""];
                        if (firstName)
                            [self.firstNames addObject:firstName];
                        else
                            [self.firstNames addObject:@""];
                        [self.selected addObject:[NSNumber numberWithInt:0]];
                        
                        NSString *fl = nil;
                        if (firstName)
                            fl = [firstName substringToIndex:1];
                        if (lastName)
                            fl = [lastName substringToIndex:1];
                        
                        if (fl) {
                            NSNumber *cc = [self.countByFirstLetterOfLastName objectForKey:[fl uppercaseString]];
                            int _cc = [cc intValue] + 1;
                            [self.countByFirstLetterOfLastName setObject:[NSNumber numberWithInt:_cc] forKey:[fl uppercaseString]];
                        }
                        //NSLog(@"Name = %@ %@ -- %@", lastName, firstName, (__bridge NSString *)emailRef);
                    }
                    
                }
            }
        }
        
        int sum = 0;
        for (NSString *flln in self.AB) {
            NSNumber *cc = [self.countByFirstLetterOfLastName objectForKey:flln];
            sum += [cc intValue];
            [self.sectionOffset addObject:[NSNumber numberWithInt:sum]];
        }
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
