//
//  PickerView.h
//  WiFiLamp
//
//  Created by LEEM on 13-4-12.
//
//

#import <Foundation/Foundation.h>

@class PickerView;

@protocol PickerViewDelegate <NSObject>

@optional
- (void)didValueChanged:(PickerView *)pickerView;

@end

@interface PickerView : NSObject

@property (nonatomic, retain) IBOutlet UIView *containerView;
@property (nonatomic, retain) IBOutlet UITableView *leftTableView;
@property (nonatomic, retain) IBOutlet UITableView *rightTableView;

@property (nonatomic, assign) id<PickerViewDelegate> delegate;
@property (nonatomic, copy) NSString *timeString; //12:10 = 1210

@end
