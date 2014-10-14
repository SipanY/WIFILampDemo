//
//  DispatchCenter.h
//  WiFiLamp
//
//  Created by Aniapp on 13-4-15.
//
//

#import <Foundation/Foundation.h>
#import "SingletonT.h"
#import "LANTransmission.h"
//#import "WifiConfigure.h"
#import "Common.h"

#define viewController(x) [[[(x) alloc] initWithNibName:NSStringFromClass((x)) bundle:nil] autorelease]
#define DispatchManager [DispatchCenter sharedInstance]

@class LANTransmission;
@class DevicesViewController;

@interface DispatchCenter : NSObject<LANTransmissionDelegate>
{
    UINavigationController *_navController;
}

@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, retain) LANTransmission *lanTransmission;
@property (nonatomic, retain) DevicesViewController *devicesController;

SINGLETON_INTERFACE(DispatchCenter)

- (id)rootViewController;

- (void)showMainView;
- (void)showDevicesView;
- (void)showLampView;
- (void)showSettingsView;
- (void)showEditView;
- (void)showUpgradeView;
- (void)showPassWordView;
- (void)showWiFiConfigureView:(id)sender;

@end
