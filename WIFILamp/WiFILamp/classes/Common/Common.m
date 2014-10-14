//
//  Common.m
//  WiFiLamp
//
//  Created by Aniapp on 12-9-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Common.h"

@implementation Common

+ (NSString*)getDeviceVersion
{
    size_t size = 1;
//    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char*)malloc(size);
//    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}

+ (id) defaultValueForKey:(NSString *)key
{
	return [[NSUserDefaults standardUserDefaults] valueForKey:key];
}

+ (void) setDefaultValueForKey:(id)value Key:(NSString *)key
{
	[[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) removeDefaultForKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *) appDocumentsDirectory
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES); //文档目录
	return [paths objectAtIndex:0];
}

+ (NSString *) libraryDocumentsDirectory
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, 
                                                         NSLocalDomainMask, YES); //文档目录
	return [paths objectAtIndex:0];
}

+ (NSString *) filePathForDocumentDirectory:(NSString*)fname
{
    NSString *dir = [Common appDocumentsDirectory];
    return [dir stringByAppendingPathComponent:fname];
}

+ (NSString *) filePathForTempDirectory:(NSString *)name
{
    NSString *dir = NSTemporaryDirectory();
    return [dir stringByAppendingPathComponent:name];
}

+ (BOOL) deleteDocumentFile:(NSString *)fileName
{
    NSString *fname = [Common filePathForDocumentDirectory:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:fname])
    {
        NSError *error;
        return [fileManager removeItemAtPath:fname error:&error];
    }
    return NO;
}

+ (NSDictionary *) fileProperty:(NSString *)fileName
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	return [fileManager attributesOfItemAtPath:fileName error:&error];
}

+ (BOOL) checkIsExistsFile:(NSString *)fileName
{
    //@synchronized (self)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        return [fileManager fileExistsAtPath:fileName];
    }
}


@end
