//
//  newPostViewController.m
//  socialNetwork-UTD
//
//  Created by Ankit Malhotra on 01/01/13.
//  Copyright (c) 2013 Ankit Malhotra. All rights reserved.
//

#import "newPostViewController.h"

static double _locationLat,_locationLong;
static NSString *localUserId;
static NSString *localGrpName;
static NSString *localUserNumber;
static NSString *localGrpNumber;
static NSString *localAccessToken;

/*Geo-location vars*/
static NSString *streetAddress;
static NSString *city;
static NSString *state;
static NSString *zip;

int locationCheck=0;

@implementation newPostViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    restObj=[[messengerRESTclient alloc]init];
    mainViewObj=[[messengerViewController alloc]init];
    lblString=[[NSString alloc]init];
    
    UIColor *bckgImg = [[UIColor alloc]initWithPatternImage:[UIImage imageNamed:@"texture08.jpg"]];
    [newPostView setBackgroundColor:bckgImg];
    
    [messageVw becomeFirstResponder];
    
    locationCheck=0;
    
    connProgress.hidden=TRUE;
    connProgress.transform=CGAffineTransformMakeScale(1.5, 1.5);
    
    /*Init loc-update to get the latest coordinates*/
    [mainViewObj initLocUpdate];
}

-(void)viewDidAppear:(BOOL)animated
{
    locationCheck=0;

    NSLog(@"testing for username: %@",localUserId);
    NSString *initText=[[NSString alloc]initWithString:@"@"];
    initText=[initText stringByAppendingString:localUserId];
    headingLabel.textColor=[UIColor grayColor];
    headingLabel.text=initText;
    
    [navBar.topItem setTitle:[mainViewObj signalGroupName]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(IBAction)backToMain
{
    /*Call clear buffer in main view*/
    [mainViewObj clearBufferList];
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma-mark TextView Delegates

- (void)textViewDidChange:(UITextView *)textView
{
    NSLog(@"len:%d",textView.text.length);
    txtLength=textView.text.length;
    lblString=[NSString stringWithFormat:@"%i",210-txtLength];
    if(txtLength>200)
    {
        charactersLabel.textColor=[UIColor redColor];
    }
    charactersLabel.text=lblString;
}

-(IBAction)createNewPost
{
    postButton.enabled=FALSE;
    messageVw.editable=FALSE;
    cancelButton.enabled=FALSE;
    connProgress.hidden=FALSE;
    [connProgress startAnimating];
    
    NSString *messageData;
    messageData=messageVw.text;
    messageData=[messageData stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [self setUserGroup];
    NSLog(@"received: %@",localGrpName);
    
    
    BOOL validLocationCheck= (![[streetAddress retain] isEqualToString:@""] && [streetAddress retain]!=NULL && ![[city retain] isEqualToString:@""] && [city retain]!=NULL && ![[state retain]isEqualToString:@""] && [state retain]!=NULL);
    
    if(![messageData isEqualToString: @""])
    {
        if(locationCheck==1)
        {
            if(validLocationCheck)
            {
                messageData=[messageData stringByAppendingString:@"\n\n"];
                messageData=[messageData stringByAppendingString:@"near "];
                messageData=[messageData stringByAppendingString:[streetAddress retain]];
                messageData=[messageData stringByAppendingString:@", "];
                messageData=[messageData stringByAppendingString:city];
                messageData=[messageData stringByAppendingString:@", "];
                messageData=[messageData stringByAppendingString:state];
            }
        }
        
        if(txtLength>210)
        {
            UIAlertView *limitExceedAlert=[[UIAlertView alloc]initWithTitle:@"Off Limits!" message:@"Your message is too long to be posted." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [limitExceedAlert show];
            [limitExceedAlert release];
            
            postButton.enabled=TRUE;
            cancelButton.enabled=TRUE;
            messageVw.editable=TRUE;
            messageVw.userInteractionEnabled=TRUE;
            connProgress.hidden=TRUE;
            [connProgress stopAnimating];
        }
        else
        {
            messageVw.editable=FALSE;
            messageVw.userInteractionEnabled=FALSE;
            
            /*Check for internet availability status*/
            internetReachability = [Reachability reachabilityForInternetConnection];
            NetworkStatus networkStatus = [internetReachability currentReachabilityStatus];
            
            if(networkStatus==NotReachable)
            {
                UIAlertView *networkOfflineAlert=[[UIAlertView alloc]initWithTitle:@"No Internet Connection !" message:@"The internet appears offline. Could not complete the request" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [networkOfflineAlert show];
                [networkOfflineAlert release];
                
                postButton.enabled=TRUE;
                cancelButton.enabled=TRUE;
                messageVw.editable=TRUE;
                messageVw.userInteractionEnabled=TRUE;
                connProgress.hidden=TRUE;
                [connProgress stopAnimating];
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    /*Place call to server with new post data & user,group,coord details*/
                    [restObj createNewPost:localUserNumber :localGrpNumber :messageData :_locationLat :_locationLong :localAccessToken :@"postMessage"];
                });
                
                double delayInSeconds = 3.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    NSLog(@"calling for status from server..");
                    retVal=[restObj returnValue];
                    NSLog(@"status received:%d",retVal);
                    if(retVal==1)
                    {
                        connProgress.hidden=TRUE;
                        [connProgress stopAnimating];
                        
                        [mainViewObj clearBufferList];
                        [mainViewObj clearAllPosts];
                        
                        /*Call to main to update table view for new post*/
                        [mainViewObj showPostData:localGrpName];
                        [mainViewObj setPostsRefreshSignal];
                        
                        UIAlertView *createdAlert=[[UIAlertView alloc]initWithTitle:@"Success" message:[NSString stringWithFormat:@"Message Successfully posted"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [createdAlert show];
                        [createdAlert release];
                        [self dismissViewControllerAnimated:YES completion:NULL];
                    }
                    else if (retVal==0)
                    {
                        double delayInSeconds = 4.0;
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            NSLog(@"calling for status from server..");
                            retVal=[restObj returnValue];
                            NSLog(@"status received:%d",retVal);
                            if(retVal==1)
                            {
                                connProgress.hidden=TRUE;
                                [connProgress stopAnimating];
                                
                                [mainViewObj clearBufferList];
                                [mainViewObj clearAllPosts];
                                
                                /*Call to main to update table view for new post*/
                                [mainViewObj showPostData:localGrpName];
                                [mainViewObj setPostsRefreshSignal];
                                
                                UIAlertView *createdAlert=[[UIAlertView alloc]initWithTitle:@"Success" message:[NSString stringWithFormat:@"Message Successfully posted"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                [createdAlert show];
                                [createdAlert release];
                                [self dismissViewControllerAnimated:YES completion:NULL];
                            }
                            else if (retVal==0)
                            {
                                double delayInSeconds = 4.0;
                                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                    NSLog(@"calling for status from server..");
                                    retVal=[restObj returnValue];
                                    NSLog(@"status received:%d",retVal);
                                    if(retVal==1)
                                    {
                                        connProgress.hidden=TRUE;
                                        [connProgress stopAnimating];
                                        
                                        [mainViewObj clearBufferList];
                                        [mainViewObj clearAllPosts];
                                        
                                        /*Call to main to update table view for new post*/
                                        [mainViewObj showPostData:localGrpName];
                                        [mainViewObj setPostsRefreshSignal];
                                        
                                        UIAlertView *createdAlert=[[UIAlertView alloc]initWithTitle:@"Success" message:[NSString stringWithFormat:@"Message Successfully posted"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                        [createdAlert show];
                                        [createdAlert release];
                                        [self dismissViewControllerAnimated:YES completion:NULL];
                                    }
                                    else if (retVal==0)
                                    {
                                        UIAlertView *connNullAlert=[[UIAlertView alloc]initWithTitle:@"Connection Error" message:@"Unable to contact server. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                        [connNullAlert show];
                                        [connNullAlert release];
                                        postButton.enabled=TRUE;
                                        cancelButton.enabled=TRUE;
                                        messageVw.editable=TRUE;
                                        messageVw.userInteractionEnabled=TRUE;
                                        connProgress.hidden=TRUE;
                                        [connProgress stopAnimating];
                                    }
                                    else if(retVal==-1)
                                    {
                                        UIAlertView *createdAlert=[[UIAlertView alloc]initWithTitle:@"Failed" message:[NSString stringWithFormat:@"New Message could not be posted. Please try again"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                        [createdAlert show];
                                        [createdAlert release];
                                        postButton.enabled=TRUE;
                                        cancelButton.enabled=TRUE;
                                        messageVw.editable=TRUE;
                                        messageVw.userInteractionEnabled=TRUE;
                                        connProgress.hidden=TRUE;
                                        [connProgress stopAnimating];
                                    }
                                    else if(retVal==43)
                                    {
                                        UIAlertView *duplicateMsgAlert=[[UIAlertView alloc]initWithTitle:@"Failed" message:[NSString stringWithFormat:@"You already posted this message a while ago ! Please check back."] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                        [duplicateMsgAlert show];
                                        [duplicateMsgAlert release];
                                        postButton.enabled=TRUE;
                                        cancelButton.enabled=TRUE;
                                        messageVw.editable=TRUE;
                                        messageVw.userInteractionEnabled=TRUE;
                                        connProgress.hidden=TRUE;
                                        [connProgress stopAnimating];
                                    }
                                });
                            }
                            else if(retVal==-1)
                            {
                                UIAlertView *createdAlert=[[UIAlertView alloc]initWithTitle:@"Failed" message:[NSString stringWithFormat:@"New Message could not be posted. Please try again"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                [createdAlert show];
                                [createdAlert release];
                                postButton.enabled=TRUE;
                                cancelButton.enabled=TRUE;
                                messageVw.editable=TRUE;
                                messageVw.userInteractionEnabled=TRUE;
                                connProgress.hidden=TRUE;
                                [connProgress stopAnimating];
                            }
                            else if(retVal==43)
                            {
                                UIAlertView *duplicateMsgAlert=[[UIAlertView alloc]initWithTitle:@"Failed" message:[NSString stringWithFormat:@"You already posted this message a while ago ! Please check back."] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                [duplicateMsgAlert show];
                                [duplicateMsgAlert release];
                                postButton.enabled=TRUE;
                                cancelButton.enabled=TRUE;
                                messageVw.editable=TRUE;
                                messageVw.userInteractionEnabled=TRUE;
                                connProgress.hidden=TRUE;
                                [connProgress stopAnimating];
                            }
                        });
                    }
                    else if(retVal==-1)
                    {
                        UIAlertView *createdAlert=[[UIAlertView alloc]initWithTitle:@"Failed" message:[NSString stringWithFormat:@"New Message could not be posted. Please try again"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [createdAlert show];
                        [createdAlert release];
                        postButton.enabled=TRUE;
                        cancelButton.enabled=TRUE;
                        messageVw.editable=TRUE;
                        messageVw.userInteractionEnabled=TRUE;
                        connProgress.hidden=TRUE;
                        [connProgress stopAnimating];
                    }
                    else if(retVal==43)
                    {
                        UIAlertView *duplicateMsgAlert=[[UIAlertView alloc]initWithTitle:@"Failed" message:[NSString stringWithFormat:@"You already posted this message a while ago ! Please check back."] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [duplicateMsgAlert show];
                        [duplicateMsgAlert release];
                        postButton.enabled=TRUE;
                        cancelButton.enabled=TRUE;
                        messageVw.editable=TRUE;
                        messageVw.userInteractionEnabled=TRUE;
                        connProgress.hidden=TRUE;
                        [connProgress stopAnimating];
                    }
                });
            }
        }
    }
    else
    {
        UIAlertView *nullPostAlert=[[UIAlertView alloc]initWithTitle:@"Nothing to post!" message:[NSString stringWithFormat:@"You must type in some message to post"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [nullPostAlert show];
        [nullPostAlert release];
        postButton.enabled=TRUE;
        cancelButton.enabled=TRUE;
        messageVw.editable=TRUE;
        messageVw.userInteractionEnabled=TRUE;
        connProgress.hidden=TRUE;
        [connProgress stopAnimating];
    }
}

-(IBAction)enableLocationCheck
{
    if(locationCheck==0)
    {
        locationCheck=1;
        UIImage *bckgImg = [UIImage imageNamed:@"loc-on.jpg"];
        [locationUpdate setImage:bckgImg forState:UIControlStateNormal];
        
        /*Call to fetch current coords*/
        [mainViewObj initLocUpdate];
        
        /*Check for internet availability status*/
        internetReachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [internetReachability currentReachabilityStatus];
        
        if(networkStatus==NotReachable)
        {
            UIAlertView *networkOfflineAlert=[[UIAlertView alloc]initWithTitle:@"No Internet Connection !" message:@"The internet appears offline. Could not complete the request" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [networkOfflineAlert show];
            [networkOfflineAlert release];
        }
        else
        {
            double delayInSeconds = 0.3;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                /*Reverse Geo-coding*/
                NSOperationQueue *geoLocQueue=[NSOperationQueue new];
                SEL methodSelector=@selector(getGeoCoords::);
                NSMethodSignature *methodSignature=[self methodSignatureForSelector:methodSelector];
                NSInvocation *methodInvocation=[NSInvocation invocationWithMethodSignature:methodSignature];
                [methodInvocation setTarget:self];
                [methodInvocation setSelector:methodSelector];
                
                [methodInvocation setArgument:&_locationLat atIndex:2];
                [methodInvocation setArgument:&_locationLong atIndex:3];
                [methodInvocation retainArguments];
                
                NSInvocationOperation *invocationOperation=[[NSInvocationOperation alloc]initWithInvocation:methodInvocation];
                [geoLocQueue addOperation:invocationOperation];
                
                [invocationOperation release];
                [geoLocQueue release];
            });
        }
    }
    else
    {
        locationCheck=0;
        UIImage *bckgImg = [UIImage imageNamed:@"loc-off.jpg"];
        [locationUpdate setImage:bckgImg forState:UIControlStateNormal];
    }
}

/*This method will be invoked by main view which will pass location coordinates*/
-(void)getLocationCoords:(double)locationLatitude :(double)locationLongitude
{
    _locationLat=locationLatitude;
    _locationLong=locationLongitude;
    NSLog(@"received coords: lat: %f ,long: %f",_locationLat,_locationLong);
}

/*This method extracts reverse geocoding information from a given coordinate position on earth*/
-(void)getGeoCoords:(double)latitude :(double)longitude
{
    CLGeocoder *geoCoder=[[CLGeocoder alloc]init];
    CLLocation *currentLocation=[[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
    
    [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placeMarks, NSError *err){
        if(err)
        {
            NSLog(@"Reverse geo-coding failed !");
            return;
        }
        if(placeMarks && placeMarks.count>0)
        {
            CLPlacemark *placeMarkers=placeMarks[0];
            NSDictionary *locationDictionary=placeMarkers.addressDictionary;
            
            streetAddress=[locationDictionary objectForKey:(NSString *)kABPersonAddressStreetKey];
            city=[locationDictionary objectForKey:(NSString *)kABPersonAddressCityKey];
            state=[locationDictionary objectForKey:(NSString *)kABPersonAddressStateKey];
            zip=[locationDictionary objectForKey:(NSString *)kABPersonAddressZIPKey];
            
            /*Detect for "En-Dash" unicode character & replace it 
              with a "-"
             */
            
            //streetAddress=@"2520–2524 Rutford Ave, 2510–2514, Richardson, Texas";

            for(int k=0;k<[streetAddress length]-1;k++)
            {
                const unichar escapeSeq=[streetAddress characterAtIndex:k];
                
                if(escapeSeq == L'\u2013')
                {
                    NSLog(@"Unicode En-Dash character detected. Replacing it..");
                    NSString *beforeSeq=[[streetAddress substringToIndex:k]retain];
                    NSString *afterSeq=[[streetAddress substringFromIndex:k+1]retain];
                    streetAddress=beforeSeq;
                    streetAddress=[[streetAddress stringByAppendingString:@"-"]retain];
                    streetAddress= [[streetAddress stringByAppendingString:afterSeq]retain];
                    
                    [beforeSeq release];
                    [afterSeq release];
                }
            }
            
            
            NSLog(@"logged in from:");
            NSLog(@"street: %@",streetAddress);
            NSLog(@"city: %@",city);
            NSLog(@"state: %@",state);
            NSLog(@"zip: %@",zip);
        }
    }];
}


/*This method will be invoked by main view which will pass currently signed userId*/
-(void)getUserId:(NSString *)userId
{
    localUserId=userId;
    NSLog(@"received userId for new post: %@",localUserId);
}

/*This method invoked locally will call main view to retrieve the group name selected*/
-(void)setUserGroup
{
    localGrpName=[mainViewObj signalGroupName];
}

-(void)getUserNumber:(NSString *)userNumber
{
    localUserNumber=userNumber;
    NSLog(@"received userNumber for new post: %@",localUserNumber);
}

-(void)getAccessToken:(NSString *)accessToken
{
    localAccessToken=accessToken;
    NSLog(@"received accessToken for new post: %@",accessToken);
}

-(void)getGroupNumber:(NSString *)groupNumber
{
    localGrpNumber=groupNumber;
    NSLog(@"received groupNumber for new post: %@",localGrpNumber);
}

#pragma mark TextView Delagates

- (BOOL)textViewShouldBeginEditing:(UITextField *)textField
{
    NSLog(@"returning yes..");
    postButton.enabled=TRUE;

    return YES;
}

- (void)textViewDidBeginEditing:(UITextField *)textField
{
    NSLog(@"begin editing..");
    postButton.enabled=TRUE;
}



-(BOOL)shouldAutorotate
{
    return NO;
}

@end
