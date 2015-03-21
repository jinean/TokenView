//  Qianbao
//
//  Created by jinean on 13-11-25.
//  Copyright (c) 2013年 jinean. All rights reserved.
//

#import "NSData+auth_totp.h"
#import <CommonCrypto/CommonHMAC.h>

#if __has_feature(objc_arc)
#define TOTP_AUTORELEASE(exp) exp
#define TOTP_RELEASE(exp) exp
#define TOTP_RETAIN(exp) exp
#else
#define TOTP_AUTORELEASE(exp) [exp autorelease]
#define TOTP_RELEASE(exp) [exp release]
#define TOTP_RETAIN(exp) [exp retain]
#endif

@implementation NSData (auth_totp)

- (NSString *)dynamicTotpPasscode
{
    return [self dynamicTotpPasscode:[NSDate date]];
}

- (NSString *)dynamicTotpPasscode:(NSDate *)sTime
{
    return [self dynamicTotpPasscode:sTime length:NSDATA_AUTH_TOTP_LENGTH_DEFAULT];
}

- (NSString *)dynamicTotpPasscode:(NSDate *)sTime length:(int)length
{
    return [self dynamicTotpPasscode:sTime length:length secondMax:NSDATA_AUTH_TOTP_SECONDMAX_DEFAULT autoZero:YES];
}

- (NSString *)dynamicTotpPasscode:(NSDate *)sTime length:(int)length secondMax:(int)secondMax
{
    return [self dynamicTotpPasscode:sTime length:length secondMax:secondMax autoZero:YES];
}

- (NSString *)dynamicTotpPasscode:(NSDate *)sTime length:(int)length secondMax:(int)secondMax autoZero:(BOOL)autoZero
{
    NSTimeInterval seconds = [sTime timeIntervalSince1970];
    uint64_t counter = (uint64_t) (seconds / secondMax);
    return [self _generateDynamicPasscode:counter length:length autoZero:autoZero];
}

- (NSString *)dynamicTotpPasscode:(NSDate *)sTime length:(int)length secondMax:(int)secondMax autofillUp:(NSString *)autofillUp
{
    NSMutableString *str = [NSMutableString stringWithString:[self dynamicTotpPasscode:sTime length:length secondMax:secondMax autoZero:NO]];

    NSMutableString *result = TOTP_AUTORELEASE([[NSMutableString alloc]init]);
    
    do {
        int len = length -[str length] ;
        if(len <= 0)
        {
            result = str;
            break;
        }
        if([autofillUp length] != 1)
        {
            autofillUp = NSDATA_AUTH_TOTP_AUTOFILLUP;
        }
        while (len --)
        {
            [result appendString:autofillUp];
        }
        [result appendString:str];
    } while (0);
    
    return result;
}

- (NSString *)_generateDynamicPasscode:(uint64_t)counter length:(int)length autoZero:(BOOL)autoZero
{
    CCHmacAlgorithm alg = kCCHmacAlgSHA1;
    NSUInteger hashLength = CC_SHA1_DIGEST_LENGTH;
    NSMutableData *hash = [NSMutableData dataWithLength:hashLength];
    counter = NSSwapHostLongLongToBig(counter);
    NSData *counterData = [NSData dataWithBytes:&counter length:sizeof(counter)];
    CCHmacContext ctx;
    CCHmacInit(&ctx, alg, [self bytes], [self length]);
    CCHmacUpdate(&ctx, [counterData bytes], [counterData length]);
    CCHmacFinal(&ctx, [hash mutableBytes]);
    
    const char *ptr = [hash bytes];
    char const offset = ptr[hashLength-1] & 0x0f;
    unsigned long truncatedHash = NSSwapBigLongToHost(*((unsigned long *)&ptr[offset])) & 0x7fffffff;
    
    int maxDigits = 1;while (length--)maxDigits*=10;

    unsigned long pinValue = truncatedHash % maxDigits;
    
    if(autoZero)
    {
        return [NSString stringWithFormat:@"%0*ld", length, pinValue];
    }
    else
    {
        return [NSString stringWithFormat:@"%ld",pinValue];
    }
}

@end
