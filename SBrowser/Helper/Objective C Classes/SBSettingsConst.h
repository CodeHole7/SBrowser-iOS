//
//  SBSettingsConst.h
//  SBrowser
//
//  Created by Jin Xu on 24/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SBSettingsConst : NSObject

extern NSString *const DID_INTRO;
extern NSString *const USE_BRIDGES;
extern NSString *const CUSTOM_BRIDGES;
extern NSString *const IPV4V6;
extern NSString *const LOCALE;

// Choices for USE_BRIDGES
extern NSInteger const USE_BRIDGES_NONE;
extern NSInteger const USE_BRIDGES_OBFS4;
extern NSInteger const USE_BRIDGES_MEEKAMAZON; // legacy; retaining this for future use if meek-amazon comes back
extern NSInteger const USE_BRIDGES_MEEKAZURE;
extern NSInteger const USE_BRIDGES_CUSTOM;

// Choices for IPV4V6
extern NSInteger const IPV4V6_AUTO;
extern NSInteger const IPV4V6_V4ONLY;
extern NSInteger const IPV4V6_V6ONLY;
extern NSInteger const IPV4V6_FORCEDUAL;

@end

NS_ASSUME_NONNULL_END
