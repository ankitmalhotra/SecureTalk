//
//  userChatViewController.m
//  socialNetwork-UTD
//
//  Created by Ankit Malhotra on 4/30/13.
//  Copyright (c) 2013 Ankit Malhotra. All rights reserved.
//

#import "userChatViewController.h"

static NSMutableArray *listOfMessages;
static NSString *senderNumber;
static NSString *_receiverName;
static int viewIsActive=0;

@interface userChatViewController ()
{
    NSString *senderClipped;
    NSString *receiverClipped;
}
@end


@implementation userChatViewController

- (messengerAppDelegate *)appDelegate
{
	return (messengerAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (XMPPStream *)xmppStream
{
	return [[self appDelegate] xmppStream];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    /*Object Instantiations*/
    restObj=[[messengerRESTclient alloc]init];
    turnSockets = [[NSMutableArray alloc] init];

    showAnimation=0;
    sendButton.enabled=FALSE;
    
    listOfMessages=[[NSMutableArray alloc]initWithObjects:nil, nil];
    chatTbView.backgroundColor=[UIColor scrollViewTexturedBackgroundColor];
    chatTbView.bubbleDataSource=self;
    chatTbView.snapInterval=120;
    chatTbView.showAvatars=NO;
    [chatTbView reloadData];
    
    UIColor *bckgImg = [[UIColor alloc]initWithPatternImage:[UIImage imageNamed:@"texture09.jpg"]];
    [chatTbView setBackgroundColor:bckgImg];
    
    messengerAppDelegate *del = [self appDelegate];
    del._messageDelegate=self;
}


-(void)viewDidAppear:(BOOL)animated
{
    viewIsActive=1;
    [chatTbView reloadData];
    NSLog(@"checking receiver name: %@",titleReceiver);
    [navBar.topItem setTitle:titleReceiver];
}

-(void)viewDidDisappear:(BOOL)animated
{
    viewIsActive=0;
}

-(int)reportViewActiveState
{
    return viewIsActive;
}

#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [listOfMessages count];
    NSLog(@"num chat msgs: %lu",(unsigned long)[listOfMessages count]);
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [listOfMessages objectAtIndex:row];
}



/*
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [listOfMessages count];
    NSLog(@"num chat msgs: %lu",(unsigned long)[listOfMessages count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ChatCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    int idx=[indexPath row];
    cell.textLabel.text=[listOfMessages objectAtIndex:idx];
    NSString *detailField;
    detailField=localUserId;
    [detailField stringByAppendingString:@" says.."];
    cell.detailTextLabel.text=detailField;
    cell.detailTextLabel.textColor=[UIColor whiteColor];
    
    return cell;
}
*/
 
 
/*
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}
*/

-(IBAction)sendMessage
{
    chatTbView.typingBubble=NSBubbleTypingTypeNobody;
    
    backButton.enabled=FALSE;
    sendButton.enabled=FALSE;
    if(showAnimation>0 && ![messageField.text isEqual:@""])
    {
        double yOffset=toolbar.frame.origin.y;
        [UIView animateWithDuration:0.2f animations:^{
            toolbar.frame=CGRectMake(toolbar.frame.origin.x, yOffset+216, toolbar.frame.size.width, toolbar.frame.size.height);
        }];
        showAnimation=0;
    }
    else if(showAnimation==0 && [messageField.text isEqual:@""])
    {
        backButton.enabled=TRUE;
    }
    else
    {
        backButton.enabled=TRUE;
        sendButton.enabled=TRUE;
    }
    
    
    if(![messageField.text isEqual:@""])
    {
        [messageField resignFirstResponder];
        _chatMessage=[messageField.text retain];
        NSBubbleData *sayBubble=[NSBubbleData dataWithText:_chatMessage date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
        [listOfMessages addObject:sayBubble];
        [chatTbView reloadData];
        
        /*Below logic routes chat messages via XMPP server*/
        NSXMLElement *body=[NSXMLElement elementWithName:@"body"];
        [body setStringValue:_chatMessage];
                
        NSXMLElement *message=[NSXMLElement elementWithName:@"message"];
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        fullReceiverName=[localReceiverName stringByAppendingString:@"@appserver.utdallas.edu"];

        [message addAttributeWithName:@"to" stringValue:fullReceiverName];
        [message addChild:body];
        
        [[self xmppStream]sendElement:message];
        
        /*Below logic places call to main server endpoint for routing chat messages via push notifications*/
        /*
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"typed: %@",_chatMessage);
            [restObj chatMessage:senderNumber :receiverNumber :_chatMessage :@"postMessageToUser"];
            NSLog(@"calling for status from server..");
            retVal=[restObj returnValue];
            NSLog(@"status received:%d",retVal);
            if(retVal==1)
            {
                backButton.enabled=TRUE;
                sendButton.enabled=TRUE;
                //[self dismissViewControllerAnimated:YES completion:nil];
            }
            else if (retVal==0)
            {
                backButton.enabled=TRUE;
                sendButton.enabled=TRUE;
                
                UIAlertView *connNullAlert=[[UIAlertView alloc]initWithTitle:@"Connection Error" message:@"Unable to contact server" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [connNullAlert show];
                [connNullAlert release];
            }
            else if(retVal==-1)
            {
                backButton.enabled=TRUE;
                sendButton.enabled=TRUE;
                
                UIAlertView *createdAlert=[[UIAlertView alloc]initWithTitle:@"Failed" message:[NSString stringWithFormat:@"New Message could not be posted"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [createdAlert show];
                [createdAlert release];
            }
        });
        */
        
        
        /*
        double delayInSeconds = 2.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    });
        */
        
        backButton.enabled=TRUE;
        sendButton.enabled=TRUE;
        messageField.text=@"";
        fullReceiverName=localReceiverName;
    }
}

/*Below logic receives message data from push notification to display on tableview*/
/*
-(void)showNewMessage:(NSString *)chatMessage :(NSString *)senderName
{
    NSLog(@"notification from: %@",senderName);
    NSLog(@"notification is: %@",chatMessage);
    NSBubbleData *sayBubble=[NSBubbleData dataWithText:chatMessage date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse];
    [listOfMessages addObject:sayBubble];
    NSLog(@"count is: %d",[listOfMessages count]);
    NSLog(@"bubble payload is: %@",listOfMessages);

    [chatTbView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[listOfMessages count] inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    //[self viewDidAppear:YES];
    [chatTbView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[listOfMessages count]-1 inSection:0] atScrollPosition:UITableViewRowAnimationTop animated:YES];
}
*/


-(IBAction)touchInsideTextField
{
    if (showAnimation==0)
    {
        sendButton.enabled=TRUE;
        double yOffset=toolbar.frame.origin.y;
        [UIView animateWithDuration:0.5 animations:^{
            toolbar.frame=CGRectMake(toolbar.frame.origin.x, yOffset-216, toolbar.frame.size.width, toolbar.frame.size.height);
        }];
        showAnimation++;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(![textField.text isEqual:@""])
    {
        sendButton.enabled=TRUE;
    }
}

-(IBAction)backToFriendsView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)getUserId:(NSString *)userId
{
    localUserId =[userId retain];
    localUserId=[localUserId stringByAppendingString:@"@appserver.utdallas.edu"];
    NSLog(@"sender's name at chat window: %@",localUserId);
}

-(void)getUserNumber:(NSString *)userNum
{
    senderNumber=[userNum retain];
    NSLog(@"sender's number at chat window: %@",senderNumber);
}

-(void)getReceiverName: (NSString *)receiverName
{
    localReceiverName=[receiverName retain];    
    titleReceiver=localReceiverName;
}

/*
-(void)getReceiverNumber:(NSString *)receiverNum
{
    receiverNumber=[receiverNum retain];
    NSLog(@"receiver number to be used: %@",receiverNumber);
}
*/

-(IBAction)backgroundTouched:(id)sender
{
    [messageField resignFirstResponder];
}




#pragma mark -
#pragma mark Chat delegates

- (void)newMessageReceived:(NSDictionary *)messageContent
{
	NSString *msgInbound = [messageContent objectForKey:@"msg"];
	NSLog(@"reading inbound msg: %@",msgInbound);
    fullReceiverName=[localReceiverName stringByAppendingString:@"@appserver.utdallas.edu"];
    NSLog(@"receiver assigned: %@",fullReceiverName);
    NSString *sender=[messageContent objectForKey:@"sender"];
    NSUInteger indexPos=0;
    for(int i=[sender length]-1;i>=0;i--)
    {
        if([sender characterAtIndex:i]=='@')
        {
            indexPos=i;
            break;
        }
    }
    if(indexPos>0)
    {
        senderClipped=[sender substringToIndex:indexPos];
        receiverClipped=[fullReceiverName substringToIndex:indexPos];
    }
    else
    {
        senderClipped=@"";
        receiverClipped=@"";
    }

    NSLog(@"received from %@",senderClipped);
    
    if([senderClipped isEqualToString:receiverClipped])
    {
        NSBubbleData *sayBubble=[NSBubbleData dataWithText:msgInbound date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse];
        [listOfMessages addObject:sayBubble];
        [chatTbView reloadData];
    }
    else
    {
        NSLog(@"%@ and %@ not in mutual communication",senderClipped,receiverClipped);
    }
    fullReceiverName=localReceiverName;
}




-(BOOL)shouldAutorotate
{
    return NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
	
	[messageField dealloc];
	[_receiverName dealloc];
	[chatTbView dealloc];
    [super dealloc];
}

@end
