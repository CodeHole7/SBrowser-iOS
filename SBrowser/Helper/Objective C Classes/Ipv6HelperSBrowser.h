//
//  Ipv6HelperSBrowser.h
//  SBrowser
//
//  Created by Jin Xu on 24/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

#define TOR_IPV6_CONN_FALSE 0
#define TOR_IPV6_CONN_DUAL 1
#define TOR_IPV6_CONN_ONLY 2
#define TOR_IPV6_CONN_UNKNOWN 99

NS_ASSUME_NONNULL_BEGIN

@interface Ipv6HelperSBrowser : NSObject

+ (NSInteger) ipv6_status;

@end

NS_ASSUME_NONNULL_END
