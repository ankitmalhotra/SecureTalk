//
//  groupsTableViewViewController.m
//  socialNetwork-UTD
//
//  Created by Ankit Malhotra on 04/12/12.
//  Copyright (c) 2012 Ankit Malhotra. All rights reserved.
//

#import "groupsTableViewViewController.h"

static double locationLat,locationLong;
static NSString *localUserId;
static NSString *localUserNumber;
static NSString *localAccessToken;
static NSString *localUserPwd;
static NSString *groupJoinPwd;
static NSString *localUserEmailID;
static NSString *selectedGroupName;
static NSString *newGroupName;
static NSString *newGroupPwd;
static NSString *retypeGroupPwd;
static NSMutableArray *groupList;
static NSMutableArray *friendsReceived;
static NSMutableArray *groupNames;
static NSMutableArray *groupNumber;
static NSMutableArray *groupPasswordCheck;
static NSDictionary *groupsPwdDictionary;
static NSDictionary *groupsNumDictionary;


int myGroupsCheck=0;
int allGroupsCheck=0;

int groupNameFieldCheck=0;
int groupPasswordFieldCheck=0;
int retypeGroupPasswordFieldCheck=0;

@interface groupsTableViewViewController ()

@end

@implementation groupsTableViewViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*Init all objects to be used*/
    mainViewObj=[[messengerViewController alloc] init];
    restObj=[[messengerRESTclient alloc]init];
    newPostObj=[[newPostViewController alloc]init];
    groupNames=[[NSMutableArray alloc]init];
    groupNumber=[[NSMutableArray alloc]init];
    groupPasswordCheck=[[NSMutableArray alloc]init];
    
    connProgress.transform=CGAffineTransformMakeScale(1.5, 1.5);
    refreshCntl=[[UIRefreshControl alloc]init];
    [refreshCntl addTarget:self action:@selector(refreshUI)forControlEvents:UIControlEventAllEvents];
    [tabVw addSubview:refreshCntl];
    
    /*Init loc-update to get the latest coordinates*/
    [mainViewObj initLocUpdate];
    
    myGroupsCheck=1;
    
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
    {
        /*Call to retrieve the collated data from server*/
        groupList=[mainViewObj getGroupObjects:nil :0];
        [self retrieveListOfGroups];
    });
}

-(void)retrieveListOfGroups
{
     if([groupNames count]>0)
     {
        [groupNames removeAllObjects];
     }
     if([groupNumber count]>0)
     {
        [groupNumber removeAllObjects];
     }
     if([groupPasswordCheck count]>0)
     {
        [groupPasswordCheck removeAllObjects];
     }
    
    
    NSLog(@"group list count: %d",[groupList count]);
    
    if([groupList count]>2 && [groupList count]%3==0)
    {
        for (int k=0; k<[groupList count]; k++)
        {
            [groupNumber addObject:[groupList objectAtIndex:k]];
            [groupNames addObject:[groupList objectAtIndex:k+1]];
            [groupPasswordCheck addObject:[groupList objectAtIndex:k+2]];
            k+=2;
        }
        groupsPwdDictionary=[[NSDictionary alloc]initWithObjects:groupPasswordCheck forKeys:groupNames];
        groupsNumDictionary=[[NSDictionary alloc]initWithObjects:groupNumber forKeys:groupNames];
        [tabVw reloadData];
        /*
        @try
        {
            
        }
        @catch (NSException *exception)
        {
            NSLog(@"Exception caught!");
        }
         */
    }
}

/*
-(void)viewDidAppear:(BOOL)animated
{
    //Reload table view with updated data
    NSLog(@"userId being used %@",localUserId);

    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [tabVw reloadData];
    });
}
*/

-(void)refreshUI
{
    addGrp.enabled=FALSE;
    backToMain.enabled=FALSE;
    myGroups.enabled=FALSE;
    allGroups.enabled=FALSE;
    
    /*Reload table view with updated data*/
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if(myGroupsCheck==1)
        {
            addGrp.enabled=FALSE;
            backToMain.enabled=FALSE;
            connProgress.hidden=FALSE;
            [connProgress startAnimating];
            [tabVw setUserInteractionEnabled:FALSE];
            [tabVw setAlpha:0.2];
            myGroups.enabled=FALSE;
            allGroups.enabled=FALSE;
                        
            if([groupList count]>0)
            {
                [groupList removeAllObjects];
            }
            
            //fetchOtherGroupsQueue=dispatch_queue_create("fetchOtherGroups", NULL);
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [restObj showMyGroups:localUserNumber:locationLat:locationLong:localAccessToken :@"listMemberGroups"];
            });
            
            double delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                NSLog(@"calling for status from server..");
                retval=[restObj returnValue];
                if(retval==1)
                {
                    [self retrieveListOfGroups];
                    [tabVw setUserInteractionEnabled:TRUE];
                    [tabVw setAlpha:1.0];
                    connProgress.hidden=TRUE;
                    [connProgress stopAnimating];
                    addGrp.enabled=TRUE;
                    backToMain.enabled=TRUE;
                    myGroups.enabled=TRUE;
                    allGroups.enabled=TRUE;
                }
                else if(retval==-1)
                {
                    UIAlertView *createdAlert=[[UIAlertView alloc]initWithTitle:@"Sorry" message:[NSString stringWithFormat:@"Groups could not be fetched for you at this time"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [createdAlert show];
                    [createdAlert release];
                    
                    [tabVw setUserInteractionEnabled:TRUE];
                    [tabVw setAlpha:1.0];
                    connProgress.hidden=TRUE;
                    [connProgress stopAnimating];
                    addGrp.enabled=TRUE;
                    backToMain.enabled=TRUE;
                    myGroups.enabled=TRUE;
                    allGroups.enabled=TRUE;
                }
                else if(retval==0)
                {
                    UIAlertView *connNullAlert=[[UIAlertView alloc]initWithTitle:@"Connection Error" message:@"Unable to contact server" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [connNullAlert show];
                    [connNullAlert release];
                    
                    [tabVw setUserInteractionEnabled:TRUE];
                    [tabVw setAlpha:1.0];
                    connProgress.hidden=TRUE;
                    [connProgress stopAnimating];
                    addGrp.enabled=TRUE;
                    backToMain.enabled=TRUE;
                    myGroups.enabled=TRUE;
                    allGroups.enabled=TRUE;
                }
            });
        }
        else if (allGroupsCheck==1)
        {
            addGrp.enabled=FALSE;
            backToMain.enabled=FALSE;
            connProgress.hidden=FALSE;
            [connProgress startAnimating];
            [tabVw setUserInteractionEnabled:FALSE];
            [tabVw setAlpha:0.2];
            myGroups.enabled=FALSE;
            allGroups.enabled=FALSE;

            if([groupList count]>0)
            {
                [groupList removeAllObjects];
            }
            
            //fetchMyGroupsQueue=dispatch_queue_create("fetchMyGroups", NULL);
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [restObj showAllGroups:localUserNumber :locationLat :locationLong :localAccessToken :@"showGroups"];
            });
            
            double delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds *NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                NSLog(@"calling for status from server..");
                retval=[restObj returnValue];
                if(retval==1)
                {
                    double delayInSeconds = 0.3;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [self retrieveListOfGroups];
                        [tabVw setUserInteractionEnabled:TRUE];
                        [tabVw setAlpha:1.0];
                        connProgress.hidden=TRUE;
                        [connProgress stopAnimating];
                        addGrp.enabled=TRUE;
                        backToMain.enabled=TRUE;
                        myGroups.enabled=TRUE;
                        allGroups.enabled=TRUE;
                    });
                }
                else if(retval==-1)
                {
                    UIAlertView *createdAlert=[[UIAlertView alloc]initWithTitle:@"Sorry" message:[NSString stringWithFormat:@"Groups could not be fetched for you at this time"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [createdAlert show];
                    [createdAlert release];
                    
                    [tabVw setUserInteractionEnabled:TRUE];
                    [tabVw setAlpha:1.0];
                    connProgress.hidden=TRUE;
                    [connProgress stopAnimating];
                    addGrp.enabled=TRUE;
                    backToMain.enabled=TRUE;
                    myGroups.enabled=TRUE;
                    allGroups.enabled=TRUE;
                }
                else if(retval==0)
                {
                    UIAlertView *connNullAlert=[[UIAlertView alloc]initWithTitle:@"Connection Error" message:@"Unable to contact server" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [connNullAlert show];
                    [connNullAlert release];
                    
                    [tabVw setUserInteractionEnabled:TRUE];
                    [tabVw setAlpha:1.0];
                    connProgress.hidden=TRUE;
                    [connProgress stopAnimating];
                    addGrp.enabled=TRUE;
                    backToMain.enabled=TRUE;
                    myGroups.enabled=TRUE;
                    allGroups.enabled=TRUE;
                }
            });
        }
        [tabVw reloadData];
    });
    
    [refreshCntl endRefreshing];
    
    addGrp.enabled=TRUE;
    backToMain.enabled=TRUE;
    myGroups.enabled=TRUE;
    allGroups.enabled=TRUE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //return [countries count];
    return [arr count];
}
*/


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"No. of groups for %@ is %d",localUserId,[groupNames count]);
    return [groupNames count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"GroupCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if([groupNames count]>0)
    {
        selectedGroupName=[groupNames objectAtIndex:[indexPath row]];
        cell.textLabel.text=selectedGroupName;
    }
    else
    {
        [tabVw reloadData];
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([groupNames count]>0)
    {
        selectedGroupName=[groupNames objectAtIndex:[indexPath row]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            connProgress.hidden=FALSE;
            [connProgress startAnimating];
            
            addGrp.enabled=FALSE;
            backToMain.enabled=FALSE;
            [tabVw setUserInteractionEnabled:FALSE];
            [tabVw setAlpha:0.2];
            [restObj getFriendList:localUserNumber :[groupsNumDictionary objectForKey:selectedGroupName] :locationLat:locationLong:localAccessToken :@"getUsersInGroup"];
            
            NSLog(@"group name selected: %@",selectedGroupName);
            NSLog(@"mapped group number: %@",[groupsNumDictionary objectForKey:selectedGroupName]);
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            double delayInSeconds = 1.3;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                retval=[restObj returnValue];
                if(retval==1)
                {
                    friendsReceived=[mainViewObj signalFriends];
                    if([friendsReceived containsObject:localUserNumber] && [friendsReceived count]>0)
                    {
                        [mainViewObj setSelectedGroupName:selectedGroupName];
                        [mainViewObj setSelectedGroupNum:[groupsNumDictionary objectForKey:selectedGroupName]];
                        [mainViewObj setPostsRefreshSignal];
                        
                        [connProgress stopAnimating];
                        connProgress.hidden=TRUE;
                        [tabVw setUserInteractionEnabled:TRUE];
                        [tabVw setAlpha:1.0];
                        
                        [mainViewObj clearBufferList];
                        [mainViewObj clearAllPosts];
                        [self dismissViewControllerAnimated:YES completion:NULL];
                    }
                    else
                    {
                        if([friendsReceived count]==0)
                        {
                            UIAlertView *tryAgainAlert=[[UIAlertView alloc]initWithTitle:@"Please try again" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                            [tryAgainAlert show];
                            [tryAgainAlert release];
                            
                            [connProgress stopAnimating];
                            connProgress.hidden=TRUE;
                            addGrp.enabled=TRUE;
                            backToMain.enabled=TRUE;
                            [tabVw setUserInteractionEnabled:TRUE];
                            [tabVw setAlpha:1.0];
                            
                            myGroups.enabled=TRUE;
                            allGroups.enabled=TRUE;
                        }
                        else
                        {
                            UIAlertView *joinAlert=[[UIAlertView alloc]initWithTitle:@"Join this group ?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                            [joinAlert show];
                            [joinAlert release];
                        }
                    }
                }
            });
        });   
    }
    
    /*
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            });
     */
}

-(IBAction)backToMain
{
    /*Call to main to clear buffer holding group list and then dismiss view*/
    [mainViewObj clearBufferList];
    [self dismissViewControllerAnimated:YES completion:NULL];
    [mainViewObj release];
}


-(IBAction)createGroup
{
    addGrp.enabled=FALSE;
    backToMain.enabled=FALSE;
    [tabVw setUserInteractionEnabled:FALSE];
    myGroups.enabled=FALSE;
    allGroups.enabled=FALSE;
    isSecured=FALSE;

    UIAlertView *createAlert=[[UIAlertView alloc]initWithTitle:@"New Group" message:[NSString stringWithFormat:@"Enter the group name"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    
    alertView=[[UIView alloc]initWithFrame:CGRectMake(36.0, 137.0, 248.0, 272.0)];
    [alertView setAlpha:0.0];
    [self.view addSubview:alertView];
    
    /*Add up frills to this view*/
    alertView.layer.cornerRadius=12.0;
    [alertView.layer setMasksToBounds:YES];
    alertView.layer.backgroundColor=[[UIColor blackColor]colorWithAlphaComponent:0.9].CGColor;
    alertView.layer.borderColor=[UIColor lightGrayColor].CGColor;
    alertView.layer.borderWidth=3.0;
    
    [UIView animateWithDuration:0.6 animations:^{
        [alertView setAlpha:0.9];
        [tabVw setAlpha:0.2];
    }];
    
    /*Add the alertview label*/
    UILabel *alertLabel=[[UILabel alloc]initWithFrame: CGRectMake(77.0, 15.0, 101.0, 20.0)];
    alertLabel.text=@"New Group";
    alertLabel.textColor=[UIColor whiteColor];
    alertLabel.font=[UIFont fontWithName:@"Arial" size:17.0];
    alertLabel.backgroundColor=[UIColor clearColor];
    [alertView addSubview:alertLabel];

    /*Add the text-field for group name*/
    groupNameField=[[UITextField alloc]initWithFrame:CGRectMake(20.0,52.0,208.0,30.0)];
    groupNameField.placeholder=@"Group Name";
    [groupNameField setBackgroundColor:[UIColor whiteColor]];
    [groupNameField setBorderStyle:UITextBorderStyleRoundedRect];
    [groupNameField setReturnKeyType:UIReturnKeyDone];
    groupNameField.delegate=self;
    [alertView addSubview:groupNameField];
    
    /*Add the secured group label*/
    UILabel *secureGroupLabel=[[UILabel alloc]initWithFrame: CGRectMake(43.0, 109.0, 100.0, 24.0)];
    secureGroupLabel.text=@"Secured Group";
    secureGroupLabel.textColor=[UIColor whiteColor];
    secureGroupLabel.font=[UIFont fontWithName:@"Arial" size:14.0];
    secureGroupLabel.backgroundColor=[UIColor clearColor];
    [alertView addSubview:secureGroupLabel];

    /*Add the secured group switch*/
    securedSwitch=[[UISwitch alloc]initWithFrame:CGRectMake(151.0, 102.0, 64.24, 22.0)];
    [securedSwitch addTarget:self action:@selector(securedSwitchAction:) forControlEvents:UIControlEventValueChanged];
    [alertView addSubview:securedSwitch];

    
    /*Add the text-field for group password*/
    groupPasswordField=[[UITextField alloc]initWithFrame:CGRectMake(20.0,138.0,208.0,30.0)];
    groupPasswordField.placeholder=@"Group Password";
    [groupPasswordField setSecureTextEntry:YES];
    [groupPasswordField setBackgroundColor:[UIColor whiteColor]];
    [groupPasswordField setBorderStyle:UITextBorderStyleRoundedRect];
    [groupPasswordField setReturnKeyType:UIReturnKeyDone];
    groupPasswordField.delegate=self;
    groupPasswordField.enabled=FALSE;
    [alertView addSubview:groupPasswordField];
    
    /*Add the text-field for retype group password*/
    retypePasswordField=[[UITextField alloc]initWithFrame:CGRectMake(20.0,174.0,208.0,30.0)];
    retypePasswordField.placeholder=@"Re-type Password";
    [retypePasswordField setSecureTextEntry:YES];
    [retypePasswordField setBackgroundColor:[UIColor whiteColor]];
    [retypePasswordField setBorderStyle:UITextBorderStyleRoundedRect];
    [retypePasswordField setReturnKeyType:UIReturnKeyDone];
    retypePasswordField.delegate=self;
    retypePasswordField.enabled=FALSE;
    [alertView addSubview:retypePasswordField];

    /*Add the create button*/
    createBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    createBtn.frame=CGRectMake(88.0, 225.0, 72.0, 30.0);
    [createBtn addTarget:self action:@selector(invokeCreate) forControlEvents:UIControlEventTouchUpInside];
    [createBtn setTitle:@"Create" forState:UIControlStateNormal];
    [alertView addSubview:createBtn];
    
    
    /*Add the close view button*/
    closeBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setBackgroundColor:[UIColor clearColor]];
    [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    closeBtn.frame=CGRectMake(218.0, -1.0, 34.0, 30.0);
    [closeBtn addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setTitle:@"X" forState:UIControlStateNormal];
    [alertView addSubview:closeBtn];
    
    
    CGAffineTransform createAlertTrans=CGAffineTransformMakeTranslation(0.0, -80.0);
    [createAlert setTransform:createAlertTrans];
    //[createAlert show];
    
    [createAlert release];
}

/*Enable group password field, if switch is set to ON*/
-(void)securedSwitchAction: (id)sender
{
    UISwitch *localSwitch=(UISwitch *)sender;
    if (localSwitch.on)
    {
        groupPasswordField.enabled=TRUE;
        retypePasswordField.enabled=TRUE;
        isSecured=TRUE;
    }
    else
    {
        groupPasswordField.enabled=FALSE;
        retypePasswordField.enabled=FALSE;
        isSecured=FALSE;
    }
}

-(void)closeView
{
    [UIView animateWithDuration:0.5 animations:^{
        [alertView setAlpha:0.0];
        [tabVw setAlpha:1.0];
    }];
    
    if(groupNameFieldCheck==1)
    {
        [groupNameField resignFirstResponder];
    }
    if(groupPasswordFieldCheck==1)
    {
        [groupPasswordField resignFirstResponder];
    }
    if(retypeGroupPasswordFieldCheck==1)
    {
        [retypePasswordField resignFirstResponder];
    }
    
    addGrp.enabled=TRUE;
    backToMain.enabled=TRUE;
    [tabVw setUserInteractionEnabled:TRUE];
    myGroups.enabled=TRUE;
    allGroups.enabled=TRUE;
}


-(void)invokeCreate
{
    NSLog(@"ready to go..");
    
    /*Capture entered group name & password*/
    newGroupName=[groupNameField.text retain];
    newGroupName=[[newGroupName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]retain];
    NSLog(@"group name is: %@",newGroupName);
    
    /*Place call to server to store new group details*/
    NSLog(@"userid check: %@",localUserId);
    NSLog(@"coords lat check: %f",locationLat);
    NSLog(@"coords long check: %f",locationLong);
    
    if(newGroupName==NULL || [newGroupName isEqualToString: @""] || [newGroupName isEqualToString:@" "])
    {
        UIAlertView *nullGroupAlert=[[UIAlertView alloc]initWithTitle:@"Empty Group name !" message:[NSString stringWithFormat:@"Group name cannot be blank"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [nullGroupAlert show];
        [nullGroupAlert release];
    }
    else
    {
        if(isSecured)
        {
            newGroupPwd=groupPasswordField.text;
            newGroupPwd=[newGroupPwd stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if(newGroupPwd==NULL || [newGroupPwd isEqualToString: @""] || [newGroupPwd isEqualToString:@" "])
            {
                UIAlertView *nullPwdAlert=[[UIAlertView alloc]initWithTitle:@"Empty Password !" message:[NSString stringWithFormat:@"You must provide a password for secured group"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [nullPwdAlert show];
                [nullPwdAlert release];
            }
            else
            {
                retypeGroupPwd=retypePasswordField.text;
                retypeGroupPwd=[retypeGroupPwd stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if(retypeGroupPwd==NULL || [retypeGroupPwd isEqualToString:@""]|| ![retypeGroupPwd isEqualToString:newGroupPwd])
                {
                    UIAlertView *retypePwdAlert=[[UIAlertView alloc]initWithTitle:@"Password mismatch !" message:@"Please re-type the password correctly" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [retypePwdAlert show];
                    [retypePwdAlert release];
                }
                else if([retypeGroupPwd isEqualToString:newGroupPwd])
                {
                    [UIView animateWithDuration:0.5 animations:^{
                        [alertView setAlpha:0.0];
                        [tabVw setAlpha:1.0];
                    }];

                    dispatch_async(dispatch_get_main_queue(), ^{
                        [restObj createGroup :locationLat :locationLong :newGroupName :localUserNumber :newGroupPwd :localAccessToken :@"addGroup"];
                        NSLog(@"calling for status from server..");
                        retval=[restObj returnValue];
                        if(retval==1)
                        {
                            UIAlertView *createdAlert=[[UIAlertView alloc]initWithTitle:@"Success" message:[NSString stringWithFormat:@"New Group Successfully created"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                            [createdAlert show];
                            [createdAlert release];
                            
                            [self refreshUI];
                        }
                        else if(retval==-1)
                        {
                            UIAlertView *createdAlert=[[UIAlertView alloc]initWithTitle:@"Failed" message:[NSString stringWithFormat:@"New Group could not be created"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                            [createdAlert show];
                            [createdAlert release];
                        }
                        else if(retval==0)
                        {
                            UIAlertView *connNullAlert=[[UIAlertView alloc]initWithTitle:@"Connection Error" message:@"Unable to contact server" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                            [connNullAlert show];
                            [connNullAlert release];
                        }
                    });
                    
                    addGrp.enabled=TRUE;
                    backToMain.enabled=TRUE;
                    [tabVw setUserInteractionEnabled:TRUE];
                    myGroups.enabled=TRUE;
                    allGroups.enabled=TRUE;
                    [connProgress stopAnimating];
                }
            }
        }
        else
        {
            [UIView animateWithDuration:0.5 animations:^{
                [alertView setAlpha:0.0];
                [tabVw setAlpha:1.0];
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"please work!! %@",newGroupName);

                [restObj createGroup :locationLat :locationLong :newGroupName :localUserNumber :newGroupPwd :localAccessToken :@"addGroup"];
                NSLog(@"calling for status from server..");
                retval=[restObj returnValue];
                if(retval==1)
                {
                    UIAlertView *createdAlert=[[UIAlertView alloc]initWithTitle:@"Success" message:[NSString stringWithFormat:@"New Group Successfully created"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [createdAlert show];
                    [createdAlert release];
                    
                    [self refreshUI];
                }
                else if(retval==-1)
                {
                    UIAlertView *createdAlert=[[UIAlertView alloc]initWithTitle:@"Failed" message:[NSString stringWithFormat:@"New Group could not be created"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [createdAlert show];
                    [createdAlert release];
                }
                else if(retval==0)
                {
                    UIAlertView *connNullAlert=[[UIAlertView alloc]initWithTitle:@"Connection Error" message:@"Unable to contact server" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [connNullAlert show];
                    [connNullAlert release];
                }
            });
            
            addGrp.enabled=TRUE;
            backToMain.enabled=TRUE;
            [tabVw setUserInteractionEnabled:TRUE];
            myGroups.enabled=TRUE;
            allGroups.enabled=TRUE;
            [connProgress stopAnimating];
        }
    }
}

#pragma mark textfield delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField==groupNameField)
    {
        groupNameFieldCheck=1;
        groupPasswordFieldCheck=0;
        retypeGroupPasswordFieldCheck=0;
        [groupNameField resignFirstResponder];
    }
    else if (textField==groupPasswordField)
    {
        groupNameFieldCheck=0;
        groupPasswordFieldCheck=1;
        retypeGroupPasswordFieldCheck=0;
        [groupPasswordField resignFirstResponder];
    }
    else if (textField==retypePasswordField)
    {
        groupNameFieldCheck=0;
        groupPasswordFieldCheck=0;
        retypeGroupPasswordFieldCheck=1;
        [retypePasswordField resignFirstResponder];
    }
    return 1;
}

#pragma mark alertview delegate

- (void)alertView:(UIAlertView *)alertViewOld didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        NSString *groupNumber=[groupsNumDictionary objectForKey:selectedGroupName];
        NSString *groupPwdCheck=[groupsPwdDictionary objectForKey:selectedGroupName];

        if([alertViewOld.title isEqual:@"Join this group ?"])
        {
            /*Call the join group endpoint*/
            dispatch_async(dispatch_get_main_queue(), ^{
                if([groupPwdCheck isEqualToString: @"true"])
                {
                    enterPasswordAlert=[[UIAlertView alloc]initWithTitle:@"Group Password" message:[NSString stringWithFormat:@"Enter the group password"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                    
                    enterPasswordAlert.alertViewStyle=UIAlertViewStyleSecureTextInput;
                    [enterPasswordAlert textFieldAtIndex:0].delegate=self;
                    [enterPasswordAlert show];
                    
                }
                else
                {
                    [restObj joinGroup:localUserNumber :groupNumber :locationLat :locationLong :NULL :localAccessToken :@"joinGroup"];
                    NSLog(@"calling for status from server..");
                    retval=[restObj returnValue];
                    if(retval==1)
                    {
                        [mainViewObj setSelectedGroupName:selectedGroupName];
                        [mainViewObj setSelectedGroupNum:[groupsNumDictionary objectForKey:selectedGroupName]];
                        [mainViewObj clearBufferList];
                        [mainViewObj clearAllPosts];
                        
                        addGrp.enabled=TRUE;
                        backToMain.enabled=TRUE;
                        [tabVw setUserInteractionEnabled:TRUE];
                        myGroups.enabled=TRUE;
                        allGroups.enabled=TRUE;
                        [connProgress stopAnimating];
                        connProgress.hidden=TRUE;
                        
                        [self dismissViewControllerAnimated:YES completion:NULL];
                    }
                    else if(retval==-1)
                    {
                        UIAlertView *createdAlert=[[UIAlertView alloc]initWithTitle:@"Failed" message:[NSString stringWithFormat:@"Could not join the group"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [createdAlert show];
                        [createdAlert release];
                        
                        addGrp.enabled=TRUE;
                        backToMain.enabled=TRUE;
                        [tabVw setUserInteractionEnabled:TRUE];
                        myGroups.enabled=TRUE;
                        allGroups.enabled=TRUE;
                        [connProgress stopAnimating];
                        connProgress.hidden=TRUE;
                    }
                    else if(retval==0)
                    {
                        UIAlertView *connNullAlert=[[UIAlertView alloc]initWithTitle:@"Connection Error" message:@"Unable to contact server" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [connNullAlert show];
                        [connNullAlert release];
                        
                        addGrp.enabled=TRUE;
                        backToMain.enabled=TRUE;
                        [tabVw setUserInteractionEnabled:TRUE];
                        myGroups.enabled=TRUE;
                        allGroups.enabled=TRUE;
                        [connProgress stopAnimating];
                        connProgress.hidden=TRUE;
                    }
                }
            });
            
            /*
            double delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
             
            });
             */
        }
        else if ([alertViewOld.title isEqualToString:@"Group Password"])
        {
            groupJoinPwd=[enterPasswordAlert textFieldAtIndex:0].text;
            NSLog(@"Joining group:%@ with password:%@",groupNumber,groupJoinPwd);
            
            retval=0;
            restObj=[[messengerRESTclient alloc]init];
            [restObj joinGroup:localUserNumber :groupNumber :locationLat :locationLong :groupJoinPwd :localAccessToken :@"joinGroup"];
            double delayInSeconds = 3.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                retval=[restObj returnValue];
                if(retval==1)
                {
                    [mainViewObj setSelectedGroupName:selectedGroupName];
                    [mainViewObj setSelectedGroupNum:[groupsNumDictionary objectForKey:selectedGroupName]];
                    [mainViewObj clearBufferList];
                    [mainViewObj clearAllPosts];
                    
                    addGrp.enabled=TRUE;
                    backToMain.enabled=TRUE;
                    [tabVw setUserInteractionEnabled:TRUE];
                    myGroups.enabled=TRUE;
                    allGroups.enabled=TRUE;
                    [connProgress stopAnimating];
                    connProgress.hidden=TRUE;
                    
                    [self dismissViewControllerAnimated:YES completion:NULL];
                }
                else if(retval==-1)
                {
                    UIAlertView *createdAlert=[[UIAlertView alloc]initWithTitle:@"Failed" message:[NSString stringWithFormat:@"Could not join the group"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [createdAlert show];
                    [createdAlert release];
                    
                    addGrp.enabled=TRUE;
                    backToMain.enabled=TRUE;
                    [tabVw setUserInteractionEnabled:TRUE];
                    myGroups.enabled=TRUE;
                    allGroups.enabled=TRUE;
                    [connProgress stopAnimating];
                    connProgress.hidden=TRUE;
                }
                else if(retval==0)
                {
                    UIAlertView *connNullAlert=[[UIAlertView alloc]initWithTitle:@"Connection Error" message:@"Unable to contact server" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [connNullAlert show];
                    [connNullAlert release];
                    
                    addGrp.enabled=TRUE;
                    backToMain.enabled=TRUE;
                    [tabVw setUserInteractionEnabled:TRUE];
                    myGroups.enabled=TRUE;
                    allGroups.enabled=TRUE;
                    [connProgress stopAnimating];
                    connProgress.hidden=TRUE;
                }
            });
        }
    }
    
    else if(buttonIndex==0)
    {
        if ([alertViewOld.title isEqualToString:@"Empty Group name !"])
        {
            [tabVw setUserInteractionEnabled:FALSE];
            [tabVw setAlpha:0.0];
            connProgress.hidden=FALSE;
            [connProgress stopAnimating];
            addGrp.enabled=FALSE;
            backToMain.enabled=FALSE;
        }
        else if ([alertViewOld.title isEqualToString:@"Empty Password !"])
        {
            [tabVw setUserInteractionEnabled:FALSE];
            [tabVw setAlpha:0.0];
            connProgress.hidden=FALSE;
            [connProgress stopAnimating];
            addGrp.enabled=FALSE;
            backToMain.enabled=FALSE;
        }
        else
        {
            [tabVw setUserInteractionEnabled:TRUE];
            [tabVw setAlpha:1.0];
            connProgress.hidden=TRUE;
            [connProgress stopAnimating];
            addGrp.enabled=TRUE;
            backToMain.enabled=TRUE;
        }
    }
}


-(void)getLocationCoords:(double)locationLatitude :(double)locationLongitude
{
    locationLat=locationLatitude;
    locationLong=locationLongitude;
    NSLog(@"received coords: lat: %f ,long: %f",locationLat,locationLong);
}

-(void)getUserNumber: (NSString *)userNum;
{
    localUserNumber=[userNum retain];
    NSLog(@"received userNumber: %@",localUserNumber);
}

-(void)getAccessToken:(NSString *)accessToken
{
    localAccessToken=[accessToken retain];
    NSLog(@"received accessToken: %@",localAccessToken);
}

-(void)getUserData: (NSString *)userId :(NSString *)userPwd :(NSString *)userEmailID
{
    //localUserNumber=[userNum retain];
    localUserId=[userId retain];
    localUserPwd=[userPwd retain];
    localUserEmailID=[userEmailID retain];
    NSLog(@"received userId: %@",localUserId);
    NSLog(@"received userPwd: %@",localUserPwd);
    NSLog(@"received userEmailID: %@",localUserEmailID);
}



#pragma mark - Tab-bar delegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item;
{
    if(item==allGroups)
    {
        myGroupsCheck=0;
        allGroupsCheck=1;
        
        addGrp.enabled=FALSE;
        backToMain.enabled=FALSE;
        connProgress.hidden=FALSE;
        [connProgress startAnimating];
        [tabVw setUserInteractionEnabled:FALSE];
        [tabVw setAlpha:0.2];
        myGroups.enabled=FALSE;
        allGroups.enabled=FALSE;
        
        [navBar.topItem setTitle:@"All Groups"];
        
        if([groupList count]>0)
        {
            [groupList removeAllObjects];
        }
        
        //fetchMyGroupsQueue=dispatch_queue_create("fetchMyGroups", NULL);
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [restObj showAllGroups:localUserNumber :locationLat :locationLong :localAccessToken :@"showGroups"];
        });
            
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds *NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
        NSLog(@"calling for status from server..");
        retval=[restObj returnValue];
        if(retval==1)
        {
            double delayInSeconds = 0.3;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self retrieveListOfGroups];
                [tabVw setUserInteractionEnabled:TRUE];
                [tabVw setAlpha:1.0];
                connProgress.hidden=TRUE;
                [connProgress stopAnimating];
                addGrp.enabled=TRUE;
                backToMain.enabled=TRUE;
                myGroups.enabled=TRUE;
                allGroups.enabled=TRUE;
            });
        }
        else if(retval==-1)
        {
            UIAlertView *createdAlert=[[UIAlertView alloc]initWithTitle:@"Sorry" message:[NSString stringWithFormat:@"Groups could not be fetched for you at this time"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [createdAlert show];
            [createdAlert release];
                    
            [tabVw setUserInteractionEnabled:TRUE];
            [tabVw setAlpha:1.0];
            connProgress.hidden=TRUE;
            [connProgress stopAnimating];
            addGrp.enabled=TRUE;
            backToMain.enabled=TRUE;
            myGroups.enabled=TRUE;
            allGroups.enabled=TRUE;
        }
        else if(retval==0)
        {
            UIAlertView *connNullAlert=[[UIAlertView alloc]initWithTitle:@"Connection Error" message:@"Unable to contact server" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [connNullAlert show];
            [connNullAlert release];
            
            [tabVw setUserInteractionEnabled:TRUE];
            [tabVw setAlpha:1.0];
            connProgress.hidden=TRUE;
            [connProgress stopAnimating];
            addGrp.enabled=TRUE;
            backToMain.enabled=TRUE;
            myGroups.enabled=TRUE;
            allGroups.enabled=TRUE;
        }
        });
    }
    else if (item==myGroups)
    {
        myGroupsCheck=1;
        allGroupsCheck=0;
        
        addGrp.enabled=FALSE;
        backToMain.enabled=FALSE;
        connProgress.hidden=FALSE;
        [connProgress startAnimating];
        [tabVw setUserInteractionEnabled:FALSE];
        [tabVw setAlpha:0.2];
        myGroups.enabled=FALSE;
        allGroups.enabled=FALSE;
        
        [navBar.topItem setTitle:@"My Groups"];
        
        if([groupList count]>0)
        {
            [groupList removeAllObjects];
        }
        
        //fetchOtherGroupsQueue=dispatch_queue_create("fetchOtherGroups", NULL);
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [restObj showMyGroups:localUserNumber:locationLat:locationLong:localAccessToken :@"listMemberGroups"];
        });
        
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            NSLog(@"calling for status from server..");
            retval=[restObj returnValue];
            if(retval==1)
            {
                [self retrieveListOfGroups];
                [tabVw setUserInteractionEnabled:TRUE];
                [tabVw setAlpha:1.0];
                connProgress.hidden=TRUE;
                [connProgress stopAnimating];
                addGrp.enabled=TRUE;
                backToMain.enabled=TRUE;
                myGroups.enabled=TRUE;
                allGroups.enabled=TRUE;
            }
            else if(retval==-1)
            {
                UIAlertView *createdAlert=[[UIAlertView alloc]initWithTitle:@"Sorry" message:[NSString stringWithFormat:@"Groups could not be fetched for you at this time"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [createdAlert show];
                [createdAlert release];
                
                [tabVw setUserInteractionEnabled:TRUE];
                connProgress.hidden=TRUE;
                [connProgress stopAnimating];
                addGrp.enabled=TRUE;
                backToMain.enabled=TRUE;
                myGroups.enabled=TRUE;
                allGroups.enabled=TRUE;
            }
            else if(retval==0)
            {
                UIAlertView *connNullAlert=[[UIAlertView alloc]initWithTitle:@"Connection Error" message:@"Unable to contact server" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [connNullAlert show];
                [connNullAlert release];
                
                [tabVw setUserInteractionEnabled:TRUE];
                [tabVw setAlpha:1.0];
                connProgress.hidden=TRUE;
                [connProgress stopAnimating];
                addGrp.enabled=TRUE;
                backToMain.enabled=TRUE;
                myGroups.enabled=TRUE;
                allGroups.enabled=TRUE;
            }
        });
    }
}


-(BOOL)shouldAutorotate
{
    return NO;
}


@end
