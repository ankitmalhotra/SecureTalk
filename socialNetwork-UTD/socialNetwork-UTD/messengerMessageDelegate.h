//
//  messengerAppDelegate.h
//  socialNetwork-UTD
//
//  Created by Ankit Malhotra on 10/10/12.
//  Copyright (c) 2012 Ankit Malhotra. All rights reserved.
//


#import <UIKit/UIKit.h>


@protocol messengerMessageDelegate

- (void)newMessageReceived:(NSDictionary *)messageContent;

@end
