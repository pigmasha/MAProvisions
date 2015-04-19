//
//  MADevicesController.m
//  MAProvisions
//
//  Created by M on 18.04.15.
//  Copyright (c) 2015 M. All rights reserved.
//

#import "MADevicesController.h"
#import "MAController.h"

#define NAME_COL_W 150

@interface MADevicesController ()<NSTableViewDataSource, NSTableViewDelegate>
{
    NSRect _r;
    NSTableView* _table;
    NSInteger _editRow;
    
    NSWindow* _addW;
    NSTextField* _addName;
    NSTextField* _addUdid;
    NSTextField* _addSt;
}
@end

//=================================================================================

@implementation MADevicesController

//---------------------------------------------------------------------------------
- (id)initWithFrame: (NSRect)frame
{
    if (self = [super initWithNibName: nil bundle: nil])
    {
        _r = frame;
        _editRow = -1;
    }
    return self;
}

//---------------------------------------------------------------------------------
- (void)loadView
{
    NSView* v = [[NSView alloc] initWithFrame: _r];
    self.view = v;
    [v release];
    
    NSTextField* l;
    ADD_LABEL(l, v, LABEL_FONT_SZ, NO, NSLeftTextAlignment, SZ(Width) | SZ_M(MinY), 10, _r.size.height - 23, _r.size.width - 20, 24);
    l.stringValue = @"Add a name for device and you will see its name in provision devices list";
    
    NSScrollView* scr = nil;
    ADD_SCROLL(scr, v, _table, NSTableView, 0, 44, _r.size.width, _r.size.height - 44 - 24);
    scr.autoresizingMask = _table.autoresizingMask;
    ADD_COLUMN(@"n", @"Name", NAME_COL_W, _table, NSTableColumnUserResizingMask);
    ADD_COLUMN(@"d", @"UDID", _r.size.width + 1 - NAME_COL_W, _table, NSTableColumnAutoresizingMask | NSTableColumnUserResizingMask);
    
    NSSortDescriptor* s = nil;
    for (NSTableColumn* c in _table.tableColumns )
    {
        NSSortDescriptor* s2 = [NSSortDescriptor sortDescriptorWithKey: c.identifier ascending: YES selector: 0];
        [c setSortDescriptorPrototype: s2];
        if (!s) s = s2;
    }
    [_table setSortDescriptors: [NSArray arrayWithObject: s]];
    
    NSMenu* menu = [[NSMenu alloc] init];
    NSMenuItem* item = [[NSMenuItem alloc] initWithTitle: @"Copy" action: @selector(onCopy:) keyEquivalent: @""];
    [menu addItem: item];
    [item release];
    item = [[NSMenuItem alloc] initWithTitle: @"Delete" action: @selector(onDelete:) keyEquivalent: @""];
    [menu addItem: item];
    [item release];
    _table.menu = menu;
    [menu release];
    
    _table.delegate = self;
    _table.dataSource = self;
    
    NSButton* b;
    ADD_BUTTON(b, v, @"Add device name", self, @selector(onAdd), 0, 10, 10, 140, BUTTON_H);
    ADD_BUTTON(b, v, @"Load from .txt", self, @selector(onLoad), 0, 150, 10, 140, BUTTON_H);
    ADD_BUTTON(b, v, @"Save all as .txt", self, @selector(onSave), 0, 290, 10, 140, BUTTON_H);
}

#define ADD_W 400
#define ADD_H 230

//---------------------------------------------------------------------------------
- (void)onAdd
{
    _addW = [[NSWindow alloc] initWithContentRect: NSMakeRect(0, 0, ADD_W, ADD_H)
                                                 styleMask: NSResizableWindowMask | NSTitledWindowMask
                                                   backing: NSBackingStoreBuffered defer: NO];
    _addW.minSize = NSMakeSize(ADD_W, ADD_H);
    
    int y = ADD_H;
    y -= 34;
    NSTextField* l;
    ADD_LABEL(l, _addW.contentView, LABEL_FONT_SZ, YES, NSCenterTextAlignment, SZ(Width) | SZ_M(MinY), 10, y, ADD_W - 20, 24);
    l.stringValue = @"Add device name";
    
    y -= 34;
    ADD_LABEL(l, _addW.contentView, LABEL_FONT_SZ, NO, NSLeftTextAlignment, SZ(Width) | SZ_M(MinY), 10, y, ADD_W - 20, 24);
    l.stringValue = @"Name";
    
    y -= 24;
    ADD_FIELD(_addName, _addW.contentView, LABEL_FONT_SZ, NO, SZ(Width) | SZ_M(MinY), 10, y, ADD_W - 20, 24);
    
    y -= 34;
    ADD_LABEL(l, _addW.contentView, LABEL_FONT_SZ, NO, NSLeftTextAlignment, SZ(Width) | SZ_M(MinY), 10, y, 280, 24);
    l.stringValue = @"UDID";
    
    y -= 24;
    ADD_FIELD(_addUdid, _addW.contentView, LABEL_FONT_SZ, NO, SZ(Width) | SZ_M(MinY), 10, y, ADD_W - 20, 24);
    
    _addName.nextKeyView = _addUdid;
    _addUdid.nextKeyView = _addName;
    [_addName becomeFirstResponder];
    
    y -= 34;
    ADD_LABEL(_addSt, _addW.contentView, LABEL_FONT_SZ, NO, NSLeftTextAlignment, SZ(Width) | SZ_M(MinY), 10, y, ADD_W - 20, 24);
    
    y -= 30;
    NSButton* b;
    ADD_BUTTON(b, _addW.contentView, @"Add", self, @selector(onSheetAdd), SZ_M(MinX) | SZ_M(MinY), ADD_W - 110, y, 100, BUTTON_H);
    ADD_BUTTON(b, _addW.contentView, @"Cancel", self, @selector(onSheetCancel), SZ_M(MinX) | SZ_M(MinY), ADD_W - 210, y, 100, BUTTON_H);
    
    [NSApp beginSheet: _addW modalForWindow: [MA_CONTROLLER window] modalDelegate: self didEndSelector: nil contextInfo: nil];
    [_addW release];
}

//---------------------------------------------------------------------------------
- (void)onSheetAdd
{
    if (!_addW) return;
    
    int err = [MA_CONTROLLER addDevice: _addUdid.stringValue name: _addName.stringValue];
    switch (err)
    {
        case 1:
            _addSt.stringValue = @"ERROR! Bad UDID string";
            break;
            
        case 2:
            _addSt.stringValue = @"ERROR! Device already exists!";
            break;
            
        default:
            [self onSheetCancel];
            [_table reloadData];
            break;
    }
}

//---------------------------------------------------------------------------------
- (void)onSheetCancel
{
    if (!_addW) return;
    [[MA_CONTROLLER window] endSheet: _addW];
    [_addW orderOut: self];
    _addW = nil;
}

//---------------------------------------------------------------------------------
- (void)onLoad
{
    NSOpenPanel* p = [NSOpenPanel openPanel];
    p.allowsMultipleSelection = NO;
    p.canChooseDirectories = NO;
    p.canChooseFiles = YES;
    p.message = @"Select TXT file with devices";
    [p beginSheetModalForWindow: [MA_CONTROLLER window] completionHandler: ^(NSModalResponse returnCode) {
        if (returnCode == NSFileHandlingPanelOKButton)
        {
            int res = [MA_CONTROLLER importDevices: [[p URLs] firstObject]];
            NSAlert* alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle: @"OK"];
            if (res == -1)
            {
                alert.messageText = @"Open file error";
                alert.alertStyle = NSWarningAlertStyle;
            } else if (res == 0)
            {
                alert.messageText = @"No new devices added";
                alert.alertStyle = NSInformationalAlertStyle;
            } else {
                [_table reloadData];
                alert.messageText = (res == 1) ? @"Success: 1 device imported" : [NSString stringWithFormat: @"Success: %d devices imported", res];
                alert.alertStyle = NSInformationalAlertStyle;
            }
            [alert runModal];
            [alert release];
            
        }
    }];
}

//---------------------------------------------------------------------------------
- (void)onSave
{
    NSSavePanel* p = [NSSavePanel savePanel];
    p.nameFieldStringValue = @"MAProvisions.txt";
    p.message = @"Save devices to TXT";
    [p beginSheetModalForWindow:[MA_CONTROLLER window] completionHandler: ^(NSModalResponse returnCode) {
        if (returnCode == NSFileHandlingPanelOKButton)
        {
            int res = [MA_CONTROLLER exportDevices: [p URL]];
            if (res == -1)
            {
                NSAlert* alert = [[NSAlert alloc] init];
                [alert addButtonWithTitle: @"OK"];
                alert.messageText = @"Save file error";
                alert.alertStyle = NSWarningAlertStyle;
                [alert runModal];
                [alert release];
            }
            
        }
    }];
    
}

#pragma mark - Menu actions

//---------------------------------------------------------------------------------
- (void)onCopy: (id)sender
{
    if (_addW || _editRow != -1 || _table.selectedRow < 0) return;
    NSArray* item = [[MA_CONTROLLER devices] objectAtIndex: _table.selectedRow];
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] writeObjects: [NSArray arrayWithObject: [item firstObject]]];
}

//---------------------------------------------------------------------------------
- (void)onDelete: (id)sender
{
    [self onKeyBackSp];
}

#pragma mark - Keyboard

//---------------------------------------------------------------------------------
- (BOOL)onKeyEsc
{
    if (_addW)
    {
        [self onSheetCancel];
        return YES;
    }
    return NO;
}

//---------------------------------------------------------------------------------
- (BOOL)onKeyBackSp
{
    NSInteger row = _table.selectedRow;
    if (_addW || _editRow != -1 || row < 0) return NO;
    
    NSArray* item = [[MA_CONTROLLER devices] objectAtIndex: _table.selectedRow];
    
    NSAlert* alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle: @"OK"];
    [alert addButtonWithTitle: @"Cancel"];
    alert.messageText = [NSString stringWithFormat: @"Delete device '%@'?", [item lastObject]];
    alert.alertStyle = NSWarningAlertStyle;
    [alert beginSheetModalForWindow: [MA_CONTROLLER window] completionHandler: ^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn)
        {
            [MA_CONTROLLER deleteDevice: [item firstObject]];
            [_table reloadData];
        }
    }];
    [alert release];
    
    return YES;
}

#pragma mark - NSTableViewDataSource

//---------------------------------------------------------------------------------
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [[MA_CONTROLLER devices] count];
}

//---------------------------------------------------------------------------------
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSArray* item = [[MA_CONTROLLER devices] objectAtIndex: row];
    return ([tableColumn.identifier isEqualToString: @"d"]) ? [item firstObject] : [item lastObject];
}

//---------------------------------------------------------------------------------
- (void)tableView:(NSTableView *)aTableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
    [MA_CONTROLLER devicesSort: _table.sortDescriptors];
    [_table reloadData];
}

#pragma mark - NSTableViewDelegate

//---------------------------------------------------------------------------------
- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    _editRow = rowIndex;
    return [aTableColumn.identifier isEqualToString: @"n"];
}

//---------------------------------------------------------------------------------
- (void)controlTextDidEndEditing:(NSNotification *)obj
{
    NSString* str = [[[obj userInfo] valueForKey: @"NSFieldEditor"] string];
    if (_editRow > -1 && _editRow < [[MA_CONTROLLER devices] count])
    {
        NSArray* item = [[MA_CONTROLLER devices] objectAtIndex: _editRow];
        if (![[item lastObject] isEqualToString: str])
        {
            [MA_CONTROLLER editDevice: [item firstObject] name: str];
            [_table reloadData];
        }
    }
    _editRow = -1;
}

@end
