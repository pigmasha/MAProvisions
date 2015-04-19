//
//  MABgView.m
//  MAProvisions
//
//  Created by M on 19.04.15.
//  Copyright (c) 2015 M. All rights reserved.
//

#import "MABgView.h"

@interface MABgView ()
{
    NSColor* _bg;
}
@end

//=================================================================================

@implementation MABgView

//---------------------------------------------------------------------------------
- (id)initWithFrame: (NSRect)frameRect bgColor: (NSColor*)bgColor
{
    if (self = [super initWithFrame: frameRect])
    {
        _bg = [bgColor retain];
    }
    return self;
}

//---------------------------------------------------------------------------------
- (void)dealloc
{
    [_bg release];
    [super dealloc];
}

//---------------------------------------------------------------------------------
- (void)drawRect:(NSRect)rect
{
    [_bg set];
    [[NSBezierPath bezierPathWithRect: self.bounds] fill];
}

@end
