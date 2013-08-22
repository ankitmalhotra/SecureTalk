//
//  friendsViewController.h
//  socialNetwork-UTD
//
//  Created by Ankit Malhotra on 17/12/12.
//  Copyright (c) 2012 Ankit Malhotra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "messengerAppDelegate.h"
#import "messengerViewController.h"
#import "userChatViewController.h"
#import "messengerChatDelegate.h"
#import "loginViewController.h"
#import "messengerRESTclient.h"

@class messengerViewController;
@class userChatViewController;
@class loginViewController;
@class messengerRESTclient;


@interface friendsViewController : UIViewController
        <UITableViewDataSource,UITableViewDelegate,UITabBarDelegate,messengerChatDelegate>
{
    IBOutlet UITableView *tabVw;
    IBOutlet UIBarButtonItem *addFriend;
    IBOutlet UITabBar *chatStatusTab;
    IBOutlet UITabBarItem *chatStatusBarItem;
    
    UIRefreshControl *refreshControl;
    
    NSArray *friendList;
    NSString *selectedIndex;
    NSDictionary *friendDictionary;
    //NSMutableArray *onlineBuddies;
    
    messengerViewController *mainViewObj;
    userChatViewController *userChatObj;
    loginViewController *loginViewObj;
    messengerRESTclient *restObj;
}

-(IBAction)backToMain;
-(IBAction)addFriend;
-(void)refreshUI;
-(void)receiveAllBuddies: (NSMutableArray *)allBuddyList;
-(void)sendBuddyRequest: (NSString *)name;
-(void)setOnline: (NSString *)buddyName;
-(void)setOffline: (NSString *)buddyName;
-(void)setAllOffline;
;

@end
