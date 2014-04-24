//
//  HHAlertView.h
//  PXAlertViewDemo
//
//  Created by cyh on 13-12-9.
//  Copyright (c) 2013年 panaxiom. All rights reserved.
//

#import <UIKit/UIKit.h>

//ios7 效果的alertView

@class HHAlertView;
@protocol HHAlertViewDelegate <NSObject>
- (void)hhAlertView:(HHAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
@end



@interface HHAlertView : UIView
{
}

//一般的alertView
- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle;

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;

-(void)show;

@end
