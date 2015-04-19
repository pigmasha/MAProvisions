//
//  MAApplication.m
//  MAProvisions
//
//  Created by M on 18.04.15.
//  Copyright (c) 2015 M. All rights reserved.
//

#import "MAApplication.h"
#import "MAController.h"

@implementation MAApplication

- (void)sendEvent:(NSEvent *)event
{
    if (event.type == NSKeyDown)
    {
        NSString* k = [event.charactersIgnoringModifiers lowercaseString];
        
        unichar c = [k characterAtIndex: 0];
        switch (c)
        {
            case 13:
                if ([MA_CONTROLLER onKeyReturn]) return;
                break;
            case 27:
                if ([MA_CONTROLLER onKeyEsc]) return;
                break;
            case 127:
                if ([MA_CONTROLLER onKeyBackSp]) return;
                break;
            default: break;
        }
        
        if ((event.modifierFlags & NSDeviceIndependentModifierFlagsMask) == NSCommandKeyMask ||
            (event.modifierFlags & NSDeviceIndependentModifierFlagsMask) == (NSCommandKeyMask | NSAlphaShiftKeyMask))
        {
            if ([k isEqualToString:@"x"])
            {
                if ([self sendAction:@selector(cut:) to: nil from: self]) return;
            }
            else if ([k isEqualToString:@"c"])
            {
                if ([self sendAction:@selector(copy:) to: nil from: self]) return;
            }
            else if ([k isEqualToString:@"v"])
            {
                if ([self sendAction:@selector(paste:) to: nil from: self]) return;
            }
            else if ([k isEqualToString:@"z"])
            {
                if ([self sendAction:NSSelectorFromString(@"undo:") to: nil from: self]) return;
            }
            else if ([k isEqualToString:@"a"])
            {
                if ([self sendAction:@selector(selectAll:) to: nil from: self]) return;
            }
        }
        else if ((event.modifierFlags & NSDeviceIndependentModifierFlagsMask) == (NSCommandKeyMask | NSShiftKeyMask) ||
                 (event.modifierFlags & NSDeviceIndependentModifierFlagsMask) == (NSCommandKeyMask | NSShiftKeyMask | NSAlphaShiftKeyMask))
        {
            if ([k isEqualToString:@"z"])
            {
                if ([self sendAction:NSSelectorFromString(@"redo:") to: nil from: self]) return;
            }
        }
    }
    [super sendEvent:event];
}

@end
