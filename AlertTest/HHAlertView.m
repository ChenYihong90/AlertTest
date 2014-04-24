
//
//  HHAlertView.m
//  PXAlertViewDemo
//
//  Created by cyh on 13-12-9.
//  Copyright (c) 2013年 panaxiom. All rights reserved.
//


#import "HHAlertView.h"

@interface HHAlertViewQueue : NSObject
@property (nonatomic) NSMutableArray *alertViews;
+ (HHAlertViewQueue *)sharedInstance;
- (void)add:(HHAlertView *)alertView;
- (void)remove:(HHAlertView *)alertView;
@end


#define AlertViewWidth  270.0
#define AlertViewContentMargin  9
#define AlertViewVerticalElementSpace  10
#define AlertViewButtonHeight 44
#define LabelWeight 75
#define BackgroundColor [UIColor colorWithRed:65/255.0 green:65/255.0 blue:65/255.0 alpha:0.5]
#define AlertViewColor [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0]
#define BlueColor [UIColor colorWithRed:50/255.0 green:130/255.0 blue:255/255.0 alpha:1.0]
#define LineColor [UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:1.0]
#define TouchColor [UIColor colorWithRed:218/255.0 green:218/255.0 blue:218/255.0 alpha:1.0]

@interface HHAlertView ()
//共用
@property (nonatomic, getter = isVisible) BOOL visible;
@property (nonatomic) id <HHAlertViewDelegate> delegate;
@property (nonatomic,retain) UIWindow *mainWindow;
@property (nonatomic,retain) UIWindow *alertWindow;
@property (nonatomic,retain) UIView *alertView;
@property (nonatomic,retain) UIView *backgroundView;
@property (nonatomic,retain) UILabel *titleLabel;
@property (nonatomic,retain) UILabel *messageLabel;
@property (nonatomic,retain) UIButton *cancelButton;
@property (nonatomic,retain) UIButton *otherButton;
@property (nonatomic,retain) UITapGestureRecognizer *tap;
@property (nonatomic,retain) CALayer *horLineLayer;
@property (nonatomic,retain) CALayer *verLineLayer;
@end

@implementation HHAlertView

- (UIWindow *)windowWithLevel:(UIWindowLevel)windowLevel
{
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for (UIWindow *window in windows) {
        if (window.windowLevel == windowLevel) {
            return window;
        }
    }
    return nil;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle
{
    if (self = [super init]) {
        self.delegate = delegate;
        
        self.mainWindow = [self windowWithLevel:UIWindowLevelNormal];
        self.alertWindow = [self windowWithLevel:UIWindowLevelAlert];
        if ( !self.alertWindow ) {
            self.alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            self.alertWindow.windowLevel = UIWindowLevelAlert;
        }
        self.frame = self.alertWindow.bounds;
        
        self.backgroundView = [[UIView alloc] initWithFrame:self.alertWindow.bounds];
        self.backgroundView.backgroundColor = BackgroundColor;
        self.backgroundView.alpha = 0;
        [self addSubview:self.backgroundView];
        
        self.alertView = [[UIView alloc] init];
        self.alertView.backgroundColor = AlertViewColor;
        self.alertView.layer.cornerRadius = 8.0;
        self.alertView.layer.opacity = 0.95;
        self.alertView.clipsToBounds = YES;
        [self addSubview:self.alertView];
        
        // Title
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(AlertViewContentMargin,
                                                                    AlertViewVerticalElementSpace,
                                                                    AlertViewWidth - AlertViewContentMargin*2,
                                                                    21)];
        self.titleLabel.text = title;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        self.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.frame = [self adjustLabelFrameHeight:self.titleLabel];
        [self.alertView addSubview:self.titleLabel];
 
        // Message
        CGFloat messageLabelY = self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 5;
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(AlertViewContentMargin,
                                                                      messageLabelY,
                                                                      AlertViewWidth -AlertViewContentMargin*2,
                                                                      21)];
        self.messageLabel.text = message;
        self.messageLabel.backgroundColor = [UIColor clearColor];
         self.messageLabel.textColor = [UIColor blackColor];
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
        self.messageLabel.font = [UIFont systemFontOfSize:14];
        self.messageLabel.lineBreakMode = NSLineBreakByCharWrapping;
        self.messageLabel.numberOfLines = 0;
        self.messageLabel.frame = [self adjustLabelFrameHeight:self.messageLabel];
        [self.alertView addSubview:self.messageLabel];
        
        // Line
        CGFloat horLineY = self.messageLabel.frame.origin.y + self.messageLabel.frame.size.height + 18;
        self.horLineLayer = [CALayer layer];
        self.horLineLayer.backgroundColor =  [LineColor CGColor];
        self.horLineLayer.frame = CGRectMake(0, horLineY, AlertViewWidth, 0.5);
        [self.alertView.layer addSublayer:self.horLineLayer];
        
        // Buttons
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if (cancelButtonTitle) {
            [self.cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
        }
        else {
            [self.cancelButton setTitle:NSLocalizedString(@"Ok", nil) forState:UIControlStateNormal];
        }
        self.cancelButton.backgroundColor = [UIColor clearColor];
        self.cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [self.cancelButton setTitleColor:BlueColor forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:BlueColor forState:UIControlStateHighlighted];
        [self.cancelButton addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
        [self.cancelButton addTarget:self action:@selector(setBackgroundColorForButton:) forControlEvents:UIControlEventTouchDown];
        [self.cancelButton addTarget:self action:@selector(clearBackgroundColorForButton:) forControlEvents:UIControlEventTouchDragExit];
        
        
        CGFloat buttonsY = self.horLineLayer.frame.origin.y + self.horLineLayer.frame.size.height;
        if (otherButtonTitle) {
            self.cancelButton.frame = CGRectMake(0, buttonsY, AlertViewWidth/2, AlertViewButtonHeight);
            
            self.otherButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.otherButton setTitle:otherButtonTitle forState:UIControlStateNormal];
            self.otherButton.backgroundColor = [UIColor clearColor];
            self.otherButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
            [self.otherButton setTitleColor:BlueColor forState:UIControlStateNormal];
            [self.otherButton setTitleColor:BlueColor forState:UIControlStateHighlighted];
            [self.otherButton addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
            [self.otherButton addTarget:self action:@selector(setBackgroundColorForButton:) forControlEvents:UIControlEventTouchDown];
            [self.otherButton addTarget:self action:@selector(clearBackgroundColorForButton:) forControlEvents:UIControlEventTouchDragExit];
            self.otherButton.frame = CGRectMake(self.cancelButton.frame.size.width, buttonsY, AlertViewWidth/2, 44);
            [self.alertView addSubview:self.otherButton];
            
            self.verLineLayer = [CALayer layer];
            self.verLineLayer.backgroundColor = [LineColor CGColor];
            self.verLineLayer.frame = CGRectMake(self.otherButton.frame.origin.x, self.otherButton.frame.origin.y, 0.5, AlertViewButtonHeight);
            [_alertView.layer addSublayer:self.verLineLayer];
        }
        else {
            self.cancelButton.frame = CGRectMake(0, buttonsY, AlertViewWidth, AlertViewButtonHeight);
        }
        [self.alertView addSubview:self.cancelButton];
        
        //alertView的高度
        CGFloat hieght = self.cancelButton.frame.origin.y + self.cancelButton.frame.size.height;
        self.alertView.bounds = CGRectMake(0, 0, AlertViewWidth, hieght);
        self.alertView.center = CGPointMake(CGRectGetMidX(self.alertWindow.bounds), CGRectGetMidY(self.alertWindow.bounds));
        
        [self setupGestures];
    }
    return self;
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    self.visible = NO;
    
    if ([[[HHAlertViewQueue sharedInstance] alertViews] count] == 1) {
        [self dismissAlertAnimation];
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            self.mainWindow.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
            [self.mainWindow tintColorDidChange];
        }
        [UIView animateWithDuration:0.2 animations:^{
            self.backgroundView.alpha = 0;
            [self.mainWindow makeKeyAndVisible];
        }];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alertView.alpha = 0;
    } completion:^(BOOL finished) {
        [[HHAlertViewQueue sharedInstance] remove:self];
        self.mainWindow = nil;
        self.alertWindow = nil;
        [self removeFromSuperview];
    }];
}

- (void)show
{
    [[HHAlertViewQueue sharedInstance] add:self];
}

- (void)_show
{
    [self.alertWindow addSubview:self];
    [self.alertWindow makeKeyAndVisible];
    self.visible = YES;
    [self showBackgroundView];
    [self showAlertAnimation];
}

- (void)showBackgroundView
{
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.mainWindow.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        [self.mainWindow tintColorDidChange];
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundView.alpha = 1;
    }];
}

- (void)hide
{
    [self removeFromSuperview];
}

- (void)dismiss:(id)sender
{
    self.visible = NO;
    
    if ([[[HHAlertViewQueue sharedInstance] alertViews] count] == 1) {
        [self dismissAlertAnimation];
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            self.mainWindow.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
            [self.mainWindow tintColorDidChange];
        }
        [UIView animateWithDuration:0.2 animations:^{
            self.backgroundView.alpha = 0;
            [self.mainWindow makeKeyAndVisible];
        }];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alertView.alpha = 0;
    } completion:^(BOOL finished) {
        [[HHAlertViewQueue sharedInstance] remove:self];
        self.mainWindow = nil;
        self.alertWindow = nil;
        [self removeFromSuperview];
    }];
    
    BOOL cancelled;
    if (sender == self.cancelButton || sender == self.tap) {
        cancelled = YES;
    } else {
        cancelled = NO;
    }
    
    if ([self.delegate respondsToSelector:@selector(hhAlertView:clickedButtonAtIndex:)]) {
        if (sender == self.cancelButton) {
            [self.delegate hhAlertView:self clickedButtonAtIndex:0];
        }
        else if (sender == self.otherButton) {
            [self.delegate hhAlertView:self clickedButtonAtIndex:1];
        }
    }
    
}

- (void)setBackgroundColorForButton:(id)sender
{
     [sender setBackgroundColor:TouchColor];
}

- (void)clearBackgroundColorForButton:(id)sender
{
    [sender setBackgroundColor:[UIColor clearColor]];
}

#pragma mark - gestures

- (void)setupGestures
{
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
    [self.tap setNumberOfTapsRequired:1];
    [self.backgroundView setUserInteractionEnabled:YES];
    [self.backgroundView setMultipleTouchEnabled:NO];
    [self.backgroundView addGestureRecognizer:self.tap];
}

#pragma mark -

- (CGRect)adjustLabelFrameHeight:(UILabel *)label
{
    CGFloat height;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CGSize size = [label.text sizeWithFont:label.font
                             constrainedToSize:CGSizeMake(label.frame.size.width, FLT_MAX)
                                 lineBreakMode:NSLineBreakByWordWrapping];
        
        height = size.height;
#pragma clang diagnostic pop
    } else {
        NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
        context.minimumScaleFactor = 1.0;
        CGRect bounds = [label.text boundingRectWithSize:CGSizeMake(label.frame.size.width, FLT_MAX)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName:label.font}
                                                 context:context];
        height = bounds.size.height;
    }
    
    return CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, height);
}

- (void)showAlertAnimation
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    animation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.05, 1.05, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1)]];
    animation.keyTimes = @[ @0, @0.5, @1 ];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.duration = .3;
    
    [self.alertView.layer addAnimation:animation forKey:@"showAlert"];
}

- (void)dismissAlertAnimation
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    animation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.95, 0.95, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1)]];
    animation.keyTimes = @[ @0, @0.5, @1 ];
    animation.fillMode = kCAFillModeRemoved;
    animation.duration = .2;
    
    [self.alertView.layer addAnimation:animation forKey:@"dismissAlert"];
}

@end

@implementation HHAlertViewQueue

+ (instancetype)sharedInstance
{
    static HHAlertViewQueue *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[HHAlertViewQueue alloc] init];
        _sharedInstance.alertViews = [NSMutableArray array];
    });
    
    return _sharedInstance;
}

- (void)add:(HHAlertView *)alertView
{
    [self.alertViews addObject:alertView];
    [alertView _show];
    for (HHAlertView *av in self.alertViews) {
        if (av != alertView) {
            [av hide];
        }
    }
}

- (void)remove:(HHAlertView *)alertView
{
    [self.alertViews removeObject:alertView];
    HHAlertView *last = [self.alertViews lastObject];
    if (last) {
        [last _show];
    }
}

@end






