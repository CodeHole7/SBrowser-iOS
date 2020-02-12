//
//  WarningsSBrowser.h
//  SBrowser
//
//  Created by Jin Xu on 24/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

#ifndef WarningsSBrowser_h
#define WarningsSBrowser_h

#define SILENCE_DEPRECATION_ON                                            \
_Pragma("clang diagnostic push")                                        \
_Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"")        \
_Pragma("clang diagnostic ignored \"-Wdeprecated-implementations\"")

#define SILENCE_DEPRECATION(expr)                                        \
do {                                                                    \
_Pragma("clang diagnostic push")                                        \
_Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"")        \
_Pragma("clang diagnostic ignored \"-Wdeprecated-implementations\"")    \
expr;                                                                    \
_Pragma("clang diagnostic pop")                                            \
} while(0)

#define SILENCE_PERFORM_SELECTOR_LEAKS_ON                                \
_Pragma("clang diagnostic push")                                        \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")

#define SILENCE_PERFORM_SELECTOR_LEAKS(expr)                            \
do {                                                                    \
_Pragma("clang diagnostic push")                                        \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")        \
expr;                                                                    \
_Pragma("clang diagnostic pop")                                            \
} while(0)

#define SILENCE_WARNINGS_OFF                                            \
_Pragma("clang diagnostic pop")

#endif /* WarningsSBrowser_h */
