//
//  MAController.h
//  MAProvisions
//
//  Created by M on 17.04.15.
//  Copyright (c) 2015 M. All rights reserved.
//

#define MA_CONTROLLER [MAController sharedInstance]

// provisions keys
#define KEY_FILE   @"file"
#define KEY_PATH   @"path"
#define KEY_ERR    @"err"
#define KEY_PARAMS @"p"
#define KEY_DATE   @"date"
#define KEY_DATE_S @"date_s"
#define KEY_NAME   @"n"
#define KEY_APPID  @"app"
#define KEY_TYPE   @"type"

// provisions types
typedef enum
{
    MAProvDev,
    MAProvAdHoc,
    MAProvAppstore
} MAProvType;

@interface MAController : NSObject

+ (void)initSharedInstance;
+ (instancetype)sharedInstance;

- (void)loadWindow;
- (NSWindow*)window;

// provisions
- (NSArray*)provisions;
- (void)deleteProv: (NSDictionary*)prov;
- (void)setProv: (NSDictionary*)prov;
- (void)provsSort: (NSArray*)sortDesc;

// devices
- (NSArray*)devices;
- (NSDictionary*)devicesMap;
- (int)addDevice: (NSString*)dev name: (NSString*)name;
- (int)editDevice: (NSString*)dev name: (NSString*)name;
- (void)deleteDevice: (NSString*)dev;
- (void)devicesSort: (NSArray*)sortDesc;
- (int)importDevices: (NSURL*)path;
- (int)exportDevices: (NSURL*)path;

// keyboard keys
- (BOOL)onKeyReturn;
- (BOOL)onKeyEsc;
- (BOOL)onKeyBackSp;

@end
