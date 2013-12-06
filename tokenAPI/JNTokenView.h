//
//  JNTokenView.h
//  TokenView
//
//  Created by jinean on 13-12-6.
//  Copyright (c) 2013年 jinean. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef JN_INSTANCETYPE
#if __has_feature(objc_instancetype)
#define JN_INSTANCETYPE instancetype
#else
#define JN_INSTANCETYPE id
#endif
#endif

#ifndef JN_STRONG
#if __has_feature(objc_arc)
#define JN_STRONG strong
#else
#define JN_STRONG retain
#endif
#endif

#ifndef JN_WEAK
#if __has_feature(objc_arc_weak)
#define JN_WEAK weak
#elif __has_feature(objc_arc)
#define JN_WEAK unsafe_unretained
#else
#define JN_WEAK assign
#endif
#endif

@interface JNTokenView : UIView

@property (nonatomic, JN_STRONG) NSString *tokenCode;

- (void)read;

@end
