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
        
    refreshControl=[[UIRefreshControl alloc]init];
    [refreshControl addTarget:self action:@selector(refreshUI) forControlEvents:UIControlEventValueChanged];
    [tabVw addSubview:refreshControl];
    
    /*Call to retrieve the collated data from server*/
    friendList=[mainViewObj getFriendObjects:nil:0];
    NSLog(@"friends got: %@",friendList);
    friendDictionary=[[NSDictionary alloc]initWithObjects:_friendNumber forKeys:friendList];
    //friendUserIdDictionary=[[NSDictionary alloc]initWithObjects:_friendUserId forKeys:friendList];
}


-(void)refreshUI
{
    [tabVw reloadData];
    [refreshControl endRefreshing];
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [restObj getUserID:[friendDictionary objectForKey:selectedIndex] :@"getUserByNum"];
        retVal=[restObj returnValue];
        if(retVal==1)
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
            UIAlertView *msgListAlert=[[UIAlertView alloc]initWithTitle:@"Failed" message:[NSString stringWithFormat:@"Message list could not be retrieved. Please try again"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [msgListAlert show];
            [msgListAlert release];
        }
        else if(retVal==0)
        {
            NSLog(@"retval is: %d",retVal);
            UIAlertView *connNullAlert=[[UIAlertView alloc]initWithTitle:@"Connection Error" message:@"Unable to contact server" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [connNullAlert show];
            [connNullAlert release];
        }
    });
}


-(void)getFriendNumbers:(NSMutableArray *)friendNumber
{
    _friendNumber=[friendNumber retain];
    NSLog(@"friend nums: %@",_friendNumber);
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
