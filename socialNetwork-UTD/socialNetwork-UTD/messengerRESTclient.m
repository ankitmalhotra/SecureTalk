//
//  messengerRESTclient.m
//  socialNetwork-UTD
//
//  Created by Ankit Malhotra on 1/20/13.
//  Copyright (c) 2013 Ankit Malhotra. All rights reserved.
//

#import "messengerRESTclient.h"
#import "groupsTableViewViewController.h"

static int valueToReturn=0;

@interface messengerRESTclient()
{
    int endpointSignal;
    groupsTableViewViewController *groupsTbVwObj;
}

/*Local method that stores the Server's Base URL. Returns server URL as String*/
-(NSString *)getServerURL;

@end



@implementation messengerRESTclient

/*Get Server's URL stored on stack locally. Returns server URL as String*/
-(NSString *)getServerURL
{
    NSString *baseURL=@"https://appserver.utdallas.edu:443/REST";
    return baseURL;
}



/*POST request calls for all endpoints below*/

-(void)showMyGroups:(NSString *)userNumber :(double)locationLat :(double)locationLong :(NSString *)accessToken :(NSString *)endPointURL
{
    serviceEndPoint=endPointURL;
    
    /*Call to fetch server URL*/
    NSString *urlString=[self getServerURL];
    
    NSURL *url=[[messengerAppDelegate sharedAppDelegate]smartURLForString:[NSString stringWithFormat:@"%@/v1/%@",urlString,endPointURL]];
    
    NSLog(@"Sending Request to URL %@", url);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    NSString *contentType=[NSString stringWithFormat:@"application/XML"];
    [request addValue:contentType forHTTPHeaderField:@"Content-type"];
    
    /*Build the XML structure to send*/
    if ([endPointURL isEqualToString:@"listMemberGroups"])
    {
        NSLog(@"user number received is: %@",userNumber);
        NSLog(@"access token received is: %@",accessToken);
        NSMutableData *postData=[NSMutableData data];
        [postData appendData:[[NSString stringWithFormat:@"<user xmlns=\"http://appserver.utdallas.edu/schema\">"]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<UserNumber>%@</UserNumber>",userNumber]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<UserLocationLat>%f</UserLocationLat>",locationLat]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<UserLocationLong>%f</UserLocationLong>",locationLong]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<AccessToken>%@</AccessToken>",accessToken]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"</user>"]dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:postData];
    }
    
    /*Asynchronous call to server initiated. Delegates will be called in order now*/
    [NSURLConnection connectionWithRequest:request delegate:self];
}

-(void)showAllGroups:(NSString *)userNumber :(double)locationLat :(double)locationLong :(NSString *)accessToken :(NSString *)endPointURL
{
    serviceEndPoint=endPointURL;
    
    /*Call to fetch server URL*/
    NSString *urlString=[self getServerURL];
    
    NSURL *url=[[messengerAppDelegate sharedAppDelegate]smartURLForString:[NSString stringWithFormat:@"%@/v1/%@",urlString,endPointURL]];
    
    NSLog(@"Sending Request to URL %@", url);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    NSString *contentType=[NSString stringWithFormat:@"application/XML"];
    [request addValue:contentType forHTTPHeaderField:@"Content-type"];
    
    /*Build the XML structure to send*/
    if([endPointURL isEqualToString:@"showGroups"])
    {
        NSMutableData *postData=[NSMutableData data];
        [postData appendData:[[NSString stringWithFormat:@"<user xmlns=\"http://appserver.utdallas.edu/schema\">"]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<UserNumber>%@</UserNumber>",userNumber]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<UserLocationLat>%f</UserLocationLat>",locationLat]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<UserLocationLong>%f</UserLocationLong>",locationLong]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<AccessToken>%@</AccessToken>",accessToken]dataUsingEncoding:NSUTF8StringEncoding]];

        [postData appendData:[[NSString stringWithFormat:@"</user>"]dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:postData];
        NSLog(@"passing xml: %@",postData);
    }
    
    /*Asynchronous call to server initiated. Delegates will be called in order now*/
    [NSURLConnection connectionWithRequest:request delegate:self];
}

-(void)joinGroup: (NSString *)userNumber :(NSString *)groupNumber :(double)locationLatitude :(double)locationLongitude :(NSString *)groupPassword :(NSString *)accessToken :(NSString *)endPointURL
{
    [self valueToReturn:0];

    serviceEndPoint=endPointURL;
    
    /*Call to fetch server URL*/
    NSString *urlString=[self getServerURL];
    
    NSURL *url=[[messengerAppDelegate sharedAppDelegate]smartURLForString:[NSString stringWithFormat:@"%@/v1/%@",urlString,endPointURL]];
    
    NSLog(@"Sending Request to URL %@", url);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    NSString *contentType=[NSString stringWithFormat:@"application/XML"];
    [request addValue:contentType forHTTPHeaderField:@"Content-type"];
    
    /*Build the XML structure to send*/
    if([endPointURL isEqualToString:@"joinGroup"])
    {
        NSMutableData *postData=[NSMutableData data];
        [postData appendData:[[NSString stringWithFormat:@"<JoinGroup xmlns=\"http://appserver.utdallas.edu/schema\">"]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<UserNumber>%@</UserNumber>",userNumber]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<GroupNumber>%@</GroupNumber>",groupNumber]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<UserLocationLat>%f</UserLocationLat>",locationLatitude]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<UserLocationLong>%f</UserLocationLong>",locationLongitude]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<GroupPassword>%@</GroupPassword>",groupPassword]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<AccessToken>%@</AccessToken>",accessToken]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"</JoinGroup>"]dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:postData];
        NSLog(@"passing xml: %@",postData);
    }
    
    /*Asynchronous call to server initiated. Delegates will be called in order now*/
    [NSURLConnection connectionWithRequest:request delegate:self];
}


-(void)unjoinGroups:(NSString *)userNumber :(NSString *)groupNumber :(NSString *)accessToken :(NSString *)endPointURL
{    
    serviceEndPoint=endPointURL;
    
    /*Call to fetch server URL*/
    NSString *urlString=[self getServerURL];
    
    NSURL *url=[[messengerAppDelegate sharedAppDelegate]smartURLForString:[NSString stringWithFormat:@"%@/v1/%@",urlString,endPointURL]];
    
    NSLog(@"Sending Request to URL %@", url);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    NSString *contentType=[NSString stringWithFormat:@"application/XML"];
    [request addValue:contentType forHTTPHeaderField:@"Content-type"];
    
    /*Build the XML structure to send*/
    if([endPointURL isEqualToString:@"leaveGroup"])
    {
        NSMutableData *postData=[NSMutableData data];
        [postData appendData:[[NSString stringWithFormat:@"<JoinGroup xmlns=\"http://appserver.utdallas.edu/schema\">"]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<UserNumber>%@</UserNumber>",userNumber]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<GroupNumber>%@</GroupNumber>",groupNumber]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<AccessToken>%@</AccessToken>",accessToken]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"</JoinGroup>"]dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:postData];
        NSLog(@"passing xml: %@",postData);
    }
    
    /*Asynchronous call to server initiated. Delegates will be called in order now*/
    [NSURLConnection connectionWithRequest:request delegate:self];
}

-(void)chatMessage:(NSString *)senderNumber :(NSString *)receiverNumber :(NSString *)chatMessageData :(NSString *)endPointURL
{
    serviceEndPoint=endPointURL;
    
    /*Call to fetch server URL*/
    NSString *urlString=[self getServerURL];
    
    NSURL *url=[[messengerAppDelegate sharedAppDelegate]smartURLForString:[NSString stringWithFormat:@"%@/v1/%@",urlString,endPointURL]];
    
    NSLog(@"Sending Request to URL %@", url);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    NSString *contentType=[NSString stringWithFormat:@"application/XML"];
    [request addValue:contentType forHTTPHeaderField:@"Content-type"];
    
    /*Build the XML structure to send*/
    if([endPointURL isEqualToString:@"postMessageToUser"])
    {
        NSMutableData *postData=[NSMutableData data];
        [postData appendData:[[NSString stringWithFormat:@"<MessageToUser xmlns=\"http://appserver.utdallas.edu/schema\">"]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<SenderNumber>%@</SenderNumber>",senderNumber]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<ReceiverNumber>%@</ReceiverNumber>",receiverNumber]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<MessageData>%@</MessageData>",chatMessageData]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"</MessageToUser>"]dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:postData];
        NSLog(@"passing xml: %@",postData);
    }
    
    /*Asynchronous call to server initiated. Delegates will be called in order now*/
    [NSURLConnection connectionWithRequest:request delegate:self];
}

-(void)showPostData:(NSString *)userNumber :(NSString *)groupNumber :(double)locationLat :(double)locationLong :(NSString *)accessToken :(NSString *)endPointURL
{
    serviceEndPoint=endPointURL;
    
    /*Call to fetch server URL*/
    NSString *urlString=[self getServerURL];
    
    NSURL *url=[[messengerAppDelegate sharedAppDelegate]smartURLForString:[NSString stringWithFormat:@"%@/v1/%@",urlString,endPointURL]];
    
    NSLog(@"Sending Request to URL %@", url);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    NSString *contentType=[NSString stringWithFormat:@"application/XML"];
    [request addValue:contentType forHTTPHeaderField:@"Content-type"];
    
    /*Build the XML structure to send*/
    if([endPointURL isEqualToString:@"getGroupMessages"])
    {
        NSMutableData *postData=[NSMutableData data];
        [postData appendData:[[NSString stringWithFormat:@"<Group xmlns=\"http://appserver.utdallas.edu/schema\">"]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<GroupUserNumber>%@</GroupUserNumber>",userNumber]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<GroupNumber>%@</GroupNumber>",groupNumber]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<GroupLocationLat>%f</GroupLocationLat>",locationLat]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<GroupLocationLong>%f</GroupLocationLong>",locationLong]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<AccessToken>%@</AccessToken>",accessToken]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"</Group>"]dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:postData];
        NSLog(@"passing xml: %@",postData);
    }
    
    /*Asynchronous call to server initiated. Delegates will be called in order now*/
    [NSURLConnection connectionWithRequest:request delegate:self];
}


-(void)createNewPost:(NSString *)userNumber :(NSString *)groupNumber :(NSString *) postMessage : (double)locationLatitude :(double)locationLongitude :(NSString *)accessToken :(NSString *)endPointURL
{
    serviceEndPoint=endPointURL;
    
    /*Call to fetch server URL*/
    NSString *urlString=[self getServerURL];
    
    NSURL *url=[[messengerAppDelegate sharedAppDelegate]smartURLForString:[NSString stringWithFormat:@"%@/v1/%@",urlString,endPointURL]];
    
    NSLog(@"Sending Request to URL %@", url);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    NSString *contentType=[NSString stringWithFormat:@"application/XML"];
    [request addValue:contentType forHTTPHeaderField:@"Content-type"];
    
    /*Build the XML structure to send*/
    if([endPointURL isEqualToString:@"postMessage"])
    {
        NSMutableData *postData=[NSMutableData data];
        [postData appendData:[[NSString stringWithFormat:@"<Message xmlns=\"http://appserver.utdallas.edu/schema\">"]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<UserNumber>%@</UserNumber>",userNumber]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<GroupNumber>%@</GroupNumber>",groupNumber]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<MessageData>%@</MessageData>",postMessage]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<UserLocationLat>%f</UserLocationLat>",locationLatitude]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<UserLocationLong>%f</UserLocationLong>",locationLongitude]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<AccessToken>%@</AccessToken>",accessToken]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"</Message>"]dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:postData];
    }
    
    /*Asynchronous call to server initiated. Delegates will be called in order now*/
    [NSURLConnection connectionWithRequest:request delegate:self];
}


/*This block places request to server to create a new group based on input received from groupsTableView*/
-(void)createGroup:(double)locationLatitude :(double)locationLongitude :(NSString *)groupName :(NSString *)userNumber :(NSString *)groupPwd :(NSString *)accessToken :(NSString *)endPointURL
{
    serviceEndPoint=endPointURL;
    
    /*Call to fetch server URL*/
    NSString *urlString=[self getServerURL];
    
    NSURL *url=[[messengerAppDelegate sharedAppDelegate]smartURLForString:[NSString stringWithFormat:@"%@/v1/%@",urlString,endPointURL]];
    
    NSLog(@"Sending Request to URL %@", url);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    NSString *contentType=[NSString stringWithFormat:@"application/XML"];
    [request addValue:contentType forHTTPHeaderField:@"Content-type"];
    
    /*Build the XML structure to send*/
    if([endPointURL isEqualToString:@"addGroup"])
    {
        NSLog(@"userchk: %@",[userNumber retain]);
        NSLog(@"acccheck: %@",[accessToken retain]);
        NSLog(@"pwdchk: %@",[groupPwd retain]);
        NSLog(@"locchk: %f,%f", locationLatitude,locationLongitude);
        NSLog(@"grpchk: %@",[groupName retain]);


        NSMutableData *postData=[NSMutableData data];
        [postData appendData:[[NSString stringWithFormat:@"<Group xmlns=\"http://appserver.utdallas.edu/schema\">"]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<GroupName>%@</GroupName>",groupName]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<GroupLocationLat>%f</GroupLocationLat>",locationLatitude]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<GroupLocationLong>%f</GroupLocationLong>",locationLongitude]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<GroupUserNumber>%@</GroupUserNumber>",userNumber]dataUsingEncoding:NSUTF8StringEncoding]];
        if(groupPwd!=NULL)
        {
            [postData appendData:[[NSString stringWithFormat:@"<GroupPassword>%@</GroupPassword>",groupPwd]dataUsingEncoding:NSUTF8StringEncoding]];
        }
        [postData appendData:[[NSString stringWithFormat:@"<AccessToken>%@</AccessToken>",accessToken]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"</Group>"]dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:postData];
    }
    
    /*Asynchronous call to server initiated. Delegates will be called in order now*/
    [NSURLConnection connectionWithRequest:request delegate:self];
}


/*This block places request to server to get the list of active users in a group*/
-(void)getFriendList:(NSString *)userNumber :(NSString *)groupNumber :(double)locationLatitude :(double)locationLongitude :(NSString *)accessToken :(NSString *)endPointURL
{
    serviceEndPoint=endPointURL;
    
    /*Call to fetch server URL*/
    NSString *urlString=[self getServerURL];
    
    NSURL *url=[[messengerAppDelegate sharedAppDelegate]smartURLForString:[NSString stringWithFormat:@"%@/v1/%@",urlString,endPointURL]];
    
    NSLog(@"Sending Request to URL %@", url);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    NSString *contentType=[NSString stringWithFormat:@"application/XML"];
    [request addValue:contentType forHTTPHeaderField:@"Content-type"];
    
    /*Build the XML structure to send*/
    if([endPointURL isEqualToString:@"getUsersInGroup"])
    {
        NSMutableData *postData=[NSMutableData data];
        [postData appendData:[[NSString stringWithFormat:@"<GroupInfo xmlns=\"http://appserver.utdallas.edu/schema\">"]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<UserNumber>%@</UserNumber>",userNumber]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<GroupNumber>%@</GroupNumber>",groupNumber]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<UserLocationLat>%f</UserLocationLat>",locationLongitude]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<UserLocationLong>%f</UserLocationLong>",locationLongitude]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<AccessToken>%@</AccessToken>",accessToken]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"</GroupInfo>"]dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:postData];
    }
    
    /*Asynchronous call to server initiated. Delegates will be called in order now*/
    [NSURLConnection connectionWithRequest:request delegate:self];
}



-(void)addNewUser:(NSString *)userID :(NSString *)userName :(NSString *)password :(NSString *)emailID :(NSString *)devToken :(NSString *)endPointURL
{
    NSLog(@"sendMessage in..");
    
    serviceEndPoint=endPointURL;
    
    /*Call to fetch server URL*/
    NSString *urlString=[self getServerURL];
    
    NSURL *url=[[messengerAppDelegate sharedAppDelegate]smartURLForString:[NSString stringWithFormat:@"%@/v1/%@",urlString,endPointURL]];
    
    NSLog(@"Sending Request to URL %@", url);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    NSString *contentType=[NSString stringWithFormat:@"application/XML"];
    [request addValue:contentType forHTTPHeaderField:@"Content-type"];
    
    /*Build the XML structure to send*/
    if([endPointURL isEqualToString:@"add"])
    {
        NSMutableData *postData=[NSMutableData data];
        [postData appendData:[[NSString stringWithFormat:@"<user xmlns=\"http://appserver.utdallas.edu/schema\">"]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<UserId>%@</UserId>",userID]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<UserName>%@</UserName>",userName]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<UserPassword>%@</UserPassword>",password]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<EmailAddress>%@</EmailAddress>",emailID]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<DeviceToken>%@</DeviceToken>",devToken]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"</user>"]dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:postData];
    }
    
    /*Asynchronous call to server initiated. Delegates will be called in order now*/
    [NSURLConnection connectionWithRequest:request delegate:self];
}


-(void)userLogin:(NSString *)userID :(NSString *)password :(NSString *)endPointURL
{
    NSLog(@"sendMessage in..");
    
    serviceEndPoint=endPointURL;
    
    /*Call to fetch server URL*/
    NSString *urlString=[self getServerURL];
    
    NSURL *url=[[messengerAppDelegate sharedAppDelegate]smartURLForString:[NSString stringWithFormat:@"%@/v1/%@",urlString,endPointURL]];
    
    NSLog(@"Sending Request to URL %@", url);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    NSString *contentType=[NSString stringWithFormat:@"application/XML"];
    [request addValue:contentType forHTTPHeaderField:@"Content-type"];
    
    if([endPointURL isEqualToString:@"login"])
    {
        NSLog(@"logging..");
        NSMutableData *postData=[NSMutableData data];
        [postData appendData:[[NSString stringWithFormat:@"<user xmlns=\"http://appserver.utdallas.edu/schema\">"]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<UserId>%@</UserId>",userID]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<UserPassword>%@</UserPassword>",password]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"</user>"]dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:postData];
    }
    
    /*Asynchronous call to server initiated. Delegates will be called in order now*/
    [NSURLConnection connectionWithRequest:request delegate:self];
}


-(void)changeUserPassword :(NSString *)userNumber :(NSString *)userPassword :(NSString *)newPassword :(NSString *)accessToken :(NSString *)endPointURL
{
    serviceEndPoint=endPointURL;
    
    /*Call to fetch server URL*/
    NSString *urlString=[self getServerURL];
    
    NSURL *url=[[messengerAppDelegate sharedAppDelegate]smartURLForString:[NSString stringWithFormat:@"%@/v1/%@",urlString,endPointURL]];
    
    NSLog(@"Sending Request to URL %@", url);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    NSString *contentType=[NSString stringWithFormat:@"application/XML"];
    [request addValue:contentType forHTTPHeaderField:@"Content-type"];
    
    if([endPointURL isEqualToString:@"changeUserInfo"])
    {
        NSLog(@"change of password init..");
        NSLog(@"user number %@", userNumber);
        NSLog(@"new password %@", [newPassword retain]);
        NSLog(@"access token %@", accessToken);
        NSLog(@"old password %@", [userPassword retain]);
       
        
        
        NSMutableData *postData=[NSMutableData data];
        [postData appendData:[[NSString stringWithFormat:@"<user xmlns=\"http://appserver.utdallas.edu/schema\">"]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<UserNumber>%@</UserNumber>",userNumber]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<UserPassword>%@</UserPassword>",[userPassword retain]]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<NewUserPassword>%@</NewUserPassword>",[newPassword retain]]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<AccessToken>%@</AccessToken>",accessToken]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"</user>"]dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:postData];
    }
    
    /*Asynchronous call to server initiated. Delegates will be called in order now*/
    [NSURLConnection connectionWithRequest:request delegate:self];
}


-(void)changeUserEmailAddress:(NSString *)userNumber :(NSString *)userPassword :(NSString *)emailAddress :(NSString *)accessToken :(NSString *)endPointURL
{
    serviceEndPoint=endPointURL;
    
    /*Call to fetch server URL*/
    NSString *urlString=[self getServerURL];
    
    NSURL *url=[[messengerAppDelegate sharedAppDelegate]smartURLForString:[NSString stringWithFormat:@"%@/v1/%@",urlString,endPointURL]];
    
    NSLog(@"Sending Request to URL %@", url);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    NSString *contentType=[NSString stringWithFormat:@"application/XML"];
    [request addValue:contentType forHTTPHeaderField:@"Content-type"];
    
    if([endPointURL isEqualToString:@"changeUserInfo"])
    {
        NSLog(@"change of email address init..");
        NSLog(@"user number %@", userNumber);
        NSLog(@"user password %@", [userPassword retain]);
        NSLog(@"new email address %@", [emailAddress retain]);
        NSLog(@"access token %@", accessToken);
        
        
        NSMutableData *postData=[NSMutableData data];
        [postData appendData:[[NSString stringWithFormat:@"<user xmlns=\"http://appserver.utdallas.edu/schema\">"]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<UserNumber>%@</UserNumber>",userNumber]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<UserPassword>%@</UserPassword>",[userPassword retain]]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<EmailAddress>%@</EmailAddress>",[emailAddress retain]]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<AccessToken>%@</AccessToken>",accessToken]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"</user>"]dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:postData];
    }
    
    /*Asynchronous call to server initiated. Delegates will be called in order now*/
    [NSURLConnection connectionWithRequest:request delegate:self];
}

-(void)wipeData:(NSString *)userNumber :(NSString *)userPassword :(NSString *)accessToken :(NSString *)endPointURL
{    
    serviceEndPoint=endPointURL;
    
    /*Call to fetch server URL*/
    NSString *urlString=[self getServerURL];
    
    NSURL *url=[[messengerAppDelegate sharedAppDelegate]smartURLForString:[NSString stringWithFormat:@"%@/v1/%@",urlString,endPointURL]];
    
    NSLog(@"Sending Request to URL %@", url);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    NSString *contentType=[NSString stringWithFormat:@"application/XML"];
    [request addValue:contentType forHTTPHeaderField:@"Content-type"];
    
    if([endPointURL isEqualToString:@"wipeData"])
    {
        NSLog(@"wiping..");
        NSLog(@"user number %@", userNumber);
        NSLog(@"user password %@", userPassword);
        NSLog(@"access token %@", accessToken);


        NSMutableData *postData=[NSMutableData data];
        [postData appendData:[[NSString stringWithFormat:@"<user xmlns=\"http://appserver.utdallas.edu/schema\">"]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<UserNumber>%@</UserNumber>",userNumber]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<UserPassword>%@</UserPassword>",userPassword]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<AccessToken>%@</AccessToken>",accessToken]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"</user>"]dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:postData];
    }
    
    /*Asynchronous call to server initiated. Delegates will be called in order now*/
    [NSURLConnection connectionWithRequest:request delegate:self];
}



-(void)userRoster :(NSString *)userNumber :(NSString *)userName :(NSString *)accessToken :(NSString *)endPointURL
{
    serviceEndPoint=endPointURL;
    
    /*Call to fetch server URL*/
    NSString *urlString=[self getServerURL];
    
    NSURL *url=[[messengerAppDelegate sharedAppDelegate]smartURLForString:[NSString stringWithFormat:@"%@/v1/%@",urlString,endPointURL]];
    
    NSLog(@"Sending Request to URL %@", url);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    NSString *contentType=[NSString stringWithFormat:@"application/XML"];
    [request addValue:contentType forHTTPHeaderField:@"Content-type"];
    
    if([endPointURL isEqualToString:@"getRosterSubscribers"])
    {
        NSLog(@"fetching roster..");
        NSLog(@"user number %@", userNumber);
        NSLog(@"user name %@", userName);
        NSLog(@"access token %@", accessToken);
        
        
        NSMutableData *postData=[NSMutableData data];
        [postData appendData:[[NSString stringWithFormat:@"<user xmlns=\"http://appserver.utdallas.edu/schema\">"]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<UserNumber>%@</UserNumber>",userNumber]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<UserName>%@</UserName>",userName]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<AccessToken>%@</AccessToken>",accessToken]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"</user>"]dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:postData];
    }
    
    /*Asynchronous call to server initiated. Delegates will be called in order now*/
    [NSURLConnection connectionWithRequest:request delegate:self];
}



-(void)recoverPassword :(NSString *)userId :(NSString *)emailAddress :(NSString *)endPointURL
{
    serviceEndPoint=endPointURL;
    
    /*Call to fetch server URL*/
    NSString *urlString=[self getServerURL];
    
    NSURL *url=[[messengerAppDelegate sharedAppDelegate]smartURLForString:[NSString stringWithFormat:@"%@/v1/%@",urlString,endPointURL]];
    
    NSLog(@"Sending Request to URL %@", url);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    NSString *contentType=[NSString stringWithFormat:@"application/XML"];
    [request addValue:contentType forHTTPHeaderField:@"Content-type"];
    
    NSLog(@"userid: %@",userId);
    NSLog(@"email address: %@",emailAddress);
    
    if([endPointURL isEqualToString:@"recoverPassword"])
    {
        NSMutableData *postData=[NSMutableData data];
        [postData appendData:[[NSString stringWithFormat:@"<user xmlns=\"http://appserver.utdallas.edu/schema\">"]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<UserId>%@</UserId>",userId]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"<EmailAddress>%@</EmailAddress>",emailAddress]dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"</user>"]dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:postData];
    }
    
    /*Asynchronous call to server initiated. Delegates will be called in order now*/
    [NSURLConnection connectionWithRequest:request delegate:self];
}




-(void)getUserID:(NSString *)userNumber :(NSString *)endPointURL
{    
    serviceEndPoint=endPointURL;
    
    /*Call to fetch server URL*/
    NSString *urlString=[self getServerURL];
    
    NSURL *url=[[messengerAppDelegate sharedAppDelegate]smartURLForString:[NSString stringWithFormat:@"%@/v1/%@/%@",urlString,endPointURL,userNumber]];
    
    NSLog(@"Sending Request to URL %@", url);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    [request setHTTPMethod:@"GET"];
    
    /*Asynchronous call to server initiated. Delegates will be called in order now*/
    [NSURLConnection connectionWithRequest:request delegate:self];
}





-(void)valueToReturn:(int)value
{
    valueToReturn=value;
}

-(int)returnValue
{
    return valueToReturn;
}


/*All the asynchronous delegates below*/


/*Received at the start of the asynchronous response from the server.  This may get called multiple times in certain redirect scenerios.*/
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    startTime = clock();
    
	NSLog(@"Received Response");
	NSHTTPURLResponse *httpResponse=(NSHTTPURLResponse *) response;;
    
    NSLog(@"response is: %@",response);
    
	if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
		int status = [httpResponse statusCode];
		
		if (!((status >= 200) && (status < 300)))
        {
			NSLog(@"Connection failed with status %d", status);
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            /*Conncetion error, return error signal 0*/
            [self valueToReturn:0];
        }
        else
        {
			/*make the working space for the REST data buffer.This could also be a file if you want to reduce the RAM footprint*/
            NSLog(@"Init RAM footprint..");
			[wipData release];
			wipData = [[NSMutableData alloc] initWithCapacity:1024];
        }
    }
    else
    {
        NSLog(@"Invalid response type: %@",httpResponse);
        /*Conncetion error, return error signal 2*/
        [self valueToReturn:0];
    }
}

/*A delegate method called by the NSURLConnection when something happens with the
 connection security-wise.  We defer all of the logic for how to handle this to
 the ChallengeHandler module (and it's very custom subclasses).
*/
- (BOOL)connection:(NSURLConnection *)conn canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    NSLog(@"handling challenge..");
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}


/*A delegate method called by the NSURLConnection when you accept a specific
authentication challenge by returning YES from connection:canAuthenticateAgainstProtectionSpace:.
Again, most of the logic has been shuffled off to the ChallengeHandler module; the only
policy decision we make here is that, if the challenge handle doesn't get it right in 5 tries,
we bail out.
*/
- (void)connection:(NSURLConnection *)conn didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSLog(@"didReceiveAuthenticationChallenge %@ %zd", [[challenge protectionSpace] authenticationMethod], (ssize_t) [challenge previousFailureCount]);
    
    NSArray *trustedHosts=[NSArray arrayWithObject:@"appserver.utdallas.edu"];
    BOOL isAuthMethodServerTrust=[challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
    if(isAuthMethodServerTrust)
    {
        if([trustedHosts containsObject:challenge.protectionSpace.host])
        {
            NSURLCredential *urlCredential=[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            [challenge.sender useCredential:urlCredential forAuthenticationChallenge:challenge];
            
            //Verify certificate info
            SecTrustRef trustRef=[[challenge protectionSpace]serverTrust];
            CFIndex indexCount=SecTrustGetCertificateCount(trustRef);
            
            for (CFIndex i=0; i<indexCount; i++)
            {
                SecCertificateRef certRef = SecTrustGetCertificateAtIndex(trustRef, i);
                CFStringRef certSummary = SecCertificateCopySubjectSummary(certRef);
                NSLog(@"certificate summary: %@",certSummary);
                CFDataRef certData = SecCertificateCopyData(certRef);
                CFRelease(certData);
            }
        }
    }
    
    //[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
}


-(void)challengeHandlerDidFinish:(ChallengeHandler *)handler
{
    NSLog(@"challenge surpassed successfully");
}

/*Can be called multiple times with chunks of the transfer*/
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [wipData appendData:data];
}

/*Called once at the end of the request*/
- (void)connectionDidFinishLoading:(NSURLConnection *)conn
{
	/*Do a little debug dump*/
    accessPtr = [[BaseRESTparser alloc]init];
	NSString *xml = [[NSString alloc] initWithData:wipData encoding:NSUTF8StringEncoding];
	NSLog(@"xml = %@", xml);
	[xml release];
	
    //NSLog(@"wip data is for %@: %@",serviceEndPoint,wipData);
    
    /*Parse inbound XML response to BaseRESTparser*/
	[accessPtr parseDocument:wipData:serviceEndPoint];
    
    /*Set conncetion status signal to 1*/
    statusSignal=1;
    
    /*Get elapsed duration to load connection*/
    stopTime = clock();
    elapsedConnDuration=((double)(stopTime-startTime))/1000;
    NSLog(@"elapsed: %f secs",elapsedConnDuration);
    
	/*turn off the network indicator*/
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

        
/*On the start of every element, clearn the intraelement text*/
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    accessPtr = [[BaseRESTparser alloc]init];
	[accessPtr clearContentsOfElement];
}

/*Called for each element*/
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    accessPtr = [[BaseRESTparser alloc]init];
    [accessPtr clearContentsOfElement];
}

/*This returns the value of conncetion status signal(0 or 1)*/
-(int)returnStatusSignal
{
    NSLog(@"Status signal is: %d",statusSignal);
    return statusSignal;
}

@end
