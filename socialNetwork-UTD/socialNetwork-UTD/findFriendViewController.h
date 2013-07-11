//
//  findFriendViewController.h
//  socialNetwork-UTD
//
//  Created by Ankit Malhotra on 5/27/13.
//  Copyright (c) 2013 Ankit Malhotra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "messengerAppDelegate.h"
#import "messengerViewController.h"
#import "messengerChatDelegate.h"
#import "messengerRESTclient.h"
#import "friendsViewController.h"


@class messengerViewController;
@class friendsViewController;
@class messengerAppDelegate;
@class messengerRESTclient;


@interface findFriendViewController : UIViewController
<UITableViewDataSource,UITableViewDelegate>
{
    IBOutlet UITableView *tabVw;
    UIRefreshControl *refreshControl;
    
    NSArray *friendList;
    NSString *selectedIndex;
    NSDictionary *friendDictionary;
    NSDictionary *friendUserIdDictionary;
    
    int retVal;
    
    messengerViewController *mainViewObj;
    friendsViewController *friendsViewObj;
    messengerRESTclient *restObj;
}

-(IBAction)backToMain;
-(void)refreshUI;
-(void)getFriendNumbers: (NSMutableArray *)friendNum;
-(void)setFriendUserId: (NSMutableArray *)friendUserId;

@end

