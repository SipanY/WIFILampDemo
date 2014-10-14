//
//  UpgradeViewController.m
//  WiFiLamp
//
//  Created by Aniapp on 14-3-13.
//
//

#import "UpgradeViewController.h"
#import "GlobalDefines.h"
#import "TBXML.h"
#import "Common.h"
#import "WaitingView.h"
#import "DispatchCenter+Data.h"
#import "NSString+SBJSON.h"

#define kNewestVersion @"newestVersion"
#define kFileURL @"file_url"
static int itiel=0;

@interface UpgradeViewController ()<LANTransmissionDelegate,
NSURLConnectionDataDelegate>
{
    WaitingView *_waitingView;
    
}

@property (nonatomic, retain) IBOutlet UILabel *currentVerLabel;
@property (nonatomic, retain) IBOutlet UILabel *latestVerLabel;
@property (nonatomic, retain) IBOutlet UIButton *updateButton;

- (void)syncLampVersion;
- (void)reloadSubviews;

@end

@implementation UpgradeViewController

@synthesize currentVerLabel = _currentVerLabel;
@synthesize latestVerLabel = _latestVerLabel;
@synthesize updateButton = _updateButton;

- (void)dealloc
{
    [_updateButton release];
    [_latestVerLabel release];
    [_currentVerLabel release];
    [_waitingView release];
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [_progressView setProgress:0.0f];
        
        
        
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
    _progressView.hidden=YES;
    
    [Common removeDefaultForKey:kNewestVersion];
    [Common removeDefaultForKey:kFileURL];
    [self reloadSubviews];
    [self syncLampVersion];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    //[self showWaitingView:nil];
    [DispatchManager sendData:[NSData data] code:kCode_GetVersion userInfo:nil];
    [DispatchManager sendData:[NSData data] code:kCode_GetMacAddress userInfo:nil];
}

- (void)updateNewestVersion
{
    [self showWaitingView:nil];
    
    NSString *mac = [Common defaultValueForKey:kXML_ATTR_MAC];
    NSString *version = [Common defaultValueForKey:kXML_ATTR_VERSION];
    if (mac && version)
    {
        NSString *url = [NSString stringWithFormat:@"http://42.121.125.94/socket/"
                         "firmware_update?socket_id=%@&firmware_version=%@&device=smartled", mac, version];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
        [connection start];
    }
}

- (NSData*)updateFileURL:(NSString*)urlString
{
    NSString *str = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                     "<xml> <value code=\"%@\" /> </xml>", urlString];
    return [NSData dataWithBytes:[str UTF8String] length:[str length]];
}

- (void)updateFirmware
{
   // [self showWaitingView:nil];
    
    NSString *fileURL = [Common defaultValueForKey:kFileURL];
    NSLog(@"%@",fileURL);
    [DispatchManager sendData:[self updateFileURL:fileURL]
                         code:kCode_Update userInfo:nil];
}

- (void)reloadSubviews
{
    _currentVerLabel.text = [NSString stringWithFormat:@"当前版本：%@",
                             [Common defaultValueForKey:kXML_ATTR_VERSION]];
    _latestVerLabel.text = [NSString stringWithFormat:@"最新版本：%@",
                            [Common defaultValueForKey:kNewestVersion] ? :
                            [Common defaultValueForKey:kXML_ATTR_VERSION]];
    
    if ([Common defaultValueForKey:kNewestVersion] &&
        [Common defaultValueForKey:kFileURL])
    {
        _updateButton.enabled = YES;
    }
}

#pragma mark - public methods

- (void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneButtonPressed:(id)sender
{
    _progressView.hidden=NO;
    UIButton *button = (UIButton*)sender;
    button.enabled = NO;
    _loopTimer=[NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(checkUpdate) userInfo:nil repeats:YES];
    [self updateFirmware]; //更新固件
}
-(void)checkUpdate{
        [DispatchManager sendData:[NSData data] code:52];
    ++itiel;
    if (_temp==7) {
        [_loopTimer invalidate];
    }
    
    int temp=(itiel%10);
    
    float a=(float)(_temp/7.0);
    a+=temp;

     [_progressView setProgress:a animated:YES];
   // [self performSelectorOnMainThread:@selector(progressUpdate:) withObject:i waitUntilDone:NO];
}
-(void)progressUpdate:(id) i{
    NSNumber *ii=i;
    float iii=[ii floatValue];
   // CLog(@"\n\n\n /n/n %f",iii);
    [_progressView setProgress:iii animated:YES];
}
#pragma mark - LANTransmissionDelegate

- (void)processRecvData:(NSDictionary *)dict
{
    if ([dict count] > 0)
    {
        NSNumber *number = [[dict allKeys] objectAtIndex:0];
        NSInteger code = [number unsignedCharValue];
        NSData *data = [[dict allValues] objectAtIndex:0];
        CLog(@",%i,%@,,",code,[NSString stringWithUTF8String:[data bytes]]);
        if (data && ((code == kCode_GetVersion) || (code == kCode_GetMacAddress)|| (code == kCode_UpdateStatus)))
        {
            [self hideWaitingView];
            
            NSError *error;
            TBXML *tbxml = [[TBXML alloc] initWithXMLData:data error:&error];
            if (tbxml && !error)
            {
                if ((code == kCode_GetVersion) || (code == kCode_GetMacAddress)||(code == kCode_UpdateStatus))
                {
                    TBXMLElement *element = [TBXML childElementNamed:kXML_NODE_VALUE
                                                       parentElement:tbxml.rootXMLElement];
                    if (element)
                    {
                        NSString *info = [TBXML valueOfAttributeNamed:kXML_ATTR_CODE
                                                           forElement:element];
                        if (![info isEqualToString:kCODE_REQ_FAILED])
                        {
                            if (code == kCode_GetVersion)
                            {
                                [Common setDefaultValueForKey:info Key:kXML_ATTR_VERSION];
                            }
                            if (code==kCode_UpdateStatus) {
                               
                                
                                self.temp=[info intValue];
                                
                            }
                            else if (code == kCode_GetMacAddress)
                            {
                                [Common setDefaultValueForKey:info Key:kXML_ATTR_MAC];
                                [self updateNewestVersion];
                            }
                            CLog(@"%d, %@", code, info);
                        }
                    }
                    [self reloadSubviews];
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

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self hideWaitingView];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
{
    NSString *value = [NSString stringWithUTF8String:[data bytes]];
    id jsonValue = [value JSONFragmentValue];
    if ([jsonValue isKindOfClass:[NSDictionary class]])
    {
        if ([(NSDictionary*)jsonValue count] > 0)
        {
            NSString *newestVersion = ((NSDictionary*)jsonValue)[@"firmware_version"];
            NSString *fileURL = ((NSDictionary*)jsonValue)[@"file_url"];
            if (newestVersion && fileURL)
            {
                [Common setDefaultValueForKey:newestVersion Key:kNewestVersion];
                [Common setDefaultValueForKey:fileURL Key:kFileURL];
                [self performSelectorOnMainThread:@selector(reloadSubviews)
                                       withObject:nil waitUntilDone:NO];
            }
        }
    }
}
- (UIStatusBarStyle)preferredStatusBarStyle

{
    
    return UIStatusBarStyleLightContent;
    
}
- (BOOL)prefersStatusBarHidden

{
    
    return NO;
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self hideWaitingView];
}

@end
