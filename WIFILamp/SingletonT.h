//
//  Singleton.h
//  
//
//  Created by Aniapp on 12-11-30.
//  Copyright (c) 2012年 Aniapp. All rights reserved.
//

#define SINGLETON_INTERFACE(ClassName) \
+ (ClassName*) sharedInstance;

#define SINGLETON_IMPLEMENTATION(ClassName) \
static ClassName *_sharedInstance = nil; \
                            \
+ (ClassName *)sharedInstance \
{\
    if (_sharedInstance == nil)\
    {\
        _sharedInstance = [NSAllocateObject([self class], 0, NULL) init];\
    }\
    \
    return _sharedInstance;\
}\
\
+ (id)allocWithZone:(NSZone *)zone\
{\
    return [[self sharedInstance] retain];\
}\
\
- (id)copyWithZone:(NSZone *)zone\
{\
    return self;\
}\
\
- (id)retain\
{\
    return self;\
}\
\
- (NSUInteger)retainCount\
{\
    return NSUIntegerMax;\
}\
\
- (oneway void)release\
{\
}\
\
- (id)autorelease\
{\
    return self;\
}\
