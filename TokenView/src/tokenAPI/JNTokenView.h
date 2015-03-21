//
//  JNTokenView.h
//  TokenView
//
//  Created by jinean on 13-12-6.
//  Copyright (c) 2013年 jinean. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JNTokenView : UIView

@property (nonatomic, copy) NSString *tokenCode;

- (void)read;

@end
