//
//  MAConstants.h
//

#define DEV_LEN 40

#define BUTTON_H 24
#define LABEL_FONT_SZ 13

#define SZ(__s)   NSView ## __s ## Sizable
#define SZ_M(__s) NSView ## __s ## Margin

#define LSTR(__str) NSLocalizedString(__str, nil)

//---------------------------------------------------------------------------------

#define CREATE_FOLDER(__path) \
if (![[NSFileManager defaultManager] fileExistsAtPath: __path]) \
[[NSFileManager defaultManager] createDirectoryAtPath: __path withIntermediateDirectories: NO attributes: nil error: nil];

#define DELETE_FILE(__path) if ([[NSFileManager defaultManager] fileExistsAtPath: __path]) [[NSFileManager defaultManager] removeItemAtPath: __path error: nil]

#define RECREATE_FOLDER(__path) \
if ([[NSFileManager defaultManager] fileExistsAtPath: __path]) [[NSFileManager defaultManager] removeItemAtPath: __path error: nil]; \
[[NSFileManager defaultManager] createDirectoryAtPath: __path withIntermediateDirectories: NO attributes: nil error: nil];


//---------------------------------------------------------------------------------

#define BUILD_LABEL(__val) \
    [__val setBezeled: NO]; \
    [__val setDrawsBackground: NO]; \
    [__val setEditable: NO];

//---------------------------------------------------------------------------------

#define ADD_COLUMN(__id, __title, __w, __table, __mask) \
{ \
    NSTableColumn* column = [[NSTableColumn alloc] initWithIdentifier: __id]; \
    [__table addTableColumn: column]; \
    column.width = __w; \
    column.title = __title; \
    column.resizingMask = __mask; \
    [column release]; \
}

#define ADD_SCROLL(__var, __parent, __contents, __tClass, __x, __y, __w, __h) \
    __contents = [[__tClass alloc] initWithFrame: NSMakeRect(0, 0, __w, __h)]; \
    __contents.autoresizingMask = SZ(Width) | SZ(Height); \
    __contents.columnAutoresizingStyle = NSTableViewLastColumnOnlyAutoresizingStyle; \
    __contents.focusRingType = NSFocusRingTypeNone; \
    __contents.usesAlternatingRowBackgroundColors = YES; \
    __contents.allowsMultipleSelection = NO; \
    __var = [[NSScrollView alloc] initWithFrame: NSMakeRect(__x, __y, __w, __h)]; \
    [__var setDocumentView: __contents]; \
    __var.hasVerticalScroller = YES; \
    __var.hasHorizontalScroller = NO; \
    __var.autohidesScrollers = YES; \
    [__contents release]; \
    [__parent addSubview: __var]; \
    [__var release];

#define ADD_BUTTON(__v, __super, __title, __target, __action, __autosz, __x, __y, __w, __h) \
    __v = [[NSButton alloc] initWithFrame: NSMakeRect(__x, __y, __w, __h)]; \
    __v.autoresizingMask = __autosz; \
    __v.bezelStyle = NSRoundedBezelStyle; \
    __v.title = __title; \
    __v.target = __target; \
    __v.action = __action; \
    [__super addSubview: __v]; \
    [__v release];

#define ADD_LABEL(__v, __super, __font, __fontB, __align, __autosz, __x, __y, __w, __h) \
__v = [[NSTextField alloc] initWithFrame: NSMakeRect(__x, __y, __w, __h)]; \
__v.autoresizingMask = __autosz; \
__v.alignment = __align; \
BUILD_LABEL(__v); \
__v.font = (__fontB) ? [NSFont boldSystemFontOfSize: __font] : [NSFont systemFontOfSize: __font]; \
[__super addSubview: __v]; \
[__v release];

#define ADD_FIELD(__v, __super, __font, __fontB, __autosz, __x, __y, __w, __h) \
__v = [[NSTextField alloc] initWithFrame: NSMakeRect(__x, __y, __w, __h)]; \
__v.autoresizingMask = __autosz; \
__v.font = (__fontB) ? [NSFont boldSystemFontOfSize: __font] : [NSFont systemFontOfSize: __font]; \
[__super addSubview: __v]; \
[__v release];

//---------------------------------------------------------------------------------

#define SETT_DEV @"dev"
