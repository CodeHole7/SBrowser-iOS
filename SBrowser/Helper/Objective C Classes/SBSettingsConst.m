//
//  SBSettingsConst.m
//  SBrowser
//
//  Created by Jin Xu on 24/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

#import "SBSettingsConst.h"

@implementation SBSettingsConst

NSString *const DID_INTRO = @"did_intro";
NSString *const USE_BRIDGES = @"use_bridges";
NSString *const CUSTOM_BRIDGES = @"custom_bridges";
NSString *const IPV4V6 = @"ipv4v6";
NSString *const LOCALE = @"locale";

// Choices for USE_BRIDGES
NSInteger const USE_BRIDGES_NONE = 0;
NSInteger const USE_BRIDGES_OBFS4 = 1;
NSInteger const USE_BRIDGES_MEEKAMAZON = 2; // legacy; retaining this number for future use if meek-amazon comes back
NSInteger const USE_BRIDGES_MEEKAZURE = 3;
NSInteger const USE_BRIDGES_CUSTOM = 99;

// Choices for IPV4V6
NSInteger const IPV4V6_AUTO = 0;
NSInteger const IPV4V6_V4ONLY = 1;
NSInteger const IPV4V6_V6ONLY = 2;
NSInteger const IPV4V6_FORCEDUAL = 3;

@end
