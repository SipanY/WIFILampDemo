//
//  WaitingView.h
//  
//
//  Created by Aniapp on 12-12-1.
//  Copyright (c) 2012年 Aniapp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WaitingView : UIView

- (void)show:(UIView *)view Text:(NSString*)text;
- (void)hide;

- (void)remove;

@end
