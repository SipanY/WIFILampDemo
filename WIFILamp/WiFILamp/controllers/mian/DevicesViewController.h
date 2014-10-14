//
//  DevicesViewController.h
//  WiFiLamp
//
//  Created by Ltian on 14-2-21.
//
//

#import <UIKit/UIKit.h>
#import "LANTransmission.h"

@interface DevicesViewController : UIViewController<UITableViewDataSource,
UITableViewDelegate, LANTransmissionDelegate>

- (void)waitingForBroadcast:(NSUInteger)times;

- (IBAction) backButtonPressed:(id)sender;
- (IBAction) refreshButtonPressed:(id)sender;

@end
