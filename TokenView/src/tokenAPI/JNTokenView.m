//
//  JNTokenView.m
//  TokenView
//
//  Created by jinean on 13-12-6.
//  Copyright (c) 2013年 jinean. All rights reserved.
//

#import "JNTokenView.h"
#import <AVFoundation/AVFoundation.h>



@interface JNTokenNumberView : UIImageView

@property (nonatomic, assign) NSInteger          nowNumber;
@property (nonatomic, assign) NSInteger          toNumber;

@end

@implementation JNTokenNumberView


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
    
    self.image = [UIImage imageNamed:[NSString stringWithFormat:@"digital_%d.png",(int)nowNumber]];
    
    if(_nowNumber != self.toNumber)
    {
        [self performSelector:@selector(_setToNumber:) withObject:[NSNumber numberWithInteger:self.toNumber] afterDelay:0.01];
    }
}


@end

@interface JNTokenView()

@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) UIImageView    *bgImageView;
@property (nonatomic, strong) AVAudioPlayer  *player;

@end

@implementation JNTokenView

-(void)dealloc
{

    [_player        stop];
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.array = [[NSMutableArray alloc]init];
        
        UIImage *img = [UIImage imageNamed:@"token_bg.png"];
        
        self.bgImageView = [[UIImageView alloc] initWithImage:img];
        
        [self.bgImageView setFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
        
        [self addSubview:self.bgImageView];
    }
    return self;
}

- (void)setTokenCode:(NSString *)tokenCode
{
    _tokenCode      = tokenCode;
    
    int length      = (int)[_tokenCode length];
    
    int nowLength   = (int)[self.array count];
    
    if(nowLength < length)
    {
        while ((length - (nowLength++))>0)
        {
            JNTokenNumberView *number = [[JNTokenNumberView alloc]initWithFrame:CGRectZero];
            
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
    
    CGSize size = [UIImage imageNamed:@"digital_0.png"].size;
    
    length      = (int)[self.array count];
    
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
    
    self.player  = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    self.player.numberOfLoops = 0;
    
    [self.player play];
    
    NSString * new = [tokenCode substringWithRange:NSMakeRange(1, [tokenCode length]-1)];
    
    [self performSelector:@selector(_read:) withObject:new afterDelay:0.7];
    
}

@end
