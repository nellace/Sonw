//
//  NSString+Substring.m
//  Snow
//
//  Created by WO on 15/7/6.
//  Copyright (c) 2015年 sg. All rights reserved.
//

#import "NSString+Substring.h"

@implementation NSString (Substring)

- (BOOL)contains:(NSString *)substring
{
    if ([self rangeOfString:substring].location != NSNotFound) {
        return YES;
    }
    return NO;
}

@end
