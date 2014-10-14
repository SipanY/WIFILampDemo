//
//  WaitingView.m
//  
//
//  Created by Aniapp on 12-12-1.
//  Copyright (c) 2012年 Aniapp. All rights reserved.
//

#import "WaitingView.h"
#import <QuartzCore/QuartzCore.h>

@interface WaitingView ()
{
    UIImageView *_maskImageView;
    UIImageView *_waitingImageView;
    UIActivityIndicatorView * _activityIndicatorView;
    UILabel *_textLabel;
    
    UIView *_superView;
    NSUInteger _refCount;
}

@property (strong, nonatomic) UIImageView *maskImageView;
@property (strong, nonatomic) UIImageView *waitingImageView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) UILabel *textLabel;

@end

@implementation WaitingView

@synthesize maskImageView = _maskImageView;
@synthesize waitingImageView = _waitingImageView;
@synthesize activityIndicatorView = _activityIndicatorView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (_maskImageView == nil)
        {
            _maskImageView = [[UIImageView alloc] initWithFrame:frame];
            [self addSubview:_maskImageView];
        }
        
        CGFloat kDefaultWidth = 128;
        CGFloat kDefaultHeight = 96;
        if (_waitingImageView == nil)
        {
            CGFloat x = (frame.size.width - kDefaultWidth) / 2;
            CGFloat y = (frame.size.height - kDefaultHeight) / 2;
            CGRect rect = CGRectMake(x, y, kDefaultWidth, kDefaultHeight);
            _waitingImageView = [[UIImageView alloc] initWithFrame:rect];
            [_waitingImageView setContentMode:UIViewContentModeScaleAspectFit];
            [_waitingImageView setBackgroundColor:[UIColor blackColor]];
            _waitingImageView.layer.cornerRadius = 8;
            _waitingImageView.alpha = 0.7;
            [self addSubview:_waitingImageView];
        }
        
        if (_activityIndicatorView == nil)
        {
            _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            CGRect rect = _activityIndicatorView.frame;
            rect.origin.x = (kDefaultWidth -  rect.size.width) / 2;
            rect.origin.y = (kDefaultHeight -  rect.size.height) / 2;
            _activityIndicatorView.frame = rect;
            [_activityIndicatorView startAnimating];
            [_waitingImageView addSubview:_activityIndicatorView];
        }
        
        if (_textLabel == nil)
        {
            CGRect rect = _activityIndicatorView.frame;
            rect = CGRectMake(10, rect.origin.y + rect.size.height,
                              kDefaultWidth - 20, 21);
            _textLabel = [[UILabel alloc] initWithFrame:rect];
            [_textLabel setBackgroundColor:[UIColor clearColor]];
            [_textLabel setTextAlignment:NSTextAlignmentCenter];
            [_textLabel setTextColor:[UIColor whiteColor]];
            [_waitingImageView addSubview:_textLabel];
        }
    }
    return self;
}

- (void)dealloc
{
    [_textLabel removeFromSuperview];
    [_textLabel release];
    [_activityIndicatorView removeFromSuperview];
    [_activityIndicatorView release];
    [_maskImageView removeFromSuperview];
    [_maskImageView release];
    [_waitingImageView removeFromSuperview];
    [_waitingImageView release];
    [super dealloc];
}

- (void)show:(UIView *)view Text:(NSString *)text
{
    if (_refCount == 0)
    {
        self.textLabel.text = text;
        [view addSubview:self];
    }
    ++_refCount;
}

- (void)hide
{
    if (_refCount > 0)
        --_refCount;
    if (_refCount == 0)
        [self removeFromSuperview];
}

- (void)remove
{
    [self removeFromSuperview];
    _refCount = 0;
}

@end
