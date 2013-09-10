//
//  newPostViewController.h
//  socialNetwork-UTD
//
//  Created by Ankit Malhotra on 01/01/13.
//  Copyright (c) 2013 Ankit Malhotra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "messengerRESTclient.h"
#import "messengerViewController.h"
#import "Reachability.h"

@class messengerRESTclient;
@class messengerViewController;
@class Reachability;

@interface newPostViewController : UIViewController<UITextViewDelegate>
{    
    IBOutlet UIBarButtonItem *cancelButton;
    IBOutlet UITextView *messageVw;
    IBOutlet UIBarButtonItem *postButton;
    IBOutlet UIView *newPostView;
    IBOutlet UILabel *headingLabel;
    IBOutlet UIButton *locationUpdate;
    IBOutlet UINavigationBar *navBar;
    IBOutlet UIActivityIndicatorView *connProgress;
    IBOutlet UILabel *charactersLabel;

    int retVal;
    int txtLength;
    NSString *lblString;
    
    Reachability *internetReachability;
    
    messengerRESTclient *restObj;
    messengerViewController *mainViewObj;
}

-(IBAction)createNewPost;
-(IBAction)backToMain;
-(IBAction)enableLocationCheck;
-(void)getLocationCoords:(double)locationLatitude :(double)locationLongitude;
-(void)getUserId:(NSString *)userId;
-(void)getUserNumber:(NSString *)userNumber;
-(void)getGroupNumber:(NSString *)groupNumber;
-(void)getAccessToken:(NSString *)accessToken;
-(void)setUserGroup;

@end
