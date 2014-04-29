//
//  ViewController.m
//  AlertTest
//
//  Created by cyh on 14-2-26.
//  Copyright (c) 2014年 cyh. All rights reserved.
//

#import "ViewController.h"
#import "HHAlertView.h"

@interface ViewController () <HHAlertViewDelegate>
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)pressSystemButton:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"title鼓楼区华东设计院title鼓楼区华东设计院" message:@"measgetitle鼓楼区华东设计院title鼓楼区华东设计院" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
    [alertView show];

}

-(IBAction)pressCustomButton:(id)sender
{
    HHAlertView *alertView = [[HHAlertView alloc] initWithTitle:@"title鼓楼区华东设计院title鼓楼区华东设计院" message:@"measgetitle鼓楼区华东设计院title鼓楼区华东设计院" delegate:self cancelButtonTitle:@"确定" otherButtonTitle:@"取消"];
    [alertView show];
}

#pragma mark - HHAlertView
- (void)hhAlertView:(HHAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"=== %d",buttonIndex);
}
@end
