//
//  MainCell.m
//  WiFiLamp
//
//  Created by Aniapp on 12-9-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MainCell.h"

@implementation MainCell

@synthesize nextButton = _nextButton;
@synthesize titleLabel = _titleLabel;
@synthesize desc1Label = _desc1Label;
@synthesize desc2Label = _desc2Label;
@synthesize iconImageView = _iconImageView;
@synthesize arrowImageView = _arrowImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    [_arrowImageView release];
    [_iconImageView release];
    [_desc2Label release];
    [_desc1Label release];
    [_titleLabel release];
    [_nextButton release];
    [_isUsed release];
    
    [super dealloc];
}

- (void)adjustLabelPosition
{
    //
}

@end
