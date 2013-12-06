//
//  JNTokenView.m
//  TokenView
//
//  Created by jinean on 13-12-6.
//  Copyright (c) 2013年 jinean. All rights reserved.
//

#import "JNTokenView.h"
#import <AVFoundation/AVFoundation.h>

#define TOKEN_IMAGE_FORMAT @"digital_%d.png"
#ifndef TOKENIMAGE
#define TOKENIMAGE(_digital_) \
    [NSString stringWithFormat:TOKEN_IMAGE_FORMAT,_digital_]
#endif

#if __has_feature(objc_arc)
#define JN_AUTORELEASE(exp) exp
#define JN_RELEASE(exp) exp
#define JN_RETAIN(exp) exp
#else
#define JN_AUTORELEASE(exp) [exp autorelease]
#define JN_RELEASE(exp) [exp release]
#define JN_RETAIN(exp) [exp retain]
#endif


@interface JNTokenNumberView : UIImageView

@property (nonatomic, assign) NSInteger          nowNumber;
@property (nonatomic, assign) NSInteger          toNumber;

@end

@implementation JNTokenNumberView

- (void)dealloc
{
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

- (void)setToNumber:(NSInteger)toNumber
{
    _toNumber = toNumber;
    
    if(self.nowNumber > toNumber)
    {
        self.nowNumber--;
    }
    else if(self.nowNumber < toNumber)
    {
        self.nowNumber ++;
    }
}

- (void)_setToNumber:(NSNumber *)number
{
    self.toNumber = [number intValue];
}

- (void)setNowNumber:(NSInteger)nowNumber
{
    _nowNumber = nowNumber;
    
    self.image = [UIImage imageNamed:TOKENIMAGE(nowNumber)];
    
    if(_nowNumber != self.toNumber)
    {
        [self performSelector:@selector(_setToNumber:) withObject:[NSNumber numberWithInt:self.toNumber] afterDelay:0.01];
    }
}


@end

@interface JNTokenView()

@property (nonatomic, JN_STRONG) NSMutableArray *array;
@property (nonatomic, JN_STRONG) UIImageView    *bgImageView;
@property (nonatomic, JN_STRONG) AVAudioPlayer  *player;

@end

@implementation JNTokenView

-(void)dealloc
{

    [_player        stop];
    
#if ! __has_feature(objc_arc)
    [_array         release];
    [_tokenCode     release];
    [_bgImageView   release];
    [_player        release];
#endif
    _array          = nil;
    _tokenCode      = nil;
    _bgImageView    = nil;
    _player         = nil;
    
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.array = JN_AUTORELEASE([[NSMutableArray alloc]init]);
        
        UIImage *img = [UIImage imageNamed:@"token_bg.png"];
        
        self.bgImageView = JN_AUTORELEASE([[UIImageView alloc] initWithImage:img]);
        
        [self.bgImageView setFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
        
        [self addSubview:self.bgImageView];
    }
    return self;
}

- (void)setTokenCode:(NSString *)tokenCode
{
    _tokenCode      = [tokenCode copy];
    
    int length      = [_tokenCode length];
    
    int nowLength   = [self.array count];
    
    if(nowLength < length)
    {
        while ((length - (nowLength++))>0)
        {
            JNTokenNumberView *number = JN_AUTORELEASE([[JNTokenNumberView alloc]initWithFrame:CGRectZero]);
            
            [self addSubview:number];
            
            [self.array addObject:number];
            
            [number setNowNumber:0];
            
            [number setToNumber:0];
        }
    }
    else if(nowLength > length)
    {
        while (((nowLength--) - length)> 0)
        {
            [[self.array lastObject] removeFromSuperview];
            
            [self.array removeLastObject];
        }
    }
    
    CGSize size = [UIImage imageNamed:TOKENIMAGE(0)].size;
    
    length      = [self.array count];
    
    int offX    = 2;
    int _X      = 64;
    
    for (int i = 0; i < length; i++)
    {
        if(i ==3)_X = 64 + 12 ;
        
        JNTokenNumberView *number = [self.array objectAtIndex:i];
        
        [number setFrame:CGRectMake(_X + size.width * i + offX * i, 16, size.width, size.height)];
        
        int k = [[tokenCode substringWithRange:NSMakeRange(i, 1)]intValue];
        
        [number setToNumber:k];
    }
}

- (void)read
{
    [self _read:[self.tokenCode copy]];
}

- (void)_read:(NSString *)tokenCode
{
    if([tokenCode length]==0)
    {
        return;
    }
    
    int    k    = [[tokenCode substringWithRange:NSMakeRange(0, 1)]intValue];
    
    NSURL  *url = [NSURL fileURLWithPath:[NSString  stringWithFormat:@"%@/VoiceNumber_%d.wav",  [[NSBundle mainBundle]  resourcePath],k]];
    
    NSError  *error;
    
    self.player  = JN_AUTORELEASE([[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error]);
    
    self.player.numberOfLoops = 0;
    
    [self.player play];
    
    NSString * new = [tokenCode substringWithRange:NSMakeRange(1, [tokenCode length]-1)];
    
    [self performSelector:@selector(_read:) withObject:new afterDelay:0.5];
    
}

@end
