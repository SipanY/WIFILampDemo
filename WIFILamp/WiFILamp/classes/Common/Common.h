//
//  Common.h
//  WiFiLamp
//
//  Created by Aniapp on 12-9-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define colorWithRGBGA(r, g, b, a) [UIColor colorWithRed:(r)/255.0f \
green:(g)/255.0f blue:(b)/255.0f alpha:(a)/255.0f]

@interface Common : NSObject

+ (NSString*)getDeviceVersion;

+ (id) defaultValueForKey:(NSString *)key;
+ (void) setDefaultValueForKey:(id)value Key:(NSString *)key;
+ (void) removeDefaultForKey:(NSString *)key;

+ (NSString *) libraryDocumentsDirectory;
+ (NSString *) appDocumentsDirectory;

/* 获取Document下的文件路径 (fname-文件名) */
+ (NSString *) filePathForDocumentDirectory:(NSString *)fname;
+ (NSString *) filePathForTempDirectory:(NSString *)name;

/* 文件属性 */
+ (NSDictionary *) fileProperty:(NSString *)fileName;
+ (BOOL) checkIsExistsFile:(NSString *)fileName;
+ (BOOL) deleteDocumentFile:(NSString *)fileName;

@end
