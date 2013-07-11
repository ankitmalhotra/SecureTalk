//
//  detailMessageViewController.h
//  socialNetwork-UTD
//
//  Created by Ankit Malhotra on 5/16/13.
//  Copyright (c) 2013 Ankit Malhotra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "messengerViewController.h"

@class messengerViewController;

@interface detailMessageViewController : UIViewController
{
    IBOutlet UIBarButtonItem *backButton;
    IBOutlet UITextView *postMessageView;
    IBOutlet UIView *detailView;
    IBOutlet UINavigationBar *navBar;
    NSString *_postMessageToDisp;
    NSString *_groupNameToDisp;
    
    messengerViewController *mainViewObj;
}

-(IBAction)backToMainView;
-(void)getPostMessageToDisplay: (NSString *)postMessageToDisp;

@end
