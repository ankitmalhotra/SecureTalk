//
//  messengerAppDelegate.m
//  socialNetwork-UTD
//
//  Created by Ankit Malhotra on 10/10/12.
//  Copyright (c) 2012 Ankit Malhotra. All rights reserved.
//

#import "messengerAppDelegate.h"
#import "messengerViewController.h"
#import "loginViewController.h"

#import "XMPPFramework.h"
#import "XMPPRoster.h"
#import "XMPPPresence.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "GCDAsyncSocket.h"

static NSString *const kHostName = @"appserver.utdallas.edu";
static XMPPJID *buddyToAdd;
static NSString *presenceFromUser;
static NSString *myUsername;
static NSMutableArray *rosterList;
static int newPresence=0;
static NSString *msg;
static NSString *from;
static NSData *devToken;

@interface messengerAppDelegate()
- (void)setupStream;
- (void)setupRoster;
- (void)teardownStream;
- (void)teardownRoster;
- (void)goOnline;
- (void)goOffline;
- (void)invokeAcceptance: (NSString *)budJID;
@end

@implementation messengerAppDelegate

@synthesize locationManager=_locationManager;
@synthesize _chatDelegate, _messageDelegate;
@synthesize xmppRosterStorage,xmppStream,xmppRoster;


// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    chatViewObj = [[userChatViewController alloc]init];
    loginViewObj = [[loginViewController alloc]init];
    friendViewObj = [[friendsViewController alloc]init];
    mainViewObj = [[messengerViewController alloc]init];

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.viewController = [[[messengerViewController alloc] initWithNibName:@"messengerViewController" bundle:nil] autorelease];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    /*Informing device about Push notification enablement*/
    [[UIApplication sharedApplication]registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert];
    [[UIApplication sharedApplication]registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge];
    [[UIApplication sharedApplication]registerForRemoteNotificationTypes:UIRemoteNotificationTypeSound];
    
    if (launchOptions != nil)
	{
		NSDictionary* dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:nil];
		if (dictionary != nil)
		{
			NSLog(@"Launched from push notification: %@", dictionary);
			[self addMessageFromRemoteNotification:dictionary updateUI:NO];
		}
	}
    
    [self setupRoster];

    return YES;
}

/*Add a badge to app icon*/
- (void)badgeApplicationIcon:(NSDictionary *)apsDictionary
{
    id badge = [apsDictionary valueForKey:@"badge"];
    
    if (badge != nil)
    {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badge];
    }
    else
    {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:nil];
    }
}


/*Device token to be used by the server. This token serves as an address of device for the server to begin pushing messages*/
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"My token is: %@", deviceToken);
    devToken=deviceToken;
    [devToken retain];
}

-(NSData *)getDeviceToken
{
    NSLog(@"returning device token fo signup: %@",devToken);
    return devToken;
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
	NSLog(@"Received notification: %@", userInfo);
	[self addMessageFromRemoteNotification:userInfo updateUI:YES];
    
    UIApplication *state=[application applicationState];
    if(state==UIApplicationStateActive)
    {
        //NSString* alertValue = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
        /*
            NSMutableArray* alertParts = [NSMutableArray arrayWithArray:[alertValue componentsSeparatedByString:@": "]];
            _chatMessage = [alertParts objectAtIndex:0];
            [alertParts removeObjectAtIndex:0];
            
            UIAlertView *newNotification=[[UIAlertView alloc]initWithTitle:@"New Post" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Show", nil];
            [newNotification show];
            [newNotification release];
         */
    }
}



- (void)addMessageFromRemoteNotification:(NSDictionary*)userInfo updateUI:(BOOL)updateUI
{    
	NSString* alertValue = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
    NSString* senderValue = [userInfo valueForKey:@"sender"];
    
    if(alertValue!=NULL)
    {
        NSMutableArray* alertParts = [NSMutableArray arrayWithArray:[alertValue componentsSeparatedByString:@": "]];
        _chatMessage = [alertParts objectAtIndex:0];
        [alertParts removeObjectAtIndex:0];
    }
    if(senderValue!=NULL)
    {
        NSMutableArray* senderParts = [NSMutableArray arrayWithArray:[senderValue componentsSeparatedByString:@": "]];
        _senderName = [senderParts objectAtIndex:0];
    }
    
	if (updateUI)
    {
		//[chatViewObj showNewMessage:_chatMessage :_senderName];
    }
    
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    //[self disconnect];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    //[self release];
    //[super dealloc];
    //NSLog(@"release called");

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    //[self init];
    //NSLog(@"awake called");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //[self connect];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskAll;
}


- (NSURL *)smartURLForString:(NSString *)str
{
    NSURL *     result;
    NSString *  trimmedStr;
    NSRange     schemeMarkerRange;
    NSString *  scheme;
    
    assert(str != nil);
    
    result = nil;
    
    trimmedStr = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ( (trimmedStr != nil) && (trimmedStr.length != 0) ) {
        schemeMarkerRange = [trimmedStr rangeOfString:@"://"];
        
        if (schemeMarkerRange.location == NSNotFound) {
            result = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", trimmedStr]];
        } else {
            scheme = [trimmedStr substringWithRange:NSMakeRange(0, schemeMarkerRange.location)];
            assert(scheme != nil);
            
            if ( ([scheme compare:@"http"  options:NSCaseInsensitiveSearch] == NSOrderedSame)
                || ([scheme compare:@"https" options:NSCaseInsensitiveSearch] == NSOrderedSame) ) {
                result = [NSURL URLWithString:trimmedStr];
            } else {
                // It looks like this is some unsupported URL scheme.
            }
        }
    }
    
    return result;
}

/*
- (void)didStartNetworking
{
    networkingCount += 1;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didStopNetworking
{
    assert(networkingCount > 0);
    networkingCount -= 1;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = (networkingCount != 0);
}
*/

+ (messengerAppDelegate *)sharedAppDelegate
{
    return (messengerAppDelegate *) [UIApplication sharedApplication].delegate;
}


/*XMPP methods*/
-(BOOL)connect
{
    [self setupStream];
    loginViewObj = [[loginViewController alloc]init];
    
    NSString *jabberID = [loginViewObj getXmppJID];
    NSString *myPassword = [loginViewObj getXmppPwd];
    if (![xmppStream isDisconnected]) {
        return YES;
    }
    if (jabberID == nil || myPassword == nil) {
        return NO;
    }
    NSString *fullJID=[[NSString alloc]initWithString:jabberID];
    fullJID=[fullJID stringByAppendingString:@"@"];
    fullJID=[fullJID stringByAppendingString:kHostName];
    [xmppStream setMyJID:[XMPPJID jidWithString:fullJID]];
    xmppPassword = myPassword;
    NSLog(@"testJID: %@",[xmppStream myJID]);
    NSError *error = nil;
    BOOL result = [xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    if (!result)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                   message:[NSString stringWithFormat:@"Can't connect to server %@", [error localizedDescription]] delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        return NO;
    }
    else
    {
        if(result==TRUE)
        {
            NSLog(@"result: %c",result);
            NSLog(@"Logged into XMPP server successfully !");
            /*Fetch the roster of users
            xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
            xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage
                                                     dispatchQueue:dispatch_get_main_queue()];
            [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
            
            [xmppRoster activate:xmppStream];
            [xmppRoster fetchRoster];
             */
            //[xmppRoster fetchRoster];
        }
    }
    return YES;
}

-(void)disconnect
{
    [self goOffline];
    [xmppStream disconnect];
}

-(void)setupStream
{
    xmppStream=[[XMPPStream alloc]init];
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppStream setHostName:kHostName];
    [xmppStream setHostPort:5222];
    allowSelfSignedCertificates = YES;
}

-(void)setupRoster
{
    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage
                                             dispatchQueue:dispatch_get_main_queue()];
    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

-(void)teardownStream
{
    [xmppStream removeDelegate:self];
    [xmppStream disconnect];
    xmppStream=nil;
}

-(void)teardownRoster
{
    [xmppRoster removeDelegate:self];
    xmppRoster=nil;
}

-(void)getRoster: (XMPPJID *)buddyName
{
    buddyToAdd=[buddyName retain];
    NSLog(@"adding buddy: %@",buddyToAdd);
    [xmppRoster activate:xmppStream];
    [xmppRoster addUser:buddyToAdd withNickname:buddyToAdd.description];
    [xmppRoster fetchRoster];
}

-(void)removeBuddy:(XMPPJID *)buddyName
{
    NSLog(@"confirmed. removing %@",buddyName);
    [xmppRoster removeUser:buddyName];
    [xmppRoster fetchRoster];
}

-(void)goOnline
{
    NSLog(@"about to go online");
    XMPPPresence *presence = [XMPPPresence presence];
    [xmppStream sendElement:presence];
}

-(void)goOffline
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream]sendElement:presence];
}




#pragma mark -
#pragma mark XMPP delegates

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
    NSLog(@"opening socket to XMPP server");
    DDLogVerbose(@"%@: %@",THIS_FILE,THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"connecting to XMPP server");
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	isOpen = YES;
	NSError *error = nil;
    NSLog(@"password with xmpp: %@",xmppPassword);
	
    if(![[self xmppStream] authenticateWithPassword:xmppPassword error:&error])
    {
        NSLog(@"authentication failiure");
    }
    else
    {
        NSLog(@"Invoking delegate to authenticate");
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	NSLog(@"authenticated!");
	[self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    NSLog(@"some problem authenticating");
}


- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    NSLog(@"iq has connections");

    NSXMLElement *rosterQuery=[iq elementForName:@"query" xmlns:@"jabber:iq:roster"];
    if(rosterQuery)
    {
        NSArray *rosterItems=[rosterQuery elementsForName:@"item"];
        if([rosterList count]>0)
        {
            [rosterList removeAllObjects];
        }
        for (int i=0; i<[rosterItems count]; i++)
        {
            NSString *jid=[[[rosterItems objectAtIndex:i]attributeForName:@"jid"]stringValue];
            [rosterList addObject:jid];
        }
        NSLog(@"my connections: %@",rosterList);
    }
	return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSLog(@"message received: %@",message);
	msg = [[message elementForName:@"body"] stringValue];
	from = [[message attributeForName:@"from"] stringValue];
    
    if([chatViewObj reportViewActiveState]==1)
    {
        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
        if(msg!=NULL && from!=NULL)
        {
            [m setObject:msg forKey:@"msg"];
            [m setObject:from forKey:@"sender"];
            
            [_messageDelegate newMessageReceived:m];
            [m release];
        }
    }
    else if ([chatViewObj reportViewActiveState]==0)
    {
        NSUInteger *indexPos=0;
        for(int i=[from length]-1;i>=0;i--)
        {
            if([from characterAtIndex:i] == '@')
            {
                indexPos=i;
                break;
            }
        }
        NSString *fromClipped=[from substringToIndex:indexPos];
        NSString *alertTitle=[[NSString alloc]initWithString:@"New message from "];
        alertTitle=[alertTitle stringByAppendingString:fromClipped];
        UIAlertView *newChatMessage=[[UIAlertView alloc]initWithTitle:alertTitle message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Show", nil];
        [newChatMessage show];
        [newChatMessage release];
    }
}


- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{	
	if (allowSelfSignedCertificates)
	{
		[settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
	}
}


- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
	NSString *presenceType = [presence type]; // online/offline
	myUsername = [[sender myJID] user];
    presenceFromUser = [[presence from] user];
    NSLog(@"User presence received from: %@",presenceFromUser);

    
	if (![presenceFromUser isEqualToString:myUsername])
    {
		if ([presenceType isEqualToString:@"available"])
        {
            NSLog(@"%@ is online",presenceFromUser);
            
            [friendViewObj setOnline:[NSString stringWithFormat:@"%@",presenceFromUser]];
			//[_chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@", presenceFromUser]];
		}
        else if ([presenceType isEqualToString:@"unavailable"])
        {
            NSLog(@"%@ is offline",presenceFromUser);
            
            [friendViewObj setOffline:[NSString stringWithFormat:@"%@",presenceFromUser]];
			//[_chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@", presenceFromUser]];
		}
        else if ([presenceType isEqualToString:@"subscribe"])
        {
            //if(newPresence==1)
            //{
                NSLog(@"subscription request pending from %@",presenceFromUser);
                //[_chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@", presenceFromUser]];
            //}
            //else
            //{
                NSString *alertMessage=[[NSString alloc]initWithString:@"New buddy request from "];
                alertMessage=[alertMessage stringByAppendingString:presenceFromUser];
                UIAlertView *buddyRequestAlert=[[UIAlertView alloc]initWithTitle:@"New Buddy Request!" message:alertMessage delegate:self cancelButtonTitle:@"Reject" otherButtonTitles:@"Accept", nil];
                NSLog(@"test1: %@",presenceFromUser);
                [self acceptRequest:0];
        
                [buddyRequestAlert show];
                [buddyRequestAlert release];
            
            NSString *buddyJID=[[NSString alloc]initWithString:presenceFromUser];
            buddyJID=[buddyJID stringByAppendingString:@"@"];
            buddyJID=[buddyJID stringByAppendingString:kHostName];
            /*
            XMPPPresence *presence = [XMPPPresence presenceWithType:@"available" to:[[XMPPJID jidWithString:buddyJID]bareJID]];
            [xmppStream sendElement:presence];
            
            [self addUser:[XMPPJID jidWithString:buddyJID] withNickname:nil];
            */

            //[xmppRoster acceptPresenceSubscriptionRequestFrom:[XMPPJID jidWithString:buddyJID] andAddToRoster:NO];
            
            //}
        }
        else if ([presenceType isEqualToString:@"subscribed"])
        {
            NSLog(@"subscribed!!!");
        }
        else if([presenceType isEqualToString:@"unsubscribed"])
        {
            NSLog(@"subscription request rejected");
        }
	}
}

-(NSString *)acceptRequest: (int)check
{
    if(check==0)
    {
        buddyPresenceToSend=[presenceFromUser retain];
        return nil;
    }
    else if(check==1)
    {
        return buddyPresenceToSend;
    }
    else
    {
        return nil;
    }
}


-(void)invokeAcceptance: (NSString *)budJID
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"subscribed" to:[[XMPPJID jidWithString:budJID] bareJID]];
	[xmppStream sendElement:presence];
    NSString *jidDesc=[[NSString alloc]initWithString:myUsername];
    jidDesc=[jidDesc stringByAppendingString:@"@"];
    jidDesc=[jidDesc stringByAppendingString:kHostName];
    
    NSLog(@"my jid right now: %@",jidDesc);
    NSLog(@"subscribing to %@",[[XMPPJID jidWithString:budJID]bareJID]);
    
    /*Reversing request*/
    [xmppStream setMyJID:[[XMPPJID jidWithString:budJID] bareJID]];
    XMPPPresence *myPresence = [XMPPPresence presenceWithType:@"subscribed" to:[[XMPPJID jidWithString:jidDesc]bareJID]];
	[xmppStream sendElement:myPresence];
    
    NSLog(@"my jid right reversed: %@",[xmppStream myJID]);
    NSLog(@"reverse subscribing to %@",[[XMPPJID jidWithString:jidDesc]bareJID]);
    
    /*Set back original JID*/
    [xmppStream setMyJID:[XMPPJID jidWithString:jidDesc]];
}


-(void)invokeRejection: (NSString *)budJID
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unsubscribed" to:[[XMPPJID jidWithString:budJID] bareJID]];
	[xmppStream sendElement:presence];
    NSString *jidDesc=[[NSString alloc]initWithString:myUsername];
    jidDesc=[jidDesc stringByAppendingString:@"@"];
    jidDesc=[jidDesc stringByAppendingString:kHostName];
    
    NSLog(@"my jid right now: %@",jidDesc);
    NSLog(@"unsubscribing from %@",[[XMPPJID jidWithString:budJID]bareJID]);
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if([alertView.title isEqualToString:@"New buddy request from "])
    {
        NSString *presenceOfBuddy;
        presenceOfBuddy=[self acceptRequest:1];
        
        if(buttonIndex==1)
        {
            NSString *buddyJID=[[NSString alloc]initWithString:presenceOfBuddy];
            buddyJID=[buddyJID stringByAppendingString:@"@"];
            buddyJID=[buddyJID stringByAppendingString:kHostName];
            [self invokeAcceptance:buddyJID];
            
            //[friendViewObj setOnline:[NSString stringWithFormat:@"%@", presenceOfBuddy]];
            //[_chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@", presenceOfBuddy]];
            newPresence=1;  //Request Accepted
        }
        else if (buttonIndex==0)
        {
            newPresence=0;   //Request Rejected
            
            NSString *buddyJID=[[NSString alloc]initWithString:presenceOfBuddy];
            buddyJID=[buddyJID stringByAppendingString:@"@"];
            buddyJID=[buddyJID stringByAppendingString:kHostName];
            [self invokeRejection:buddyJID];
            NSLog(@"buddy request rejected");
        }
    }
    else if([alertView.title hasPrefix:@"New message from "])
    {
        if(buttonIndex==1)
        {
            [mainViewObj invokeChatView];
        }
    }
}


#pragma mark XMPPRosterDelegate


-(void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender
{
    NSLog(@"user being added to roster: %@",buddyToAdd);
}

-(void)xmppRoster:(XMPPRoster *)sender didRecieveRosterItem:(DDXMLElement *)item
{
    NSLog(@"buddy request received from: %@",item);
}

-(void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    NSLog(@"working..");
    presenceFromUser = [[presence from] user];
    NSString *buddyJID=[[NSString alloc]initWithString:presenceFromUser];
    buddyJID=[buddyJID stringByAppendingString:@"@"];
    buddyJID=[buddyJID stringByAppendingString:kHostName];
    NSLog(@"accepting request from: %@",[XMPPJID jidWithString:buddyJID]);
    [xmppRoster acceptPresenceSubscriptionRequestFrom:[XMPPJID jidWithString:buddyJID] andAddToRoster:YES];
}

-(void)xmppRosterDidEndPopulating:(XMPPRoster *)sender
{
    NSLog(@"ended..");
}



#pragma mark Core Data


- (NSManagedObjectContext *)managedObjectContext_roster
{
	return [xmppRosterStorage mainThreadManagedObjectContext];
}


- (void)dealloc
{
    NSLog(@"dealloc called at app delegate");
	[xmppStream removeDelegate:self];
    [xmppRoster removeDelegate:self];
	[xmppStream disconnect];
	[xmppStream release];
    
	[xmppRoster release];
	[xmppPassword release];
    [loginViewObj release];
    [super dealloc];
}


@end
