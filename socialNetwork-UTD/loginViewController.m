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
//static int loginRetryCounter=0;
static int const MAX_RETRY=5;

@interface loginViewController ()
{
    /*User credentials*/
    NSString *userId;
    NSString *userPwd;
    NSString *accessToken;
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
    NSLog(@"flagval: %d",appearFlagCheck);
    
    obj=[[messengerViewController alloc]init];
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
    
    /*Accept username and password entered by user*/
    userId = nameField.text;
    userPwd = passwordField.text;
    NSLog(@"sending.. %@",userId);

    /*Start REST request*/
    spinningView.hidden=FALSE;
    spinningView.transform=CGAffineTransformMakeScale(1.5, 1.5);
    [spinningView startAnimating];
    
    /*Pass this username to server*/
    [restObj userLogin:userId :userPwd :@"login"];
    
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
   
        NSLog(@"calling for status !");
        receivedStatus=[restObj returnValue];
        NSLog(@"status received:%d",receivedStatus);
        if(receivedStatus==1)
        {
            /*Signal username to main view*/
            obj=[[messengerViewController alloc]init];
            [obj getUserId:userId:@"test"];
            [obj release];
            
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
        }
        else if(receivedStatus==0)
        {
            UIAlertView *connNullAlert=[[UIAlertView alloc]initWithTitle:@"Connection Error" message:@"Unable to contact server" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [connNullAlert show];
            [connNullAlert release];
            [spinningView stopAnimating];
            spinningView.hidden=TRUE;
            loginBtn.enabled=TRUE;
            signupBtn.enabled=TRUE;
            nameField.enabled=TRUE;
            passwordField.enabled=TRUE;
        }

    });
    
}

-(void)loginRecurRetry
{
}

/*Load new user signup view*/
-(IBAction)signupUser
{
    signupUserViewController *signupObj=[[signupUserViewController alloc]initWithNibName:nil bundle:nil];
    [self presentViewController:signupObj animated:YES completion:nil];
    [signupObj release];
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
