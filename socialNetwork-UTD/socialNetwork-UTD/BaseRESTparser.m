//
//  BaseRESTparser.m
//  socialNetwork-UTD
//
//  Created by Ankit Malhotra on 1/20/13.
//  Copyright (c) 2013 Ankit Malhotra. All rights reserved.
//

#import "BaseRESTparser.h"

static NSString *serviceEndPoint;


@implementation BaseRESTparser

    - (id) init
    {
        self = [super init];
        return self;
        stopDataSignal=0;
    }

   /*Clear the contents of the collected inter-element text*/
    - (void) clearContentsOfElement
    {
        [_contentsOfElement release];
    }

    /*Start the parsing process*/
    - (void) parseDocument:(NSData *)data :(NSString *)endPoint
    {
        serviceEndPoint=endPoint;
        mainViewPtr=[[messengerViewController alloc]init];
        //NSLog(@"data in: %@",data);
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
        [parser setDelegate:self];
        /*Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser*/
        [parser setShouldProcessNamespaces:YES];
        [parser setShouldReportNamespacePrefixes:YES];
        [parser setShouldResolveExternalEntities:NO];
        
        [parser parse];
        
        [parser release];
    }

    /*Handle the receipt of intraelement text*/
    - (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
    {
        //NSLog(@"string in: %@",string);
        _contentsOfElement=[NSMutableArray arrayWithObjects:string, nil];
        //NSLog(@"contents buid: %@",_contentsOfElement);
        [self callMain:_contentsOfElement];
    }

   /*Manage call to main view and send the parsed data*/
    -(void)callMain:(NSMutableArray *)mainContents
    {
        if([serviceEndPoint isEqualToString:@"add"])
        {
            /*Point to add response handler in mainView*/
            callRESTclient=[[messengerRESTclient alloc]init];
            NSLog(@"calling new user signup check with %@",mainContents);
            [callRESTclient valueToReturn:1];
        }
        else if([serviceEndPoint isEqualToString:@"login"])
        {
            callRESTclient=[[messengerRESTclient alloc]init];
                       
            NSLog(@"calling login check with %@",mainContents);
            if([[mainContents objectAtIndex:0] isEqual:@"true"])
            {
                NSLog(@"returning 1 from BaseREST");
                [callRESTclient valueToReturn:1];
            }
            else if([[mainContents objectAtIndex:0] isEqual:@"false"])
            {
                stopDataSignal=1;
                [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
                NSLog(@"returning -1 from BaseREST");
                [callRESTclient valueToReturn:-1];
            }
            else
            {
                if(stopDataSignal==0)
                {
                    /*Send the user number to main view controller class*/
                    [mainViewPtr storeUserDetails:mainContents];
                }
            }
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
            [callRESTclient release];
        }
        else if([serviceEndPoint isEqualToString:@"listMemberGroups"])
        {
            callRESTclient=[[messengerRESTclient alloc]init];
             //NSLog(@"calling groups list check with: %@",mainContents);
            /*
             if([mainContents containsObject:@"false"])
             {
                [mainContents removeObject:@"false"];
             }
             if([mainContents containsObject:@"true"])
             {
                [mainContents removeObject:@"true"];
             }
             */
            
            [mainViewPtr getGroupObjects:mainContents :1];
            [callRESTclient valueToReturn:1];
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        }
        else if([serviceEndPoint isEqualToString:@"getUsersInGroup"])
        {
            callRESTclient=[[messengerRESTclient alloc]init];
            //NSLog(@"calling friends list check with: %@",mainContents);
            if([mainContents containsObject:@"false"])
            {
                [mainContents removeObject:@"false"];
            }
            if([mainContents containsObject:@"true"])
            {
                [mainContents removeObject:@"true"];
            }
            if([mainContents containsObject:@"group does not exist"])
            {
                [mainContents removeObject:@"group does not exist"];
            }
            [mainViewPtr getFriendObjects:mainContents :1];
            
            [callRESTclient valueToReturn:1];
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        }
        else if ([serviceEndPoint isEqualToString:@"addGroup"])
        {
            NSLog(@"creating group");
            callRESTclient=[[messengerRESTclient alloc]init];
            
            /*Point to addGroup response handler in loginView*/
            NSLog(@"calling addGroup check with %@",mainContents);
            if([[mainContents objectAtIndex:0] isEqual:@"true"])
            {
                NSLog(@"returning 1 from BaseREST");
                [callRESTclient valueToReturn:1];
            }
            else
            {
                [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
                NSLog(@"returning -1 from BaseREST");
                [callRESTclient valueToReturn:-1];
            }
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
            [callRESTclient release];
        }
        else if ([serviceEndPoint isEqualToString:@"postMessage"])
        {
            NSLog(@"creating new post");
            callRESTclient=[[messengerRESTclient alloc]init];
            
            /*Point to addGroup response handler in loginView*/
            NSLog(@"calling post message check with %@",mainContents);
            if([[mainContents objectAtIndex:0] isEqual:@"true"])
            {
                NSLog(@"returning 1 from BaseREST");
                [callRESTclient valueToReturn:1];
            }
            else if ([[mainContents objectAtIndex:0] isEqual:@"43"])
            {
                NSLog(@"returning 43 from BaseREST");
                [callRESTclient valueToReturn:43];
            }
            else
            {
                NSLog(@"returning -1 from BaseREST");
                [callRESTclient valueToReturn:-1];
            }
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
            [callRESTclient release];
        }
        else if ([serviceEndPoint isEqualToString:@"getGroupMessages"])
        {
            NSLog(@"group message data is: %@",mainContents);
            [mainViewPtr collectedPostData:mainContents];
            NSLog(@"returning 1 from BaseREST");
            callRESTclient=[[messengerRESTclient alloc]init];
            [callRESTclient valueToReturn:1];
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        }
        else if ([serviceEndPoint isEqualToString:@"showGroups"])
        {
            callRESTclient=[[messengerRESTclient alloc]init];
            //NSLog(@"calling all groups list check with: %@",mainContents);
            /*
            if([mainContents containsObject:@"false"])
            {
                [mainContents removeObject:@"false"];
            }
            if([mainContents containsObject:@"true"])
            {
                [mainContents removeObject:@"true"];
            }
             */
            [mainViewPtr getGroupObjects:mainContents :1];
            [callRESTclient valueToReturn:1];
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        }
        else if ([serviceEndPoint isEqualToString:@"joinGroup"])
        {
            NSLog(@"joining group");
            callRESTclient=[[messengerRESTclient alloc]init];
            
            /*Point to joinGroup response handler in groupTableView*/
            NSLog(@"calling joinGroup check with %@",mainContents);
            if([[mainContents objectAtIndex:0] isEqual:@"true"])
            {
                NSLog(@"returning 1 from BaseREST");
                [callRESTclient valueToReturn:1];
            }
            else
            {
                NSLog(@"returning -1 from BaseREST");
                [callRESTclient valueToReturn:-1];
            }
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        }
        else if ([serviceEndPoint isEqualToString:@"leaveGroup"])
        {
            NSLog(@"leaving group");
            callRESTclient=[[messengerRESTclient alloc]init];
            
            NSLog(@"calling leaveGroup check with %@",mainContents);
            if([[mainContents objectAtIndex:0] isEqual:@"true"])
            {
                NSLog(@"returning 1 from BaseREST");
                [callRESTclient valueToReturn:1];
            }
            else
            {
                NSLog(@"returning -1 from BaseREST");
                [callRESTclient valueToReturn:-1];
            }
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        }
        else if ([serviceEndPoint isEqualToString:@"postMessageToUser"])
        {
            NSLog(@"initiating chat");
            callRESTclient=[[messengerRESTclient alloc]init];
            
            NSLog(@"calling chatView check with %@",mainContents);
            if([[mainContents objectAtIndex:0] isEqual:@"true"])
            {
                NSLog(@"returning 1 from BaseREST");
                [callRESTclient valueToReturn:1];
            }
            else
            {
                NSLog(@"returning -1 from BaseREST");
                [callRESTclient valueToReturn:-1];
            }
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
            [callRESTclient release];
        }
        else if ([serviceEndPoint isEqualToString:@"getUserByNum"])
        {
            NSLog(@"fetching userID through user-number");
            callRESTclient=[[messengerRESTclient alloc]init];
            
            /*Point to chatmessage response handler in chatView*/
            NSLog(@"calling chatView check with %@",mainContents);
            if(mainContents)
            {
                findFriendPtr=[[findFriendViewController alloc]init];
                [findFriendPtr setFriendUserId:mainContents];
                NSLog(@"returning 1 from BaseREST");
                [callRESTclient valueToReturn:1];
            }
            else
            {
                NSLog(@"returning -1 from BaseREST");
                [callRESTclient valueToReturn:-1];
            }
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
            [callRESTclient release];
        }
        else if ([serviceEndPoint isEqualToString:@"changeUserInfo"])
        {
            NSLog(@"changing user info");
            callRESTclient=[[messengerRESTclient alloc]init];
            
            NSLog(@"calling changeUserInfo check with %@",mainContents);
            if([[mainContents objectAtIndex:0] isEqual:@"true"])
            {
                NSLog(@"returning 1 from BaseREST");
                [callRESTclient valueToReturn:1];
            }
            else
            {
                NSLog(@"returning -1 from BaseREST");
                [callRESTclient valueToReturn:-1];
            }
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
            [callRESTclient release];
        }

        else if ([serviceEndPoint isEqualToString:@"wipeData"])
        {
            NSLog(@"wiping data");
            callRESTclient=[[messengerRESTclient alloc]init];
            
            NSLog(@"calling wipedata check with %@",mainContents);
            if([[mainContents objectAtIndex:0] isEqual:@"true"])
            {
                NSLog(@"returning 1 from BaseREST");
                [callRESTclient valueToReturn:1];
            }
            else
            {
                NSLog(@"returning -1 from BaseREST");
                [callRESTclient valueToReturn:-1];
            }
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
            [callRESTclient release];
        }
        else if ([serviceEndPoint isEqualToString:@"getRosterSubscribers"])
        {
            NSLog(@"sending roster subscribers: %@",mainContents);
            [mainViewPtr collectedRosterSubscribers:mainContents];
            NSLog(@"returning 1 from BaseREST");
            callRESTclient=[[messengerRESTclient alloc]init];
            [callRESTclient valueToReturn:1];
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        }
        else if ([serviceEndPoint isEqualToString:@"recoverPassword"])
        {
            callRESTclient=[[messengerRESTclient alloc]init];
            
            NSLog(@"calling recoverPassword check with %@",mainContents);
            if([[mainContents objectAtIndex:0] isEqual:@"true"])
            {
                NSLog(@"returning 1 from BaseREST");
                [callRESTclient valueToReturn:1];
            }
            else
            {
                NSLog(@"returning -1 from BaseREST");
                [callRESTclient valueToReturn:-1];
            }
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
            [callRESTclient release];
        }

    }


    -(int)statusSignal
    {
        return 1;
    }

    /*Trim leading and trailing spaces*/
    - (NSString *)trim:(NSString *)inStr
    {
        return [inStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    
    - (void) dealloc
    {
        [_contentsOfElement release];
        [super dealloc];
    }

@end
