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
    
    XMPPRosterCoreDataStorage *xmppRosterStorage;
    NSString *xmppPassword;
    NSString *buddyPresenceToSend;
    XMPPStream *xmppStream;
    XMPPRoster *xmppRoster;
    BOOL isOpen;
    BOOL allowSelfSignedCertificates;
    __weak NSObject <messengerChatDelegate> *_chatDelegate;
	__weak NSObject <messengerMessageDelegate> *_messageDelegate;
    
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) messengerViewController *viewController;

@property (nonatomic, retain, strong) XMPPStream *xmppStream;
@property (nonatomic, retain, strong) XMPPRoster *xmppRoster;
@property (nonatomic, retain, strong) XMPPRosterCoreDataStorage *xmppRosterStorage;


@property (nonatomic, assign) id  _chatDelegate;
@property (nonatomic, assign) id  _messageDelegate;


//-(void)didStartNetworking;
+ (messengerAppDelegate *)sharedAppDelegate;
- (void)addMessageFromRemoteNotification:(NSDictionary*)userInfo updateUI:(BOOL)updateUI;
- (NSURL *)smartURLForString:(NSString *)str;
- (NSData *)getDeviceToken;

/*XMPP methods*/
-(BOOL)connect;
-(BOOL)disconnect;
-(void)getRoster: (XMPPJID *)buddyName;
-(void)removeBuddy: (XMPPJID *)buddyName;
-(NSString *)fetchCurrentJID: (int)check;


@end
