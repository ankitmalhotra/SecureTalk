//
//  BaseRESTparser.h
//  socialNetwork-UTD
//
//  Created by Ankit Malhotra on 1/20/13.
//  Copyright (c) 2013 Ankit Malhotra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "messengerViewController.h"
#import "loginViewController.h"
#import "messengerRESTclient.h"
#import "findFriendViewController.h"

/*use this forward declaration to avoid class parse issues*/
@class loginViewController;
@class messengerViewController;  /*Holds inbound service endpoint*/
@class messengerRESTclient;
@class findFriendViewController;

@interface BaseRESTparser : NSObject<NSXMLParserDelegate>
{
    NSMutableArray	*_contentsOfElement;	// Contents of the current element
    messengerViewController *mainViewPtr;
    loginViewController *loginViewPtr;
    messengerRESTclient *callRESTclient;
    findFriendViewController *findFriendPtr;
    
    int stopDataSignal;
}

- (id) init;
- (void) parseDocument:(NSData *)data :(NSString *)endPoint ;
- (void) clearContentsOfElement ;
- (void)callMain:(NSMutableArray *)mainContents;
- (int)statusSignal;


@end
