//
//  WKWebView+Helper.h
//  SBrowser
//
//  Created by JinXu on 21/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//



#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKWebView (Helper)

- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;

@end

NS_ASSUME_NONNULL_END
