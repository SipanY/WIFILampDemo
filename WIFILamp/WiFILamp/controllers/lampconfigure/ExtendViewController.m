//
//  ExtendViewController.m
//  WiFiLamp
//
//  Created by Aniapp on 13-4-12.
//
//

#import "ExtendViewController.h"
#import "PickerViewController.h"
#import "DispatchCenter+Data.h"
#import "Common.h"
#import "GlobalDefines.h"
#import "TBXML.h"
#import "WaitingView.h"

@interface ExtendViewController ()<PickerViewControllerDelegate,
LANTransmissionDelegate>
{
    NSInteger _displayingDay;
    NSMutableDictionary *_dictTimerInfo;
    UIView *_containerView;
    PickerViewController *_pickerController;
    WaitingView *_waitingView;
    BOOL _isSleepMode;
}

@property (nonatomic, retain) NSMutableDictionary *dictTimerInfo;
@property (nonatomic, retain) IBOutlet UIView *containerView;
@property (nonatomic, retain) PickerViewController *pickerController;
@property (nonatomic, retain) IBOutlet UILabel *timerStateLabel;
@property (nonatomic, retain) IBOutlet UILabel *sleepStateLabel;
@property (nonatomic, retain) IBOutlet UIImageView *timerImageView;
@property (nonatomic, retain) IBOutlet UIImageView *sleepImageView;
@property (nonatomic, retain) IBOutlet UIButton *turnOnOffButton;

- (void)syncExtender;

- (void)showWaitingView:(NSString*)text;
- (void)hideWaitingView;
- (void)reloadSubViews;

@end

@implementation ExtendViewController

@synthesize dictTimerInfo = _dictTimerInfo;
@synthesize containerView = _containerView;
@synthesize pickerController = _pickerController;
@synthesize timerStateLabel = _timerStateLabel;
@synthesize sleepStateLabel = _sleepStateLabel;
@synthesize timerImageView = _timerImageView;
@synthesize sleepImageView = _sleepImageView;
@synthesize turnOnOffButton = _turnOnOffButton;

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

- (void)setButtonsInteractionEnabled
{
    if ([[Common defaultValueForKey:kXML_ATTR_IP]
         isEqualToString:@"192.168.137.1"]) // WIFI地址
    {
        for (UIView *view in self.view.subviews)
        {
            if ([view isKindOfClass:[UIButton class]] && (view.tag != 1000))
                [view setUserInteractionEnabled:NO];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self syncExtender];
//    [self setButtonsInteractionEnabled];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UIStatusBarStyle)preferredStatusBarStyle

{
    
    return UIStatusBarStyleLightContent;
    
}
- (BOOL)prefersStatusBarHidden

{
    
    return NO;
    
}

- (void)dealloc
{
    [_waitingView release];
    [_turnOnOffButton release];
    [_sleepImageView release];
    [_timerImageView release];
    [_sleepStateLabel release];
    [_timerStateLabel release];
    [_pickerController release];
    [_containerView release];
    [_dictTimerInfo release];
    [super dealloc];
}

#pragma mark - public methods

- (void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelButtonPressed:(id)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        _containerView.alpha = 0.0f;
    }];
}

- (void)turnOnOffButtonPressed:(id)sender
{
    [self showWaitingView:@""];
    NSDictionary *wlan = [Common defaultValueForKey:kXML_NODE_WLAN];
    NSString *value = ([wlan[kXML_ATTR_STATE] integerValue] == 1) ? @"0" : @"1";
    [self updateExtenderTimer:value repeat:@"0" stime:nil etime:nil];
}

- (void)sleepButtonPressed:(id)sender
{
    [(UIButton*)sender setUserInteractionEnabled:NO];
//    NSDictionary *wlan = [Common defaultValueForKey:kXML_NODE_WLAN];
//    if (([wlan[kXML_ATTR_STATE] integerValue] == 1) &&
//        ([wlan[kXML_ATTR_TIMER] integerValue] == 1) &&
//        ([wlan[kXML_ATTR_REPEAT] integerValue] == 1))
//    {
//        [self showWaitingView:nil];
//        [self updateExtenderTimer:@"0" repeat:@"1" stime:nil etime:nil];
//    }
//    else
//    {
        [UIView animateWithDuration:0.3 animations:^{
            _containerView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            _isSleepMode = YES;
            [self showPickerView:sender withType:PickerViewDouble];
        }];
//    }
    [(UIButton*)sender setUserInteractionEnabled:YES];
}

- (void)continueButtonPressed:(id)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        _containerView.alpha = 1.0f;
    }];
}

- (void)continueOnOffButtonPressed:(id)sender
{
    NSDictionary *wlan = [Common defaultValueForKey:kXML_NODE_WLAN];
    if (([wlan[kXML_ATTR_STATE] integerValue] == 1) &&
        ([wlan[kXML_ATTR_TIMER] integerValue] == 1) &&
        (([wlan[kXML_ATTR_REPEAT] integerValue] == 0) ||
         ([wlan[kXML_ATTR_REPEAT] integerValue] == 3)))
    {
        [self showWaitingView:nil];
        [self updateExtenderTimer:@"0" repeat:wlan[kXML_ATTR_REPEAT]
                            stime:nil etime:nil];
    }
}

- (void)sleepOnOffButtonPressed:(id)sender
{
    NSDictionary *wlan = [Common defaultValueForKey:kXML_NODE_WLAN];
    if (([wlan[kXML_ATTR_STATE] integerValue] == 1) &&
        ([wlan[kXML_ATTR_TIMER] integerValue] == 1) &&
        ([wlan[kXML_ATTR_REPEAT] integerValue] == 1))
    {
        [self showWaitingView:nil];
        [self updateExtenderTimer:@"0" repeat:@"1" stime:nil etime:nil];
    }
}

- (NSDictionary *)contextDataOfType:(TPickerViewType)type
{
    NSString *stime = @"2330";
    NSString *etime = @"0600";
    if (!_isSleepMode)
    {
        if (type == PickerViewSingle)
        {
            stime = @"0100";
            etime = @"0000";
        }
        else if (type == PickerViewDouble)
        {
            stime = @"0800";
            etime = @"1800";
        }
    }
    NSDictionary *wlan = [Common defaultValueForKey:kXML_NODE_WLAN];
    if (([wlan[kXML_ATTR_STIME] integerValue] != 0) ||
        ([wlan[kXML_ATTR_ETIME] integerValue] != 0))
    {
        stime = wlan[kXML_ATTR_STIME];
        etime = wlan[kXML_ATTR_ETIME];
    }

    return @{kXML_ATTR_STIME: stime, kXML_ATTR_ETIME: etime};
}

- (void)showPickerView:(id)sender withType:(TPickerViewType)type
{
    if (_pickerController == nil)
    {
        self.pickerController = viewController([PickerViewController class]);
        self.pickerController.delegate = self;
    }
    
    self.pickerController.contextData = [self contextDataOfType:type];
    
    if (!_pickerController.view.superview)
    {
        self.pickerController.type = type;
        self.pickerController.view.alpha = 0.0f;
        [self.view addSubview:_pickerController.view];
        [UIView animateWithDuration:0.3 animations:^{
            self.pickerController.view.alpha = 1.0f;
            [(UIButton*)sender setUserInteractionEnabled:YES];
        }];
    }
}

- (void)continueCycleButtonPressed:(id)sender
{
    [(UIButton*)sender setUserInteractionEnabled:NO];
    NSDictionary *wlan = [Common defaultValueForKey:kXML_NODE_WLAN];
    if (([wlan[kXML_ATTR_STATE] integerValue] == 1) &&
        ([wlan[kXML_ATTR_TIMER] integerValue] == 1) &&
        ([wlan[kXML_ATTR_REPEAT] integerValue] == 0))
    {
        [self showWaitingView:nil];
        [self updateExtenderTimer:@"0" repeat:@"0" stime:nil etime:nil];
    }
    else
    {
        [UIView animateWithDuration:0.3 animations:^{
            _containerView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            _isSleepMode = NO;
            [self showPickerView:sender withType:PickerViewDouble];
        }];
    }
    [(UIButton*)sender setUserInteractionEnabled:YES];
}

- (void)continueTimeButtonPressed:(id)sender
{
    [(UIButton*)sender setUserInteractionEnabled:NO];
    NSDictionary *wlan = [Common defaultValueForKey:kXML_NODE_WLAN];
    if (([wlan[kXML_ATTR_STATE] integerValue] == 1) &&
        ([wlan[kXML_ATTR_TIMER] integerValue] == 1) &&
        ([wlan[kXML_ATTR_REPEAT] integerValue] == 3))
    {
        [self showWaitingView:nil];
        [self updateExtenderTimer:@"0" repeat:@"3" stime:nil etime:nil];
    }
    else
    {
        [UIView animateWithDuration:0.3 animations:^{
            _containerView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            _isSleepMode = NO;
            [self showPickerView:sender withType:PickerViewSingle];
        }];
    }
    [(UIButton*)sender setUserInteractionEnabled:YES];
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

- (NSData *)extenderTimer:(NSString *)timer state:(NSString *)state
                   repeat:(NSString *)repeat stime:(NSString *)stime
                    etime:(NSString *)etime
{
    NSString *str = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                     "<xml> <wlan state=\"%@\" timer=\"%@\" repeat =\"%@\" />"
                     "<timer stime=\"%@\" etime=\"%@\"/> </xml>",
                     state, timer, repeat, stime, etime];
    return [NSData dataWithBytes:[str UTF8String] length:[str length]];
}

- (void)updateExtenderTimer:(NSString *)state repeat:(NSString *)repeat
                      stime:(NSString *)stime etime:(NSString *)etime
{
    repeat = repeat ? : @"0";
    stime = stime ? : @"0000";
    etime = etime ? : @"0000";
    NSString *timer = ([state integerValue] == 1) ? @"1" : @"0";
    NSData *data = [self extenderTimer:timer state:state repeat:repeat stime:stime etime:etime];
    [DispatchManager sendData:data code:kCode_SetExtenderTimer userInfo:nil];
}

- (void)syncExtender
{
    [DispatchManager sendData:[NSData data] code:kCode_GetExtenderTimer userInfo:nil];
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

- (void)reloadSubViews
{
    NSDictionary *wlan = [Common defaultValueForKey:kXML_NODE_WLAN];
    BOOL enabledContinue = (([wlan[kXML_ATTR_STATE] integerValue] == 1) &&
                            ([wlan[kXML_ATTR_TIMER] integerValue] == 1) &&
                            (([wlan[kXML_ATTR_REPEAT] integerValue] == 0) ||
                             ([wlan[kXML_ATTR_REPEAT] integerValue] == 3)));
    _timerStateLabel.text = enabledContinue ? @"开" : @"关";
    _timerImageView.image = [UIImage imageNamed:enabledContinue ?
                             @"icon_home_hot.png" : @"icon_home.png"];
    
    BOOL enabledSleep = (([wlan[kXML_ATTR_STATE] integerValue] == 1) &&
                         ([wlan[kXML_ATTR_TIMER] integerValue] == 1) &&
                         ([wlan[kXML_ATTR_REPEAT] integerValue] == 1));
    NSString *stime = [self formatTime:wlan[kXML_ATTR_STIME]] ? : @"23:30";
    NSString *etime = [self formatTime:wlan[kXML_ATTR_ETIME]] ? : @"06:00";
    NSString *time = [NSString stringWithFormat:@"%@-%@", stime, etime];
    
    _sleepStateLabel.text = enabledSleep ? time : @"关";
    _sleepImageView.image = [UIImage imageNamed:enabledSleep ?
                             @"icon_sleep_hot.png" : @"icon_sleep.png"];
    
    NSString *value = ([wlan[kXML_ATTR_STATE] integerValue] == 1) ?
    @"btn_wifi_on.png" : @"btn_wifi_off.png";
    [_turnOnOffButton setBackgroundImage:[UIImage imageNamed:value]
                                forState:UIControlStateNormal];
}

#pragma mark - PickerViewControllerDelegate

- (void)pickerView:(PickerViewController *)pvc didSelectedData:(id)data
{
    [self showWaitingView:@""];
    
    if (_isSleepMode)
    {
        if (pvc.type == PickerViewDouble)
        {
            [self updateExtenderTimer:@"1" repeat:@"1"
                                stime:data[kXML_ATTR_STIME]
                                etime:data[kXML_ATTR_ETIME]];
        }
    }
    else
    {
        if (pvc.type == PickerViewSingle)
        {
            [self updateExtenderTimer:@"1" repeat:@"3"
                                stime:nil etime:data[kXML_ATTR_STIME]];
        }
        else if (pvc.type == PickerViewDouble)
        {
            [self updateExtenderTimer:@"1" repeat:@"0" stime:data[kXML_ATTR_STIME]
                                etime:data[kXML_ATTR_ETIME]];
        }
    }
    CLog(@"%@", data);
}

#pragma mark - LANTransmissionDelegate

- (void)processRecvData:(NSDictionary *)dict
{
    if ([dict count] > 0)
    {
        NSNumber *number = [[dict allKeys] objectAtIndex:0];
        NSInteger code = [number unsignedCharValue];
        NSData *data = [[dict allValues] objectAtIndex:0];
        
        if (data && ((code == kCode_GetExtenderTimer) || (code == kCode_SetExtenderTimer)))
        {
            [self hideWaitingView];
            
            NSError *error;
            TBXML *tbxml = [[TBXML alloc] initWithXMLData:data error:&error];
            if (tbxml && !error)
            {
                if (code == kCode_GetExtenderTimer)
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
                    [self reloadSubViews];
                }
                else if (code == kCode_SetExtenderTimer)
                {
                    TBXMLElement *element = [TBXML childElementNamed:kXML_NODE_VALUE
                                                       parentElement:tbxml.rootXMLElement];
                    if (element)
                    {
                        NSString *info = [TBXML valueOfAttributeNamed:kXML_ATTR_CODE
                                                           forElement:element];
                        if (![info isEqualToString:kCODE_REQ_FAILED])
                        {
                            [self syncExtender];
                            CLog(@"%d, %@", code, info);
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
