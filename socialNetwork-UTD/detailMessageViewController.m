//
//  detailMessageViewController.m
//  socialNetwork-UTD
//
//  Created by Ankit Malhotra on 5/16/13.
//  Copyright (c) 2013 Ankit Malhotra. All rights reserved.
//

#import "detailMessageViewController.h"


@implementation detailMessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mainViewObj = [[messengerViewController alloc]init];
    UIColor *bckgImg = [[UIColor alloc]initWithPatternImage:[UIImage imageNamed:@"texture08.jpg"]];
    [detailView setBackgroundColor:bckgImg];
}

-(void)viewDidAppear:(BOOL)animated
{
    postMessageView.text=_postMessageToDisp;
    postMessageView.font=[UIFont fontWithName:@"Marker Felt" size:18.0];
    
    _groupNameToDisp=[mainViewObj signalGroupName];
    [navBar.topItem setTitle:_groupNameToDisp];
}

-(IBAction)backToMainView
{
    postMessageView.text=@"";
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)getPostMessageToDisplay:(NSString *)postMessageToDisp
{
    _postMessageToDisp=[postMessageToDisp retain];
    NSLog(@"post received: %@",_postMessageToDisp);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate
{
    return NO;
}

@end
