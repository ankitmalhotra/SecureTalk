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
#import "MFSideMenuContainerViewController.h"


@class groupsTableViewViewController;
@class messengerRESTclient;
@class newPostViewController;
@class friendsViewController;
@class findFriendViewController;
@class userChatViewController;
@class detailMessageViewController;


@interface messengerViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITabBarDelegate,UIAlertViewDelegate,CLLocationManagerDelegate,UITextFieldDelegate>
{
    /*Core IB-Outlets*/
    IBOutlet UIBarButtonItem *postBtn;
    IBOutlet UITabBarItem *friendsTab;
    IBOutlet UITabBarItem *groupsTab;
    IBOutlet UITabBar *mainViewTab;
    IBOutlet UINavigationBar *navBar;
    IBOutlet UITableView *postsViewer;
    IBOutlet UIActivityIndicatorView *connProgress;
    
    UIAlertView *newChatMessage;
    
    UIView *wipeDataView;
    UIAlertView *credentialAlert;
    UIAlertView *changeEmailAlert;
    UIAlertView *changePasswordConfirmAlert;
    UIAlertView *changeEmailConfirmAlert;
    UIAlertView *changePasswordAlert;
    UIButton *deleteAllBtn;
    UIButton *changePasswordBtn;
    UIButton *changeEmailBtn;
    UILabel *settingsLabel;
    UIImageView *patchView;
    UIRefreshControl *refreshControl;
    NSString *cellDetailTextLabel;
    NSString *selectedPost;
    
    /*Objects to be used*/
    messengerRESTclient *restObj;
    groupsTableViewViewController *groupViewObj;
    newPostViewController *newPostObj;
    findFriendViewController *findFriendObj;
    friendsViewController *friendObj;
    userChatViewController *userChatObj;
    detailMessageViewController *detailMsgViewObj;
    loginViewController *loginViewObj;
    
    
    /*Stores return status from REST calls to specific endpoints*/
    int retVal;
}


/*Method signatures*/
-(void)getUserId :(NSString *)userId :(NSString *)userPassword;
-(void)getUserMailID :(NSString *)mailID;
-(NSMutableArray *)getGroupObjects :(NSMutableArray *)inputArray :(int)toReturn;
-(NSMutableArray *)getFriendObjects :(NSMutableArray *)inputArray :(int)toReturn;
-(NSString *)signalGroupName;
-(NSMutableArray *)signalFriends;
-(void)collectedPostData :(NSMutableArray *)inputArray;
-(void)setSelectedGroupNum:(NSString *)indexVal;
-(void)setSelectedGroupName:(NSString *)indexVal;
-(void)setSelectedIndexFriends:(NSString *)indexVal;
-(void)stopUpdate;
-(void)refreshTableView;
-(void)setPostsRefreshSignal;
-(void)clearBufferList;
-(void)clearAllPosts;
-(void)showPostData :(NSString *)groupName;
-(void)storeUserDetails :(NSMutableArray *)userData;
-(void)initLocUpdate;
-(void)invokeChatView :(NSString *)sender :(NSString *)messageData;
-(void)getGeoCoords :(double)latitude :(double)longitude;
-(void)wipeAllUserData;
-(void)changeUserPassword;
-(void)changeUserEmailAddress;
-(void)collectedRosterSubscribers:(NSMutableArray *)inputArray;
-(void)fetchRosterForMe;
-(int)tellLoginStatus;

-(IBAction)createPost;
-(IBAction)settingsMenu;


@end
