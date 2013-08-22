//
//  groupsTableViewViewController.h
//  socialNetwork-UTD
//
//  Created by Ankit Malhotra on 04/12/12.
//  Copyright (c) 2012 Ankit Malhotra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "messengerViewController.h"
#import "newPostViewController.h"
#import "messengerRESTclient.h"
#import "loginViewController.h"

@class messengerViewController;
@class messengerRESTclient;
@class newPostViewController;

@interface groupsTableViewViewController : UIViewController
         <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UITabBarDelegate,UITextFieldDelegate>
{
    IBOutlet UINavigationBar *navBar;
    IBOutlet UITableView *tabVw;
    IBOutlet UIBarButtonItem *addGrp;
    IBOutlet UIBarButtonItem *backToMain;
    IBOutlet UITabBar *groupsTab;
    IBOutlet UITabBarItem *myGroups;
    IBOutlet UITabBarItem *allGroups;
    IBOutlet UIActivityIndicatorView *connProgress;
    
    //dispatch_queue_t fetchMyGroupsQueue;
    //dispatch_queue_t fetchOtherGroupsQueue;

    /*Custom UI elements for "New Group" view*/
    UIView *newGroupAlertView;
    UITextField *groupNameField;
    UIAlertView *groupPasswordAlert;
    UITextField *groupPasswordField;
    UITextField *retypePasswordField;
    UISwitch *securedSwitch;
    UIButton *createBtn;
    UIButton *lockButton;
    UIButton *closeBtn;
    UIRefreshControl *refreshCntl;
        
    UIAlertView *enterPasswordAlert;

    int retval;
    BOOL isSecured;
    
    messengerViewController *mainViewObj;
    messengerRESTclient *restObj;
    newPostViewController *newPostObj;
    loginViewController *loginViewObj;
}

@property(nonatomic,retain) IBOutlet UINavigationBar *navBar;
@property(nonatomic,retain) IBOutlet UITableView *tabVw;
@property(nonatomic,retain) IBOutlet UIBarButtonItem *addGrp;
@property(nonatomic,retain) IBOutlet UIBarButtonItem *backToMain;
@property(nonatomic,retain) IBOutlet UITabBar *groupsTab;
@property(nonatomic,retain) IBOutlet UITabBarItem *myGroups;
@property(nonatomic,retain) IBOutlet UITabBarItem *allGroups;
@property(nonatomic,retain) IBOutlet UIActivityIndicatorView *connProgress;


-(IBAction)backToMainView;
-(IBAction)createGroup;
-(void)invokeCreate;
-(void)closeView;
-(void)securedSwitchAction: (id)sender;
-(void)retrieveListOfGroups;
-(void)getLocationCoords:(double)locationLatitude :(double)locationLongitude;
-(void)getUserData: (NSString *)userId :(NSString *)userPwd :(NSString *)userEmailID;
-(void)getUserNumber: (NSString *)userNum;
-(void)getAccessToken: (NSString *)accessToken;

@end
