//
//  PagingScrollView.h
//  Snow
//
//  Created by WO on 15/7/9.
//  Copyright (c) 2015年 sg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PagingScrollView : UIScrollView


- (void)addSubview:(UIView *)weatherView isLaunch:(BOOL)launch;

- (void)insertSubview:(UIView *)weatherview atIndex:(NSInteger)index;

- (void)removeSubview:(UIView *)weatherview;

@end
