//
//  PickerViewController.m
//  WiFiLamp
//
//  Created by Aniapp on 13-4-13.
//
//

#import "PickerViewController.h"
#import "GlobalDefines.h"
#import "Common.h"

@interface PickerViewController ()<PickerViewDelegate>

@property (nonatomic, retain) IBOutlet UILabel *dayTimeLabel;
@property (nonatomic, retain) IBOutlet UILabel *nightTimeLabel;
@property (nonatomic, retain) IBOutlet UILabel *dayTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *nightTitleLabel;
@property (nonatomic, retain) IBOutlet UIImageView *dayImageView;
@property (nonatomic, retain) IBOutlet UIImageView *nightImageView;
@property (nonatomic, retain) IBOutlet UIImageView *bgImageView;
@property (nonatomic, retain) IBOutlet PickerView *dayPickerView;
@property (nonatomic, retain) IBOutlet PickerView *nightPickerView;

@end

@implementation PickerViewController

@synthesize delegate = _delegate;
@synthesize dayTimeLabel = _dayTimeLabel;
@synthesize nightTimeLabel = _nightTimeLabel;
@synthesize dayTitleLabel = _dayTitleLabel;
@synthesize nightTitleLabel = _nightTitleLabel;
@synthesize contextData = _contextData;
@synthesize dayImageView = _dayImageView;
@synthesize nightImageView = _nightImageView;
@synthesize bgImageView = _bgImageView;
@synthesize type = _type;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadDatePicker:(PickerView *)pickerView hours:(NSUInteger)hours
               mintues:(NSUInteger)mintues
{
    pickerView.timeString = [NSString stringWithFormat:@"%02d%02d", hours, mintues];
}

- (void)loadTimeLabel:(UILabel *)timeLabel hours:(NSUInteger)hours
              mintues:(NSUInteger)mintues
{
    timeLabel.text = [NSString stringWithFormat:@"%02d:%02d", hours, mintues];
}

- (NSInteger)singleValueOfDatePicker:(UIDatePicker *)datePicker
                          dateFormat:(NSString *)dateFormat
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateFormat];
    NSString *value = [formatter stringFromDate:datePicker.date];
    [formatter release];
    
    return value ? [value integerValue] : -1;
}

- (void)didValueChanged:(PickerView *)pickerView
{
    if ([pickerView.timeString length] == 4)
    {
        NSInteger hours = [[pickerView.timeString substringToIndex:2] integerValue];
        NSInteger mintues = [[pickerView.timeString substringFromIndex:2] integerValue];
        if ((hours >= 0) && (mintues >= 0))
        {
            UILabel *label = nil;
            if (pickerView == _dayPickerView)
                label = _dayTimeLabel;
            else if (pickerView == _nightPickerView)
                label = _nightTimeLabel;
            
            [self loadTimeLabel:label hours:hours mintues:mintues];
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

- (NSUInteger)defaultStartHours
{
    if (_type == PickerViewSingle)
        return 1;
    else if (_type == PickerViewDouble)
        return 8;
    else
        return 18;
}

- (NSUInteger)defaultMintues
{
    if (_type == PickerViewComplex)
        return 30;
    else
        return 0;
}

- (NSUInteger)defaultEndHours
{
    if (_type == PickerViewSingle)
        return 1;
    else if (_type == PickerViewDouble)
        return 18;
    else
        return 23;
}

- (void)initPickerView
{
    NSInteger hours = [self defaultStartHours];
    NSInteger mintues = [self defaultMintues];
    NSString *stime = _contextData[kXML_ATTR_STIME];
    if ([stime length] == 4)
    {
        hours = [[stime substringToIndex:2] integerValue];
        mintues = [[stime substringWithRange:NSMakeRange(2, 2)] integerValue];
    }
    
    [self loadTimeLabel:_dayTimeLabel hours:hours mintues:mintues];
    [self loadDatePicker:_dayPickerView hours:hours mintues:mintues];
    
    if (self.type != PickerViewSingle)
    {
        hours = [self defaultEndHours];
        NSString *etime = _contextData[kXML_ATTR_ETIME];
        if ([etime length] == 4)
        {
            hours = [[etime substringToIndex:2] integerValue];
            mintues = [[etime substringWithRange:NSMakeRange(2, 2)] integerValue];
        }
        
        [self loadTimeLabel:_nightTimeLabel hours:hours mintues:mintues];
        [self loadDatePicker:_nightPickerView hours:hours mintues:mintues];
    }
    
    _dayPickerView.delegate = self;
    _nightPickerView.delegate = self;
}

- (void)hiddenSubViews
{
    self.dayTimeLabel.hidden = NO;
    self.dayTitleLabel.hidden = NO;
    self.dayImageView.hidden = NO;
    self.nightTimeLabel.hidden = NO;
    self.nightTitleLabel.hidden = NO;
    self.nightPickerView.containerView.hidden = NO;
    self.nightImageView.hidden = NO;
    
    if (_type == PickerViewSingle)
    {
        self.dayTimeLabel.hidden = YES;
        self.dayTitleLabel.hidden = YES;
        self.dayImageView.hidden = YES;
        self.nightTimeLabel.hidden = YES;
        self.nightTitleLabel.hidden = YES;
        self.nightPickerView.containerView.hidden = YES;
        self.nightImageView.hidden = YES;
    }
    else if (_type == PickerViewDouble)
    {
        self.dayTimeLabel.hidden = YES;
        self.dayImageView.hidden = YES;
        self.nightTimeLabel.hidden = YES;
        self.nightImageView.hidden = YES;
    }
}

- (void)adjustSubviews
{
    CGRect ddpframe = self.dayPickerView.containerView.frame;
    CGRect ndpframe = self.nightPickerView.containerView.frame;
    
    if (_type == PickerViewSingle)
    {
        ddpframe.origin.x = (CGRectGetWidth(self.bgImageView.frame) - CGRectGetWidth(ddpframe)) / 2 + CGRectGetMinX(self.bgImageView.frame);
        ddpframe.origin.y = CGRectGetMinY(self.bgImageView.frame) + 50;
    }
    else if (_type == PickerViewDouble)
    {
        ddpframe.origin.x = CGRectGetMinX(_bgImageView.frame);
        ddpframe.origin.y = CGRectGetMinY(_bgImageView.frame) + 40;
        
        ndpframe.origin.x = CGRectGetMaxX(ddpframe);
        ndpframe.origin.y = ddpframe.origin.y;
        
        CGRect dtlframe = self.dayTitleLabel.frame;
        dtlframe.origin.x = (CGRectGetWidth(ddpframe) - CGRectGetWidth(dtlframe)) / 2 + CGRectGetMinX(ddpframe);
        dtlframe.origin.y = CGRectGetMaxY(self.bgImageView.frame) - 80;
        self.dayTitleLabel.frame = dtlframe;

        CGRect ntlframe = self.nightTitleLabel.frame;
        ntlframe.origin.x = (CGRectGetWidth(ndpframe) - CGRectGetWidth(ntlframe)) / 2 + CGRectGetMinX(ndpframe);
        ntlframe.origin.y = dtlframe.origin.y;
        self.nightTitleLabel.frame = ntlframe;
    }
    else
    {
        ddpframe.origin.x = CGRectGetMinX(_bgImageView.frame);
        ddpframe.origin.y = CGRectGetMinY(_bgImageView.frame) + 100;
        
        ndpframe.origin.x = CGRectGetMaxX(ddpframe);
        ndpframe.origin.y = ddpframe.origin.y;
    }
    
    self.dayPickerView.containerView.frame = ddpframe;
    self.nightPickerView.containerView.frame = ndpframe;
}

- (void)loadSubviews
{
    NSString *imageNamed = @"schedule_bg.png";
    NSString *dayTitle = @"日落";
    NSString *nightTitle = @"睡觉时间";
    
    if (_type == PickerViewSingle)
    {
        imageNamed = @"schedule_s_bg.png";
    }
    else if (_type == PickerViewDouble)
    {
        dayTitle = @"开启时间";
        nightTitle = @"关闭时间";
        imageNamed = @"schedule_d_bg.png";
    }
    
    self.dayTitleLabel.text = dayTitle;
    self.nightTitleLabel.text = nightTitle;
    self.bgImageView.image = [UIImage imageNamed:imageNamed];
}

- (void)reloadSubViews
{
    [self hiddenSubViews];
    [self adjustSubviews];
    [self loadSubviews];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initPickerView];
    [self reloadSubViews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_bgImageView release];
    [_nightTitleLabel release];
    [_dayTitleLabel release];
    [_nightImageView release];
    [_dayImageView release];
    [_nightTimeLabel release];
    [_dayTimeLabel release];
    [_contextData release];
    [_dayPickerView release];
    [_nightPickerView release];
    [super dealloc];
}

- (void)backButtonPressed:(id)sender
{
    [(UIButton*)sender setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.2 animations:^{
        self.view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [(UIButton*)sender setUserInteractionEnabled:YES];
    }];
}

- (void)doneButtonPressed:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(pickerView:didSelectedData:)])
    {
        NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithCapacity:4];
        if ([_dayPickerView.timeString length] == 4)
        {
            [data setObject:_dayPickerView.timeString forKey:kXML_ATTR_STIME];
        }

        if ([_nightPickerView.timeString length] == 4)
        {
            [data setObject:_nightPickerView.timeString forKey:kXML_ATTR_ETIME];
        }
        
        [_delegate pickerView:self didSelectedData:data];
        [data release];
    }
    [self backButtonPressed:nil];
}

@end
