//
//  signupUserViewController.h
//  socialNetwork-UTD
//
//  Created by Ankit Malhotra on 1/30/13.
//  Copyright (c) 2013 Ankit Malhotra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "messengerViewController.h"
#import "messengerRESTclient.h"
#import "messengerAppDelegate.h"
#import "Reachability.h"

/*use this forward declaration to avoid class parse issues*/
@class messengerRESTclient;
@class messengerAppDelegate;
@class messengerViewController;
@class Reachability;

@interface signupUserViewController : UIViewController
{
    IBOutlet UIView *signupView;
    IBOutlet UIButton *signupBtn;
    IBOutlet UIBarButtonItem *backToLoginBtn;
    IBOutlet UITextField *dispNameField;
    IBOutlet UITextField *realNameField;
    IBOutlet UITextField *newPasswordField;
    IBOutlet UITextField *retypePasswordField;
    IBOutlet UITextField *emailField;
    IBOutlet UIActivityIndicatorView *connProgress;
    
    NSString *userID;
    NSString *userName;
    NSString *password;
    NSString *retypePwd;
    NSString *emailID;
    NSString *domainID;
    
    NSData *deviceToken;
    
    int retVal;
    
    Reachability *internetReachability;
    
    messengerRESTclient *restObj;
    messengerAppDelegate *appDelegateObj;
    messengerViewController *mainViewObj;
}

-(IBAction)returnKeyboard:(id)sender;
-(IBAction)switchBackLogin;
-(IBAction)sendNewUserData;
-(IBAction)backgroundTouched:(id)sender;


@end
