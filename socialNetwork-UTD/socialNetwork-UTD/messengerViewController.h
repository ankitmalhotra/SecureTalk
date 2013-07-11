//
//  messengerViewController.h
//  socialNetwork-UTD
//
//  Created by Ankit Malhotra on 10/10/12.
//  Copyright (c) 2012 Ankit Malhotra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "groupsTableViewViewController.h"
#import "friendsViewController.h"
#import "newPostViewController.h"
#import "signupUserViewController.h"
#import "messengerRESTclient.h"
#import "userChatViewController.h"
#import "detailMessageViewController.h"
#import "findFriendViewController.h"
#import "messengerChatDelegate.h"

@class groupsTableViewViewController;
@class messengerRESTclient;
@class newPostViewController;
@class friendsViewController;
@class findFriendViewController;
@class userChatViewController;
@class detailMessageViewController;


@interface messengerViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,messengerChatDelegate,UITabBarDelegate>
{
    /*Core IB-Outlets*/
    IBOutlet UIBarButtonItem *postBtn;
    IBOutlet UITabBarItem *friendsTab;
    IBOutlet UITabBarItem *groupsTab;
    IBOutlet UITabBar *mainViewTab;
    IBOutlet UINavigationBar *navBar;
    IBOutlet UITableView *postsViewer;
    IBOutlet UIActivityIndicatorView *connProgress;
    
    UIRefreshControl *refreshControl;
    NSString *cellDetailTextLabel;
    NSString *selectedPost;
    
    /*Objects to be used*/
    messengerRESTclient *restObj;
    groupsTableViewViewController *groupViewObj;
    newPostViewController *newPostObj;
    findFriendViewController *findFriendObj;
    userChatViewController *userChatObj;
    detailMessageViewController *detailMsgViewObj;
    
    /*Stores return status from REST calls to specific endpoints*/
    int retVal;
}


/*Method signatures*/
-(void)getUserId :(NSString *)userId :(NSString *)userPassword;
-(void)getUserMailID :(NSString *)mailID;
-(NSMutableArray *)getGroupObjects :(NSMutableArray *)inputArray :(int)toReturn;
-(NSMutableArray *)getFriendObjects :(NSMutableArray *)inputArray :(int)toReturn;
-(void)collectedPostData :(NSMutableArray *)inputArray;
-(void)setSelectedGroupNum:(NSString *)indexVal;
-(void)setSelectedGroupName:(NSString *)indexVal;
-(void)setSelectedIndexFriends:(NSString *)indexVal;
-(IBAction)createPost;
-(void)stopUpdate;
-(void)refreshTableView;
-(void)setPostsRefreshSignal;
-(void)clearBufferList;
-(void)clearAllPosts;
-(NSString *)signalGroupName;
-(NSMutableArray *)signalFriends;
-(void)showPostData :(NSString *)groupName;
-(void)storeUserDetails :(NSMutableArray *)userData;
-(void)initLocUpdate;
-(void)invokeChatView;
-(void)getGeoCoords :(double)latitude :(double)longitude;


@end
