//
//  MainViewController.h
//  WiFiLamp
//
//  Created by Aniapp on 12-9-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LANTransmission.h"

@interface MainViewController : UIViewController<UITableViewDataSource,
UITableViewDelegate, LANTransmissionDelegate>

- (IBAction)showSettingsView:(id)sender;
- (IBAction)devicesButtonPressed:(id)sender;
@property (retain, nonatomic) IBOutletCollection(UITableView) NSArray *tableView;

@end
