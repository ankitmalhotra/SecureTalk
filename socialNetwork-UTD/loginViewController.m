//
//  loginViewController.m
//  socialNetwork-UTD
//
//  Created by Ankit Malhotra on 13/11/12.
//  Copyright (c) 2012 Ankit Malhotra. All rights reserved.
//

#import "loginViewController.h"
#import "messengerViewController.h"


static int appearFlagCheck=0;
static int receivedStatus;
static NSString *const kXMPPmyJID = @"kXMPPmyJID";
static NSString *const kXMPPmyPassword = @"kXMPPmyPassword";
static int const MAX_RETRY=5;

@interface loginViewController ()
{
    /*User credentials*/
    NSString *userId;
    NSString *userPwd;
    NSString *accessToken;
    NSString *usernameToSend;
    NSString *emailAddrToSend;
    
    int emailAddressFieldCheck;
    int usernameFieldCheck;
    int loginStatusChk;
}
@end
    
@implementation loginViewController

- (void)viewDidLoad
{
    UIColor *bckgImg = [[UIColor alloc]initWithPatternImage:[UIImage imageNamed:@"logo-bckg.png"]];
    [loginView setBackgroundColor:bckgImg];
    
    [super viewDidLoad];
    spinningView.hidden=TRUE;
    appearFlagCheck=1;
    receivedStatus=0;
    emailAddressFieldCheck=0;
    usernameFieldCheck=0;
    NSLog(@"flagval: %d",appearFlagCheck);
    
    mainViewObj=[[messengerViewController alloc]init];
    restObj=[[messengerRESTclient alloc]init];
}

- (void)setField:(UITextField *)field forKey:(NSString *)key
{
    if (field.text != nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:field.text forKey:key];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
}


-(NSString *)getXmppJID
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kXMPPmyJID];
}

-(NSString *)getXmppPwd
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kXMPPmyPassword];
}


-(IBAction)loginUser
{
    nameField.enabled=FALSE;
    passwordField.enabled=FALSE;
    loginBtn.enabled=FALSE;
    signupBtn.enabled=FALSE;
    forgotPasswordBtn.enabled=FALSE;
    
    /*Accept username and password entered by user*/
    userId = nameField.text;
    userPwd = passwordField.text;
    NSLog(@"sending.. %@",userId);
    
    if([userId isEqualToString:@""]||userId==NULL)
    {
        UIAlertView *nullUserIdAlert=[[UIAlertView alloc]initWithTitle:@"Empty Username" message:@"Please enter a valid username. It cannot be empty" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [nullUserIdAlert show];
        [nullUserIdAlert release];
        
        loginBtn.enabled=TRUE;
        signupBtn.enabled=TRUE;
        nameField.enabled=TRUE;
        passwordField.enabled=TRUE;
        forgotPasswordBtn.enabled=TRUE;
    }
    else if ([userPwd isEqualToString:@""]||userPwd==NULL)
    {
        UIAlertView *nullUserPwdAlert=[[UIAlertView alloc]initWithTitle:@"Empty Password" message:@"Please enter a valid password to login" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [nullUserPwdAlert show];
        [nullUserPwdAlert release];
        
        loginBtn.enabled=TRUE;
        signupBtn.enabled=TRUE;
        nameField.enabled=TRUE;
        passwordField.enabled=TRUE;
        forgotPasswordBtn.enabled=TRUE;
    }
    else
    {
        /*Start REST request*/
        spinningView.hidden=FALSE;
        spinningView.transform=CGAffineTransformMakeScale(1.5, 1.5);
        [spinningView startAnimating];
        
        /*First Check if login data already received by main View*/
        mainViewObj=[[messengerViewController alloc]init];
        loginStatusChk=[mainViewObj tellLoginStatus];
        if(loginStatusChk==1)
        {
            double delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                /*Push back main view*/
                messengerViewController *mainVw=[[messengerViewController alloc]initWithNibName:nil bundle:nil];
                [self presentViewController:mainVw animated:YES completion:NULL];
                [spinningView stopAnimating];
                [mainVw release];
            });
        }
        else
        {
            /*Pass this username to server*/
            [restObj userLogin:userId :userPwd :@"login"];
            
            double delayInSeconds = 5.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                NSLog(@"calling for status !");
                receivedStatus=[restObj returnValue];
                NSLog(@"status received:%d",receivedStatus);
                if(receivedStatus==1)
                {
                    /*Signal username to main view*/
                    mainViewObj=[[messengerViewController alloc]init];
                    [mainViewObj getUserId:userId:userPwd];
                    [mainViewObj release];
                    
                    [self setField:nameField forKey:kXMPPmyJID];
                    [self setField:passwordField forKey:kXMPPmyPassword];
                    
                    /*Generate Key Pairs routine*/
                    [secureMessageRSA generateKeyPairs];
                    
                    /*Push back main view*/
                    messengerViewController *mainVw=[[messengerViewController alloc]initWithNibName:nil bundle:nil];
                    [self presentViewController:mainVw animated:YES completion:NULL];
                    [spinningView stopAnimating];
                    [mainVw release];
                }
                else if(receivedStatus==-1)
                {
                    UIAlertView *loginFail=[[UIAlertView alloc]initWithTitle:@"Login Failed" message:@"Please check the login credentials" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [loginFail show];
                    [loginFail release];
                    [spinningView stopAnimating];
                    spinningView.hidden=TRUE;
                    loginBtn.enabled=TRUE;
                    signupBtn.enabled=TRUE;
                    nameField.enabled=TRUE;
                    passwordField.enabled=TRUE;
                    forgotPasswordBtn.enabled=TRUE;
                }
                else if(receivedStatus==0)
                {
                    /*Try again*/
                    NSLog(@"retrying due to slow connection..");
                    double delayInSeconds = 5.0;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        
                        receivedStatus=[restObj returnValue];
                        NSLog(@"status received:%d",receivedStatus);
                        if(receivedStatus==1)
                        {
                            /*Signal username to main view*/
                            mainViewObj=[[messengerViewController alloc]init];
                            [mainViewObj getUserId:userId:userPwd];
                            [mainViewObj release];
                            
                            [self setField:nameField forKey:kXMPPmyJID];
                            [self setField:passwordField forKey:kXMPPmyPassword];
                            
                            /*Generate Key Pairs routine*/
                            [secureMessageRSA generateKeyPairs];
                            
                            /*Push back main view*/
                            messengerViewController *mainVw=[[messengerViewController alloc]initWithNibName:nil bundle:nil];
                            [self presentViewController:mainVw animated:YES completion:NULL];
                            [spinningView stopAnimating];
                            [mainVw release];
                        }
                        else if(receivedStatus==-1)
                        {
                            UIAlertView *loginFail=[[UIAlertView alloc]initWithTitle:@"Login Failed" message:@"Please check the login credentials" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                            [loginFail show];
                            [loginFail release];
                            [spinningView stopAnimating];
                            spinningView.hidden=TRUE;
                            loginBtn.enabled=TRUE;
                            signupBtn.enabled=TRUE;
                            nameField.enabled=TRUE;
                            passwordField.enabled=TRUE;
                            forgotPasswordBtn.enabled=TRUE;
                        }
                        else if(receivedStatus==0)
                        {
                            /*Signal username to main view*/
                            mainViewObj=[[messengerViewController alloc]init];
                            [mainViewObj getUserId:userId:userPwd];
                            [mainViewObj release];
                            
                            UIAlertView *connNullAlert=[[UIAlertView alloc]initWithTitle:@"Connection Error" message:@"Unable to contact server. Please try again or try on a WiFi network" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                            [connNullAlert show];
                            [connNullAlert release];
                            [spinningView stopAnimating];
                            spinningView.hidden=TRUE;
                            loginBtn.enabled=TRUE;
                            signupBtn.enabled=TRUE;
                            nameField.enabled=TRUE;
                            passwordField.enabled=TRUE;
                            forgotPasswordBtn.enabled=TRUE;
                        }
                    });
                    
                }
                
            });
        }
    }
}


/*Load new user signup view*/
-(IBAction)signupUser
{
    signupUserViewController *signupObj=[[signupUserViewController alloc]initWithNibName:nil bundle:nil];
    [self presentViewController:signupObj animated:YES completion:nil];
    [signupObj release];
}

/*Load custom view to get username and email address for password reset*/
-(IBAction)forgotPassword
{
        signupBtn.enabled=FALSE;
        loginBtn.enabled=FALSE;
        forgotPasswordBtn.enabled=FALSE;
        nameField.enabled=FALSE;
        passwordField.enabled=FALSE;
    
        forgotPasswordView=[[UIView alloc]initWithFrame:CGRectMake(59.0, 120.0, 200.0, 178.0)];
        [forgotPasswordView setAlpha:0.0];
        [self.view addSubview:forgotPasswordView];
        
        /*Add up frills to this view*/
        forgotPasswordView.layer.cornerRadius=12.0;
        [forgotPasswordView.layer setMasksToBounds:YES];
        forgotPasswordView.layer.backgroundColor=[[UIColor blackColor]colorWithAlphaComponent:0.8].CGColor;
        forgotPasswordView.layer.borderColor=[UIColor lightGrayColor].CGColor;
        forgotPasswordView.layer.borderWidth=2.0;
        
        [UIView animateWithDuration:0.4 animations:^{
            [forgotPasswordView setAlpha:0.9];
        }];
        
        /*Add the view label*/
        viewLabel=[[UILabel alloc]initWithFrame:CGRectMake(forgotPasswordView.frame.origin.x-10, forgotPasswordView.frame.origin.y-108, 109.0, 21.0)];
        viewLabel.text=@"Forgot Password?";
        viewLabel.textColor=[UIColor whiteColor];
        viewLabel.font=[UIFont fontWithName:@"Marker Felt" size:15.0];
        viewLabel.backgroundColor=[UIColor clearColor];
        [forgotPasswordView addSubview:viewLabel];
        
        /*Add the username text field*/
        usernameField=[[UITextField alloc]initWithFrame:CGRectMake(forgotPasswordView.frame.origin.x-37, forgotPasswordView.frame.origin.y-80, 161.0, 30.0)];
        usernameField.placeholder=@"username";
        [usernameField setBackgroundColor:[UIColor whiteColor]];
        [usernameField setBorderStyle:UITextBorderStyleRoundedRect];
        usernameField.font=[UIFont systemFontOfSize:16.0];
        [usernameField setReturnKeyType:UIReturnKeyDone];
        usernameField.delegate=self;

        
        [forgotPasswordView addSubview:usernameField];
        
        /*Add the email ID text field*/
        emailField=[[UITextField alloc]initWithFrame:CGRectMake(forgotPasswordView.frame.origin.x-39, forgotPasswordView.frame.origin.y-42, 162.0, 30.0)];
        emailField.placeholder=@"Email Address";
        [emailField setBackgroundColor:[UIColor whiteColor]];
        [emailField setBorderStyle:UITextBorderStyleRoundedRect];
        emailField.font=[UIFont systemFontOfSize:16.0];
        [emailField setReturnKeyType:UIReturnKeyDone];
        [emailField setKeyboardType:UIKeyboardTypeEmailAddress];
        emailField.delegate=self;

        [forgotPasswordView addSubview:emailField];
        
        /*Send Password request to server*/
        sendPasswordBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        sendPasswordBtn.frame=CGRectMake(forgotPasswordView.frame.origin.x+7, forgotPasswordView.frame.origin.y+9, 70.0, 28.0);
        [sendPasswordBtn addTarget:self action:@selector(sendPasswordToServer) forControlEvents:UIControlEventTouchUpInside];
        sendPasswordBtn.titleLabel.font=[UIFont fontWithName:@"Marker Felt" size:15.0];
        [sendPasswordBtn setTitle:@"Submit" forState:UIControlStateNormal];
        
        [forgotPasswordView addSubview:sendPasswordBtn];
        
        
        /*Add the close view button*/
        closeBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [closeBtn setBackgroundColor:[UIColor clearColor]];
        [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        closeBtn.frame=CGRectMake(forgotPasswordView.frame.origin.x+114, forgotPasswordView.frame.origin.y-120, 27.0, 25.0);
        [closeBtn addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
        [closeBtn setBackgroundImage:[UIImage imageNamed:@"close_btn.png"] forState:UIControlStateNormal];
        //[closeBtn setTitle:@"X" forState:UIControlStateNormal];
        [forgotPasswordView addSubview:closeBtn];
}

-(void)sendPasswordToServer
{
    /*server logic*/
    usernameToSend=usernameField.text;
    emailAddrToSend=emailField.text;
    
    spinningView.hidden=FALSE;
    [spinningView startAnimating];
    sendPasswordBtn.enabled=FALSE;
    
    if([usernameToSend isEqualToString:@""] || usernameToSend==NULL)
    {
        UIAlertView *nullUsernameAlert=[[UIAlertView alloc]initWithTitle:@"Empty username" message:@"Please provide your login username" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [nullUsernameAlert show];
        [nullUsernameAlert release];
        
        spinningView.hidden=TRUE;
        [spinningView stopAnimating];
        sendPasswordBtn.enabled=TRUE;    }
    else
    {
        if([emailAddrToSend isEqualToString:@""]||emailAddrToSend==NULL)
        {
            UIAlertView *nullEmailAddrAlert=[[UIAlertView alloc]initWithTitle:@"Empty Email Address" message:@"Please provide your registered Email Address" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [nullEmailAddrAlert show];
            [nullEmailAddrAlert release];
            
            spinningView.hidden=TRUE;
            [spinningView stopAnimating];
            sendPasswordBtn.enabled=TRUE;
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [restObj recoverPassword:usernameToSend :emailAddrToSend :@"recoverPassword"];
            });
            
            NSLog(@"receiving status of the recover password request now");
            double delayInSeconds = 3.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                retVal=[restObj returnValue];
                
                if(retVal==1)
                {
                    UIAlertView *recoverSuccessAlert=[[UIAlertView alloc]initWithTitle:@"Check your Email" message:@"Your new password has been emailed to you" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [recoverSuccessAlert show];
                    [recoverSuccessAlert release];
                    
                    [UIView animateWithDuration:0.5 animations:^{
                        [forgotPasswordView setAlpha:0.0];
                    }];
                    
                    if(usernameFieldCheck==1)
                    {
                        [usernameField resignFirstResponder];
                    }
                    if(emailAddressFieldCheck==1)
                    {
                        [emailField resignFirstResponder];
                    }
                    
                    signupBtn.enabled=TRUE;
                    loginBtn.enabled=TRUE;
                    forgotPasswordBtn.enabled=TRUE;
                    nameField.enabled=TRUE;
                    passwordField.enabled=TRUE;
                    spinningView.hidden=TRUE;
                    [spinningView stopAnimating];
                    sendPasswordBtn.enabled=TRUE;
                }
                else if (retVal==-1)
                {
                    UIAlertView *recoverFailAlert=[[UIAlertView alloc]initWithTitle:@"Invalid details" message:@"Your entered details do not match our records. Please try again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [recoverFailAlert show];
                    [recoverFailAlert release];
                    
                    signupBtn.enabled=TRUE;
                    loginBtn.enabled=TRUE;
                    forgotPasswordBtn.enabled=TRUE;
                    nameField.enabled=TRUE;
                    passwordField.enabled=TRUE;
                    spinningView.hidden=TRUE;
                    [spinningView stopAnimating];
                    sendPasswordBtn.enabled=TRUE;
                }
                else if (retVal==0)
                {
                    double delayInSeconds = 3.0;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        retVal=[restObj returnValue];
                        if(retVal==1)
                        {
                            UIAlertView *recoverSuccessAlert=[[UIAlertView alloc]initWithTitle:@"Check your Email" message:@"Your new password has been emailed to you" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                            [recoverSuccessAlert show];
                            [recoverSuccessAlert release];
                            
                            [UIView animateWithDuration:0.5 animations:^{
                                [forgotPasswordView setAlpha:0.0];
                            }];
                            
                            if(usernameFieldCheck==1)
                            {
                                [usernameField resignFirstResponder];
                            }
                            if(emailAddressFieldCheck==1)
                            {
                                [emailField resignFirstResponder];
                            }
                            
                            signupBtn.enabled=TRUE;
                            loginBtn.enabled=TRUE;
                            forgotPasswordBtn.enabled=TRUE;
                            nameField.enabled=TRUE;
                            passwordField.enabled=TRUE;
                            spinningView.hidden=TRUE;
                            [spinningView stopAnimating];
                            sendPasswordBtn.enabled=TRUE;
                        }
                        else if (retVal==-1)
                        {
                            UIAlertView *recoverFailAlert=[[UIAlertView alloc]initWithTitle:@"Invalid details" message:@"Your entered details do not match our records. Please try again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                            [recoverFailAlert show];
                            [recoverFailAlert release];
                            
                            signupBtn.enabled=TRUE;
                            loginBtn.enabled=TRUE;
                            forgotPasswordBtn.enabled=TRUE;
                            nameField.enabled=TRUE;
                            passwordField.enabled=TRUE;
                            spinningView.hidden=TRUE;
                            [spinningView stopAnimating];
                            sendPasswordBtn.enabled=TRUE;
                        }
                        else if (retVal==0)
                        {
                            UIAlertView *connNullAlert=[[UIAlertView alloc]initWithTitle:@"Connection Error" message:@"Unable to contact server. Please try again." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                            [connNullAlert show];
                            [connNullAlert release];
                            
                            signupBtn.enabled=TRUE;
                            loginBtn.enabled=TRUE;
                            forgotPasswordBtn.enabled=TRUE;
                            nameField.enabled=TRUE;
                            passwordField.enabled=TRUE;
                            spinningView.hidden=TRUE;
                            [spinningView stopAnimating];
                            sendPasswordBtn.enabled=TRUE;
                        }
                    });
                }
            });
        }
    }
}

-(void)closeView
{
    [UIView animateWithDuration:0.5 animations:^{
        [forgotPasswordView setAlpha:0.0];
    }];
    
    if(usernameFieldCheck==1)
    {
        [usernameField resignFirstResponder];
    }
    if(emailAddressFieldCheck==1)
    {
        [emailField resignFirstResponder];
    }
    
    signupBtn.enabled=TRUE;
    loginBtn.enabled=TRUE;
    forgotPasswordBtn.enabled=TRUE;
    nameField.enabled=TRUE;
    passwordField.enabled=TRUE;
    spinningView.hidden=TRUE;
    [spinningView stopAnimating];
}



#pragma mark textfield delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField==usernameField)
    {
        usernameFieldCheck=1;
        emailAddressFieldCheck=0;
        [usernameField resignFirstResponder];
    }
    else if (textField==emailField)
    {
        usernameFieldCheck=0;
        emailAddressFieldCheck=1;
        [emailField resignFirstResponder];
    }

    return 1;
}


#pragma mark alertview delegate

- (void)alertView:(UIAlertView *)alertViewOld didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        if ([alertViewOld.title isEqual:@"Check your Email"])
        {
            if(usernameFieldCheck==1)
            {
                [usernameField resignFirstResponder];
            }
            if(emailAddressFieldCheck==1)
            {
                [emailField resignFirstResponder];
            }
            
            signupBtn.enabled=TRUE;
            loginBtn.enabled=TRUE;
            forgotPasswordBtn.enabled=TRUE;
            nameField.enabled=TRUE;
            passwordField.enabled=TRUE;
            spinningView.hidden=TRUE;
            [spinningView stopAnimating];
        }
        
    }
    
}



/*Resign the keyboard on pressing return*/
-(IBAction)returnKeyBoard:(id)sender
{
    [sender resignFirstResponder];
}

-(IBAction)backgroundTouched:(id)sender
{
    [nameField resignFirstResponder];
    [passwordField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(BOOL)shouldAutorotate
{
    return NO;
}

@end
