//
//  DispatchCenter+Data.m
//  WiFiLamp
//
//  Created by LEEM on 13-12-24.
//
//

#import "DispatchCenter+Data.h"
#import "GlobalDefines.h"
#import "DevicesViewController.h"

@implementation DispatchCenter (Data)

- (void)startBroadcast
{
    [self.lanTransmission startUDPBroadcast];
}

- (void)stopBroadcast
{
    [self.lanTransmission stopUDPBroadcast];
}

- (NSArray *)devicesList
{
    return self.lanTransmission.devicesList;
}

- (void)startConnect:(NSString *)ipaddress
{
    if (ipaddress)
    {
        [self.lanTransmission startTCPConnect:ipaddress];
    }
}

- (void)sendData:(NSData*)data code:(NSInteger)code
        userInfo:(NSDictionary*)userInfo
{
    @synchronized(self)
    {
        if ([self isConnected])
        {
            [self.lanTransmission sendTCPData:data code:code];
            if (code != kCode_SetBrightness)
            {
                [NSThread sleepForTimeInterval:0.05];
            }
        }
    }
}

- (void)sendData:(NSData *)data code:(NSInteger)code
{
    [self sendData:data code:code userInfo:nil];
}

- (void)stopConnect
{
    [self.lanTransmission stopTCPConnect];
}

- (BOOL)isConnected
{
    return [self.lanTransmission isTCPConnected];
}

#pragma mark - LANTransmissionDelegate

- (void)lanTransmissionConnected:(LANTransmission *)lanTransmission
{
    for (UIViewController *controller in self.navController.viewControllers)
    {
        if ([controller respondsToSelector:@selector(lanTransmissionConnected:)])
        {
            [controller performSelector:@selector(lanTransmissionConnected:)
                             withObject:lanTransmission];
        }
    }

    if ([self.navController.topViewController isEqual:self.devicesController])
    {
        [self showMainView];
    }
}

- (void)lanTransmission:(LANTransmission *)lanTransmission
               recvData:(NSDictionary *)dict
{
    for (UIViewController *controller in self.navController.viewControllers)
    {
        if ([controller respondsToSelector:@selector(lanTransmission:recvData:)])
        {
            [controller performSelector:@selector(lanTransmission:recvData:)
                             withObject:lanTransmission withObject:dict];
        }
    }
    
}

- (void)lanTransmissionDisconnect:(LANTransmission *)lanTransmission
{
    for (UIViewController *controller in self.navController.viewControllers)
    {
        if ([controller respondsToSelector:@selector(lanTransmissionDisconnect:)])
        {
            [controller performSelector:@selector(lanTransmissionDisconnect:)
                             withObject:lanTransmission];
        }
    }

    if ([self.navController.topViewController isEqual:self.devicesController])
        [(UIViewController*)self.devicesController viewWillAppear:NO];
    else
        [self showDevicesView];
}

@end
