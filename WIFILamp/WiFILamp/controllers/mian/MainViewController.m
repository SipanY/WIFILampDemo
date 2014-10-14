//
//  MainViewController.m
//  WiFiLamp
//
//  Created by Aniapp on 12-9-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "LampViewController.h"
#import "ExtendViewController.h"
#import "SettingsViewController.h"
#import "DispatchCenter+Data.h"
#import "GlobalDefines.h"
#import "WaitingView.h"
#import "MainCell.h"
#import "Common.h"
#import "ZHClient.h"
#import "TBXML.h"

@interface MainViewController ()
{
    dispatch_semaphore_t _semKeepAlive;
    WaitingView *_waitingView;
}

- (void)showWaitingView:(NSString*)text;
- (void)hideWaitingView;
- (void)reloadTableView;

- (void)syncLampInfo;
- (void)syncExtenderInfo;

@end

@implementation MainViewController

- (void)viewDidLoad
{   
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self syncLampInfo];
    [self syncExtenderInfo];
    [self reloadTableView];

}
//-(void)viewDidAppear:(BOOL)animated{
//    [super viewDidAppear:animated];
//    [self reloadTableView];
//}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return ((interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) ||
            (interfaceOrientation == UIInterfaceOrientationPortrait));
}

- (void)dealloc
{
    [_waitingView release];
    [_tableView release];
    [super dealloc];
}

#pragma mark - private methods

- (void)showWaitingView:(NSString*)text
{
    if (_waitingView == nil)
    {
        CGRect rect = [[UIScreen mainScreen] bounds];
        _waitingView = [[WaitingView alloc] initWithFrame:rect];
    }
    
    [_waitingView show:self.navigationController.topViewController.view Text:text];
}

- (void)hideWaitingView
{
    [_waitingView hide];
}

- (void)startKeepAlive
{
    void (^task)(void) = ^{
        
        while ([DispatchManager isConnected])
        {
            [DispatchManager sendData:[NSData data] code:kCode_KeepAlive userInfo:nil];
            [NSThread sleepForTimeInterval:5];
        }
        
        dispatch_semaphore_signal(_semKeepAlive);
        CLog(@"[keepLANTransmission] exit...");
    };
    
    _semKeepAlive = dispatch_semaphore_create(0);
    dispatch_queue_t queue = dispatch_queue_create("keepLANTrans", NULL);
    dispatch_async(queue, task);
    dispatch_release(queue);
}

- (void)stopKeepAlive
{
    if (_semKeepAlive > 0)
    {
        dispatch_semaphore_wait(_semKeepAlive, DISPATCH_TIME_FOREVER);
        dispatch_release(_semKeepAlive);
        _semKeepAlive = 0;
    }
    
    CLog(@"[stopLANTransmission]");
}

- (NSData*)currentTime
{
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *str = [formatter stringFromDate:[NSDate date]];
    str = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
           "<xml> <value code=\"%@\" /> </xml>", str];
    return [NSData dataWithBytes:[str UTF8String] length:[str length]];
}

- (void)syncLampInfo
{
    [DispatchManager sendData:[self currentTime] code:kCode_SetSyncTime userInfo:nil];
    [DispatchManager sendData:[NSData data] code:kCode_GetLampName userInfo:nil];
    [DispatchManager sendData:[NSData data] code:kCode_GetLampTimer userInfo:nil];
    [DispatchManager sendData:[NSData data] code:kCode_GetBrightness userInfo:nil];
}

- (void)syncExtenderInfo
{
    [DispatchManager sendData:[NSData data] code:kCode_GetExtenderTimer userInfo:nil];
    [DispatchManager sendData:[NSData data] code:kCode_GetExtenderAuth userInfo:nil];
//    [DispatchManager sendData:[NSData data] code:kCode_GetExtenderState userInfo:nil];
}

#pragma mark - pubilc methods

- (void)devicesButtonPressed:(id)sender
{
    [DispatchManager showDevicesView];
}

- (void)showSettingsView:(id)sender
{
    SettingsViewController *controller =
    [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

#pragma mark - UITableViewDataSource/UITableViewDelegate

- (void)reloadTableView
{
    for (UIView *view in self.view.subviews)
    {
        if ([view isKindOfClass:[UITableView class]])
        {
            [(UITableView*)view reloadData];
            break;
        }
    }
}

- (void)buttonPressed:(id)object
{
    UIButton *button = (UIButton*)object;
    if (button.tag == 1)
    {
        LampViewController *controller = viewController([LampViewController class]);
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if (button.tag == 0)
    {
//        NSString *rssi = [Common defaultValueForKey:kXML_ATTR_RSSI];
//        if ([rssi length] > 0)
        {
            ExtendViewController *controller = viewController([ExtendViewController class]);
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 166;
}

- (NSString *)formatTime:(NSString *)time
{
    if ([time length] == 4)
    {
        return [NSString stringWithFormat:@"%@:%@", [time substringToIndex:2],
                [time substringFromIndex:2]];
    }
    return nil;
}
- (UIStatusBarStyle)preferredStatusBarStyle

{
    
    return UIStatusBarStyleLightContent;
    
}
- (BOOL)prefersStatusBarHidden

{
    
    return NO;
    
}
- (void)loadCell:(MainCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    NSString *title = (row != 0) ? @"台灯开关控制" : @"儿童上网控制";
    NSString *desc1 = (row != 0) ? @"灯光：%@" : @"状态：%@";
    NSString *desc2 = (row != 0) ? @"定时：%@" : @"WiFi延长热点名称：%@";
    
    if (row == 1)
    {
        NSString *value = [Common defaultValueForKey:kXML_ATTR_BRIGHTNESS];
        value = ([value integerValue] > 0) ? @"开" : @"关";
        desc1 = [NSString stringWithFormat:desc1, value];
        
        NSDictionary *led = [Common defaultValueForKey:kXML_NODE_LED];
        if ([led[kXML_ATTR_REPEAT] integerValue] == 2)
        {
            desc2 = @"度假模式";
        }
        else
        {
            NSString *stime = led[kXML_ATTR_STIME];
            NSString *etime = led[kXML_ATTR_ETIME];
            if (stime && etime && ![stime isEqualToString:@"0000"] &&
                ![etime isEqualToString:@"0000"])
            {
                value = [NSString stringWithFormat:@"%@ - %@",
                         [self formatTime:stime], [self formatTime:etime]];
            }
            else
            {
                value = ([led[kXML_ATTR_TIMER] integerValue] > 0) ? @"开" : @"关";
            }
            desc2 = [NSString stringWithFormat:desc2, value];
        }
    }
    else
    {
        NSDictionary *wlan = [Common defaultValueForKey:kXML_NODE_WLAN];
        NSString *value = ([wlan[kXML_ATTR_STATE] integerValue] > 0) ? @"开" : @"关";
        desc1 = [NSString stringWithFormat:desc1, value];
        value = [Common defaultValueForKey:kXML_ATTR_NAME] ? : @"空";
        desc2 = [NSString stringWithFormat:desc2, value];
    }
   // NSString *str=[Common defaultValueForKey:@"LampName"];
    cell.titleLabel.text = title;
    cell.desc1Label.text = desc1;
    cell.desc2Label.text = desc2;
    [cell.nextButton setTag:row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MainIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"MainCell" owner:self options:nil];
        if ([array count] > 0)
        {
            cell = [array objectAtIndex:0];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            MainCell *mainCell = (MainCell*)cell;
            [mainCell.nextButton addTarget:self action:@selector(buttonPressed:)
                          forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    [self loadCell:(MainCell*)cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIButton *button = [[[UIButton alloc] init] autorelease];
    button.tag = [indexPath row];
    [self buttonPressed:button];
}

#pragma mark - LANTransmissionDelegate

- (void)lanTransmissionConnected:(LANTransmission *)lanTransmission
{
    [self startKeepAlive];
}

- (void)lanTransmissionDisconnect:(LANTransmission *)lanTransmission
{
    [self stopKeepAlive];
}

- (void)lanTransmission:(LANTransmission *)lanTransmission
               recvData:(NSDictionary *)dict
{
@synchronized(self)
{
    if ([dict count] > 0)
    {
        NSNumber *number = [[dict allKeys] objectAtIndex:0];
        NSInteger code = [number unsignedCharValue];
        NSData *data = [[dict allValues] objectAtIndex:0];
        
//        CLog(@"-----------> %d", code);
        if (data && (code != kCode_KeepAlive) && (code != kCode_SetSyncTime))
        {
            NSError *error;
            TBXML *tbxml = [[TBXML alloc] initWithXMLData:data error:&error];
            if (tbxml && !error)
            {
                if (code == kCode_GetLampTimer)
                {
                    TBXMLElement *element = [TBXML childElementNamed:kXML_NODE_LED
                                                       parentElement:tbxml.rootXMLElement];
                    if (element)
                    {
                        NSString *timer = [TBXML valueOfAttributeNamed:kXML_ATTR_TIMER
                                                            forElement:element];
                        NSString *repeat = [TBXML valueOfAttributeNamed:kXML_ATTR_REPEAT
                                                            forElement:element];
                        
                        NSString *stime = nil;
                        NSString *etime = nil;
                        element = [TBXML childElementNamed:kXML_NODE_TIMER
                                             parentElement:element];
                        if (element)
                        {
                            stime = [TBXML valueOfAttributeNamed:kXML_ATTR_STIME
                                                      forElement:element];
                            etime = [TBXML valueOfAttributeNamed:kXML_ATTR_ETIME
                                                      forElement:element];
                        }
                        
                        NSDictionary *led = @{kXML_ATTR_TIMER: timer ? : @"0",
                                              kXML_ATTR_REPEAT: repeat ? : @"0",
                                              kXML_ATTR_STIME: stime ? : @"0000",
                                              kXML_ATTR_ETIME: etime ? :@"0000"};
                        [Common setDefaultValueForKey:led Key:kXML_NODE_LED];
                        CLog(@"%d, %@", code, led);
                    }
                }
                else if (code == kCode_GetExtenderTimer)
                {
                    TBXMLElement *element = [TBXML childElementNamed:kXML_NODE_WLAN
                                                       parentElement:tbxml.rootXMLElement];
                    if (element)
                    {
                        NSString *state = [TBXML valueOfAttributeNamed:kXML_ATTR_STATE
                                                            forElement:element];
                        NSString *timer = [TBXML valueOfAttributeNamed:kXML_ATTR_TIMER
                                                            forElement:element];
                        NSString *repeat = [TBXML valueOfAttributeNamed:kXML_ATTR_REPEAT
                                                             forElement:element];
                        
                        NSString *stime = nil;
                        NSString *etime = nil;
                        element = [TBXML childElementNamed:kXML_NODE_TIMER
                                             parentElement:element];
                        if (element)
                        {
                            stime = [TBXML valueOfAttributeNamed:kXML_ATTR_STIME
                                                      forElement:element];
                            etime = [TBXML valueOfAttributeNamed:kXML_ATTR_ETIME
                                                      forElement:element];
                        }
                        
                        NSDictionary *wlan = @{kXML_ATTR_STATE: state ? : @"0",
                                               kXML_ATTR_TIMER: timer ? : @"0",
                                               kXML_ATTR_REPEAT: repeat ? : @"0",
                                               kXML_ATTR_STIME: stime ? : @"0000",
                                               kXML_ATTR_ETIME: etime ? :@"0000"};
                        [Common setDefaultValueForKey:wlan Key:kXML_NODE_WLAN];
                        CLog(@"%d, %@", code, wlan);
                    }
                }
                else if ((code == kCode_GetLampName) || (code == kCode_GetBrightness))
                {
                    TBXMLElement *element = [TBXML childElementNamed:kXML_NODE_VALUE
                                                       parentElement:tbxml.rootXMLElement];
                    if (element)
                    {
                        NSString *info = [TBXML valueOfAttributeNamed:kXML_ATTR_CODE
                                                           forElement:element];
                        if (![info isEqualToString:kCODE_REQ_FAILED])
                        {
                            if (code == kCode_GetLampName)
                                [Common setDefaultValueForKey:info Key:kXML_ATTR_NAME];
                            else if (code == kCode_GetBrightness)
                                [Common setDefaultValueForKey:info Key:kXML_ATTR_BRIGHTNESS];
                            CLog(@"%d, %@", code, info);
                        }
                    }
                }
                else
                {
                    CLog(@"%i,%@", code,[NSString stringWithUTF8String:[data bytes]]);
                }
                [self performSelectorOnMainThread:@selector(reloadTableView)
                                       withObject:nil waitUntilDone:NO];
            }
            [tbxml release];
        }
    }
}
}

@end
