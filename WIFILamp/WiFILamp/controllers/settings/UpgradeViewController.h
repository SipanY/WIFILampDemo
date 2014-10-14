//
//  UpgradeViewController.h
//  WiFiLamp
//
//  Created by Aniapp on 14-3-13.
//
//

#import <UIKit/UIKit.h>

@interface UpgradeViewController : UIViewController
{NSTimer *_loopTimer;

}
- (IBAction)backButtonPressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;

@property (retain, nonatomic) IBOutlet UIProgressView *progressView;



@property(assign,nonatomic)int temp;
@end