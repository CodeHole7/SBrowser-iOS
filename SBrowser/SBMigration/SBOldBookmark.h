//
//  SBOldBookmark.h
//  SBrowser
//
//  Created by Jin Xu on 27/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface SBOldBookmark : NSManagedObject
@property (nonatomic) int16_t order;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@end

NS_ASSUME_NONNULL_END
