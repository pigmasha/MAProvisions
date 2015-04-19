//
//  MAProvInfoController.m
//  MAProvisions
//
//  Created by M on 19.04.15.
//  Copyright (c) 2015 M. All rights reserved.
//

#import "MAProvInfoController.h"
#import "MABgView.h"
#import "MAController.h"

#define PROV_LABEL_W 120
#define PROV_DEV_W   350

@interface MAProvInfoController ()<NSTableViewDataSource, NSTableViewDelegate>
{
    NSRect _r;
    NSTextField* _name;
    NSTextField* _type;
    NSTextField* _dateC;
    NSTextField* _dateE;
    NSTextField* _prId;
    NSTextField* _appId;
    NSTableView* _table;
    NSMutableArray* _dev;
    NSTextField* _devTitle;
}
@end

//=================================================================================

@implementation MAProvInfoController

//---------------------------------------------------------------------------------
- (id)initWithFrame: (NSRect)frame
{
    if (self = [super initWithNibName: nil bundle: nil])
    {
        _r = frame;
    }
    return self;
}

//---------------------------------------------------------------------------------
- (void)dealloc
{
    [_dev release];
    [super dealloc];
}

//---------------------------------------------------------------------------------
- (void)loadView
{
    NSView* v = [[MABgView alloc] initWithFrame: _r bgColor: [NSColor whiteColor]];
    self.view = v;
    [v release];
    
    int y = _r.size.height;
    y -= 40;
    NSTextField* l;
    ADD_LABEL(l, v, 16, YES, NSLeftTextAlignment, SZ(Width) | SZ_M(MinY), 30, y, _r.size.width - 40 - PROV_DEV_W, 30);
    l.stringValue = @"Provision profile";
    
    ADD_LABEL(_devTitle, v, 16, YES, NSLeftTextAlignment, SZ_M(MinX) | SZ_M(MinY), _r.size.width - PROV_DEV_W, y, PROV_DEV_W, 30);
    
    y -= 24;
    ADD_LABEL(l, v, LABEL_FONT_SZ, YES, NSRightTextAlignment, SZ_M(MinY), 10, y, PROV_LABEL_W, 24);
    l.stringValue = @"Name:";
    ADD_LABEL(_name, v, LABEL_FONT_SZ, NO, NSLeftTextAlignment, SZ(Width) | SZ_M(MinY), 15 + PROV_LABEL_W, y, _r.size.width - PROV_LABEL_W - 15, 24);
    
    y -= 24;
    ADD_LABEL(l, v, LABEL_FONT_SZ, YES, NSRightTextAlignment, SZ_M(MinY), 10, y, PROV_LABEL_W, 24);
    l.stringValue = @"Type:";
    ADD_LABEL(_type, v, LABEL_FONT_SZ, NO, NSLeftTextAlignment, SZ(Width) | SZ_M(MinY), 15 + PROV_LABEL_W, y, _r.size.width - PROV_LABEL_W - 15, 24);
    
    y -= 24;
    ADD_LABEL(l, v, LABEL_FONT_SZ, YES, NSRightTextAlignment, SZ_M(MinY), 10, y, PROV_LABEL_W, 24);
    l.stringValue = @"Creation date:";
    ADD_LABEL(_dateC, v, LABEL_FONT_SZ, NO, NSLeftTextAlignment, SZ(Width) | SZ_M(MinY), 15 + PROV_LABEL_W, y, _r.size.width - PROV_LABEL_W - 15, 24);
    
    y -= 24;
    ADD_LABEL(l, v, LABEL_FONT_SZ, YES, NSRightTextAlignment, SZ_M(MinY), 10, y, PROV_LABEL_W, 24);
    l.stringValue = @"Expiration date:";
    ADD_LABEL(_dateE, v, LABEL_FONT_SZ, NO, NSLeftTextAlignment, SZ(Width) | SZ_M(MinY), 15 + PROV_LABEL_W, y, _r.size.width - PROV_LABEL_W - 15, 24);
    
    y -= 24;
    ADD_LABEL(l, v, LABEL_FONT_SZ, YES, NSRightTextAlignment, SZ_M(MinY), 10, y, PROV_LABEL_W, 24);
    l.stringValue = @"Profile identifier:";
    ADD_LABEL(_prId, v, LABEL_FONT_SZ, NO, NSLeftTextAlignment, SZ(Width) | SZ_M(MinY), 15 + PROV_LABEL_W, y, _r.size.width - PROV_LABEL_W - 15, 24);
    
    y -= 24;
    ADD_LABEL(l, v, LABEL_FONT_SZ, YES, NSRightTextAlignment, SZ_M(MinY), 10, y, PROV_LABEL_W, 24);
    l.stringValue = @"App identifier:";
    ADD_LABEL(_appId, v, LABEL_FONT_SZ, NO, NSLeftTextAlignment, SZ(Width) | SZ_M(MinY), 15 + PROV_LABEL_W, y, _r.size.width - PROV_LABEL_W - 15, 24);
    
    NSScrollView* scr = nil;
    ADD_SCROLL(scr, v, _table, NSTableView, _r.size.width - PROV_DEV_W - 10, 10, PROV_DEV_W, _r.size.height - 50);
    scr.autoresizingMask = SZ_M(MinX) | SZ(Height);
    scr.borderType = NSGrooveBorder;
    _table.headerView = nil;
    ADD_COLUMN(@"", @"", PROV_DEV_W, _table, NSTableColumnNoResizing);
    
    _table.delegate = self;
    _table.dataSource = self;
    
    NSMenu* menu = [[NSMenu alloc] init];
    NSMenuItem* item = [[NSMenuItem alloc] initWithTitle: @"Copy" action: @selector(onCopy:) keyEquivalent: @""];
    [menu addItem: item];
    [item release];
    _table.menu = menu;
    [menu release];
    
    _dev = [[NSMutableArray alloc] init];
    
    if ([[MA_CONTROLLER provisions] count]) [self setProv: [[MA_CONTROLLER provisions] firstObject]];
}

//---------------------------------------------------------------------------------
- (void)setProv: (NSDictionary*)prov
{
    _name.stringValue = [prov objectForKey: KEY_NAME];
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterMediumStyle;
    df.timeStyle = NSDateFormatterShortStyle;
    _dateC.stringValue = [df stringFromDate: [[prov objectForKey: KEY_PARAMS] objectForKey: @"CreationDate"]];
    _dateE.stringValue = [df stringFromDate: [prov objectForKey: KEY_DATE]];
    [df release];
    _prId.stringValue = [[prov objectForKey: KEY_PARAMS] objectForKey: @"UUID"];
    _appId.stringValue = [prov objectForKey: KEY_APPID];
    
    int t = [[prov objectForKey: KEY_TYPE] intValue];
    _type.stringValue = (t == MAProvDev) ? @"Dev" : ((t == MAProvAdHoc) ? @"Ad Hoc" : @"App Store");
    
    // devices
    [_dev removeAllObjects];
    for (NSString* d in [[prov objectForKey: KEY_PARAMS] objectForKey: @"ProvisionedDevices"])
    {
        NSString* name = [[MA_CONTROLLER devicesMap] objectForKey: d];
        [_dev addObject: [NSArray arrayWithObjects: (name) ? name : d, [NSNumber numberWithBool: name != nil], nil]];
    }
    [_dev sortUsingComparator: ^ NSComparisonResult(NSArray* a, NSArray* b) {
        BOOL fA = [[a lastObject] boolValue];
        BOOL fB = [[b lastObject] boolValue];
        
        if (fA && !fB) return NSOrderedAscending;
        if (!fA && fB) return NSOrderedDescending;
        
        return [[a firstObject] caseInsensitiveCompare: [b firstObject]];
    }];
    _devTitle.stringValue = ([_dev count] == 1) ? @"1 device" : [NSString stringWithFormat: @"%ld devices", [_dev count]];
    [_table reloadData];
}

//---------------------------------------------------------------------------------
- (void)onCopy: (id)sender
{
    NSInteger row = _table.selectedRow;
    if (row > -1 && row < [_dev count])
    {
        [[NSPasteboard generalPasteboard] clearContents];
        [[NSPasteboard generalPasteboard] writeObjects: [NSArray arrayWithObject: [[_dev objectAtIndex: row] firstObject]]];
    }
}

#pragma mark - NSTableViewDataSource

//---------------------------------------------------------------------------------
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [_dev count];
}

//---------------------------------------------------------------------------------
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return [[_dev objectAtIndex: row] firstObject];
}

#pragma mark - NSTableViewDelegate

//---------------------------------------------------------------------------------
- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    return NO;
}

@end
