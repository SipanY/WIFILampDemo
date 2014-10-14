

#import "DevicesViewController.h"
#import "SettingsViewController.h"
#import "DispatchCenter+Data.h"
#import "GlobalDefines.h"
#import "WaitingView.h"
#import "MainCell.h"
#import "Common.h"
#import "ZHClient.h"
#import "TBXML.h"
#import "AppDelegate.h"
@interface DevicesViewController ()
{
    LANTransmission *_lanTransmission;
    dispatch_semaphore_t _semKeepAlive;
    
    WaitingView *_waitingView;
}

@property (nonatomic, copy) NSArray *devicesList;

- (void)showWaitingView:(NSString*)text;
- (void)hideWaitingView;
- (void)reloadTableView;

@end

@implementation DevicesViewController

@synthesize devicesList = _devicesList;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self refreshButtonPressed:nil];
    
    
    
}

- (UIStatusBarStyle)preferredStatusBarStyle

{
    
    return UIStatusBarStyleLightContent;
    
}
- (BOOL)prefersStatusBarHidden

{
    
    return NO;
    
}

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
    [_devicesList release];
    [_waitingView release];
    [_lanTransmission release];
    [super dealloc];
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
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
   
}
- (void)hideWaitingView
{
    [_waitingView hide];
}

- (void)backButtonPressed:(id)sender
{
//    if ([DispatchManager isConnected])
//    {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
//    else
//    {
//        if (![Common defaultValueForKey:kXML_ATTR_IP])
//        {
//            exit(0);
//        }
//    }
//    AppDelegate *app = [UIApplication sharedApplication].delegate;
//    UIWindow *window = app.window;
//    
//    [UIView animateWithDuration:0.3f animations:^{
//    window.alpha = 0;
//            window.frame = CGRectMake(0, window.bounds.size.width, 0, 0);
//          } completion:^(BOOL finished) {
//                exit(0);
//              }];

    
    
}

- (void)refreshButtonPressed:(id)sender
{
    //[self showWaitingView:nil];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
     // self.view.frame=CGRectMake(0, 20, 320, 600);
    //[BPStatusBar showActivityWithStatus:@"寻找台灯..."];
        [self waitingForBroadcast:10];
}

#pragma mark - WiFiViewControllerDelegate

- (NSData*)currentTime
{
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *str = [formatter stringFromDate:[NSDate date]];
    str = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
           "<xml> <value code=\"%@\" /> </xml>", str];
    return [NSData dataWithBytes:[str UTF8String] length:[str length]];
}

- (void)broadcastCompleted
{
    [DispatchManager stopBroadcast];
    [self hideWaitingView];
    
    if ([DispatchManager.devicesList count] > 0)
    {
        self.devicesList = DispatchManager.devicesList;
        if (self.devicesList.count==1) {//搜索到一个设备是直接连接
            NSDictionary *deviceInfo = _devicesList[0];
            if ([[deviceInfo objectForKey:@"ifused"]isEqualToString:@"0"])
            {
                [self showWaitingView:@""];
                [DispatchManager stopConnect];
                [DispatchManager startConnect:deviceInfo[kXML_ATTR_IP]];
                [Common setDefaultValueForKey:deviceInfo[kXML_ATTR_IP]
                                          Key:kXML_ATTR_IP];
            }
            
        }
       else [self reloadTableView];
    }
    else
    {
        if (![DispatchManager isConnected])
        {
            [DispatchManager showWiFiConfigureView:nil];
        }
    }
}

- (void)waitingForBroadcast:(NSUInteger)times
{
    [DispatchManager startBroadcast];
    
    void (^task)(void) = ^{
        
        NSDate *sDate = [NSDate date];
        do
        {
            NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:sDate];
            if (interval >= times) break;
            [NSThread sleepForTimeInterval:1];
            
        } while (1);
        
        [self performSelectorOnMainThread:@selector(broadcastCompleted)
                               withObject:nil
                            waitUntilDone:NO];
    };
    
    dispatch_queue_t queue = dispatch_queue_create("waiting", NULL);
    dispatch_async(queue, task);
    dispatch_release(queue);
}

#pragma mark - UITableViewDataSource/UITableViewDelegate

- (NSUInteger)numberOfRows
{
    return [_devicesList count];
}

- (void)reloadTableView
{   [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
   // [BPStatusBar showSuccessWithStatus:@"查找成功"];
    for (UIView *view in self.view.subviews)
    {
        if ([view isKindOfClass:[UITableView class]])
        {
            [(UITableView*)view reloadData];
            break;
        }
    }
    self.view.frame=CGRectMake(0, 0, 320, 600);
   // [BPStatusBar dismiss];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self numberOfRows];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    //[BPStatusBar dismiss];
}
- (void)loadCell:(MainCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    NSString *title = @"";
    UIColor *titleColor = colorWithRGBGA(157, 162, 170, 255);
    NSString *imageNamed = @"icon_lamp.png";
    NSString *imageNamed_hot = @"icon_lamp_hot.png";
    CGRect iconFrame = cell.iconImageView.frame;
    CGRect titleFrame = cell.titleLabel.frame;
   
    NSInteger lastIndex = [self numberOfRows] +1;
    if (row != lastIndex)
    {
        NSDictionary *deviceInfo = _devicesList[row];
        CLog(@"%@",[deviceInfo objectForKey:@"ifused"]);
        title = deviceInfo[kXML_ATTR_NAME];
        iconFrame.origin.x = 10;
        titleFrame.origin.x = CGRectGetMaxX(iconFrame);
        //NSDictionary *ddeviceInfo = _devicesList[indexPath.row];
       

    }
    else
    {
//        imageNamed = @"icon_add.png";
//        imageNamed_hot = @"icon_hot.png";
//        titleColor = colorWithRGBGA(255, 144, 0, 255);
//        title = @"添加新设备";
//        iconFrame.origin.x = 100;
//        titleFrame.origin.x = CGRectGetMaxX(iconFrame);
    }
    
    [cell.iconImageView setImage:[UIImage imageNamed:imageNamed]];
    [cell.iconImageView setHighlightedImage:[UIImage imageNamed:imageNamed_hot]];
    [cell.iconImageView setFrame:iconFrame];
    [cell.titleLabel setText:title];
    [cell.titleLabel setTextColor:titleColor];
    [cell.titleLabel setFrame:titleFrame];
    NSDictionary *deviceInfo = _devicesList[row];
    if ([[deviceInfo objectForKey:@"ifused"]isEqualToString:@"0"]) {
        [cell.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{   //static int i=0;
    static NSString *cellIdentifier = @"SubIdentifier";
    MainCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"MainCell" owner:self options:nil];
        if ([array count] > 1)
        {
            cell = [array objectAtIndex:1];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
            [cell setBackgroundColor:[UIColor clearColor]];
            
            UIImageView *imageView = [[[UIImageView alloc]initWithFrame:cell.bounds] autorelease];
            imageView.image = [UIImage imageNamed:@"com_cell_bg_hot.png"];
            [cell setSelectedBackgroundView:imageView];
            imageView = [[[UIImageView alloc]initWithFrame:cell.bounds] autorelease];
            imageView.image = [UIImage imageNamed:@"com_cell_bg.png"];
            [cell setBackgroundView:imageView];
            
  
//            NSDictionary *deviceInfo = _devicesList[i];
//           if ([[deviceInfo objectForKey:@"ifused"]isEqualToString:@"0"]) {//?
//               cell.isUsed.text=@"有人使用";
//           }
//
        }
    }
    //i++;
    
    [self loadCell:(MainCell*)cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    NSInteger lastIndex = [self numberOfRows] +1;
    if ([indexPath row] != lastIndex)
    {
        NSDictionary *deviceInfo = _devicesList[row];
        if ([deviceInfo[kXML_ATTR_IP] length] > 0&&[[deviceInfo objectForKey:@"ifused"]isEqualToString:@"0"])
        {
            [self showWaitingView:@""];
            [DispatchManager stopConnect];
            [DispatchManager startConnect:deviceInfo[kXML_ATTR_IP]];
            [Common setDefaultValueForKey:deviceInfo[kXML_ATTR_IP]
                                      Key:kXML_ATTR_IP];
        }
        else{
//             [ KGStatusBar showErrorWithStatus:@"有设备正在使用!"];
//            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarStyleDefault];
            

        }
    }
    else
    {
       // [DispatchManager showWiFiConfigureView:nil];
       // [ KGStatusBar showErrorWithStatus:@"有设备正在使用!"];

        
    }
//    //begin
//     NSDictionary *deviceInfo = _devicesList[row];
//    if ([[deviceInfo objectForKey:@"ifused"]isEqualToString:@"0"]) {//?
//       [ KGStatusBar showErrorWithStatus:@"有设备正在使用!"];
//    }
//   else
//       //end
   {[tableView deselectRowAtIndexPath:indexPath animated:YES];}
}

#pragma mark - LANTransmissionDelegate

- (void)lanTransmissionConnected:(LANTransmission *)lanTransmission
{
    [self performSelectorOnMainThread:@selector(hideWaitingView)
                           withObject:nil waitUntilDone:NO];
}

- (void)lanTransmissionDisconnect:(LANTransmission *)lanTransmission
{
    [self performSelectorOnMainThread:@selector(hideWaitingView)
                           withObject:nil waitUntilDone:NO];
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
            if (data == nil) return ;
#ifdef DEBUG
            if (code != kCode_KeepAlive)
            {
                NSLog(@"[processedPacket] code = %d \n %@", code,
                      [NSString stringWithCString:[data bytes] encoding:NSUTF8StringEncoding]);
            }
#endif
        }
    }
}

@end
