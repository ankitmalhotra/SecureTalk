//
//  friendsViewController.m
//  socialNetwork-UTD
//
//  Created by Ankit Malhotra on 17/12/12.
//  Copyright (c) 2012 Ankit Malhotra. All rights reserved.
//

#import "friendsViewController.h"
#import "XMPP.h"
#import "XMPPRoster.h"
#import "XMPPRosterCoreDataStorage.h"


static NSString *const kHostName = @"appserver.utdallas.edu";
static NSMutableArray *onlineBuddies;
static NSMutableArray *offlineBuddies;

static int chatStatus=0;

@implementation friendsViewController


-(messengerAppDelegate *)appDelegate
{
    return (messengerAppDelegate *)[[UIApplication sharedApplication]delegate];
}

-(XMPPStream *)xmppStream
{
    return [[self appDelegate]xmppStream];
}

- (XMPPRoster *)xmppRoster
{
	return [[self appDelegate] xmppRoster];
}


- (void)viewDidAppear:(BOOL)animated
{
    tabVw.dataSource=self;
    tabVw.delegate=self;
    
	[super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*Object instantiations*/
    mainViewObj=[[messengerViewController alloc] init];
    onlineBuddies = [[NSMutableArray alloc ] init];
    restObj=[[messengerRESTclient alloc]init];
    
    if(!offlineBuddies)
    {
        offlineBuddies = [[NSMutableArray alloc]init];  
    }
    
    messengerAppDelegate *appDel=[self appDelegate];
    appDel._chatDelegate=self;
    
    loginViewObj = [[loginViewController alloc]init];
	NSString *login = [[loginViewObj getXmppJID]retain];
	NSLog(@"JID received: %@",login);
    
    if(chatStatus==0)
    {
        chatStatusBarItem.title=@"Go Offline";
        chatStatusBarItem.image=[UIImage imageNamed:@"offline.png"];
        [chatStatusTab setSelectedImageTintColor:[UIColor greenColor]];
        
        if(login)
        {
            if([[self appDelegate] connect])
            {
                double delayInSeconds = 1.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [tabVw reloadData];
                    NSLog(@"Login successful!!");
                });
            }
        }
        else
        {
            NSLog(@"Login unsuccessful");
        }
    }
    else
    {
        chatStatusBarItem.title=@"Go Online";
        chatStatusBarItem.image=[UIImage imageNamed:@"offline.png"];
    }
	
    refreshControl=[[UIRefreshControl alloc]init];
    [refreshControl addTarget:self action:@selector(refreshUI) forControlEvents:UIControlEventValueChanged];
    [tabVw addSubview:refreshControl];
    
    /*Call to retrieve the collated data from server
    friendList=[mainViewObj getFriendObjects:nil:0];
    NSLog(@"friends got: %@",friendList);
    friendDictionary=[[NSDictionary alloc]initWithObjects:friendNumber forKeys:friendList];
    */ 
}


-(void)refreshUI
{
    if(chatStatus==0)
    {
        if([offlineBuddies count]==0)
        {
            [mainViewObj fetchRosterForMe];
        }
        double delayInSeconds = 3.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if ([[self appDelegate] connect])
            {
                [tabVw reloadData];
                NSLog(@"Login successful!!");
                [refreshControl endRefreshing];
            }
            else
            {
                [tabVw reloadData];
                NSLog(@"Login unsuccessful");
                [refreshControl endRefreshing];
            }
        });
    }
    else
    {
        if ([[self appDelegate] disconnect])
        {
            if([offlineBuddies count]==0)
            {
                [mainViewObj fetchRosterForMe];
            }
            double delayInSeconds = 3.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self setAllOffline];
                [tabVw reloadData];
                NSLog(@"Logout successful!!");
                [refreshControl endRefreshing];
            });
        }

    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([onlineBuddies count]>0 || [offlineBuddies count]>0)
    {
        return 2;
    }
    else
    {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if([onlineBuddies count]>0 || [offlineBuddies count]>0)
    {
        if(section==0)
        {
            return @"Online";
        }
        if (section==1)
        {
            return @"Offline";
        }
        else
        {
            return nil;
        }
    }
    else
    {
        return nil;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0)
    {
        NSLog(@"online buddy count: %d",[onlineBuddies count]);
        return [onlineBuddies count];
    }
    if (section==1)
    {
        NSLog(@"offline buddy count: %d",[offlineBuddies count]);
        return [offlineBuddies count];
    }
    else
    {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
    {
        static NSString *CellIdentifier = @"OnlineFriendCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        if([indexPath row]<[onlineBuddies count])
        {
            //NSLog(@"cell text: %@",[onlineBuddies objectAtIndex:[indexPath row]]);
            
            if([onlineBuddies count]>0)
            {
                selectedIndex=[onlineBuddies objectAtIndex:[indexPath row]];
                cell.textLabel.text=selectedIndex;
                [cell setUserInteractionEnabled:YES];
                return cell;
            }
            else
            {
                selectedIndex=NULL;
                cell.textLabel.text=selectedIndex;
                return cell;
            }
        }
        else
        {
            selectedIndex=NULL;
            cell.textLabel.text=selectedIndex;
            [cell setUserInteractionEnabled:NO];
            return cell;
        }
    }
    if (indexPath.section==1)
    {
        static NSString *CellIdentifier = @"OfflineFriendCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }

        if([indexPath row]<[offlineBuddies count])
        {
            //NSLog(@"cell text: %@",[offlineBuddies objectAtIndex:[indexPath row]]);
                        
            if([offlineBuddies count]>0)
            {
                selectedIndex=[offlineBuddies objectAtIndex:[indexPath row]];
                cell.textLabel.text=selectedIndex;
                cell.textLabel.textColor=[UIColor grayColor];
                [cell setUserInteractionEnabled:NO];
                return cell;
            }
            else
            {
                selectedIndex=NULL;
                cell.textLabel.text=selectedIndex;
                return cell;
            }
        }
        else
        {
            selectedIndex=NULL;
            cell.textLabel.text=selectedIndex;
            [cell setUserInteractionEnabled:NO];
            return cell;
        }
    }
    else
    {
        return nil;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
    {
        selectedIndex=[onlineBuddies objectAtIndex:[indexPath row]];
        
        [mainViewObj setSelectedIndexFriends:selectedIndex];
        [mainViewObj clearBufferList];
        
        NSLog(@"selected friend is: %@",selectedIndex);
        userChatObj=[[userChatViewController alloc]initWithNibName:nil bundle:nil];
        [userChatObj getReceiverName:selectedIndex];
        [self presentViewController:userChatObj animated:YES completion:nil];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    if (indexPath.section==1)
    {
        selectedIndex=[offlineBuddies objectAtIndex:[indexPath row]];
        
        [mainViewObj setSelectedIndexFriends:selectedIndex];
        [mainViewObj clearBufferList];
        
        NSLog(@"selected friend is: %@",selectedIndex);
        userChatObj=[[userChatViewController alloc]initWithNibName:nil bundle:nil];
        [userChatObj getReceiverName:selectedIndex];
        [self presentViewController:userChatObj animated:YES completion:nil];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
	
    //[self dismissViewControllerAnimated:YES completion:nil];
}


-(void)sendBuddyRequest:(NSString *)name
{
    name=[name stringByAppendingString:@"@"];
    name=[name stringByAppendingString:kHostName];
    XMPPJID *newBuddy = [XMPPJID jidWithString:name];
    [[self appDelegate]getRoster:newBuddy];
}

/*Receive the list of all buddies in the user's roster*/
-(void)receiveAllBuddies: (NSMutableArray *)allBuddyList
{
    if(offlineBuddies==NULL)
    {
        offlineBuddies=[[NSMutableArray alloc]init];
    }
    [offlineBuddies addObjectsFromArray:[allBuddyList retain]];
    NSLog(@"receiving buddy list to be shown: %@",[offlineBuddies retain]);
}

#pragma mark -
#pragma mark Chat delegate

-(void)setOnline: (NSString *)buddyName
{
    NSLog(@"new buddy is: %@",buddyName);
    
	if (![onlineBuddies containsObject:buddyName])
    {
        NSLog(@"adding buddy to list");
		[onlineBuddies addObject:buddyName];
        
        if([offlineBuddies containsObject:buddyName])
        {
            NSLog(@"removing buddy from offline list");
            [offlineBuddies removeObject:buddyName];
        }
        [tabVw reloadData];
	}
    else
    {
        NSLog(@"%@ already there!",buddyName);
    }
}

-(void)setOffline:(NSString *)buddyName
{
    [onlineBuddies removeObject:buddyName];
    if(![offlineBuddies containsObject:buddyName])
    {
        [offlineBuddies addObject:buddyName];
    }
	[tabVw reloadData];
}

-(void)setAllOffline
{
    if([onlineBuddies count]>0)
    {
        for(int j=0;j<[onlineBuddies count];j++)
        {
            [offlineBuddies addObject:[onlineBuddies objectAtIndex:j]];
            [onlineBuddies removeObjectAtIndex:j];
        }
    }
    
	[tabVw reloadData];
}

- (void)newBuddyOnline:(NSString *)buddyName
{
    NSLog(@"new buddy is: %@",buddyName);
    
	if (![onlineBuddies containsObject:buddyName])
    {
		[onlineBuddies addObject:buddyName];
		[tabVw reloadData];
	}
    else
    {
        NSLog(@"%@ already there!",buddyName);
    }
     
}

- (void)buddyWentOffline:(NSString *)buddyName
{	
	[onlineBuddies removeObject:buddyName];
	[tabVw reloadData];
}

- (void)didDisconnect
{
	[onlineBuddies removeAllObjects];
    [offlineBuddies removeAllObjects];
	[tabVw reloadData];
}


-(IBAction)backToMain
{
    [mainViewObj clearBufferList];
    [self dismissViewControllerAnimated:YES completion:NULL];
    [mainViewObj release];
}

-(IBAction)addFriend
{
    findFriendViewController *fTblView=[[findFriendViewController alloc]initWithNibName:nil bundle:nil];
    [self presentViewController:fTblView animated:YES completion:NULL];
    [fTblView release];
}

-(BOOL)shouldAutorotate
{
    return NO;
}


#pragma mark - Tab-bar delegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if(item==chatStatusBarItem)
    {
       if(chatStatus==0)
       {
           chatStatus=1;
           chatStatusBarItem.title=@"Go Online";
           [chatStatusTab setSelectedImageTintColor:[UIColor grayColor]];
           [[self appDelegate]disconnect];
           
           [tabVw reloadData];
       }
       else if (chatStatus==1)
       {
           chatStatus=0;
           chatStatusBarItem.title=@"Go Offline";
           [chatStatusTab setSelectedImageTintColor:[UIColor greenColor]];
           [[self appDelegate]connect];
        
           [tabVw reloadData];
       }
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
