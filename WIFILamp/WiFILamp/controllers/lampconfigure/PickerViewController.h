//
//  PickerViewController.h
//  WiFiLamp
//
//  Created by Aniapp on 13-4-13.
//
//

#import <UIKit/UIKit.h>
#import "PickerView.h"

@class PickerViewController;

@protocol PickerViewControllerDelegate <NSObject>

@optional
- (void)pickerView:(PickerViewController*)pvc didSelectedData:(id)data;

@end

typedef NS_ENUM(NSInteger, TPickerViewType)
{
    PickerViewComplex,
    PickerViewSingle,
    PickerViewDouble
};

@interface PickerViewController : UIViewController
{
    id <PickerViewControllerDelegate> _delegate;
}

@property (nonatomic, assign) id <PickerViewControllerDelegate> delegate;
@property (nonatomic, assign) TPickerViewType type;
@property (nonatomic, copy) NSDictionary *contextData;

- (IBAction)backButtonPressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;

@end