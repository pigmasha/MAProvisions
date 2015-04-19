//
//  MAProvController.h
//  MAProvisions
//
//  Created by M on 19.04.15.
//  Copyright (c) 2015 M. All rights reserved.
//

@interface MAProvController : NSSplitViewController

- (id)initWithFrame: (NSRect)frame;
- (void)setProv: (NSDictionary*)prov;
- (void)devChanged;

// keyboard
- (BOOL)onKeyBackSp;

@end
