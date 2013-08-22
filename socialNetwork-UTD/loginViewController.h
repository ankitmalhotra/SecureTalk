//
//  loginViewController.h
//  socialNetwork-UTD
//
//  Created by Ankit Malhotra on 13/11/12.
//  Copyright (c) 2012 Ankit Malhotra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "messengerViewController.h"
#import "secureMessageRSA.h"
#import "messengerRESTclient.h"


@class messengerRESTclient;
@class messengerViewController;

@interface loginViewController : UIViewController<UIAlertViewDelegate,UITextFieldDelegate>
{
    IBOutlet UIView *loginView;
    IBOutlet UIButton *loginBtn;
    IBOutlet UIButton *signupBtn;
    IBOutlet UITextField *nameField;
    IBOutlet UITextField *passwordField;
    IBOutlet UIActivityIndicatorView *spinningView;
    IBOutlet UIButton *forgotPasswordBtn;
    
    int retVal;
    
    UIView *forgotPasswordView;
    UILabel *viewLabel;
    UITextField *usernameField;
    UITextField *emailField;
    UIButton *sendPasswordBtn;
    UIButton *closeBtn;
    
    messengerRESTclient *restObj;
    messengerViewController *mainViewObj;
}
-(IBAction)loginUser;
-(IBAction)signupUser;
-(IBAction)forgotPassword;
-(IBAction)returnKeyBoard:(id)sender;
-(IBAction)backgroundTouched:(id)sender;
-(NSString *)getXmppJID;
-(NSString *)getXmppPwd;
-(void)sendPasswordToServer;
-(void)closeView;


@end
