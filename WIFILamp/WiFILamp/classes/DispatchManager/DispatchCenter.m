//
//  DispatchCenter.m
//  WiFiLamp
//
//  Created by Aniapp on 13-4-15.
//
//

#import "DispatchCenter.h"
#import "DevicesViewController.h"
#import "MainViewController.h"
#import "UpgradeViewController.h"
#import "EditViewController.h"
#import "WiFiViewController.h"
#import "SetPassWordViewController.h"
@interface DispatchCenter () <WiFiViewControllerDelegate>

@property (nonatomic, retain) MainViewController *mainController;
@property (nonatomic, retain) UpgradeViewController *upgradeController;
@property (nonatomic, retain) EditViewController *editController;
@property (nonatomic, retain) WiFiViewController *wifiController;
@property (nonatomic, retain) SetPassWordViewController *passWordController;
@end

@implementation DispatchCenter

@synthesize navController = _navController;
@synthesize mainController = _mainController;
@synthesize devicesController = _devicesController;
@synthesize upgradeController = _upgradeController;
@synthesize editController = _editController;
@synthesize wifiController = _wifiController;
@synthesize lanTransmission = _lanTransmission;

SINGLETON_IMPLEMENTATION(DispatchCenter)

- (void)dealloc
{
    [_lanTransmission release];
    [_wifiController release];
    [_editController release];
    [_upgradeController release];
    [_mainController release];
    [_devicesController release];
    [_navController release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        if (_lanTransmission == nil)
        {
            _lanTransmission = [[LANTransmission alloc] init];
            _lanTransmission.protocolType = PROTOCOL_TYPE_LAMP;
            _lanTransmission.delegate = self;
          //  _wifiController=[WifiConfigure sharedInstance];//改
            self.upgradeController = viewController([UpgradeViewController class]);
            self.wifiController=viewController([WiFiViewController class]);
            
        }
    }
    return self;
}

- (id)rootViewController
{
    if (_navController == nil)
    {
        if (_mainController == nil)
        {
            self.mainController = viewController([MainViewController class]);
        }
        
        self.navController = [[[UINavigationController alloc] initWithRootViewController:_mainController] autorelease];
        [_navController setNavigationBarHidden:YES];
    }
    
    [DispatchManager showDevicesView];

    return _navController;
}

- (void)showMainView
{
    if (_mainController == nil)
    {
        self.mainController = viewController([MainViewController class]);
    }
    
    if (![self.navController.viewControllers containsObject:_mainController])
        [self.navController pushViewController:_mainController animated:YES];
    else
        [self.navController popToViewController:_mainController animated:YES];
}

- (void)showLampView
{
    
}

- (void)showWiFiConfigureView:(id)sender
{
    if (_wifiController == nil)
    {
        self.wifiController = viewController([WiFiViewController class]);
        self.wifiController.delegate = self;
        self.wifiController.skipTips = sender ? YES : NO;
    }
    
    if (![self.navController.viewControllers containsObject:_wifiController])
        [self.navController pushViewController:_wifiController animated:YES];
    else
        [self.navController popToViewController:_wifiController animated:YES];
}

- (void)showEditView
{
    if (_editController == nil)
    {
        self.editController = viewController([EditViewController class]);
    }
    
    if (![self.navController.viewControllers containsObject:_editController])
        [self.navController pushViewController:_editController animated:YES];
    else
        [self.navController popToViewController:_editController animated:YES];
}

- (void)showSettingsView
{
    
}

- (void)showDevicesView
{
    if (_devicesController == nil)
    {
        self.devicesController = viewController([DevicesViewController class]);
    }
    
    if (![self.navController.viewControllers containsObject:_devicesController])
        [self.navController pushViewController:_devicesController animated:YES];
    else
        [self.navController popToViewController:_devicesController animated:YES];
}

- (void)showUpgradeView
{
    if (_upgradeController == nil)
    {
        self.upgradeController = viewController([UpgradeViewController class]);
        
    }
    
    if (![self.navController.viewControllers containsObject:_upgradeController])
        [self.navController pushViewController:_upgradeController animated:YES];
    else
        [self.navController popToViewController:_upgradeController animated:YES];
}
- (void)showPassWordView//313
{
    if (_passWordController == nil)
    {
        self.passWordController = viewController([SetPassWordViewController class]);
        
    }
    
    if (![self.navController.viewControllers containsObject:_passWordController])
        [self.navController pushViewController:_passWordController animated:YES];
    else
        [self.navController popToViewController:_passWordController animated:YES];
}

#pragma mark - WiFiViewControllerDelegate

- (void)didWiFiConfigure:(BOOL)value
{
    if (value)
    {
        [self.navController popToViewController:_devicesController animated:YES];
    }
}

@end
