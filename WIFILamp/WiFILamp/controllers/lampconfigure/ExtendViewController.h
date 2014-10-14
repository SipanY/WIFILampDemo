//
//  ExtendViewController.h
//  WiFiLamp
//
//  Created by Aniapp on 13-4-12.
//
//

#import <UIKit/UIKit.h>
#import "PickerViewController.h"

@interface ExtendViewController : UIViewController

- (IBAction)backButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;

- (IBAction)turnOnOffButtonPressed:(id)sender;
- (IBAction)continueButtonPressed:(id)sender;
- (IBAction)continueTimeButtonPressed:(id)sender;
- (IBAction)continueCycleButtonPressed:(id)sender;
- (IBAction)sleepButtonPressed:(id)sender;
- (IBAction)continueOnOffButtonPressed:(id)sender;
- (IBAction)sleepOnOffButtonPressed:(id)sender;

@end
