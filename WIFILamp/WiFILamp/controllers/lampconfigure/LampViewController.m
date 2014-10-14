//
//  LampViewController.m
//  WiFiLamp
//
//  Created by Aniapp on 13-4-12.
//
//

#import "LampViewController.h"
#import "MainCell.h"
#import "GlobalDefines.h"
#import "Common.h"
#import "TBXML.h"
#import "PickerViewController.h"
#import "DispatchCenter+Data.h"
#import "WaitingView.h"

@interface LampViewController ()<LANTransmissionDelegate,
PickerViewControllerDelegate>
{
    PickerViewController *_pickerController;
    NSUInteger _brightness;
    WaitingView *_waitingView;
    UIPanGestureRecognizer *_panGestureRecognizer;
}

@property (nonatomic, retain) PickerViewController *pickerController;
@property (nonatomic, retain) IBOutlet UILabel *timerStateLabel;
@property (nonatomic, retain) IBOutlet UILabel *holidayStateLabel;
@property (nonatomic, retain) IBOutlet UIImageView *timerImageView;
@property (nonatomic, retain) IBOutlet UIImageView *holidayImageView;
@property (nonatomic, retain) IBOutlet UIImageView *progressImageView;

- (void)syncLampTimer;
- (void)syncLampBrightness;

- (void)showWaitingView:(NSString*)text;
- (void)hideWaitingView;
- (void)reloadSubviews;
- (void)reloadBrightnessView;

@end

@implementation LampViewController

@synthesize pickerController = _pickerController;
@synthesize timerStateLabel = _timerStateLabel;
@synthesize holidayStateLabel = _holidayStateLabel;
@synthesize timerImageView = _timerImageView;
@synthesize holidayImageView = _holidayImageView;
@synthesize progressImageView = _progressImageView;

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
    [self.progressImageView setUserInteractionEnabled:YES];
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    [self.progressImageView addGestureRecognizer:_panGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self syncLampTimer];
    [self syncLampBrightness];
}

static float startAngle;

- (float)calculateDistance:(CGPoint)center toPoint:(CGPoint)point {
    
	float dx = point.x - center.x;
	float dy = point.y - center.y;
	return sqrt(dx*dx + dy*dy);
}

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)panGR
{
    if (panGR.state == UIGestureRecognizerStateBegan)
    {
        CGPoint center = [self.view convertPoint:_progressImageView.center
                                         toView:_progressImageView];
        CGPoint point = [panGR locationInView:_progressImageView];
        startAngle = atan2(point.y - center.y, point.x - center.x);
    }
    
    CGAffineTransform oldTransform = _progressImageView.transform;
    _progressImageView.transform = CGAffineTransformIdentity;
    CGPoint center = [self.view convertPoint:_progressImageView.center
                                      toView:_progressImageView];
    CGPoint point = [panGR locationInView:_progressImageView];
    
	float angle = atan2(point.y - center.y, point.x - center.x) - startAngle;
    if ((angle >= 0) || (angle <= -1.1))
    {
        _progressImageView.transform = CGAffineTransformMakeRotation(angle);
        
        NSUInteger _currBrightness = _brightness;
        if (angle > 0)
            _currBrightness = (int)(angle * 100 / 490 * 50);
        else if (angle < 0)
            _currBrightness = (int)(((angle + 6) * 100 / 490 * 50) + 0.5);
        
        if (_brightness != _currBrightness)
        {
            _brightness = (_currBrightness < 2) ? 0 : _currBrightness;
            [self updateLampBrightness];
        }
    }
    else
    {
        _progressImageView.transform = oldTransform;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [_waitingView release];
    [_progressImageView removeGestureRecognizer:_panGestureRecognizer];
    [_panGestureRecognizer release];
    [_progressImageView release];
    [_holidayImageView release];
    [_timerImageView release];
    [_holidayStateLabel release];
    [_timerStateLabel release];
    [_pickerController release];
    [super dealloc];
}

- (void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSDictionary *)contextDataOfType:(TPickerViewType)type
{
    NSString *stime = @"1830";
    NSString *etime = @"2330";
    NSDictionary *led = [Common defaultValueForKey:kXML_NODE_LED];
    if (([led[kXML_ATTR_STIME] integerValue] != 0) ||
        ([led[kXML_ATTR_ETIME] integerValue] != 0))
    {
        stime = led[kXML_ATTR_STIME];
        etime = led[kXML_ATTR_ETIME];
    }
    
    return @{kXML_ATTR_STIME: stime, kXML_ATTR_ETIME: etime};
}

- (void)showPickerView:(id)sender
{
    if (_pickerController == nil)
    {
        self.pickerController = viewController([PickerViewController class]);
    }
    
    self.pickerController.contextData = [self contextDataOfType:PickerViewDouble];

    self.pickerController.delegate = self;
    if (!_pickerController.view.superview)
    {
        self.pickerController.view.alpha = 0.0f;
        [self.view addSubview:_pickerController.view];
        [UIView animateWithDuration:0.3 animations:^{
            self.pickerController.view.alpha = 1.0f;
            [(UIButton*)sender setUserInteractionEnabled:YES];
        }];
    }
}

- (void)scheduleButtonPressed:(id)sender
{
    [(UIButton*)sender setUserInteractionEnabled:NO];
//    NSDictionary *led = [Common defaultValueForKey:kXML_NODE_LED];
//    if (([led[kXML_ATTR_REPEAT] integerValue] == 2) ||
//        ([led[kXML_ATTR_TIMER] integerValue] == 0) ||
//        (([led[kXML_ATTR_STIME] integerValue] == 0) &&
//         ([led[kXML_ATTR_ETIME] integerValue] == 0)))
//    {
        [self showPickerView:sender];
//    }
//    else
//    {
//        [self showWaitingView:@""];
//        [self updateLampTimer:@"0" stime:nil etime:nil];
//    }
    [(UIButton*)sender setUserInteractionEnabled:YES];
}

- (void)holidayButtonPressed:(id)sender
{
    NSDictionary *led = [Common defaultValueForKey:kXML_NODE_LED];
    NSString *repeat = ([led[kXML_ATTR_REPEAT] integerValue] == 2) ? @"0" : @"2";
    [self updateLampTimer:repeat stime:nil etime:nil];
}

- (void)scheduleOffOnButtonPressed:(id)sender
{
    NSDictionary *led = [Common defaultValueForKey:kXML_NODE_LED];
    if (!(([led[kXML_ATTR_REPEAT] integerValue] == 2) ||
          ([led[kXML_ATTR_TIMER] integerValue] == 0) ||
          (([led[kXML_ATTR_STIME] integerValue] == 0) &&
           ([led[kXML_ATTR_ETIME] integerValue] == 0))))
    {
        [self showWaitingView:@""];
        [self updateLampTimer:@"0" stime:nil etime:nil];
    }
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

- (void)syncLampTimer
{
    [DispatchManager sendData:[NSData data] code:kCode_GetLampTimer userInfo:nil];
}

- (void)syncLampBrightness
{
    [DispatchManager sendData:[NSData data] code:kCode_GetBrightness userInfo:nil];
}

- (NSData *)lampTimer:(NSString *)timer repeat:(NSString *)repeat
                stime:(NSString *)stime etime:(NSString *)etime
{
    NSString *str = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
           "<xml> <led timer=\"%@\" repeat =\"%@\" /><timer stime=\"%@\" etime=\"%@\"/> </xml>",
                     timer, repeat, stime, etime];
    return [NSData dataWithBytes:[str UTF8String] length:[str length]];
}

- (void)updateLampTimer:(NSString *)repeat stime:(NSString *)stime
                  etime:(NSString *)etime
{
    repeat = repeat ? : @"0";
    stime = stime ? : @"0000";
    etime = etime ? : @"0000";
    BOOL enabledTimer = ((([stime integerValue] != 0) && ([etime integerValue] != 0)) ||
                         ([repeat integerValue] == 2));
    NSString *timer = enabledTimer ? @"1" : @"0";
    NSData *data = [self lampTimer:timer repeat:repeat stime:stime etime:etime];
    [DispatchManager sendData:data code:kCode_SetLampTimer userInfo:nil];
}

- (NSData *)lampBrightness:(NSInteger)brightness
{
    NSString *str = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                     "<xml> <value code=\"%d\"/> </xml>", brightness];
    return [NSData dataWithBytes:[str UTF8String] length:[str length]];
}

- (void)updateLampBrightness
{
    NSData *data = [self lampBrightness:_brightness];
    [DispatchManager sendData:data code:kCode_SetBrightness userInfo:nil];
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
- (void)reloadSubviews
{
    NSDictionary *led = [Common defaultValueForKey:kXML_NODE_LED];
    BOOL enabledTimer = ([led[kXML_ATTR_TIMER] integerValue] == 1) &&
                        ([led[kXML_ATTR_REPEAT] integerValue] == 0);
    
    NSString *stime = [self formatTime:led[kXML_ATTR_STIME]] ? : @"18:30";
    NSString *etime = [self formatTime:led[kXML_ATTR_ETIME]] ? : @"23:30";
    NSString *time = [NSString stringWithFormat:@"%@-%@", stime, etime];

    _timerStateLabel.text = enabledTimer ? time : @"关";
    _timerImageView.image = [UIImage imageNamed:enabledTimer ?
                             @"icon_scheduled_hot.png" : @"icon_scheduled.png"];
    
    BOOL enabledHoliday = ([led[kXML_ATTR_REPEAT] integerValue] == 2);
    _holidayStateLabel.text = enabledHoliday ? @"开" : @"关";
    _holidayImageView.image = [UIImage imageNamed:enabledHoliday ?
                               @"icon_holiday_hot.png" : @"icon_holiday.png"];
}

- (void)reloadBrightnessView
{
    startAngle = (M_PI * 2.0f - M_PI / 3.0f) * (_brightness / 50.0f);
    _progressImageView.transform = CGAffineTransformMakeRotation(startAngle);
}

#pragma mark - PickerViewControllerDelegate

- (void)pickerView:(PickerViewController *)pvc didSelectedData:(id)data
{
    [self showWaitingView:@""];
    [self updateLampTimer:@"0" stime:data[kXML_ATTR_STIME] etime:data[kXML_ATTR_ETIME]];
    CLog(@"%@", data);
}

#pragma mark - LANTransmissionDelegate

- (void)processRecvData:(NSDictionary *)dict
{
    if ([dict count] == 0) return ;
    
    NSNumber *number = [[dict allKeys] objectAtIndex:0];
    NSInteger code = [number unsignedCharValue];
    NSData *data = [[dict allValues] objectAtIndex:0];
    
    if (data && ((code == kCode_GetLampTimer) || (code == kCode_SetLampTimer) ||
                 (code == kCode_GetBrightness) || (code == kCode_SetBrightness)))
    {
        [self hideWaitingView];

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
                    [self reloadSubviews];
                }
            }
            else
            {
                TBXMLElement *element = [TBXML childElementNamed:kXML_NODE_VALUE
                                                   parentElement:tbxml.rootXMLElement];
                if (element)
                {
                    NSString *info = [TBXML valueOfAttributeNamed:kXML_ATTR_CODE
                                                       forElement:element];
                    if (![info isEqualToString:kCODE_REQ_FAILED])
                    {
                        if (code == kCode_SetLampTimer)
                        {
                            [self syncLampTimer];
                        }
                        else if (code == kCode_GetBrightness)
                        {
                            _brightness = [info integerValue];
                            [self reloadBrightnessView];
                        }
                        CLog(@"%d, %@", code, info);
                    }
                }
            }
        }
        [tbxml release];
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
