//
//  PickerView.m
//  WiFiLamp
//
//  Created by LEEM on 13-4-12.
//
//

#import "PickerView.h"

@interface PickerView ()<UITableViewDataSource, UITableViewDelegate,
UIScrollViewDelegate>
{
    NSUInteger _selectedHourIndex;
    NSUInteger _selectedMinutesIndex;
}

@property (nonatomic, retain) NSArray *hoursOfDay;
@property (nonatomic, retain) NSArray *mintuesOfHour;

@end

@implementation PickerView

@synthesize leftTableView = _leftTableView;
@synthesize rightTableView = _rightTableView;
@synthesize containerView = _containerView;

@synthesize hoursOfDay = _hoursOfDay;
@synthesize mintuesOfHour = _mintuesOfHour;
@synthesize timeString = _timeString;


- (void)dealloc
{
    [_timeString release];
    [_mintuesOfHour release];
    [_hoursOfDay release];
    [_containerView release];
    [_rightTableView release];
    [_leftTableView release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        NSMutableArray *hours = [NSMutableArray array];
        [hours addObject:[NSNumber numberWithInteger:-1]];
        for (int i=0; i < 24; ++i)
        {
            [hours addObject:[NSNumber numberWithInteger:i]];
        }
        [hours addObject:[NSNumber numberWithInteger:-2]];
        self.hoursOfDay = hours;

        NSMutableArray *mintues = [NSMutableArray array];
        [mintues addObject:[NSNumber numberWithInteger:-1]];
        for (int i=0; i < 60; ++i)
        {
            [mintues addObject:[NSNumber numberWithInteger:i]];
        }
        [mintues addObject:[NSNumber numberWithInteger:-2]];
        self.mintuesOfHour = mintues;
        self.timeString = @"0000";
    }
    return self;
}

- (NSString *)timeString
{
    return [NSString stringWithFormat:@"%02d%02d",
            _selectedHourIndex, _selectedMinutesIndex];
}

- (void)setTimeString:(NSString *)timeString
{
    if (timeString != _timeString)
    {
        [_timeString release];
        _timeString = [timeString copy];
        
        if ([_timeString length] == 4)
        {
            _selectedHourIndex = [[_timeString substringToIndex:2] integerValue];
            _selectedMinutesIndex = [[_timeString substringFromIndex:2] integerValue];
            [self performSelectorOnMainThread:@selector(reloadLeftTableView)
                                   withObject:nil waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(reloadRightTableView)
                                   withObject:nil waitUntilDone:NO];
        }
    }
}

#define kTableViewCellHeight 44

- (void)reloadTableView:(UITableView *)tableView atIndex:(NSInteger)atIndex
{
    [UIView animateWithDuration:0.3f animations:^{
        CGPoint offset = CGPointMake(tableView.contentOffset.x,
                                     atIndex * kTableViewCellHeight);
        tableView.contentOffset = offset;
    }];
}

- (void)reloadLeftTableView
{
    [self reloadTableView:_leftTableView atIndex:_selectedHourIndex];
}

- (void)reloadRightTableView
{
    [self reloadTableView:_rightTableView atIndex:_selectedMinutesIndex];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSUInteger index = (scrollView.contentOffset.y + kTableViewCellHeight / 2) / kTableViewCellHeight;
    [UIView animateWithDuration:0.3 animations:^{
        CGPoint offset = scrollView.contentOffset;
        offset.y = index * kTableViewCellHeight;
        scrollView.contentOffset = offset;
    }];
    
    if (scrollView == _leftTableView)
        _selectedHourIndex = index;
    else if (scrollView == _rightTableView)
        _selectedMinutesIndex = index;

    if ([self.delegate respondsToSelector:@selector(didValueChanged:)])
    {
        [self.delegate didValueChanged:self];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    return (tableView == _leftTableView) ? [_hoursOfDay count] : [_mintuesOfHour count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:reuseIdentifier] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        [cell.textLabel setFont:[UIFont systemFontOfSize:19]];
        
        CGRect rect = CGRectMake(0, CGRectGetHeight(cell.frame)-2,
                                 CGRectGetWidth(cell.frame) - 30, 2);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
        [imageView setBackgroundColor:[UIColor colorWithRed:51/255.0f
                                                      green:145/255.0f
                                                       blue:179/255.0f
                                                      alpha:1.0f]];
        [cell addSubview:imageView];
        [cell setTag:100];
        [imageView release];
    }
    
    NSArray *list = (tableView == _leftTableView) ? _hoursOfDay : _mintuesOfHour;
    NSNumber *value = list[[indexPath row]];
    
    BOOL separatorHidden = NO;
    NSString *title = nil;
    if ([value integerValue] >= 0)
        title = [NSString stringWithFormat:@"%02d", [value integerValue]];
    else if ([value integerValue] == -2)
        separatorHidden = YES;
    
    cell.textLabel.text = title;
    [[cell viewWithTag:100] setHidden:separatorHidden];
    
    return cell;
}

@end
