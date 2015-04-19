//
//  MAController.m
//  MAProvisions
//
//  Created by M on 17.04.15.
//  Copyright (c) 2015 M. All rights reserved.
//

#import "MAController.h"
#import "MADevicesController.h"
#import "MAProvController.h"

#define FOLDER_PROV @"~/Library/MobileDevice/Provisioning Profiles/"

//=================================================================================

@interface MAController ()
{
    NSWindow* _window;
    MADevicesController* _vcDev;
    MAProvController* _vcProv;
    NSTabView* _tab;
    
    NSMutableArray* _provisions;
    int _provSortCol;
    BOOL _provSortDesc;
    
    NSMutableDictionary* _devices;
    NSMutableArray* _devicesArr;
    int _devSortCol;
    BOOL _devSortDesc;
}
@end

//=================================================================================

@implementation MAController

static MAController* _s_inst = nil;

//---------------------------------------------------------------------------------
+ (void)initSharedInstance
{
    if (!_s_inst) _s_inst = [[MAController alloc] init];
}

//---------------------------------------------------------------------------------
+ (instancetype)sharedInstance
{
    return _s_inst;
}

//---------------------------------------------------------------------------------
- (void)dealloc
{
    [_window release];
    [_vcDev  release];
    [_vcProv release];
    
    [_provisions release];
    
    [_devices    release];
    [_devicesArr release];
    
    [super dealloc];
}

//---------------------------------------------------------------------------------
- (void)loadWindow
{
    _window = [[NSWindow alloc] initWithContentRect: NSMakeRect(0, 0, 800, 520)
                                          styleMask: NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask
                                            backing: NSBackingStoreBuffered defer: NO];
    _window.minSize = NSMakeSize(800, 450);
    _window.title = @"MAProvisions";
    
    _provisions = [[NSMutableArray alloc] init];
    [self loadProvisions];
    
    _devices    = [[NSMutableDictionary alloc] init];
    _devicesArr = [[NSMutableArray alloc] init];
    [self loadDevices];
    
    _tab = [[NSTabView alloc] initWithFrame: [_window.contentView bounds]];
    _tab.autoresizingMask = SZ(Width) | SZ(Height);
    
    // provisions tab
    _vcProv = [[MAProvController alloc] initWithFrame: [_window.contentView bounds]];
    NSTabViewItem* item = [[NSTabViewItem alloc] initWithIdentifier: @"p"];
    [item setLabel: @"Provisions"];
    [item setView: _vcProv.view];
    
    [_tab addTabViewItem: item];
    [item release];
    
    // devices tab
    _vcDev = [[MADevicesController alloc] initWithFrame: [_window.contentView bounds]];
    item = [[NSTabViewItem alloc] initWithIdentifier: @"d"];
    [item setLabel: @"Devices names"];
    [item setView: _vcDev.view];
    
    [_tab addTabViewItem: item];
    [item release];
    
    // finish
    [_window.contentView addSubview: _tab];
    [_tab release];
    
    [_window center];
    [_window makeKeyAndOrderFront: NSApp];
}

//---------------------------------------------------------------------------------
- (NSWindow*)window
{
    return _window;
}

#pragma mark - Provisions

//---------------------------------------------------------------------------------
- (NSArray*)provisions
{
    return _provisions;
}

//---------------------------------------------------------------------------------
- (void)deleteProv: (NSDictionary*)prov
{
    [[NSFileManager defaultManager] removeItemAtPath: [prov objectForKey: KEY_PATH] error: nil];
    [self loadProvisions];
}

//---------------------------------------------------------------------------------
- (void)setProv: (NSDictionary*)prov
{
    [_vcProv setProv: prov];
}

//---------------------------------------------------------------------------------
- (void)provsSort: (NSArray*)sortDesc
{
    if (![sortDesc count]) return;
    NSSortDescriptor* s = [sortDesc firstObject];
    
    _provSortCol = ([s.key isEqualToString: @"n"]) ? 0 : (([s.key isEqualToString: @"t"]) ? 1 : (([s.key isEqualToString: @"d"]) ? 2 : 3));
    _provSortDesc = !s.ascending;
    
    NSString* k = nil;
    switch (_provSortCol)
    {
        case 0: k = KEY_NAME; break;
        case 1: k = KEY_TYPE; break;
        case 2: k = KEY_DATE; break;
        default: k = KEY_APPID; break;
    }
    [_provisions sortUsingComparator: ^ NSComparisonResult(NSDictionary* a, NSDictionary* b) {
        NSComparisonResult c = NSOrderedSame;
        if (_provSortCol == 0 || _provSortCol == 3)
        {
            c = (_provSortDesc) ? [[b objectForKey: k] caseInsensitiveCompare: [a objectForKey: k]] : [[a objectForKey: k] caseInsensitiveCompare: [b objectForKey: k]];
        } else {
            c = (_provSortDesc) ? [[b objectForKey: k] compare: [a objectForKey: k]] : [[a objectForKey: k] compare: [b objectForKey: k]];
        }
        if (!_provSortCol || c != NSOrderedSame) return c;
        return (_provSortDesc) ? [[b objectForKey: KEY_NAME] caseInsensitiveCompare: [a objectForKey: KEY_NAME]] : [[a objectForKey: KEY_NAME] caseInsensitiveCompare: [b objectForKey: KEY_NAME]];
    }];
}

//---------------------------------------------------------------------------------
- (void)loadProvisions
{
    [_provisions removeAllObjects];
    
    NSString* path = [FOLDER_PROV stringByExpandingTildeInPath];
    NSDirectoryEnumerator* en = [[NSFileManager defaultManager] enumeratorAtPath: path];
    NSString* file;
    while (file = [en nextObject])
    {
        if (![file rangeOfString: @".mobileprovision"].length) continue;
        
        NSMutableDictionary* item = [[NSMutableDictionary alloc] initWithObjectsAndKeys: file, KEY_FILE, [path stringByAppendingPathComponent: file], KEY_PATH, nil];
        int err = [self loadProvision: item];
        [item setObject: [NSNumber numberWithInt: err] forKey: KEY_ERR];
        [_provisions addObject: item];
        [item release];
    }
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterMediumStyle;
    df.timeStyle = NSDateFormatterNoStyle;
    
    // prepare _provisions for use
    for (NSMutableDictionary* item in _provisions)
    {
        [item setObject: @"" forKey: KEY_NAME];
        [item setObject: @"" forKey: KEY_DATE_S];
        [item setObject: @"" forKey: KEY_APPID];
        if (![item objectForKey: KEY_PARAMS]) continue;
        
        id v = [[item objectForKey: KEY_PARAMS] objectForKey: @"Name"];
        if (v) [item setObject: v forKey: KEY_NAME];
        
        v = [[item objectForKey: KEY_PARAMS] objectForKey: @"ExpirationDate"];
        if (v)
        {
            [item setObject: v forKey: KEY_DATE];
            [item setObject: [df stringFromDate: v] forKey: KEY_DATE_S];
        }
        
        BOOL allow = [[[[item objectForKey: KEY_PARAMS] objectForKey: @"Entitlements"] objectForKey: @"get-task-allow"] boolValue];
        MAProvType t = (allow) ? MAProvDev : (([[item objectForKey: KEY_PARAMS] objectForKey: @"ProvisionedDevices"]) ? MAProvAdHoc : MAProvAppstore);
        [item setObject: [NSNumber numberWithInt: t] forKey: KEY_TYPE];
        v = [[[item objectForKey: KEY_PARAMS] objectForKey: @"Entitlements"] objectForKey: @"application-identifier"];
        if (v) [item setObject: v forKey: KEY_APPID];
    }
    [df release];
    
    [_provisions sortUsingComparator: ^ NSComparisonResult(NSDictionary* a, NSDictionary* b) {
        return [[a objectForKey: KEY_NAME] caseInsensitiveCompare: [b objectForKey: KEY_NAME]];
    }];
}

//---------------------------------------------------------------------------------
- (int)loadProvision: (NSMutableDictionary*)item
{
    NSData* d = [[NSData alloc] initWithContentsOfFile: [item objectForKey: KEY_PATH]];
    if (![d length])
    {
        [d release];
        return 1;
    }
    
    const char* prefix = "<?xml";
    int prLen = (int)strlen(prefix);
    if ([d length] < prLen)
    {
        [d release];
        return 2;
    }
    
    const char* bytes = (const char*)[d bytes];
    const char* p1 = nil;
    
    for (int i = 0; i < [d length] - prLen; i++)
    {
        if (bytes[i] == prefix[0])
        {
            BOOL isOk = YES;
            for (int j = 1; j < prLen; j++)
            {
                if (bytes[i + j] != prefix[j])
                {
                    isOk = NO;
                    break;
                }
            }
            if (isOk)
            {
                p1 = bytes + i;
                break;
            }
        }
    }
    if (!p1) { [d release]; return 3; }
    
    const char* p2 = strstr(p1, "</plist>");
    if (!p2) { [d release]; return 4; }
    
    NSString* path = [NSTemporaryDirectory() stringByAppendingPathComponent: @"MAProvisions"];
    while ([[NSFileManager defaultManager] fileExistsAtPath: path]) path = [path stringByAppendingString: @"1"];
    
    NSData* d2 = [[NSData alloc] initWithBytes: p1 length: p2 - p1 + strlen("</plist>")];
    [d2 writeToFile: path atomically: YES];
    [d2 release];
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    [[NSFileManager defaultManager] removeItemAtPath: path error: nil];
    if (!params)
    {
        [params release];
        return 5;
    }
    [params removeObjectForKey: @"DeveloperCertificates"];
    [item setObject: params forKey: KEY_PARAMS];
    [params release];
    return 0;
}

#pragma mark - Devices

//---------------------------------------------------------------------------------
- (NSArray*)devices
{
    return _devicesArr;
}

//---------------------------------------------------------------------------------
- (NSDictionary*)devicesMap
{
    return _devices;
}

//---------------------------------------------------------------------------------
// return error code (0 - ok, 1 - bad device, 2 - device exists)
//---------------------------------------------------------------------------------
- (int)addDevice: (NSString*)dev name: (NSString*)name
{
    dev = [dev stringByReplacingOccurrencesOfString: @"-" withString: @""];
    dev = [dev stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([dev length] != DEV_LEN) return 1;
    if ([_devices objectForKey: dev]) return 2;
    [_devices setObject: [name stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey: dev];
    [self saveDevices];
    return 0;
}

//---------------------------------------------------------------------------------
// return error code (0 - ok, 1 - bad device, 2 - device not exists)
//---------------------------------------------------------------------------------
- (int)editDevice: (NSString*)dev name: (NSString*)name
{
    dev = [dev stringByReplacingOccurrencesOfString: @"-" withString: @""];
    dev = [dev stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([dev length] != DEV_LEN) return 1;
    if (![_devices objectForKey: dev]) return 2;
    [_devices setObject: [name stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey: dev];
    [self saveDevices];
    return 0;
}

//---------------------------------------------------------------------------------
- (void)deleteDevice: (NSString*)dev
{
    [_devices removeObjectForKey: dev];
    [self saveDevices];
}

//---------------------------------------------------------------------------------
- (void)devicesSort: (NSArray*)sortDesc
{
    if (![sortDesc count]) return;
    NSSortDescriptor* s = [sortDesc firstObject];
    
    _devSortCol = ([s.key isEqualToString: @"n"]) ? 0 : 1;
    _devSortDesc = !s.ascending;
    
    [self reloadDevArr];
}

//---------------------------------------------------------------------------------
- (int)importDevices: (NSURL*)path
{
    NSMutableData* d = [[NSMutableData alloc] initWithContentsOfURL: path];
    if (![d length])
    {
        [d release];
        return -1;
    }
    int res = 0;
    
    int len = (int)[d length];
    [d setLength: len + 1];
    
    char* bytes = (char*)[d bytes];
    bytes[len] = '\0';
    while (YES)
    {
        char* p1 = strchr(bytes, '\n');
        if (p1) p1[0] = '\0';
        char* p2 = strchr(bytes, '\t');
        if (p2)
        {
            p2[0] = '\0';
            NSString* name = [NSString stringWithUTF8String: p2 + 1];
            NSString* dev  = [NSString stringWithUTF8String: bytes];
            name = [name stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            dev  = [dev stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([dev length] != DEV_LEN && [name length] == DEV_LEN)
            {
                NSString* s = name;
                name = dev;
                dev  = s;
            }
            if ([dev length] == DEV_LEN && ![_devices objectForKey: dev])
            {
                [_devices setObject: name forKey: dev];
                res++;
            }
        }
        if (!p1) break;
        bytes = p1 + 1;
    }
    [d release];
    if (res) [self saveDevices];
    
    return res;
}

//---------------------------------------------------------------------------------
- (int)exportDevices: (NSURL*)path
{
    NSMutableString* str = [[NSMutableString alloc] init];
    for (NSArray* item in _devicesArr) [str appendFormat: @"%@\t%@\n", [item firstObject], [item lastObject]];
    BOOL res = [str writeToURL: path atomically: YES encoding: NSUTF8StringEncoding error: nil];
    [str release];
    return (res) ? 0 : -1;
}

//---------------------------------------------------------------------------------
- (void)loadDevices
{
    id d = [[NSUserDefaults standardUserDefaults] objectForKey: SETT_DEV];
    if (![d isKindOfClass: [NSDictionary class]]) return;
    for (NSString* k in d)
    {
        if ([k length] != DEV_LEN) continue;
        [_devices setObject: [d objectForKey: k] forKey: k];
    }
    [self reloadDevArr];
}

//---------------------------------------------------------------------------------
- (void)saveDevices
{
    [self reloadDevArr];
    [_vcProv devChanged];
    NSDictionary* d = [[NSDictionary alloc] initWithDictionary: _devices];
    [[NSUserDefaults standardUserDefaults] setObject: d forKey: SETT_DEV];
    [d release];
}

//---------------------------------------------------------------------------------
- (void)reloadDevArr
{
    [_devicesArr removeAllObjects];
    for (NSString* k in _devices)
    {
        [_devicesArr addObject: [NSArray arrayWithObjects: k, [_devices objectForKey: k], nil]];
    }
    [_devicesArr sortUsingComparator: ^ NSComparisonResult(NSArray* a, NSArray* b) {
        if (_devSortCol == 0)
        {
            return (_devSortDesc) ? [[b lastObject] caseInsensitiveCompare: [a lastObject]] : [[a lastObject] caseInsensitiveCompare: [b lastObject]];
        }
        return (_devSortDesc) ? [[b firstObject] caseInsensitiveCompare: [a firstObject]] : [[a firstObject] caseInsensitiveCompare: [b firstObject]];
    }];
}

#pragma mark - Keyboard

//---------------------------------------------------------------------------------
- (BOOL)onKeyReturn
{
    return NO;
}

//---------------------------------------------------------------------------------
- (BOOL)onKeyEsc
{
    if ([_tab.selectedTabViewItem.identifier isEqualToString: @"d"]) return [_vcDev onKeyEsc];
    return NO;
}

//---------------------------------------------------------------------------------
- (BOOL)onKeyBackSp
{
    if ([_tab.selectedTabViewItem.identifier isEqualToString: @"d"]) return [_vcDev onKeyBackSp];
    return [_vcProv onKeyBackSp];
}

@end
