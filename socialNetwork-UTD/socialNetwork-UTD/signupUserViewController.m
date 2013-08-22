//
//  signupUserViewController.m
//  socialNetwork-UTD
//
//  Created by Ankit Malhotra on 1/30/13.
//  Copyright (c) 2013 Ankit Malhotra. All rights reserved.
//

#import "signupUserViewController.h"

@interface signupUserViewController ()

@end

@implementation signupUserViewController


- (void)viewDidLoad
{
    UIColor *bckgImg = [[UIColor alloc]initWithPatternImage:[UIImage imageNamed:@"logo-bckg-signup.png"]];
    [signupView setBackgroundColor:bckgImg];
    
    [super viewDidLoad];
    mainViewObj=[[messengerViewController alloc]init];
    restObj=[[messengerRESTclient alloc]init];
    appDelegateObj=[[messengerAppDelegate alloc]init];
    
    connProgress.hidden=TRUE;
}

-(IBAction)switchBackLogin
{
    /*Push back to login view*/
    [self dismissViewControllerAnimated:YES completion:nil];
    
    /*Release allocated objects*/
    [mainViewObj release];
    [restObj release];
    [appDelegateObj release];
}

/*Resign the keyboard on pressing return*/
-(IBAction)returnKeyboard:(id)sender
{
    [sender resignFirstResponder];
}

-(IBAction)sendNewUserData
{
    userID=dispNameField.text;
    userID=[userID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    userName=realNameField.text;
    userName=[userName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    password=newPasswordField.text;
    password=[password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    retypePwd=retypePasswordField.text;
    retypePwd=[retypePwd stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    emailID=emailField.text;
    emailID=[emailID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSUInteger indexVal=0;
    for(int k=[emailID length]-1;k>0;k--)
    {
        if([emailID characterAtIndex:k]=='@')
        {
            indexVal=k;
            break;
        }
    }
    
    domainID=[emailID substringFromIndex:indexVal];
    NSLog(@"domain name of user email: %@",domainID);
    
    NSLog(@"password: %@",password);
    NSLog(@"retypePwd: %@",retypePwd);
    
    BOOL signupCheck=[password isEqualToString:retypePwd] && ![userName isEqualToString:@""] && ![userID isEqualToString:@""] && ![emailID isEqualToString:@""] && [emailID rangeOfString:@"@"].location!=NSNotFound && [domainID rangeOfString:@"."].location!=NSNotFound && ![password isEqualToString:@""] && ![retypePwd isEqualToString:@""];
    
    if(signupCheck)
    {
        connProgress.hidden=FALSE;
        [connProgress startAnimating];
        signupBtn.enabled=FALSE;
        backToLoginBtn.enabled=FALSE;
        
        /*Retreive the device token ID*/
        appDelegateObj=[[messengerAppDelegate alloc]init];
        deviceToken=[[appDelegateObj getDeviceToken]retain];
        NSLog(@"tokenchk: %@", deviceToken);

        NSString *tokenstr=[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        tokenstr=[tokenstr stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSLog(@"My local token is: %@", tokenstr);
        
        /*Call to add-new-user endpoint*/
        [restObj addNewUser:userID :userName :password :emailID :tokenstr :@"add"];
        double delayInSeconds = 4.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            NSLog(@"calling for status !");
            retVal=[restObj returnValue];
            if(retVal==1)
            {
                connProgress.hidden=TRUE;
                [connProgress stopAnimating];
                
                [mainViewObj getUserMailID:emailID];
                [self dismissViewControllerAnimated:YES completion:nil];
                UIAlertView *signUpSuccessAlert=[[UIAlertView alloc]initWithTitle:@"SignUp successful" message:@"Login to continue" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [signUpSuccessAlert show];
                [signUpSuccessAlert release];
                
                /*Release allocated objects*/
                [mainViewObj release];
                [restObj release];
                [appDelegateObj release];
            }
            else
            {
                double delayInSeconds = 4.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    NSLog(@"calling for status !");
                    retVal=[restObj returnValue];
                    if(retVal==1)
                    {
                        connProgress.hidden=TRUE;
                        [connProgress stopAnimating];
                        
                        [mainViewObj getUserMailID:emailID];
                        [self dismissViewControllerAnimated:YES completion:nil];
                        UIAlertView *signUpSuccessAlert=[[UIAlertView alloc]initWithTitle:@"SignUp successful" message:@"Login to continue" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [signUpSuccessAlert show];
                        [signUpSuccessAlert release];
                        
                        /*Release allocated objects*/
                        [mainViewObj release];
                        [restObj release];
                        [appDelegateObj release];
                    }
                    else
                    {
                        connProgress.hidden=TRUE;
                        [connProgress stopAnimating];
                        signupBtn.enabled=TRUE;
                        backToLoginBtn.enabled=TRUE;
                        
                        UIAlertView *signUpFailAlert=[[UIAlertView alloc]initWithTitle:@"SignUp Failed" message:@"Connection failiure. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [signUpFailAlert show];
                        [signUpFailAlert release];
                    }
                });
            }

        });
    }
    else if(![password isEqualToString:retypePwd])
    {
        UIAlertView *wrongPwd=[[UIAlertView alloc]initWithTitle:@"Password mismatch !" message:@"Please retype the password correctly" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [wrongPwd show];
        [wrongPwd release];
        retypePwd=NULL;
        password=NULL;
        newPasswordField.text=@"";
        retypePasswordField.text=@"";
    }
    else if ([userID isEqualToString:@""])
    {
        UIAlertView *wrongUserID=[[UIAlertView alloc]initWithTitle:@"Error" message:@"You must provide a user name" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [wrongUserID show];
        [wrongUserID release];
        retypePwd=NULL;
        password=NULL;
        newPasswordField.text=@"";
        retypePasswordField.text=@"";
    }
    else if ([userName isEqualToString:@""])
    {
        UIAlertView *wrongUserName=[[UIAlertView alloc]initWithTitle:@"Error" message:@"You must provide a real name" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [wrongUserName show];
        [wrongUserName release];
        retypePwd=NULL;
        password=NULL;
        newPasswordField.text=@"";
        retypePasswordField.text=@"";
    }
    else if ([emailID isEqualToString:@""])
    {
        UIAlertView *wrongEmailID=[[UIAlertView alloc]initWithTitle:@"Error" message:@"You must provide an email ID" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [wrongEmailID show];
        [wrongEmailID release];
        retypePwd=NULL;
        password=NULL;
        emailID=NULL;
        newPasswordField.text=@"";
        retypePasswordField.text=@"";
    }
    else if ([emailID rangeOfString:@"@"].location==NSNotFound)
    {
        UIAlertView *wrongEmailID=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Please provide a valid email ID" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [wrongEmailID show];
        [wrongEmailID release];
        retypePwd=NULL;
        password=NULL;
        emailID=NULL;
        newPasswordField.text=@"";
        retypePasswordField.text=@"";
    }
    else if([password isEqualToString:@""])
    {
        UIAlertView *emptyPwd=[[UIAlertView alloc]initWithTitle:@"Password required !" message:@"You must have a login password" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [emptyPwd show];
        [emptyPwd release];
        retypePwd=NULL;
        password=NULL;
        newPasswordField.text=@"";
        retypePasswordField.text=@"";
    }
}


-(IBAction)backgroundTouched:(id)sender
{
    [dispNameField resignFirstResponder];
    [retypePasswordField resignFirstResponder];
    [emailField resignFirstResponder];
    [newPasswordField resignFirstResponder];
    [realNameField resignFirstResponder];
}


-(BOOL)shouldAutorotate
{
    return NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
