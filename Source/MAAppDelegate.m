//
//  AppDelegate.m
//  MAProvisions
//
//  Created by M on 17.04.15.
//  Copyright (c) 2015 M. All rights reserved.
//

#import "MAAppDelegate.h"
#import "MAController.h"

@implementation MAAppDelegate

//---------------------------------------------------------------------------------
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [MAController initSharedInstance];
    [MA_CONTROLLER loadWindow];
}

//---------------------------------------------------------------------------------
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}


@end
