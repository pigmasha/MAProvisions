//
//  main.m
//  MAProvisions
//
//  Created by M on 17.04.15.
//  Copyright (c) 2015 M. All rights reserved.
//

#import "MAAppDelegate.h"
#import "MAApplication.h"

int main(int argc, const char * argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    id d = [[MAAppDelegate alloc] init];
    [MAApplication sharedApplication].delegate = d;
    [[MAApplication sharedApplication] run];
    
    [d release];
    [pool release];
    
    return 0;
}

