//
//  messengerAppDelegate.h
//  socialNetwork-UTD
//
//  Created by Ankit Malhotra on 10/10/12.
//  Copyright (c) 2012 Ankit Malhotra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "messengerViewController.h"
#import "userChatViewController.h"
#import "messengerChatDelegate.h"
#import "messengerMessageDelegate.h"
#import "friendsViewController.h"

#import "XMPPFramework.h"
#import "XMPPRoster.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "GCDAsyncSocket.h"


@class messengerViewController,loginViewController,userChatViewController,friendsViewController;

@interface messengerAppDelegate : UIResponder <UIApplicationDelegate,XMPPRosterDelegate>
{
    NSInteger *networkingCount;
    
    userChatViewController *chatViewObj;
    loginViewController *loginViewObj;
    friendsViewController *friendViewObj;
    messengerViewController *mainViewObj;
    
    NSString *_senderName;
    NSString *_chatMessage;
    
    /*XMPP related objs*/
    XMPPStream *xmppStream;
    XMPPRoster *xmppRoster;
    XMPPRosterCoreDataStorage *xmppRosterStorage;
    NSString *xmppPassword;
    NSString *buddyPresenceToSend;
    BOOL isOpen;
    BOOL allowSelfSignedCertificates;
    __weak NSObject <messengerChatDelegate> *_chatDelegate;
	__weak NSObject <messengerMessageDelegate> *_messageDelegate;
    
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) messengerViewController *viewController;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (nonatomic, readonly) XMPPStream *xmppStream;
@property (nonatomic, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;


@property (nonatomic, assign) id  _chatDelegate;
@property (nonatomic, assign) id  _messageDelegate;


//-(void)didStartNetworking;
+ (messengerAppDelegate *)sharedAppDelegate;
- (void)addMessageFromRemoteNotification:(NSDictionary*)userInfo updateUI:(BOOL)updateUI;
- (NSURL *)smartURLForString:(NSString *)str;
- (NSData *)getDeviceToken;

/*XMPP methods*/
-(BOOL)connect;
-(void)disconnect;
-(void)getRoster: (XMPPJID *)buddyName;
-(void)removeBuddy: (XMPPJID *)buddyName;
-(NSString *)acceptRequest: (int)check;


@end
