//
//  MAProvController.m
//  MAProvisions
//
//  Created by M on 19.04.15.
//  Copyright (c) 2015 M. All rights reserved.
//

#import "MAProvController.h"
#import "MAProvInfoController.h"
#import "MAProvTableController.h"

@interface MAProvController ()<NSTableViewDataSource, NSTableViewDelegate>
{
    NSRect _r;
    NSTableView* _table;
    MAProvTableController* _vcTable;
    MAProvInfoController*  _vcInfo;
}
@end

//=================================================================================

@implementation MAProvController

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
    [_vcInfo  release];
    [_vcTable release];
    [super dealloc];
}

//---------------------------------------------------------------------------------
- (void)loadView
{
    [super loadView];
    self.splitView.vertical = NO;
    self.splitView.dividerStyle = NSSplitViewDividerStylePaneSplitter;
    _vcTable = [[MAProvTableController alloc] initWithFrame: _r];
    [self addSplitViewItem: [NSSplitViewItem splitViewItemWithViewController: _vcTable]];
    
    _vcInfo = [[MAProvInfoController alloc] initWithFrame: _r];
    [self addSplitViewItem: [NSSplitViewItem splitViewItemWithViewController: _vcInfo]];
}

//---------------------------------------------------------------------------------
- (void)setProv: (NSDictionary*)prov
{
    [_vcInfo setProv: prov];
}

//---------------------------------------------------------------------------------
- (void)devChanged
{
    [_vcTable tableViewSelectionDidChange: nil];
}

#pragma mark - Keyboard

//---------------------------------------------------------------------------------
- (BOOL)onKeyBackSp
{
    return [_vcTable onKeyBackSp];
}

@end
