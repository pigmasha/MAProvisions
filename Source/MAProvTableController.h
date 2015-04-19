//
//  MAProvTableController.h
//  MAProvisions
//
//  Created by M on 19.04.15.
//  Copyright (c) 2015 M. All rights reserved.
//

@interface MAProvTableController : NSViewController

- (id)initWithFrame: (NSRect)frame;
- (void)tableViewSelectionDidChange: (NSNotification *)aNotification;

// keyboard
- (BOOL)onKeyBackSp;

@end
