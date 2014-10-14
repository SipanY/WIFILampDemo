//
//  SettingsViewController.m
//  WiFiLamp
//
//  Created by Aniapp on 12-9-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "EditViewController.h"
#import "DispatchCenter+Data.h"
#import "GlobalDefines.h"
#import "MainCell.h"
#import "TBXML.h"
#import "Common.h"
#import "WaitingView.h"

@interface SettingsViewController ()<LANTransmissionDelegate>
{
    UITableView *_tvSettings;
    WaitingView *_waitingView;
}

@property (nonatomic, retain) IBOutlet UITableView *tvSettings;

- (void)showWaitingView:(NSString*)text;
- (void)hideWaitingView;
- (void)reloadTableView;

- (void)syncLampVersion;

@end

@implementation SettingsViewController

@synthesize tvSettings = _tvSettings;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self syncLampVersion];
    [self reloadTableView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
    [_waitingView release];
    [_tvSettings release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

- (void)syncLampVersion
{
    [self showWaitingView:nil];
    [DispatchManager sendData:[NSData data] code:kCode_GetVersion userInfo:nil];
    [DispatchManager sendData:[NSData data] code:kCode_GetExtenderState userInfo:nil];
}

#pragma mark - tableView

- (NSUInteger)numberOfRows
{
    return 5;
}

- (void)reloadTableView
{
    [_tvSettings reloadData];
}
- (UIStatusBarStyle)preferredStatusBarStyle

{
    
    return UIStatusBarStyleLightContent;
    
}
- (BOOL)prefersStatusBarHidden

{
    
    return NO;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self numberOfRows];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)loadCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    NSString *title = @"";
    NSString *desc = nil;
    NSString *iconName = nil;
    NSString *iconName_hot = nil;
    
    if (row == 0)
    {
        title = @"台灯名称";
        iconName = @"icon_alias.png";
        iconName_hot = @"icon_alias_hot.png";
        desc = [Common defaultValueForKey:kXML_ATTR_NAME];
    }
    else if (row == 1)
    {
        title = @"当前连接WiFi";
        iconName = @"icon_trans.png";
        iconName_hot = @"icon_trans_hot.png";
        desc = [Common defaultValueForKey:kXML_ATTR_SSID];
    }
    else if (row == 2)
    {
        title = @"版本号";
        iconName = @"icon_version.png";
        iconName_hot = @"icon_version_hot.png";
        desc = [Common defaultValueForKey:kXML_ATTR_VERSION];
    }
    else if (row == 3)
    {
        title = @"检查更新";
        iconName = @"icon_refresh.png";
        iconName_hot = @"icon_refresh_hot.png";
        desc = @"";
    }
    else if (row==4)
    {
    title=@"设置密码";
        iconName = @"icon_refresh.png";
        iconName_hot = @"icon_refresh_hot.png";
        desc=@"";
        
    }
    
    [cell.imageView setImage:[UIImage imageNamed:iconName]];
    [cell.imageView setHighlightedImage:[UIImage imageNamed:iconName_hot]];
    [cell.textLabel setText:title];
    [cell.textLabel setTextColor:colorWithRGBGA(140, 140, 140, 255)];
    [cell.detailTextLabel setText:desc];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SubIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                       reuseIdentifier:cellIdentifier] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        UIImageView *imageView = [[[UIImageView alloc]initWithFrame:cell.bounds] autorelease];
        imageView.image = [UIImage imageNamed:@"com_cell_bg_hot.png"];
        [cell setSelectedBackgroundView:imageView];
        imageView = [[[UIImageView alloc]initWithFrame:cell.bounds] autorelease];
        imageView.image = [UIImage imageNamed:@"com_cell_bg.png"];
        [cell setBackgroundView:imageView];
    }
    
    [self loadCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    if (row == 0)
    {
        [DispatchManager showEditView];
    }
    else if (row == 1)
    {
        [DispatchManager showWiFiConfigureView:self];
         [DispatchManager showWiFiConfigureView:nil];
    }
    else if (row == 3)
    {
        [DispatchManager showUpgradeView];
    }
    else if(row==4){
        [DispatchManager showPassWordView];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - public methods

- (IBAction) backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - LANTransmissionDelegate

- (void)processRecvData:(NSDictionary *)dict
{
    if ([dict count] > 0)
    {
        NSNumber *number = [[dict allKeys] objectAtIndex:0];
        NSInteger code = [number unsignedCharValue];
        NSData *data = [[dict allValues] objectAtIndex:0];
        
        if (data && ((code == kCode_GetVersion) || (code == kCode_GetExtenderState)))
        {
            [self hideWaitingView];
            
            NSError *error;
            TBXML *tbxml = [[TBXML alloc] initWithXMLData:data error:&error];
            if (tbxml && !error)
            {
                if (code == kCode_GetVersion)
                {
                    TBXMLElement *element = [TBXML childElementNamed:kXML_NODE_VALUE
                                                       parentElement:tbxml.rootXMLElement];
                    if (element)
                    {
                        NSString *info = [TBXML valueOfAttributeNamed:kXML_ATTR_CODE
                                                           forElement:element];
                        if (![info isEqualToString:kCODE_REQ_FAILED])
                        {
                            [Common setDefaultValueForKey:info Key:kXML_ATTR_VERSION];
                        }
                        [self reloadTableView];
                        
                    }
                }
                else if (code == kCode_GetExtenderState)
                {
                    TBXMLElement *element = [TBXML childElementNamed:kXML_NODE_WIFI
                                                       parentElement:tbxml.rootXMLElement];
                    NSString *passWord=[[NSString alloc]init];
                    if (element)
                    {
                        element = [TBXML childElementNamed:kXML_NODE_WLAN
                                             parentElement:element];
                        
                        if (element)
                        {
                            NSString *info = [TBXML valueOfAttributeNamed:kXML_ATTR_RSSI
                                                               forElement:element];
                            
                            passWord=[TBXML valueOfAttributeNamed:@"pwd" forElement:element];
                            NSString *ssid = [TBXML valueOfAttributeNamed:kXML_ATTR_SSID
                                                               forElement:element];
                            [Common removeDefaultForKey:kXML_ATTR_SSID];
                            [Common setDefaultValueForKey:ssid Key:kXML_ATTR_SSID];
                            CLog(@"%@ ->%@",passWord,[Common defaultValueForKey:kXML_ATTR_SSID]);
                            [Common removeDefaultForKey:kXML_LAMP_PASSWORD];
                            [Common setDefaultValueForKey:passWord Key:kXML_LAMP_PASSWORD];
                           // [[NSUserDefaults standardUserDefaults] stringForKey:kXML_LAMP_PASSWORD];
                            //CLog(@"%@", [[NSUserDefaults standardUserDefaults] stringForKey:kXML_LAMP_PASSWORD] )  ;
                            //[passWord release];
                            if (![info isEqualToString:kCODE_REQ_FAILED])
                            {
                                if ([info length] == 0)
                                {
                                    info = [TBXML valueOfAttributeNamed:kXML_ATTR_SSID
                                                             forElement:element];
                                }
                               
//                                [Common setDefaultValueForKey:info Key:kXML_ATTR_SSID];
//                                CLog(@"%@",[Common defaultValueForKey:kXML_ATTR_SSID]);
                                [self reloadTableView];
                                                            }
                        }
                    }
                }
            }
            [tbxml release];
        }
    }
}

- (void)lanTransmission:(LANTransmission *)lanTransmission
               recvData:(NSDictionary *)dict
{
    [self performSelectorOnMainThread:@selector(processRecvData:)
                           withObject:dict waitUntilDone:NO];
}

- (void)lanTransmissionDisconnect:(LANTransmission *)lanTransmission
{
    [self performSelectorOnMainThread:@selector(hideWaitingView)
                           withObject:nil waitUntilDone:NO];
}

@end
