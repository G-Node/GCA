//
//  InfoVC.m
//  INCF 13
//
//  Created by Christian Kellner on 16/08/2013.
//  Copyright (c) 2013 G-Node. All rights reserved.
//

#import "InfoVC.h"
#import "CKMarkdownParser.h"
#import "CKMarkdownView.h"
#import "UIColor+ConferenceKit.h"

@interface InfoVC ()
@property (weak, nonatomic) IBOutlet UIScrollView *container;
@property (strong, nonatomic) CKMarkdownView *mdView;
@end

@implementation InfoVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"info" ofType:@"md"];
    NSString *fileContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    NSAttributedString *attrStr = [CKMarkdownParser parseString:fileContents];
    
    self.mdView = [[CKMarkdownView alloc] init];
    self.mdView.fgColor = [UIColor whiteColor];
    self.mdView.backgroundColor = [UIColor ckColor];
    
    self.mdView.text = attrStr;
    self.mdView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.container addSubview:self.mdView];
    self.container.backgroundColor = [UIColor ckColor];
    
    CGFloat padding = 10;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        padding = 100;
    }
    
    CGFloat width = CGRectGetWidth(self.view.bounds) - 2*padding;
    UIView *mdView = self.mdView;
    
    //the logos bits
    UIImage *logoImage = [UIImage imageNamed:@"INCF-Logo"];
    UIImageView *logo = [[UIImageView alloc] initWithImage:logoImage];
    logo.translatesAutoresizingMaskIntoConstraints = NO;
    [self.container addSubview:logo];
 
    UIImage *gnodeLogo = [UIImage imageNamed:@"G-Node"];
    UIImageView *gnode = [[UIImageView alloc] initWithImage:gnodeLogo];
    gnode.translatesAutoresizingMaskIntoConstraints = NO;
    [self.container addSubview:gnode];
    gnode.backgroundColor = [UIColor whiteColor];
    
    UILabel *broughtBy = [[UILabel alloc] init];
    broughtBy.text = @"This App is brought to you by the German Neuroinformatics Node";
    broughtBy.font = [UIFont systemFontOfSize:9.0];
    broughtBy.textColor = [UIColor whiteColor];
    [self.container addSubview:broughtBy];
    broughtBy.translatesAutoresizingMaskIntoConstraints = NO;
    
    //Constraints
    NSDictionary *viewsMap = NSDictionaryOfVariableBindings(mdView, logo, gnode, broughtBy);
    
    [self.container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=pad)-[mdView(==width)]-(>=pad)-|"
                                                                           options:NSLayoutFormatAlignAllCenterY
                                                                           metrics:@{@"width" : @(width), @"pad" : @(padding)}
                                                                             views:viewsMap]];
    
//    [self.container addConstraint:[NSLayoutConstraint constraintWithItem:mdView
//                                 attribute:NSLayoutAttributeCenterX
//                                 relatedBy:NSLayoutRelationEqual
//                                    toItem:self.container
//                                 attribute:NSLayoutAttributeCenterX
//                                                multiplier:1.f constant:0.f]];
    
    
    [self.container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=pad)-[logo]-(>=pad)-|"
                                                                           options:NSLayoutFormatAlignAllCenterY
                                                                           metrics:@{@"width" : @(width), @"pad" : @(padding)}
                                                                             views:viewsMap]];
    
    
    [self.container addConstraint:[NSLayoutConstraint constraintWithItem:logo
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.container
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.f constant:0.f]];
    
    [self.container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=pad)-[gnode]-(>=pad)-|"
                                                                           options:0
                                                                           metrics:@{@"width" : @(width), @"pad" : @0.0f}
                                                                             views:viewsMap]];
    
    [self.container addConstraint:[NSLayoutConstraint constraintWithItem:gnode
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.container
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.f constant:0.f]];
    
    [self.container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=pad)-[broughtBy(==gnode)]-(>=pad)-|"
                                                                           options:0
                                                                           metrics:@{@"width" : @(width), @"pad" : @0.0f}
                                                                             views:viewsMap]];
    
    [self.container addConstraint:[NSLayoutConstraint constraintWithItem:broughtBy
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.container
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.f constant:0.f]];
    
    CGSize size = CGSizeMake(width, CGFLOAT_MAX);
    CGSize height = [self.mdView sizeThatFits:size];
    [self.container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[logo]-[mdView(==height)]-(20)-[broughtBy]-(10)-[gnode]|"
                                                                           options:0
                                                                           metrics:@{@"height" : @(height.height)}
                                                                             views:viewsMap]];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.container.contentInset = UIEdgeInsetsMake(40, 0, 88, 0);
    }
}


//Workaround for an SDK bug(?) 
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.container.contentOffset = CGPointZero;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
