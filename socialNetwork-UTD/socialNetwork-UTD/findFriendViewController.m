//
//  findFriendViewController.m
//  socialNetwork-UTD
//
//  Created by Ankit Malhotra on 5/27/13.
//  Copyright (c) 2013 Ankit Malhotra. All rights reserved.
//

#import "findFriendViewController.h"
#import "XMPP.h"
#import "XMPPRoster.h"

static NSMutableArray *_friendNumber;
static NSMutableArray *_friendUserId;


@implementation findFriendViewController


- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
    [tabVw reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*Object instantiations*/
    mainViewObj=[[messengerViewController alloc] init];
    friendsViewObj = [[friendsViewController alloc]init];
    restObj = [[messengerRESTclient alloc]init];
        
    
    /*Call to retrieve the collated data from server*/
    friendList=[mainViewObj getFriendObjects:nil:0];
    NSLog(@"friends got: %@",friendList);

    
    if([_friendNumber count]==[friendList count])
    {
        friendDictionary=[[NSDictionary alloc]initWithObjects:_friendNumber forKeys:friendList]; 
    }
    else
    {
        friendDictionary=[[NSDictionary alloc]initWithObjects:nil forKeys:nil];
    }

    //friendUserIdDictionary=[[NSDictionary alloc]initWithObjects:_friendUserId forKeys:friendList];
}




#pragma mark - Table view data source
/*
 - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
 {
 return [friendList count];
 }
 
 - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
 {
 return [[friendList allKeys] objectAtIndex:section];
 }
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [friendList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FriendCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    selectedIndex=[friendList objectAtIndex:[indexPath row]];
    cell.textLabel.text=selectedIndex;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	selectedIndex=[friendList objectAtIndex:[indexPath row]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSString *alertMessage=[[NSString alloc]initWithString:@"You are about to send a chat request to "];
    alertMessage=[alertMessage stringByAppendingString:selectedIndex];

    UIAlertView *confirmRequestAlert=[[UIAlertView alloc]initWithTitle:@"Add Buddy ?" message:alertMessage delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    [confirmRequestAlert show];
    [confirmRequestAlert release];    
}


-(void)getFriendNumbers:(NSMutableArray *)friendNumber
{
    _friendNumber=[friendNumber retain];
    NSLog(@"friend nums: %@",_friendNumber);
}



#pragma mark alertview delegate

- (void)alertView:(UIAlertView *)alertViewOld didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        
        NSLog(@"about to add %@ as buddy!",selectedIndex);
        [friendsViewObj sendBuddyRequest:selectedIndex];
        
        [mainViewObj setSelectedIndexFriends:selectedIndex];
        [mainViewObj clearBufferList];
        
        //NSLog(@"number of selected friend is: %@",[friendDictionary objectForKey:selectedIndex]);
        [self dismissViewControllerAnimated:YES completion:NULL];
        
        /*
        dispatch_async(dispatch_get_main_queue(), ^{
            [restObj getUserID:[friendDictionary objectForKey:selectedIndex] :@"getUserByNum"];
            retVal=[restObj returnValue];
            if(retVal==1)
            {
                double delayInSeconds = 1.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    NSLog(@"about to add %@ as buddy!",_friendUserId);
                    [friendsViewObj sendBuddyRequest:[_friendUserId objectAtIndex:0]];
                    
                    [mainViewObj setSelectedIndexFriends:selectedIndex];
                    [mainViewObj clearBufferList];
                    
                    NSLog(@"number of selected friend is: %@",[friendDictionary objectForKey:selectedIndex]);
                    [self dismissViewControllerAnimated:YES completion:NULL];
                });
            }
            else if(retVal==-1)
            {
                UIAlertView *msgListAlert=[[UIAlertView alloc]initWithTitle:@"Failed" message:[NSString stringWithFormat:@"Please try again"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [msgListAlert show];
                [msgListAlert release];
            }
            else if(retVal==0)
            {
                NSLog(@"retval is: %d",retVal);
                UIAlertView *connNullAlert=[[UIAlertView alloc]initWithTitle:@"Connection Error" message:@"Unable to contact server. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [connNullAlert show];
                [connNullAlert release];
            }
        }); 
       */  
    }
    else if (buttonIndex==0)
    {
        //do nothing
    }
}

-(void)setFriendUserId:(NSMutableArray *)friendUserId
{
    _friendUserId=[friendUserId retain];
    NSLog(@"friend user id received: %@",_friendUserId);
}

-(IBAction)backToMain
{
    [mainViewObj clearBufferList];
    [self dismissViewControllerAnimated:YES completion:NULL];
    [mainViewObj release];
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
