//
//  PagingScrollView.m
//  Snow
//
//  Created by WO on 15/7/9.
//  Copyright (c) 2015年 sg. All rights reserved.
//

#import "PagingScrollView.h"

@implementation PagingScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.pagingEnabled  = YES;
        self.backgroundColor = [UIColor clearColor];
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.alwaysBounceHorizontal = YES;
    }
    return self;
}

- (void)addSubview:(UIView *)weatherView isLaunch:(BOOL)launch
{
    [super addSubview: weatherView];
    NSUInteger numSubviews = [self.subviews count];
    [weatherView setFrame:CGRectMake(SCR_WIDTH * (numSubviews - 1), 0, SCR_WIDTH, SCR_HEIGHT)];
    [self setContentSize:CGSizeMake(SCR_WIDTH * numSubviews, SCR_HEIGHT)];
    
    if (!launch) {
        [self setContentOffset:CGPointMake(weatherView.bounds.size.width * (self.subviews.count - 1), 0) animated:YES];
    }
}

- (void)insertSubview:(UIView *)weatherview atIndex:(NSInteger)index
{
    [super insertSubview:weatherview atIndex:index];
    
    [weatherview setFrame:CGRectMake(SCR_WIDTH * index, 0, SCR_WIDTH, SCR_HEIGHT)];
    NSUInteger numSubviews =[self.subviews count];
    for (NSInteger i = index + 1; i < numSubviews; i++) {
        UIView *subview = [self.subviews objectAtIndex:i];
        [subview setFrame:CGRectMake(SCR_WIDTH * i, 0, SCR_WIDTH, SCR_HEIGHT)];
    }
    [self setContentSize:CGSizeMake(SCR_WIDTH * numSubviews, SCR_HEIGHT)];
}

- (void)removeSubview:(UIView *)weatherview
{
    NSUInteger index = [self.subviews indexOfObject:weatherview];
    if (index != NSNotFound) {
        NSUInteger numSubview = [self.subviews count];
        for (NSInteger i = index + 1; i < numSubview; i++) {
            UIView *view = [self.subviews objectAtIndex:i];
            [view setFrame:CGRectOffset(view.frame, -1 * SCR_WIDTH, 0)];
        }
        [weatherview removeFromSuperview];
        [self setContentSize:CGSizeMake(SCR_WIDTH * (numSubview - 1), SCR_HEIGHT)];
    }
}

@end
