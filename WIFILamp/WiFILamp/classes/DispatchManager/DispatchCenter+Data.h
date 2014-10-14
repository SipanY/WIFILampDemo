//
//  DispatchCenter+Data.h
//  WiFiLamp
//
//  Created by LEEM on 13-12-24.
//
//

#import "DispatchCenter.h"

@interface DispatchCenter (Data)

- (void)startBroadcast;
- (void)stopBroadcast;
- (NSArray*)devicesList;

- (void)startConnect:(NSString *)ipaddress;
- (void)sendData:(NSData*)data code:(NSInteger)code
        userInfo:(NSDictionary*)userInfo;
- (void)sendData:(NSData*)data code:(NSInteger)code;
- (void)stopConnect;
- (BOOL)isConnected;

@end
