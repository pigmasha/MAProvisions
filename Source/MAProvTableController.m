//
//  MAProvTableController.m
//  MAProvisions
//
//  Created by M on 19.04.15.
//  Copyright (c) 2015 M. All rights reserved.
//

#import "MAProvTableController.h"
#import "MAController.h"

#define PROV_NAME_COL_W 170
#define PROV_DATE_COL_W 130
#define PROV_TYPE_COL_W 80

@interface MAProvTableController ()<NSTableViewDataSource, NSTableViewDelegate>
{
    NSRect _r;
    NSTableView* _table;
}
@end

//=================================================================================

@implementation MAProvTableController

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
- (void)loadView
{
    NSView* v = [[NSView alloc] initWithFrame: _r];
    self.view = v;
    [v release];
    
    NSScrollView* scr = nil;
    ADD_SCROLL(scr, v, _table, NSTableView, 0, 0.5, _r.size.width, _r.size.height - 1);
    scr.autoresizingMask = _table.autoresizingMask;
    ADD_COLUMN(@"n", @"Name", PROV_NAME_COL_W, _table, NSTableColumnUserResizingMask);
    ADD_COLUMN(@"t", @"Type", PROV_TYPE_COL_W, _table, NSTableColumnUserResizingMask);
    ADD_COLUMN(@"d", @"Expiration Date", PROV_DATE_COL_W, _table, NSTableColumnUserResizingMask);
    ADD_COLUMN(@"u", @"Application Identifier", _r.size.width + 1 - PROV_NAME_COL_W - PROV_DATE_COL_W - PROV_TYPE_COL_W, _table, NSTableColumnAutoresizingMask | NSTableColumnUserResizingMask);
    
    NSSortDescriptor* s = nil;
    for (NSTableColumn* c in _table.tableColumns )
    {
        NSSortDescriptor* s2 = [NSSortDescriptor sortDescriptorWithKey: c.identifier ascending: YES selector: 0];
        [c setSortDescriptorPrototype: s2];
        if (!s) s = s2;
    }
    [_table setSortDescriptors: [NSArray arrayWithObject: s]];
    
    NSMenu* menu = [[NSMenu alloc] init];
    NSMenuItem* item = [[NSMenuItem alloc] initWithTitle: @"Show in Finder" action: @selector(onFinder:) keyEquivalent: @""];
    [menu addItem: item];
    [item release];
    item = [[NSMenuItem alloc] initWithTitle: @"Delete" action: @selector(onDelete:) keyEquivalent: @""];
    [menu addItem: item];
    [item release];
    _table.menu = menu;
    [menu release];
    
    _table.delegate = self;
    _table.dataSource = self;
    
    if ([[MA_CONTROLLER provisions] count]) [_table selectRowIndexes: [NSIndexSet indexSetWithIndex: 0] byExtendingSelection: NO];
}

#pragma mark - Menu actions

//---------------------------------------------------------------------------------
- (void)onFinder: (id)sender
{
    if (_table.selectedRow < 0) return;
    NSDictionary* item = [[MA_CONTROLLER provisions] objectAtIndex: _table.selectedRow];
    [[NSWorkspace sharedWorkspace] selectFile: [item objectForKey: KEY_PATH] inFileViewerRootedAtPath: nil];
}

//---------------------------------------------------------------------------------
- (void)onDelete: (id)sender
{
    [self onKeyBackSp];
}

#pragma mark - Keyboard

//---------------------------------------------------------------------------------
- (BOOL)onKeyBackSp
{
    NSInteger row = _table.selectedRow;
    if (row < 0) return NO;
    
    NSAlert* alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle: @"OK"];
    [alert addButtonWithTitle: @"Cancel"];
    alert.messageText = [NSString stringWithFormat: @"Delete provision '%@'?", [[[MA_CONTROLLER provisions] objectAtIndex: row] objectForKey: KEY_NAME]];
    alert.informativeText = @"Deleted provisions cannot be restored.";
    alert.alertStyle = NSWarningAlertStyle;
    [alert beginSheetModalForWindow: [MA_CONTROLLER window] completionHandler: ^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn)
        {
            [MA_CONTROLLER deleteProv: [[MA_CONTROLLER provisions] objectAtIndex: row]];
            [_table reloadData];
            [self tableViewSelectionDidChange: nil];
        }
    }];
    [alert release];
    
    return YES;
}

#pragma mark - NSTableViewDataSource

//---------------------------------------------------------------------------------
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [[MA_CONTROLLER provisions] count];
}

//---------------------------------------------------------------------------------
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSDictionary* item = [[MA_CONTROLLER provisions] objectAtIndex: row];
    if ([tableColumn.identifier isEqualToString: @"n"]) return [item objectForKey: KEY_NAME];
    if ([tableColumn.identifier isEqualToString: @"d"]) return [item objectForKey: KEY_DATE_S];
    if ([tableColumn.identifier isEqualToString: @"t"])
    {
        int t = [[item objectForKey: KEY_TYPE] intValue];
        return (t == MAProvDev) ? @"Dev" : ((t == MAProvAdHoc) ? @"Ad Hoc" : @"App Store");
    }
    return [item objectForKey: KEY_APPID];
}

//---------------------------------------------------------------------------------
- (void)tableView:(NSTableView *)aTableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
    [MA_CONTROLLER provsSort: _table.sortDescriptors];
    [_table reloadData];
    [self tableViewSelectionDidChange: nil];
}

#pragma mark - NSTableViewDelegate

//---------------------------------------------------------------------------------
- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    return NO;
}

//---------------------------------------------------------------------------------
- (void)tableViewSelectionDidChange: (NSNotification *)aNotification
{
    NSInteger row = _table.selectedRow;
    if (row > -1) [MA_CONTROLLER setProv: [[MA_CONTROLLER provisions] objectAtIndex: row]];
}

@end
