//
//  JNViewController.m
//  TokenView
//
//  Created by jinean on 13-12-6.
//  Copyright (c) 2013年 jinean. All rights reserved.
//

#import "JNViewController.h"
#import "JNTokenView.h"
#import "NSData+auth_totp.h"

@interface JNViewController ()

@property (nonatomic, strong) JNTokenView *tokenView;

@end

@implementation JNViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.tokenView = [[JNTokenView alloc]initWithFrame:CGRectMake(0, 100, 320, 100)];
    
    [self.view addSubview:self.tokenView];
    
    [self performSelector:@selector(refresh) withObject:nil afterDelay:0];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self.view addSubview:btn];
    
    [btn setBackgroundColor:[UIColor redColor]];
    
    [btn setFrame:CGRectMake(0, 200, 320, 44)];
    
    [btn addTarget:self action:@selector(read) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)read
{
    [self.tokenView read];
}

- (void)refresh
{
    
    NSData *data = [@"1111111111" dataUsingEncoding:NSASCIIStringEncoding];
    
    NSString * code = [data dynamicTotpPasscode:[NSDate date] length:NSDATA_AUTH_TOTP_LENGTH_DEFAULT secondMax:NSDATA_AUTH_TOTP_SECONDMAX_DEFAULT autofillUp:@"x"];
    
    NSLog(@"%@",code);
    
    [self.tokenView setTokenCode:code];
    
    [self performSelector:@selector(refresh) withObject:nil afterDelay:4.2];
    
}

@end
