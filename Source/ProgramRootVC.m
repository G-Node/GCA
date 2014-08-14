//
//  ProgramRootVC.m
//  INCF 13
//
//  Created by Christian Kellner on 15/08/2013.
//  Copyright (c) 2013 G-Node. All rights reserved.
//

#import "ProgramRootVC.h"
#import "ProgramDayTVC.h"
#import "UIColor+ConferenceKit.h"

@interface ProgramRootVC () <ProgramDayDelegate>

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *dayLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *dayNext;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *dayPrev;

@property (weak, nonatomic) IBOutlet UIView *container;

@property (strong, nonatomic) NSLayoutConstraint *leftConstraint;

@property (strong, nonatomic) NSDateFormatter *dayDateFormatter;
@property (strong, nonatomic) NSArray *dayController; //of type ProgramDayTVC
@property (nonatomic) NSInteger dayIndex;
@end

@implementation ProgramRootVC
@synthesize dayIndex = _dayIndex;

#pragma mark layout

- (void)addConstraintsForView:(UIView *)view leftOf:(UIView *)leftView
{
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:view
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.container
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1.0f
                                                               constant:0];
    
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:view
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.container
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1.0f
                                                             constant:0];
    
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:view
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.container
                                                               attribute:NSLayoutAttributeHeight
                                                              multiplier:1.0f
                                                                constant:0];
    NSLayoutConstraint *left = nil;
    if (leftView) {
        left = [NSLayoutConstraint constraintWithItem:view
                                            attribute:NSLayoutAttributeLeft
                                            relatedBy:NSLayoutRelationEqual
                                               toItem:leftView
                                            attribute:NSLayoutAttributeRight
                                           multiplier:1.0f
                                             constant:0];
        
        
    } else {
        left = [NSLayoutConstraint constraintWithItem:view
                                            attribute:NSLayoutAttributeLeft
                                            relatedBy:NSLayoutRelationEqual
                                               toItem:self.container
                                            attribute:NSLayoutAttributeLeft
                                           multiplier:1.0f
                                             constant:0];
        self.leftConstraint = left;
    }
    
    [self.container addConstraint:left];
    [self.container addConstraint:width];
    [self.container addConstraint:top];
    [self.container addConstraint:height];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                               duration:(NSTimeInterval)duration
{
    self.dayNext.enabled = NO;
    self.dayPrev.enabled = NO;
    [self.view setNeedsUpdateConstraints];
}


-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.leftConstraint.constant = -1.0f * self.view.frame.size.width * self.dayIndex;
    [self.container layoutIfNeeded];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //Bug in ios??
    for (ProgramDayTVC *pdvc in self.dayController) {
        CGSize contentSize = pdvc.tableView.contentSize;
        contentSize.width = pdvc.tableView.bounds.size.width;
        pdvc.tableView.contentSize = contentSize;
    }
    
    self.dayPrev.enabled = self.dayIndex != 0;
    self.dayNext.enabled = self.dayIndex != self.dayController.count - 1;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.toolbar.tintColor = [UIColor ckColor];
    self.container.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"Program" ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:dataPath];
    id list= [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (![list isKindOfClass:[NSArray class]]) {
        NSLog(@"Error parsing program file");
        return;
    }
    
    NSArray *days = (NSArray *) list;
    
    NSDateFormatter *dayDateFormatter = [[NSDateFormatter alloc] init];
    [dayDateFormatter setDateFormat:@"dd.MM.yyyy"];
    
    NSMutableArray *vcList = [[NSMutableArray alloc] initWithCapacity:days.count];
    
    UIView *lastView = nil;
    
    for (NSDictionary *dayDict in days) {
        NSString *dateString = [dayDict objectForKey:@"date"];
        NSDate *date = [dayDateFormatter dateFromString:dateString];
        
        ProgramDayTVC *pdvc = [[ProgramDayTVC alloc] initWithNibName:@"ProgramDayTVC" bundle:nil];
        pdvc.events = [dayDict objectForKey:@"events"];
        pdvc.date = date;
        pdvc.delegate = self;
        pdvc.view.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.container addSubview:pdvc.view];
        [self addConstraintsForView:pdvc.view leftOf:lastView];
        lastView = pdvc.view;

        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            pdvc.tableView.contentInset = UIEdgeInsetsMake(10, 0, 88, 0);
        }
        
        [vcList addObject:pdvc];
    }
    
    
    self.dayController = vcList;
    
    self.dayDateFormatter = [[NSDateFormatter alloc] init];
    [self.dayDateFormatter setDateFormat:@"EEEE, dd.MM."];
    
    self.dayIndex = 0;
}


- (void) setDayIndex:(NSInteger)dayIndex
{
    self.dayPrev.enabled = dayIndex != 0;
    self.dayNext.enabled = dayIndex != self.dayController.count - 1;
    
    ProgramDayTVC *pdvc = self.dayController[dayIndex];
    self.dayLabel.title = [self.dayDateFormatter stringFromDate:pdvc.date];
    
    _dayIndex = dayIndex;
}


- (IBAction)prevDay:(id)sender
{
    self.dayIndex--;
    self.leftConstraint.constant += self.view.frame.size.width;
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
    

}

- (IBAction)nextDay:(id)sender
{
    self.dayIndex++;
    self.leftConstraint.constant -= self.view.frame.size.width;
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark -
#pragma mark ProgramDayDelegate

-(void)programDay:(ProgramDayTVC *)programDay didSelectEvent:(NSDictionary *)event
{
    
}

@end
