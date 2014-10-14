//
//  MainCell.h
//  WiFiLamp
//
//  Created by Aniapp on 12-9-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIButton *nextButton;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *desc1Label;
@property (nonatomic, retain) IBOutlet UILabel *desc2Label;
@property (nonatomic, retain) IBOutlet UIImageView *iconImageView;
@property (nonatomic, retain) IBOutlet UIImageView *arrowImageView;
@property (retain, nonatomic) IBOutlet UILabel *isUsed;


- (void) adjustLabelPosition;

@end
